#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate a zoned-borefield kappa matrix in the exact Modelica layout.

Inputs:
- model_mo_path: path to a top-level .mo file that instantiates a
  Buildings.Fluid.Geothermal.ZonedBorefields borefield component (e.g. OneUTube),
  e.g. MBL_Example_ParallelZonesWithHorizontalPipes.mo
- optional output_name: short name used for the output file (default: the model
  file's stem), e.g. MBL_Example
- optional workers: number of parallel processes (default: CPU count - 1)

The borefield's configuration/soil data is resolved directly from whichever
record classes the model file references for its `borFieDat` parameter
(standard Buildings library records or case-specific ones alike) by following
Modelica `extends` chains back to each record kind's `Template.mo` - no
special per-case file naming convention or coordinates CSV is required.

Output:
- <model_mo_path's directory>/Data/Kappa_<output_name>.txt
  with matrix name "kappaFlat"

Notes:
- Uses pygfunction's own equivalent-borehole machinery directly: _EquivalentBorehole.
  unique_distance() for the unique-distance/weight sets, and
  finite_line_source_equivalent_boreholes_vectorized() (exact, via scipy.integrate.quad_vec - no
  closed-form approximation) for the FLS response, batching every (u,v) segment pair of a
  zone-pair into a single call - see the comment on _compute_pair() for why batching (not just
  looping per pair) is required for this to be numerically practical.
- Keeps exact Modelica layout and cumulative->incremental conversion.
- Mirror index is u+v (correct), not u+v-1.
"""

from __future__ import annotations

import os
import re
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path
from typing import Any

import numpy as np
from scipy.integrate import quad_vec
from scipy.special import exp1, j0, j1, y0, y1
from pygfunction.boreholes import _EquivalentBorehole
from pygfunction.heat_transfer import finite_line_source_equivalent_boreholes_vectorized

CASE_TIMFIN_SECONDS = 50.0 * 365.0 * 24.0 * 3600.0
REL_TOL = 0.02
LVL_BAS = 2.0


# Read UTF-8 text file.
def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# Extract first float matched by regex.
def extract_first_float(text: str, pattern: str, label: str) -> float:
    m = re.search(pattern, text, flags=re.S)
    if not m:
        raise ValueError(f"Could not find {label}")
    return float(m.group(1))


# Extract first int matched by regex.
def extract_first_int(text: str, pattern: str, label: str) -> int:
    m = re.search(pattern, text, flags=re.S)
    if not m:
        raise ValueError(f"Could not find {label}")
    return int(m.group(1))


# Extract all numeric tokens as floats.
def extract_number_list(text: str) -> list[float]:
    return [float(t) for t in re.findall(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", text)]


# Parse a flat Modelica array assignment by key.
def parse_flat_array(text: str, key: str) -> list[float]:
    m = re.search(rf"{re.escape(key)}\s*=\s*\{{(.*?)\}}", text, flags=re.S)
    if not m:
        raise ValueError(f"Could not find array {key}")
    return extract_number_list(m.group(1))


# Parse cooBor={{x,y},...} into Nx2 array.
def parse_coo_bor(text: str) -> np.ndarray:
    m = re.search(r"cooBor\s*=\s*\{(.*?)\}\s*,\s*iZon", text, flags=re.S)
    if not m:
        raise ValueError("Could not find cooBor array")
    body = m.group(1)
    pairs = re.findall(
        r"\{\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*,\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*\}",
        body,
    )
    if not pairs:
        raise ValueError("Could not parse coordinate pairs from cooBor")
    return np.array([[float(x), float(y)] for x, y in pairs], dtype=float)


# Parse iZon={...} as integer list.
def parse_i_zon(text: str) -> list[int]:
    m = re.search(r"iZon\s*=\s*\{(.*?)\}\s*,\s*mBor_flow_nominal", text, flags=re.S)
    if not m:
        raise ValueError("Could not find iZon array")
    return [int(v) for v in extract_number_list(m.group(1))]


# Find the record class a fixed-name parameter (conDat/soiDat/filDat/borFieDat) is declared with.
def find_class_ref(text: str, param_name: str) -> str:
    m = re.search(rf"parameter\s+(\.?[\w.]+)\s+{re.escape(param_name)}\b", text)
    if not m:
        raise ValueError(f"Could not find declaration of parameter '{param_name}'")
    return m.group(1)


# Convert a dotted Modelica class reference to its .mo file path, trying each package root in
# turn (a class reference only carries its own package path, e.g. "Buildings.Fluid..." or
# "ConferenceCollab_2026.ZonedBorefield_ParallelFlow_LKCC...", not which repo/root it lives
# under, so every model this script is pointed at needs its top-level package's root available
# here - see default_search_roots()). Falls back to the first root if none match, so the
# resulting FileNotFoundError still points at a sensible path.
def class_ref_to_path(search_roots: list[Path], class_ref: str) -> Path:
    parts = class_ref.lstrip(".").split(".")
    for root in search_roots:
        candidate = root.joinpath(*parts).with_suffix(".mo")
        if candidate.exists():
            return candidate
    return search_roots[0].joinpath(*parts).with_suffix(".mo")


# Read a record's own file plus its sibling Template.mo (if any), so field values that are only
# ever set in one or the other can both be found via a single text search.
def read_record_text_with_template(search_roots: list[Path], class_ref: str) -> str:
    leaf_text = read_text(class_ref_to_path(search_roots, class_ref))
    template_ref = class_ref.rsplit(".", 1)[0] + ".Template"
    template_path = class_ref_to_path(search_roots, template_ref)
    template_text = read_text(template_path) if template_path.exists() else ""
    return leaf_text + "\n" + template_text


# Locate the Buildings library root (the directory containing the "Buildings" package) from this script's own location.
def default_buildings_root() -> Path:
    for parent in Path(__file__).resolve().parents:
        if parent.name == "Buildings" and (parent / "package.mo").exists():
            return parent.parent
    raise RuntimeError("Could not locate the Buildings library root from this script's location")


# Package roots to search when resolving a class reference (conDat/soiDat/borFieDat records can
# live in Buildings itself, or in a deployment repo that references Buildings models, such as
# ConferenceCollab_2026's ZonedBorefield_ParallelFlow_LKCC examples). Add further roots here if
# a model references a record from yet another repo.
def default_search_roots() -> list[Path]:
    roots = [default_buildings_root()]
    modelicadeployment_root = Path(
        "/home/jovyan/impact/local_projects/Impact_collab_sg-kul_modelicadeployment")
    if modelicadeployment_root.exists():
        roots.append(modelicadeployment_root)
    return roots


# If model_text declares `extends SomeClass(...)`, look for a sibling file named
# <SimpleClassName>.mo next to model_path (the standard Modelica one-class-per-file convention)
# and return its text, so a variant model that only overrides a few parameters (e.g.
# `extends Base(nSegBor=5, ...)`) can still inherit fields it doesn't re-specify, like tLoaAgg.
# Returns "" if there's no extends clause or the sibling file can't be found - non-fatal, since
# not every model uses this pattern.
def find_extended_sibling_text(model_path: Path) -> str:
    model_text = read_text(model_path)
    m = re.search(r"extends\s+\.?([\w.]+)", model_text)
    if not m:
        return ""
    simple_name = m.group(1).rsplit(".", 1)[-1]
    sibling_path = model_path.parent / f"{simple_name}.mo"
    if sibling_path.exists() and sibling_path.resolve() != model_path.resolve():
        return read_text(sibling_path)
    return ""


# Find a parameter's value, matching either a full declaration
# ("parameter Integer nSegBor(min=1)=8") or a bare modifier override ("nSegBor=5" as used inside
# an `extends Base(nSegBor=5)` clause) - whichever appears first in `text`.
def extract_param_value(text: str, name: str, label: str) -> str:
    m = re.search(rf"\b{re.escape(name)}\s*(?:\([^()]*\))?\s*=\s*([^;,)\s]+)", text)
    if not m:
        raise ValueError(f"Could not find {label}")
    return m.group(1)


# Parse all required borefield inputs directly from a top-level .mo model file: nSegBor/tLoaAgg/nCel
# are read straight off the model, and the conDat/soiDat record classes it declares (which, by
# ZonedBorefields convention, always carry these fixed names) point at the geometry/soil data.
def parse_model_data(model_path: Path, search_roots: list[Path]) -> dict[str, Any]:
    model_text = read_text(model_path)
    # A variant model that only overrides some parameters (e.g. nSegBor) via `extends Base(...)`
    # still needs to inherit whatever it doesn't override (e.g. tLoaAgg) from Base's own file -
    # search the current file first (so overrides win), falling back to the sibling.
    search_text = model_text + "\n" + find_extended_sibling_text(model_path)

    n_seg_bor = int(extract_param_value(search_text, "nSegBor", "nSegBor"))
    t_loa_agg = float(extract_param_value(search_text, "tLoaAgg", "tLoaAgg"))
    n_cel = int(extract_param_value(search_text, "nCel", "nCel"))

    # Optional: fraction of hBor represented by each segment (top to bottom, sums to 1),
    # matching the Modelica-side `segRatio` parameter (see PartialStorage.mo). If the model
    # doesn't set it, default to uniform segmentation - same as the Modelica-side default.
    try:
        seg_ratio = np.array(parse_flat_array(search_text, "segRatio"), dtype=float)
        if len(seg_ratio) != n_seg_bor:
            raise ValueError(
                f"segRatio has {len(seg_ratio)} entries but nSegBor={n_seg_bor}")
    except ValueError as exc:
        if "Could not find array segRatio" not in str(exc):
            raise
        seg_ratio = np.full(n_seg_bor, 1.0 / n_seg_bor, dtype=float)

    con_class = find_class_ref(search_text, "conDat")
    soi_class = find_class_ref(search_text, "soiDat")

    config_text = read_record_text_with_template(search_roots, con_class)
    soil_text = read_record_text_with_template(search_roots, soi_class)

    n_zon = extract_first_int(config_text, r"nZon\s*=\s*(\d+)", "nZon")
    h_bor = extract_first_float(config_text, r"hBor\s*=\s*([0-9.eE+-]+)", "hBor")
    r_bor = extract_first_float(config_text, r"rBor\s*=\s*([0-9.eE+-]+)", "rBor")
    d_bor = extract_first_float(config_text, r"dBor\s*=\s*([0-9.eE+-]+)", "dBor")

    k_soi = extract_first_float(soil_text, r"kSoi\s*=\s*([0-9.eE+-]+)", "kSoi")
    d_soi = extract_first_float(soil_text, r"dSoi\s*=\s*([0-9.eE+-]+)", "dSoi")
    c_soi = extract_first_float(soil_text, r"cSoi\s*=\s*([0-9.eE+-]+)", "cSoi")
    a_soi = k_soi / (d_soi * c_soi)

    coo_bor = parse_coo_bor(config_text)
    i_zon = np.array(parse_i_zon(config_text), dtype=int)

    if len(i_zon) != len(coo_bor):
        raise ValueError("iZon and cooBor lengths do not match")

    zones: dict[int, list[dict[str, float]]] = {z: [] for z in range(1, n_zon + 1)}
    for zone, (x, y) in zip(i_zon, coo_bor):
        zones[int(zone)].append({"x": float(x), "y": float(y)})

    n_bor_per_zon = np.array([len(zones[z]) for z in range(1, n_zon + 1)], dtype=int)
    if np.any(n_bor_per_zon <= 0):
        raise ValueError("Found an empty zone in cooBor/iZon")

    return {
        "nZon": n_zon,
        "nSegBor": n_seg_bor,
        "segRatio": seg_ratio,
        "tLoaAgg": t_loa_agg,
        "nCel": n_cel,
        "hBor": h_bor,
        "rBor": r_bor,
        "dBor": d_bor,
        "kSoi": k_soi,
        "aSoi": a_soi,
        "zones": zones,
        "nBorPerZon": n_bor_per_zon,
    }


# Compute number of aggregation cells to cover simulation horizon.
def count_aggregation_cells(tim_fin: float, t_loa_agg: float, n_cel: int, lvl_bas: float = 2.0) -> int:
    nu_i = 0.0
    i = 0
    while nu_i < tim_fin:
        i += 1
        nu_i += t_loa_agg * (lvl_bas ** ((i - 1) // n_cel))
    return i


# Build cumulative aggregation time vector and cell ratio vector.
def aggregation_cell_times(i: int, t_loa_agg: float, n_cel: int, tim_fin: float, lvl_bas: float = 2.0) -> tuple[np.ndarray, np.ndarray]:
    nu = np.zeros(i, dtype=float)
    r_cel = np.zeros(i, dtype=float)
    width_j = 0.0
    for j in range(1, i + 1):
        width_j += t_loa_agg * (lvl_bas ** ((j - 1) // n_cel))
        nu[j - 1] = width_j
        r_cel[j - 1] = lvl_bas ** ((j - 1) // n_cel)
    if nu[-1] > tim_fin:
        nu[-1] = tim_fin
        if i > 1:
            r_cel[-1] = (nu[-1] - nu[-2]) / t_loa_agg
    return nu, r_cel


# Evaluate infinite line source response.
def infinite_line_source(time_s: np.ndarray, alpha: float, r: float) -> np.ndarray:
    return exp1(r**2 / (4.0 * alpha * time_s))


# Evaluate cylindrical heat source correction term.
def cylindrical_heat_source(time_s: float, alpha: float, r: float, r_b: float) -> float:
    fo = alpha * time_s / (r_b**2)
    p = r / r_b

    def integrand(u: np.ndarray) -> np.ndarray:
        return (
            1.0 / (u**2 * np.pi**2)
            * (np.exp(-u**2 * fo) - 1.0)
            / (j1(u) ** 2 + y1(u) ** 2)
            * (j0(p * u) * y1(u) - j1(u) * y0(p * u))
        )

    return float(quad_vec(integrand, 0.0, np.inf)[0])


# Build unique distance bins and multiplicities for a zone pair, using pygfunction's own
# equivalent-borehole distance logic (the same _EquivalentBorehole class gt.gfunction.gFunction
# itself uses internally for method='equivalent') instead of a hand-rolled reimplementation.
# r_bor (not some other reference radius) is the correct floor for the same-borehole distance:
# _EquivalentBorehole.distance() floors every distance at its own r_b, so a borehole's distance
# to itself - which naturally occurs here when zone_a is zone_b - comes out as r_bor for free,
# with no special-casing needed.
def build_unique_distance_set(
    zone_a: list[dict[str, float | int]],
    zone_b: list[dict[str, float | int]],
    r_bor: float,
    rel_tol: float,
) -> tuple[np.ndarray, np.ndarray]:
    x_a = np.array([b["x"] for b in zone_a], dtype=float)
    x_b = np.array([b["x"] for b in zone_b], dtype=float)
    equiv_a = _EquivalentBorehole((
        1.0, 0.0, r_bor, x_a,
        np.array([b["y"] for b in zone_a], dtype=float),
        0.0, np.zeros_like(x_a),
    ))
    equiv_b = _EquivalentBorehole((
        1.0, 0.0, r_bor, x_b,
        np.array([b["y"] for b in zone_b], dtype=float),
        0.0, np.zeros_like(x_b),
    ))
    dis, w_dis = equiv_a.unique_distance(equiv_b, disTol=rel_tol)
    return dis, w_dis.astype(float)


# Compute one zone-pair response block for all times. block[u,v,:] is the response at the
# receiving zone's local segment u due to a unit source at the (other) zone's local segment v.
#
# For EQUAL segments, this used to exploit translation invariance (real-source term only depends
# on the offset |u-v|, mirror-source term only on u+v) to get away with ~3*n_seg calls instead of
# n_seg^2. That shortcut is only valid when every segment has the same length - with unequal
# segments (segRatio), each (u,v) pair has its own absolute depths/lengths and must be computed
# directly. Do not reintroduce the offset-based shortcut without segments being provably equal.
#
# Uses pygfunction's own exact equivalent-borehole FLS (finite_line_source_equivalent_boreholes_
# vectorized, via scipy.integrate.quad_vec, no closed-form approximation), batching ALL n_seg^2
# (u,v) pairs of this zone-pair into a single call - matching how pygfunction's own solver
# (solvers/equivalent.py, thermal_response_factors) batches all segment pairs of a borehole-pair
# group together, rather than one call per pair. This batching is not just an optimization: a
# first attempt that called the exact FLS once per (u,v) pair found that scipy's quad_vec hangs or
# is extremely slow whenever source and receiver segments are at different depths, because at a
# specific mid-range time the true FLS value is astronomically small (~1e-44) but nonzero, and
# quad_vec cannot satisfy its convergence tolerance that close to zero in isolation. quad_vec's
# tolerance is an aggregate norm over the whole output vector, not per-element - bundling all
# n_seg^2 pairs (most of them well-behaved, much larger in magnitude) into one call dilutes that
# one pathological value's influence on the convergence check, exactly as it is diluted in
# pygfunction's own batched calls. Confirmed empirically: batching all pairs of one zone-pair
# takes ~0.1s; a single unbatched pair can hang indefinitely.
def _compute_pair(args: tuple[Any, ...]) -> tuple[int, int, np.ndarray]:
    (
        i,
        j,
        n_seg,
        _n_seg_tot,
        time_s,
        alpha,
        h_seg,
        d_seg,
        n_bor_per_zon_i,
        _n_bor_per_zon_j,
        dis,
        w_dis,
    ) = args

    i_tim = len(time_s)

    # Flatten every (u,v) receiver/source combination into one batch, row-major so that
    # reshape(n_seg, n_seg, i_tim) below recovers block[u,v,:] in the same layout as before.
    u_idx, v_idx = np.meshgrid(np.arange(n_seg), np.arange(n_seg), indexing="ij")
    u_idx = u_idx.ravel()
    v_idx = v_idx.ravel()
    H1 = h_seg[v_idx]
    D1 = d_seg[v_idx]
    H2 = h_seg[u_idx]
    D2 = d_seg[u_idx]

    h = finite_line_source_equivalent_boreholes_vectorized(
        time=time_s, alpha=alpha, dis=dis, wDis=w_dis,
        H1=H1, D1=D1, H2=H2, D2=D2, N2=n_bor_per_zon_i,
    )
    block = h.reshape(n_seg, n_seg, i_tim)

    return i, j, block


# Build full kappa tensor, apply corrections, and flatten to kappaFlat.
def build_kappa_matrix(data: dict[str, Any], workers: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    t0 = time.perf_counter()

    n_zon = data["nZon"]
    n_seg = data["nSegBor"]
    n_seg_tot = n_zon * n_seg
    h_bor = data["hBor"]
    r_bor = data["rBor"]
    d_bor = data["dBor"]
    a_soi = data["aSoi"]
    k_soi = data["kSoi"]
    zones = data["zones"]
    n_bor_per_zon = data["nBorPerZon"]
    t_loa_agg = data["tLoaAgg"]
    n_cel = data["nCel"]
    seg_ratio = data["segRatio"]

    # Per-segment length and top-of-segment burial depth (same for every zone, since all zones
    # share the same segRatio - see the assertion in main()). h_seg/d_seg replace the uniform
    # h_bor/n_seg and d_bor+m*(h_bor/n_seg) used when segments were assumed equal.
    h_seg = seg_ratio * h_bor
    d_seg = d_bor + np.concatenate(([0.0], np.cumsum(h_seg)[:-1]))

    i_tim = count_aggregation_cells(CASE_TIMFIN_SECONDS, t_loa_agg, n_cel, LVL_BAS)
    nu, _ = aggregation_cell_times(i_tim, t_loa_agg, n_cel, CASE_TIMFIN_SECONDS, LVL_BAS)

    print(f"[INFO] nZon={n_zon}, nSeg={n_seg}, nSegTot={n_seg_tot}, nTim={i_tim}, workers={workers}", flush=True)

    # Every ORDERED zone pair (i,j), including i==j and both (i,j)/(j,i), is computed directly -
    # no reciprocal-fill shortcut. That shortcut relied on all segments having equal length
    # (H_i==H_j term cancelling in the reciprocity formula); with unequal segments the per-segment
    # lengths differ by index, so reusing one zone-pair's block for its reciprocal would require a
    # per-(u,v) reciprocity correction. Computing both directions costs at most 2x the zone-pair
    # calls, which is trivial next to the n_seg^2 (vs. the old ~3*n_seg) per-pair cost already
    # accepted for unequal segments - not worth the correctness risk of a hand-derived shortcut.
    zone_pairs = [(i, j) for i in range(1, n_zon + 1) for j in range(1, n_zon + 1)]
    zone_pair_distances: dict[tuple[int, int], tuple[np.ndarray, np.ndarray]] = {}

    for (i, j) in zone_pairs:
        dis, w_dis = build_unique_distance_set(zones[i], zones[j], r_bor=r_bor, rel_tol=REL_TOL)
        zone_pair_distances[(i, j)] = (dis, w_dis)
        print(f"[DIST] pair ({i},{j}) uniqueDistances={len(dis)}", flush=True)

    kappa = np.zeros((n_seg_tot, n_seg_tot, i_tim), dtype=float)

    print("[INFO] Computing pair responses in parallel...", flush=True)

    tasks = []
    for (i, j) in zone_pairs:
        dis, w_dis = zone_pair_distances[(i, j)]
        tasks.append(
            (i, j, n_seg, n_seg_tot, nu, a_soi, h_seg, d_seg, int(n_bor_per_zon[i - 1]), int(n_bor_per_zon[j - 1]), dis, w_dis)
        )

    done = 0
    total = len(tasks)

    with ProcessPoolExecutor(max_workers=workers) as ex:
        fut_to_pair = {ex.submit(_compute_pair, t): (t[0], t[1]) for t in tasks}
        for fut in as_completed(fut_to_pair):
            i, j, block = fut.result()
            done += 1

            r0 = (i - 1) * n_seg
            c0 = (j - 1) * n_seg
            kappa[r0:r0 + n_seg, c0:c0 + n_seg, :] = block

            elapsed = time.perf_counter() - t0
            avg = elapsed / done
            eta = avg * (total - done)
            print(f"[PAIR] ({i},{j}) done | {done}/{total} | elapsed={elapsed/60:.1f} min | ETA={eta/60:.1f} min", flush=True)

    print("[INFO] Applying diagonal CHS-ILS correction...", flush=True)
    ils_vec = 0.5 * infinite_line_source(nu, a_soi, 0.0005 * h_bor)
    chs_vec = np.array([2.0 * np.pi * cylindrical_heat_source(t, a_soi, r_bor, r_bor) for t in nu], dtype=float)
    diag_add = chs_vec - ils_vec
    for idx in range(n_seg_tot):
        kappa[idx, idx, :] += diag_add

    print("[INFO] Convert cumulative -> incremental...", flush=True)
    # denom depends on the RECEIVING segment's own length (matching the 1/(N2*H2) receiver
    # normalization in finite_line_source_equivalent_boreholes_vectorized), not a single
    # borefield-wide value - each kappa[row,:,:]
    # is normalized by the length of receiver segment (row mod n_seg), same for every zone since
    # segRatio is shared across zones.
    denom_per_row = 2.0 * np.pi * k_soi * np.tile(h_seg, n_zon)
    for k in range(i_tim - 1, 0, -1):
        kappa[:, :, k] = (kappa[:, :, k] - kappa[:, :, k - 1]) / denom_per_row[:, None]
    kappa[:, :, 0] /= denom_per_row[:, None]

    print("[INFO] Flattening matrix...", flush=True)
    kappa_flat = np.zeros((n_seg_tot * n_seg_tot, i_tim), dtype=float)
    for receiver in range(n_seg_tot):
        for source in range(n_seg_tot):
            row = receiver * n_seg_tot + source
            kappa_flat[row, :] = kappa[receiver, source, :]

    z_seg = d_seg + h_seg / 2.0

    print(f"[DONE] total runtime={(time.perf_counter()-t0)/60:.2f} min", flush=True)
    return kappa_flat, nu, z_seg


# Parse CLI arguments, run matrix generation, and write output file.
def main() -> int:
    if len(sys.argv) not in (2, 3, 4):
        print(
            "Usage: python -u kappaGenerator.py <model_mo_path> [output_name] [workers]\n"
            "Example: python -u kappaGenerator.py MBL_Example_ParallelZonesWithHorizontalPipes.mo MBL_Example 8"
        )
        return 2

    model_path = Path(sys.argv[1]).resolve()
    if not model_path.exists():
        raise FileNotFoundError(f"Model file does not exist: {model_path}")

    output_name = sys.argv[2].strip() if len(sys.argv) >= 3 else model_path.stem
    workers = max(1, int(sys.argv[3])) if len(sys.argv) == 4 else max(1, (os.cpu_count() or 2) - 1)

    data = parse_model_data(model_path, default_search_roots())
    kappa_flat, nu, _ = build_kappa_matrix(data, workers=workers)

    out_dir = model_path.parent / "Data"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / f"Kappa_{output_name}.txt"

    with out_file.open("w", encoding="utf-8") as handle:
        handle.write("#1\n")
        handle.write(f"double kappaFlat({kappa_flat.shape[0]},{kappa_flat.shape[1]})\n")
        np.savetxt(handle, kappa_flat, fmt="%.17e")

    print(f"Wrote: {out_file}", flush=True)
    print(f"nZon={data['nZon']}, nSegBor={data['nSegBor']}, nTim={kappa_flat.shape[1]}", flush=True)
    print(f"tLoaAgg={data['tLoaAgg']}, nCel={data['nCel']}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
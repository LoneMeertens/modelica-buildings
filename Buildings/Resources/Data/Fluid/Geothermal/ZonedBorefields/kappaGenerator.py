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
from pygfunction.heat_transfer import _finite_line_source_equivalent_boreholes_integrand

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
# <SimpleClassName>.mo next to model_path (the standard Modelica one-class-per-file convention),
# then repeats on THAT file's own `extends` clause, and so on, so a multi-level chain of variant
# models (e.g. A extends B extends C, each only overriding a few parameters) can still inherit a
# field declared only on the root class - not just one hop up. Returns the concatenation of every
# ancestor's text found this way (nearer ancestors first, so extract_param_value's "first match
# wins" still prefers the closer override). Stops when a sibling file can't be found or would
# revisit an already-seen file (guards against an extends cycle) - non-fatal, since not every
# model uses this pattern.
def find_extended_sibling_text(model_path: Path) -> str:
    texts = []
    seen = {model_path.resolve()}
    current_text = read_text(model_path)
    current_dir = model_path.parent
    while True:
        m = re.search(r"extends\s+\.?([\w.]+)", current_text)
        if not m:
            break
        simple_name = m.group(1).rsplit(".", 1)[-1]
        # Same-directory lookup first (the standard one-class-per-file layout).
        # Fall back to the parent directory so a model in a subpackage (e.g.
        # Foo/KappaValidation/Bar.mo extending Foo/Base.mo one level up) can
        # still resolve its base class - Modelica's own `within`-to-directory
        # mapping allows this, so the lookup should too. Purely additive: the
        # parent-directory check only runs when the same-directory one misses,
        # so every existing flat-directory model resolves exactly as before.
        sibling_path = current_dir / f"{simple_name}.mo"
        if not sibling_path.exists():
            sibling_path = current_dir.parent / f"{simple_name}.mo"
        if not sibling_path.exists() or sibling_path.resolve() in seen:
            break
        seen.add(sibling_path.resolve())
        current_text = read_text(sibling_path)
        current_dir = sibling_path.parent
        texts.append(current_text)
    return "\n".join(texts)


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
    # segRatio can appear as either a literal array (segRatio={0.05, 0.168, ...}) or a
    # fill(value, count) call (segRatio=fill(1/10, 10), as equal-segment models write it) -
    # check both and use whichever occurs FIRST in search_text, matching this file's
    # "nearest override wins" convention elsewhere (a model's own modifier, searched before
    # its sibling's, should win regardless of which of the two forms either one happens to use).
    literal_m = re.search(r"segRatio\s*=\s*\{(.*?)\}", search_text, flags=re.S)
    fill_m = re.search(
        r"segRatio\s*=\s*fill\s*\(([^,]+),\s*(\d+)\s*\)", search_text)
    if literal_m and (not fill_m or literal_m.start() < fill_m.start()):
        seg_ratio = np.array(extract_number_list(literal_m.group(1)), dtype=float)
    elif fill_m:
        fill_value = eval(fill_m.group(1), {"__builtins__": {}}, {})
        fill_count = int(fill_m.group(2))
        seg_ratio = np.full(fill_count, float(fill_value), dtype=float)
    else:
        seg_ratio = np.full(n_seg_bor, 1.0 / n_seg_bor, dtype=float)
    if len(seg_ratio) != n_seg_bor:
        raise ValueError(
            f"segRatio has {len(seg_ratio)} entries but nSegBor={n_seg_bor}")

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
#
# The floor used for a borehole's distance to itself is `r_lin` (= 0.0005*hBor), NOT r_bor. This
# was previously r_bor (matching what pygfunction's own gFunction(method='equivalent') uses
# internally) - reasonable-looking, but wrong for parity with this project's actual reference:
# temperatureResponseMatrix.mo's own distance-list construction uses `dis_ij := rLin` (not rBor)
# for i==j (same borehole) - see `Modelica.Units.SI.Radius rLin=0.0005*hBor` in that function.
# Confirmed by direct comparison against Modelica's own computed kappa (via pyfmi on the compiled
# internal-kappa FMU): with r_bor as the floor, kappa[1,1,1] (same-zone diagonal, t=1hr) was
# 2.504e-3 against Modelica's actual 4.507e-3 (1.8x off); with r_lin, recomputing by hand matches
# Modelica to 6 significant figures (and likewise for an off-diagonal entry, 1.06624e-5 both
# sides). The choice of self-distance only matters at short elapsed times (where the FLS
# integral's sensitivity to the exact source-receiver distance is high) - which is exactly why
# every entry checked matched perfectly at nu[82]=50yr but diverged specifically at nu[1]=1hr,
# decaying smoothly over the first few (1-hour-width) aggregation cells: the 2026-09-17
# KappaValidation_NoHP_3x4_ExternalKappa investigation.
def build_unique_distance_set(
    zone_a: list[dict[str, float | int]],
    zone_b: list[dict[str, float | int]],
    r_lin: float,
    rel_tol: float,
) -> tuple[np.ndarray, np.ndarray]:
    x_a = np.array([b["x"] for b in zone_a], dtype=float)
    x_b = np.array([b["x"] for b in zone_b], dtype=float)
    equiv_a = _EquivalentBorehole((
        1.0, 0.0, r_lin, x_a,
        np.array([b["y"] for b in zone_a], dtype=float),
        0.0, np.zeros_like(x_a),
    ))
    equiv_b = _EquivalentBorehole((
        1.0, 0.0, r_lin, x_b,
        np.array([b["y"] for b in zone_b], dtype=float),
        0.0, np.zeros_like(x_b),
    ))
    dis, w_dis = equiv_a.unique_distance(equiv_b, disTol=rel_tol)
    return dis, w_dis.astype(float)


# Real-source disMin, matching finiteLineSource_Equivalent.mo lines 35-42 exactly: if the receiver
# segment lies entirely above or entirely below the source segment (no depth overlap), the
# relevant separation is the diagonal distance to the nearest end of the source, not the plain
# horizontal dis_min. D1/H1 = source (burDep1/len1), D2/H2 = receiver (burDep2/len2), all arrays.
def _dis_min_real(dis_min: float, D1: np.ndarray, H1: np.ndarray, D2: np.ndarray, H2: np.ndarray) -> np.ndarray:
    out = np.full_like(D1, dis_min, dtype=float)
    above = (D2 + H2) < D1  # receiver entirely above source
    below = D2 > (D1 + H1)  # receiver entirely below source
    out = np.where(above, np.sqrt(dis_min**2 + (D1 - D2 - H2)**2), out)
    out = np.where(below, np.sqrt(dis_min**2 + (D1 - D2 + H1)**2), out)
    return out


# Mirror-source disMin, matching finiteLineSource_Equivalent.mo line 44: always the diagonal
# distance through the above-ground mirror image (D1+D2), regardless of depth overlap.
def _dis_min_mirror(dis_min: float, D1: np.ndarray, D2: np.ndarray) -> np.ndarray:
    return np.sqrt(dis_min**2 + (D1 + D2)**2)


# Isolated real-only or mirror-only FLS evaluation, with an explicit, generous epsabs (matching
# pygfunction's own precedent for exactly this situation - see finite_line_source_inclined_
# vectorized's epsabs=1e-4/epsrel=1e-6 quad_vec calls in heat_transfer.py) instead of the default
# (effectively epsabs=0) scipy.integrate.quad_vec tolerance used internally by pygfunction's own
# finite_line_source_equivalent_boreholes_vectorized. Needed because isolating either source term
# alone (reaSource=False or imgSource=False) - required to apply Modelica's per-term causality
# threshold, see _compute_pair - can pass through a true near-zero value at some times/depths,
# confirmed empirically: for this project's row-grouped geometry, the combined real+mirror call
# (pygfunction's default, used elsewhere in this file) returns promptly, but the mirror-only call
# alone hangs indefinitely with default tolerances. Without a floor, quad_vec's relative-only
# stopping criterion has nothing to stop at near a genuine zero and keeps subdividing chasing
# floating-point noise. A generous absolute floor doesn't measurably affect the values that matter
# here (near a true near-zero, this term is either dwarfed by the other source term once summed,
# or is only being used as the linearization anchor for a value defined to ramp down toward zero
# anyway) but stops the hang.
def _fls_isolated_source(
    time: np.ndarray | float, alpha: float, dis: np.ndarray, w_dis: np.ndarray,
    H1: np.ndarray, D1: np.ndarray, H2: np.ndarray, D2: np.ndarray, n2: int,
    rea_source: bool, img_source: bool,
) -> np.ndarray:
    f = _finite_line_source_equivalent_boreholes_integrand(
        dis, w_dis, H1, D1, H2, D2, n2, rea_source, img_source)
    if isinstance(time, (np.floating, float)):
        a = 1.0 / np.sqrt(4.0 * alpha * time)
        return 0.5 / (n2 * H2) * quad_vec(f, a, np.inf, epsabs=1e-4, epsrel=1e-6)[0]
    a = 1.0 / np.sqrt(4.0 * alpha * time)
    b = np.concatenate(([np.inf], a[:-1]))
    return np.cumsum(np.stack(
        [0.5 / (n2 * H2) * quad_vec(f, a_i, b_i, epsabs=1e-4, epsrel=1e-6)[0]
         for a_i, b_i in zip(a, b)],
        axis=-1), axis=-1)


# Evaluate the (real- or mirror-only) FLS response at both the standard aggregation times AND
# every pair's own scalar timTre threshold, in ONE array-mode call, by inserting the timTre values
# as extra points into the requested time grid.
#
# This exists because two naive alternatives both hang scipy's quad_vec: (a) a separate scalar
# call per distinct timTre value, even batched over the full pair set, still integrates the WHOLE
# semi-infinite tail [1/sqrt(4*aSoi*timTre), inf) in one shot - a fundamentally harder integral
# than the narrow disjoint sub-intervals the array-mode branch normally integrates, and hangs on
# the same ~1e-44-but-nonzero pathology documented on _compute_pair's main call, just via a
# different code path; (b) doing that per-pair rather than batched hangs even worse (undiluted).
# The fix: reuse the array-mode branch's own decomposition (integrate each requested time as a
# disjoint, generally narrow, slice relative to its neighbor, then cumsum) - proven safe for the
# main nu grid - by simply extending that same grid with the extra timTre points before calling it
# once, so the timTre evaluations get the exact same narrow-disjoint-interval treatment as every
# other requested time, still batched over the full pair set. `time_grid` must already be sorted
# ascending and include every value in `time_s` (checked by the caller via merge_time_grid).
def _eval_at_times_and_own_thresholds(
    time_grid: np.ndarray, time_s_index: np.ndarray, time_tre_index: np.ndarray,
    alpha: float, dis: np.ndarray, w_dis: np.ndarray,
    H1: np.ndarray, D1: np.ndarray, H2: np.ndarray, D2: np.ndarray, n_bor_per_zon_i: int,
    rea_source: bool, img_source: bool,
) -> tuple[np.ndarray, np.ndarray]:
    h_grid = _fls_isolated_source(
        time_grid, alpha, dis, w_dis, H1, D1, H2, D2, n_bor_per_zon_i,
        rea_source, img_source,
    )
    h_raw = h_grid[:, time_s_index]
    h_at_tre = h_grid[np.arange(h_grid.shape[0]), time_tre_index]
    return h_raw, h_at_tre


# Build the merged, sorted, de-duplicated time grid used by _eval_at_times_and_own_thresholds:
# every value in time_s, plus every distinct threshold time requested, together in one ascending
# array - and the index maps needed to look each of those back up in the grid afterward.
def _merge_time_grid(time_s: np.ndarray, extra_times: np.ndarray) -> tuple[np.ndarray, np.ndarray, dict[float, int]]:
    grid = np.unique(np.concatenate([time_s, extra_times]))
    time_s_index = np.searchsorted(grid, time_s)
    lookup = {t: idx for idx, t in enumerate(grid)}
    return grid, time_s_index, lookup


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
#
# Real- and mirror-source terms are evaluated SEPARATELY (not combined in one call, unlike
# before), because each needs its own short-time causality safeguard - see
# finiteLineSource_Equivalent.mo lines 24-89 ("Linearize the solution at times below the time
# treshold"): for elapsed time t below timTre = disMin^2/(25*aSoi) (the time for the diffusion
# front to physically reach the receiver), Modelica does not trust the raw integral - it's
# numerically ill-conditioned for quadratureLobatto there (the integration lower bound 1/sqrt(4*
# aSoi*t) blows up as t->0) - and substitutes a linear ramp from 0, using the value AT timTre
# scaled by t/timTre, instead. Real and mirror source terms have different disMin formulas (see
# _dis_min_real/_dis_min_mirror above) and therefore different timTre per (u,v) pair, so they must
# be thresholded independently, exactly as Modelica's hSegRea/hSegMir separation does. Omitting
# this (as this generator originally did) silently diverges from Modelica's own reference kappa
# for any zone pair whose (per-segment-pair) disMin is large enough that early aggregation cells
# fall below timTre - common for cross-zone pairs, and confirmed to cause a multi-Kelvin,
# multi-year-growing fluid-temperature drift in production (KappaValidation_NoHP_3x4_ExternalKappa,
# 2026-09-17).
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
    dis_min = float(np.min(dis))

    # Flatten every (u,v) receiver/source combination into one batch, row-major so that
    # reshape(n_seg, n_seg, i_tim) below recovers block[u,v,:] in the same layout as before.
    u_idx, v_idx = np.meshgrid(np.arange(n_seg), np.arange(n_seg), indexing="ij")
    u_idx = u_idx.ravel()
    v_idx = v_idx.ravel()
    H1 = h_seg[v_idx]
    D1 = d_seg[v_idx]
    H2 = h_seg[u_idx]
    D2 = d_seg[u_idx]

    time_tre_rea = _dis_min_real(dis_min, D1, H1, D2, H2)**2 / (25.0 * alpha)
    time_tre_mir = _dis_min_mirror(dis_min, D1, D2)**2 / (25.0 * alpha)

    # One shared merged grid (time_s plus every distinct threshold needed by either term) - both
    # calls below reuse it, so the extra disjoint sub-intervals it introduces are paid for once.
    grid, time_s_idx, lookup = _merge_time_grid(
        time_s, np.concatenate([time_tre_rea, time_tre_mir]))

    def thresholded_term(rea_source: bool, img_source: bool, time_tre: np.ndarray) -> np.ndarray:
        time_tre_idx = np.array([lookup[t] for t in time_tre])
        h_raw, h_at_tre = _eval_at_times_and_own_thresholds(
            grid, time_s_idx, time_tre_idx, alpha, dis, w_dis,
            H1, D1, H2, D2, n_bor_per_zon_i, rea_source, img_source,
        )
        below = time_s[None, :] < time_tre[:, None]
        h_linear = (time_s[None, :] / time_tre[:, None]) * h_at_tre[:, None]
        return np.where(below, h_linear, h_raw)

    h_rea = thresholded_term(True, False, time_tre_rea)
    h_mir = thresholded_term(False, True, time_tre_mir)
    h = h_rea + h_mir
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

    r_lin = 0.0005 * h_bor
    for (i, j) in zone_pairs:
        dis, w_dis = build_unique_distance_set(zones[i], zones[j], r_lin=r_lin, rel_tol=REL_TOL)
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
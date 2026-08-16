#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate a zoned-borefield kappa matrix in the exact Modelica layout.

Inputs:
- case_root: root folder of the case package, e.g.
  /home/jovyan/impact/local_projects/Impact_collab_sg-kul_modelicadeployment/ConferenceCollab_2026/ZonedBorefield_ParallelFlow_LKCC
- case_data_name: short case name, e.g. LKCC
- optional workers: number of parallel processes (default: CPU count - 1)

Expected case structure:
- <case_root>/<case_data_name>_KappaTest.mo
- <case_root>/Data/<case_data_name>_Configuration.mo
- <case_root>/Data/<case_data_name>_Soil.mo
- <case_root>/Data/<case_data_name>_Borefield.mo
- <case_root>/Data/<case_data_name>_BoreholeCoordinates.csv

Output:
- <case_root>/Data/Kappa_<case_data_name>.txt
  with matrix name "kappaFlat"

Notes:
- Uses finite_line_source_vectorized(..., approximation=True) from pygfunction
  for speed, with equivalent-borehole weighted aggregation done locally.
- Keeps exact Modelica layout and cumulative->incremental conversion.
- Mirror index is u+v (correct), not u+v-1.
"""

from __future__ import annotations

import csv
import math
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
from pygfunction.heat_transfer import finite_line_source_vectorized

CASE_TIMFIN_SECONDS = 50.0 * 365.0 * 24.0 * 3600.0
REL_TOL = 0.02
LVL_BAS = 2.0
FLS_APPROX_N = 10


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


# Parse all required case inputs from Modelica and CSV files.
def parse_case_data(case_root: Path, case_data_name: str) -> dict[str, Any]:
    data_dir = case_root / "Data"
    model_path = case_root / f"{case_data_name}_KappaTest.mo"
    config_path = data_dir / f"{case_data_name}_Configuration.mo"
    soil_path = data_dir / f"{case_data_name}_Soil.mo"
    borefield_path = data_dir / f"{case_data_name}_Borefield.mo"
    coords_csv = data_dir / f"{case_data_name}_BoreholeCoordinates.csv"

    model_text = read_text(model_path)
    config_text = read_text(config_path)
    soil_text = read_text(soil_path)
    _ = read_text(borefield_path)

    n_seg_bor = extract_first_int(model_text, r"parameter\s+Integer\s+nSegBor\(min=1\)\s*=\s*(\d+)", "nSegBor")
    t_loa_agg = extract_first_float(model_text, r"parameter\s+\.?Modelica\.Units\.SI\.Time\s+tLoaAgg\s*=\s*([0-9.eE+-]+)", "tLoaAgg")
    n_cel = extract_first_int(model_text, r"parameter\s+Integer\s+nCel\(min=1\)\s*=\s*(\d+)", "nCel")

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

    m_bor_flow_nominal = np.array(parse_flat_array(config_text, "mBor_flow_nominal"), dtype=float)
    dp_nominal = np.array(parse_flat_array(config_text, "dp_nominal"), dtype=float)

    if len(i_zon) != len(coo_bor):
        raise ValueError("iZon and cooBor lengths do not match")
    if len(m_bor_flow_nominal) != n_zon:
        raise ValueError("mBor_flow_nominal length does not match nZon")
    if len(dp_nominal) != n_zon:
        raise ValueError("dp_nominal length does not match nZon")

    zones: dict[int, list[dict[str, float | int]]] = {z: [] for z in range(1, n_zon + 1)}
    with coords_csv.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            zone = int(row["Zone"])
            zones[zone].append({"borehole": int(row["Borehole"]), "x": float(row["X_m"]), "y": float(row["Y_m"])})

    n_bor_per_zon = np.array([len(zones[z]) for z in range(1, n_zon + 1)], dtype=int)
    if np.any(n_bor_per_zon <= 0):
        raise ValueError("Found an empty zone in BoreholeCoordinates.csv")

    return {
        "nZon": n_zon,
        "nSegBor": n_seg_bor,
        "tLoaAgg": t_loa_agg,
        "nCel": n_cel,
        "hBor": h_bor,
        "rBor": r_bor,
        "dBor": d_bor,
        "kSoi": k_soi,
        "aSoi": a_soi,
        "zones": zones,
        "nBorPerZon": n_bor_per_zon,
        "caseName": case_data_name,
        "caseRoot": case_root,
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


# Build unique distance bins and multiplicities for a zone pair.
def build_unique_distance_set(
    zone_a: list[dict[str, float | int]],
    zone_b: list[dict[str, float | int]],
    same_zone: bool,
    rel_tol: float,
    r_lin: float,
) -> tuple[np.ndarray, np.ndarray]:
    unique_distances: list[float] = []
    weights: list[int] = []

    for bore_a in zone_a:
        for bore_b in zone_b:
            if same_zone and bore_a["borehole"] == bore_b["borehole"]:
                distance = r_lin
            else:
                distance = math.hypot(float(bore_a["x"]) - float(bore_b["x"]), float(bore_a["y"]) - float(bore_b["y"]))

            found = False
            for idx, ref in enumerate(unique_distances):
                if abs(distance - ref) / ref < rel_tol:
                    weights[idx] += 1
                    found = True
                    break
            if not found:
                unique_distances.append(distance)
                weights.append(1)

    return np.asarray(unique_distances, dtype=float), np.asarray(weights, dtype=float)


# Compute fast equivalent-borehole FLS approximation with robust shape handling.
def equivalent_fls_approx(
    time_s: np.ndarray,
    alpha: float,
    dis: np.ndarray,
    w_dis: np.ndarray,
    H1: float,
    D1: float,
    H2: float,
    D2: float,
    N2: int,
    reaSource: bool,
    imgSource: bool,
) -> np.ndarray:
    n_dis = int(np.size(dis))
    n_tim = int(np.size(time_s))

    h = finite_line_source_vectorized(
        time=time_s,
        alpha=alpha,
        dis=dis,
        H1=H1,
        D1=D1,
        H2=H2,
        D2=D2,
        reaSource=reaSource,
        imgSource=imgSource,
        approximation=True,
        N=FLS_APPROX_N,
    )

    h = np.asarray(h, dtype=float).squeeze()

    if h.ndim == 0:
        h = np.full((n_dis, n_tim), float(h), dtype=float)
    elif h.ndim == 1:
        if h.size == n_dis and n_tim == 1:
            h = h.reshape(n_dis, 1)
        elif h.size == n_tim and n_dis == 1:
            h = h.reshape(1, n_tim)
        elif h.size == n_dis:
            h = np.tile(h.reshape(n_dis, 1), (1, n_tim))
        elif h.size == n_tim:
            h = np.tile(h.reshape(1, n_tim), (n_dis, 1))
        else:
            raise ValueError(f"Unexpected 1D shape from finite_line_source_vectorized: {h.shape}, n_dis={n_dis}, n_tim={n_tim}")
    elif h.ndim == 2:
        if h.shape == (n_tim, n_dis):
            h = h.T
        elif h.shape != (n_dis, n_tim):
            raise ValueError(f"Unexpected 2D shape from finite_line_source_vectorized: {h.shape}, expected {(n_dis, n_tim)} or {(n_tim, n_dis)}")
    else:
        raise ValueError(f"Unexpected ndim from finite_line_source_vectorized: {h.ndim}, shape={h.shape}")

    weighted_sum = w_dis @ h
    return 0.5 / (N2 * H2) * weighted_sum


# Compute one zone-pair response block for all times.
def _compute_pair(args: tuple[Any, ...]) -> tuple[int, int, np.ndarray]:
    (
        i,
        j,
        n_seg,
        _n_seg_tot,
        time_s,
        alpha,
        h_bor,
        d_bor,
        n_bor_per_zon_i,
        _n_bor_per_zon_j,
        dis,
        w_dis,
    ) = args

    i_tim = len(time_s)
    block = np.zeros((n_seg, n_seg, i_tim), dtype=float)

    h_seg_rea = np.zeros((n_seg, i_tim), dtype=float)
    h_seg_mir = np.zeros((2 * n_seg - 1, i_tim), dtype=float)

    for m in range(n_seg):
        h_seg_rea[m, :] = equivalent_fls_approx(
            time_s, alpha, dis, w_dis, h_bor / n_seg, d_bor, h_bor / n_seg, d_bor + m * (h_bor / n_seg),
            n_bor_per_zon_i, True, False
        )

    for m in range(2 * n_seg - 1):
        h_seg_mir[m, :] = equivalent_fls_approx(
            time_s, alpha, dis, w_dis, h_bor / n_seg, d_bor, h_bor / n_seg, d_bor + m * (h_bor / n_seg),
            n_bor_per_zon_i, False, True
        )

    for u in range(n_seg):
        for v in range(n_seg):
            block[u, v, :] = h_seg_rea[abs(u - v), :] + h_seg_mir[u + v, :]

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

    i_tim = count_aggregation_cells(CASE_TIMFIN_SECONDS, t_loa_agg, n_cel, LVL_BAS)
    nu, _ = aggregation_cell_times(i_tim, t_loa_agg, n_cel, CASE_TIMFIN_SECONDS, LVL_BAS)

    print(f"[INFO] nZon={n_zon}, nSeg={n_seg}, nSegTot={n_seg_tot}, nTim={i_tim}, workers={workers}", flush=True)

    zone_pairs = [(i, j) for i in range(1, n_zon + 1) for j in range(i, n_zon + 1)]
    zone_pair_distances: dict[tuple[int, int], tuple[np.ndarray, np.ndarray]] = {}

    for (i, j) in zone_pairs:
        dis, w_dis = build_unique_distance_set(zones[i], zones[j], same_zone=(i == j), rel_tol=REL_TOL, r_lin=0.0005 * h_bor)
        zone_pair_distances[(i, j)] = (dis, w_dis)
        print(f"[DIST] pair ({i},{j}) uniqueDistances={len(dis)}", flush=True)

    kappa = np.zeros((n_seg_tot, n_seg_tot, i_tim), dtype=float)

    print("[INFO] Computing pair responses in parallel...", flush=True)

    tasks = []
    for (i, j) in zone_pairs:
        dis, w_dis = zone_pair_distances[(i, j)]
        tasks.append(
            (i, j, n_seg, n_seg_tot, nu, a_soi, h_bor, d_bor, int(n_bor_per_zon[i - 1]), int(n_bor_per_zon[j - 1]), dis, w_dis)
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

            if i != j:
                scale = int(n_bor_per_zon[i - 1]) / int(n_bor_per_zon[j - 1])
                rr0 = (j - 1) * n_seg
                cc0 = (i - 1) * n_seg
                kappa[rr0:rr0 + n_seg, cc0:cc0 + n_seg, :] = block * scale

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
    denom = 2.0 * np.pi * h_bor / n_seg * k_soi
    for k in range(i_tim - 1, 0, -1):
        kappa[:, :, k] = (kappa[:, :, k] - kappa[:, :, k - 1]) / denom
    kappa[:, :, 0] /= denom

    print("[INFO] Flattening matrix...", flush=True)
    kappa_flat = np.zeros((n_seg_tot * n_seg_tot, i_tim), dtype=float)
    for receiver in range(n_seg_tot):
        for source in range(n_seg_tot):
            row = receiver * n_seg_tot + source
            kappa_flat[row, :] = kappa[receiver, source, :]

    z_seg = np.array([h_bor / n_seg * (m + 0.5) for m in range(n_seg)], dtype=float)

    print(f"[DONE] total runtime={(time.perf_counter()-t0)/60:.2f} min", flush=True)
    return kappa_flat, nu, z_seg


# Parse CLI arguments, run matrix generation, and write output file.
def main() -> int:
    if len(sys.argv) not in (3, 4):
        print(
            "Usage: python -u kappaGenerator.py <case_root> <case_data_name> [workers]\n"
            "Example: python -u kappaGenerator.py /home/jovyan/.../ZonedBorefield_ParallelFlow_LKCC LKCC 8"
        )
        return 2

    case_root = Path(sys.argv[1]).resolve()
    case_data_name = sys.argv[2].strip()

    if not case_root.exists():
        raise FileNotFoundError(f"Case root does not exist: {case_root}")

    if len(sys.argv) == 4:
        workers = max(1, int(sys.argv[3]))
    else:
        workers = max(1, (os.cpu_count() or 2) - 1)

    data = parse_case_data(case_root, case_data_name)
    kappa_flat, nu, _ = build_kappa_matrix(data, workers=workers)

    out_file = data["caseRoot"] / "Data" / f"Kappa_{data['caseName']}.txt"
    out_file.parent.mkdir(parents=True, exist_ok=True)

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
# Borefield visualization export — data dictionary

Generated: 2026-08-19 05:40 UTC
Source model: `ConferenceCollab_2026.ZonedBorefield_ParallelFlow_LKCC.LKCC_3_MixVolManifold_15Pipes`
Result label: `Result 7` (workspace `collab-sg-kul-deploy`)
Result file: `/home/jovyan/impact/generated_resources/workspaces/collab-sg-kul-deploy/experiments/_d_parallelflow_lkcc_lkcc_3_mixvolmanifold_15pipes_20260818_214416_5db77c1/cases/case_1/result.mat`

Exported for local ground-temperature visualization
([LoneMeertens/modelica-buildings#9](https://github.com/LoneMeertens/modelica-buildings/issues/9)),
structured to be compatible with `geothermsim`/`pygfunction`.

## Borefield summary

- 15 zone(s), 60 borehole(s) total, 4 segment(s) per borehole
- Borehole active length H = 152.4 m, buried depth D = 1.0 m, radius r_b = 0.0762 m
- Heat-rate energy aggregation step: 3600 s
  (model default tLoaAgg)

## Coordinate & sign conventions

- x, y: horizontal Cartesian coordinates, meters, from the model's `cooBor` (borefield-local origin).
- z: depth below grade, positive downward, meters. z=0 is the ground surface.
  A segment's borehole wall sits at [z_start_m, z_end_m], with z_start_m = D + (segment_index-1)*H/n_segments.
- Heat rate / energy: positive = heat rejected from the borehole into the ground
  (the sign of `<borFie>.groTemRes.QBor_flow`, which feeds the ground thermal response).

## Files

All four tables are committed as **Parquet** — read with
`pandas.read_parquet('<table>.parquet')` (requires `pyarrow`). Each table is a
separate file so every file keeps a single schema and readers can load only
what they need. CSV variants are Optional - Not Advised: segment_heat_rates.csv
is ~294 MB at hourly aggregation, over GitHub's 100 MB per-file push limit, and
all export CSVs are git-ignored in this repo. Run
`Parquet_to_dataframe_or_csv.ipynb` (next to the export notebook) to produce
local CSV copies of all four tables. Rows in segment_heat_rates are sorted by
(zone_id, segment_id, time_s, borehole_id) for compression efficiency.

### boreholes.parquet — one row per borehole

| column | meaning |
|---|---|
| borehole_id | unique borehole id, e.g. BH001 |
| zone_id | independent hydraulic/thermal zone this borehole belongs to |
| x_m, y_m | horizontal position |
| H_m | active borehole length |
| D_m | buried depth (offset from grade to the top of the active length) |
| r_b_m | borehole radius |
| tilt_deg, orientation_deg | 0 for all current models (vertical boreholes) |
| n_segments | number of vertical segments this borehole is discretized into |

### borehole_segments.parquet — one row per borehole x segment

| column | meaning |
|---|---|
| borehole_id | joins to boreholes |
| segment_id | 1-based index along the borehole, from the top (near D) down |
| z_start_m, z_end_m | depth range of this segment; (x, y, r_b) are constant along the borehole and live in boreholes |

### ground_properties.parquet — one row, whole-domain soil properties

| column | meaning |
|---|---|
| T_undisturbed_K | undisturbed ground temperature above z_start_gradient |
| gradient_K_m | vertical temperature gradient below z_start_gradient (K/m) |
| z_start_gradient | depth (m) below which the gradient applies; above it, T = T_undisturbed_K |
| k_soil_W_mK | soil thermal conductivity |
| rho_soil_kg_m3 | soil density |
| c_soil_J_kgK | soil specific heat capacity |

### segment_heat_rates.parquet — one row per aggregation step x borehole x segment

| column | meaning |
|---|---|
| time_s, time_end_s | start/end of the aggregation bin |
| borehole_id, segment_id | join to borehole_segments |
| zone_id | hydraulic/thermal zone |
| q_segment_J | **energy** exchanged at this segment's borehole wall during [time_s, time_end_s), trapezoidally integrated from the simulated heat-rate trajectory (not power x dt) |
| q_segment_W_avg | q_segment_J / (time_end_s - time_s), for convenience |
| T_fluid_in_zone_K, T_fluid_out_zone_K | zone-level (not per-segment) fluid inlet/outlet temperature, sampled at bin midpoint |
| m_flow_zone_kg_s | zone-level (not per-segment) mass flow rate, sampled at bin midpoint |

## Modeling assumptions

- `borFie` (`Buildings.Fluid.Geothermal.ZonedBorefields.OneUTube`/`TwoUTubes`) simulates
  **one representative borehole per zone**. All boreholes within a zone are assumed
  hydraulically and thermally identical, so the representative zone's segment heat
  rate is replicated to every physical borehole in that zone in segment_heat_rates.
- Segment z-boundaries are read from a per-segment array in the result if the model
  exposes one; otherwise computed as D + (segment_index-1)*H/n_segments, matching the
  segment position actually used by the model's ground thermal-response calculation
  (`Buildings...BaseClasses.HeatTransfer.temperatureResponseMatrix`).

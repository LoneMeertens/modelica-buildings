# `Temperature_visualization.ipynb` — how it works

This notebook reconstructs the transient ground temperature field around a
**zoned borefield** from the heat-rate history exported by a Modelica
simulation, using the analytical **finite line source (FLS)** method. It does
not read any temperature from the simulation — it *recomputes* the ground
temperature everywhere from the borehole geometry, ground properties, and the
heat injected/extracted by each borehole segment over time.

## 1. Input data (`./export/*.parquet`)

The simulation exports four tables. All lengths are in metres, all
temperatures in Kelvin, all times in seconds, all heat rates in Watts.

| File | Grain | Key columns |
|---|---|---|
| `boreholes.parquet` | one row per borehole | `borehole_id`, `zone_id`, `x_m`, `y_m`, `H_m` (length), `D_m` (buried depth), `r_b_m` (radius) |
| `borehole_segments.parquet` | one row per axial segment of a borehole | `borehole_id`, `segment_id`, `z_start_m`, `z_end_m` |
| `ground_properties.parquet` | one row (global) | `k_soil_W_mK`, `rho_soil_kg_m3`, `c_soil_J_kgK`, `T_undisturbed_K`, `gradient_K_m`, `z_start_gradient` |
| `segment_heat_rates.parquet` | one row per (time step, segment) | `time_end_s`, `zone_id`, `segment_id`, `q_segment_W_avg` |

**Zones**: boreholes are grouped into zones. All boreholes in a zone share the
same length `H`, buried depth `D`, radius `r_b`, and axial segment
discretization (`z_start`/`z_end`) — this lets the notebook do one FLS
evaluation per zone instead of per borehole, which is a big cost saving when
a zone has many boreholes.

## 2. Physics: superposition of segment step-responses

For a single line-shaped heat source, the temperature rise at a point at
distance `r`, caused by a *constant* unit heat rate turned on at `t=0`, is
given by the finite line source solution — an integral of the heat-conduction
Green's function along the source's depth, including an image source above
the ground surface (`z=0`) to enforce either a fixed-temperature or adiabatic
boundary condition there.

The notebook works with the **thermal response factor** `h(t)` (an integral
that only depends on geometry, `α_s`, and time — not on the heat rate itself,
see `zoned_finite_line_source_to_points_reduced_vector`), then derives a
**step-response kernel**

```
kappa(t) = [h(t) - h(t - Δt)] / (2 π k_s H_segment)
```

i.e. the temperature response to *one* segment injecting a constant 1 W/m
average heat rate during exactly one simulation time step. Because heat
conduction is linear, the temperature at any point and time is then a
**superposition** (convolution) of every segment's actual, time-varying heat
rate with this kernel:

```
T(point, t_n) = T_undisturbed(point) + Σ_segments Σ_{i≤n} kappa(t_n − t_i) · q_segment(t_i)
```

This is exactly what the `einsum('tps,ts->p', kappa[:index+1], q[index::-1])`
line computes for a single time index `index` (summed separately per zone,
since each zone has its own `kappa`).

### Why distances are "reduced" / clustered

Evaluating the FLS integral exactly for every (point, segment) pair is
expensive. `_cluster_distances` groups (point, segment) pairs whose
horizontal distance is within `relative_tolerance` (default 1%) of each
other and evaluates the integral only once per group ("representative"
distance), then broadcasts the result back out with `point_weights`. This is
a very effective approximation because the FLS response only depends
weakly on small distance differences at the ranges relevant here.

### Why a vertical cut is slower than a horizontal layer

The distance-clustering above only groups points by horizontal distance, and
it does so **separately for each unique depth** in the point set
(`for depth in np.unique(p_points[:, 2])`). A horizontal slice has every
evaluation point at the same `z`, so that loop runs once, over the whole
grid. A vertical slice spans many distinct depths (one per grid row), so the
loop — and the expensive `quad_vec` integral it feeds — effectively runs once
per depth, over a correspondingly larger combined (distance, depth) set. Cost
scales roughly with *(number of distinct depths) × (representative distances
per depth)*, not with the number of grid points directly, so a vertical grid
with many depth levels can be much slower even at a similar total point count.

### Why time is log-compressed (`time_reduced`)

The FLS integral is evaluated only at a geometrically-spaced subset of times
(`time_reduced`, growing step size the further back in time), then linearly
interpolated (`interpn`) onto the actual simulation time stamps. This keeps
the number of (expensive) integral evaluations low, exploiting the fact that
the response function is smooth and slowly-varying at long times.

## 3. Notebook structure

1. **Import data** — reads the four parquet tables and reshapes them into
   per-zone arrays (`x, y, H, D, r_b`, segment depths, heat rates).
2. **Visualize borefield** — top view (`x,y` scatter) and side view (`y,z`
   borehole extents) sanity-check plots of the raw geometry.
3. **Evaluation of the temperature field on a horizontal layer** (steps below).
4. **Evaluation of the temperature field on a vertical plane** — the same
   steps, applied to a different point set (details below).

### 3a. Horizontal layer, step by step

1. **Grid setup** (`x_T, y_T, z_T, p_T`): a horizontal `x,y` grid at one fixed
   depth `z_T` (defaults to mid-depth of zone 0's boreholes), extended 15 m
   past the borehole extents in `x` and `y` so you can see the field decay
   into undisturbed ground. `p_T` flattens this into a `(n_points, 3)` array
   of `(x, y, z)` coordinates — the FLS machinery below works on any such
   point set, it doesn't know or care that these particular points form a
   grid.
2. **`T_g_T`**: the *undisturbed* ground temperature at `z_T` (before any
   borehole heat injection/extraction), from the geothermal gradient.
3. **Finite line source solution** (`kappa_zoned`): for every zone, evaluates
   the thermal step-response kernel described in section 2, for every point
   in `p_T`, at every simulation time step. This is the expensive step — but
   because the grid is horizontal, every point shares the same depth, so the
   depth-clustering discussed above never has to run more than once (see
   "Why a vertical cut is slower").
4. **Temperature at `index`** (`T`): superposes every zone's actual,
   time-varying heat rate through `kappa_zoned`, using the formula in
   section 2, giving the temperature at every grid point at one chosen time
   step. Plotted as a filled contour.
5. **Animation**: repeats step 4 for a set of `frame_indices` (evenly spaced
   time steps, capped at `max_frames` — see the note on long simulations
   below) and plays them back with `matplotlib.animation.FuncAnimation`.
   Cheap on top of step 3, because `kappa_zoned` already covers the whole
   timeline — animating doesn't re-run the FLS integral at all.

### 3b. Vertical plane, step by step

Mirrors 3a exactly, on a different point set:

1. **Grid setup** (`y_Tv, z_Tv, x_mid, p_Tv`): a vertical `y,z` grid at one
   fixed `x_mid` (the midpoint of the borehole `x`-coordinates, computed from
   the data). `z` runs from the ground surface (`z=0`) down to 15 m past the
   borehole bottom — it does *not* get a symmetric margin like `y` does,
   since going above `z=0` would mean evaluating temperature in open air, not
   ground.
2. **`T_g_Tv`**: same idea as `T_g_T`, evaluated at every depth in the grid
   (not just one depth, since `z` now varies across the grid).
3. **Finite line source solution** (`kappa_zoned_v`): the *same* function as
   3a's step 3, called on `p_Tv` instead of `p_T`. This is the slow step
   discussed above — many distinct depths means the depth-clustering
   shortfall bites here, so the vertical grid is kept coarser (`num_z_v`)
   than the horizontal one to keep this a run-once-per-session cost (a few
   minutes) rather than tens of minutes.
4. **Temperature at `index`** (`T_v`) and **animation**: identical in
   structure to 3a's steps 4-5, just using `kappa_zoned_v`/`T_g_Tv`/`p_Tv`
   instead. The animation is cheap for the same reason as the horizontal
   one — the expensive part already happened in step 3.

## 4. Key parameters you can tune

| Parameter | Location | Effect |
|---|---|---|
| `z_T` / `x_mid` | grid setup cells | which horizontal / vertical slice is evaluated |
| `num_x`, `num_y` (horizontal), `num_y_v`, `num_z_v` (vertical) | grid setup cells | grid resolution (quality vs. speed — `num_z_v` in particular is expensive, see above) |
| `index` | "Temperature field at prescribed time index" | which simulation time step the static plots show |
| `max_frames` | animation cells | cap on the number of animated time steps (evenly spaced), so long simulations don't produce an unplayable number of frames |
| `relative_tolerance` | FLS evaluation cells | distance-clustering tolerance (accuracy vs. speed trade-off) |
| `_cells_per_level` in the `time_reduced` loop | just above the FLS calls | how aggressively time is log-compressed (accuracy vs. speed) |

## 5. Scaling to much longer simulations (e.g. years instead of days)

The FLS integral cost (section 3, step 3) barely changes with total
simulation duration: `time_reduced` grows only with `log(duration / first
time step)`, so 20 years vs. 90 days is only ~2-3x more expensive there, not
~80x. What *does* scale linearly with the raw number of time steps is
`kappa_zoned`'s memory footprint (`shape = (n_time_steps, n_points,
n_segments)`) and the per-frame animation loop cost. With a much longer,
finely-resolved simulation (e.g. thousands of daily/hourly steps), this can
become a real memory concern well before the FLS integral does — worth
re-checking `kappa_zoned`'s size against available memory if/when a much
longer dataset is used.

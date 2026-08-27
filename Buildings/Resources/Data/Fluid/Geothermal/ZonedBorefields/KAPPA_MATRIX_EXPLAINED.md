# How the kappa matrix is built — a detailed walkthrough

This document explains, in detail and from scratch, how the kappa matrix for a zoned borefield
is computed — both by `kappaGenerator.py` (Python, using `pygfunction`) and by Modelica's own
built-in computation (`temperatureResponseMatrix.mo`). It's written so someone with no prior
context can read it start to finish and understand how the two implementations work and how
they correspond to each other.

## 1. What is the kappa matrix?

`Buildings.Fluid.Geothermal.ZonedBorefields.OneUTube` is a Modelica model of a field of
geothermal boreholes, split into "zones" (groups of boreholes connected in parallel). Each
borehole is divided into vertical segments. To simulate how heat moves from the boreholes into
the surrounding soil and back, the model needs to know, for every pair of segments: "if I inject
1 W of heat at segment A, how much does the temperature at segment B rise, after time `t`?"
That's the **thermal response factor**. The full grid of these values — for every segment pair,
at every simulated aggregation time step — is the **kappa matrix**, `kappa[receiver, source,
time]`.

Computing this matrix by evaluating the underlying math *inside Modelica itself* (symbolically,
at translation/compile time) uses a large amount of memory for bigger borefields. The
alternative implemented on this branch: **pre-compute** the kappa matrix in Python (using the
`pygfunction` library — `kappaGenerator.py`), save it to a flat text file, and have Modelica
load that file at simulation start via a small C helper (`kappaExternal.c`) instead of computing
it symbolically. This document explains how that Python computation works, and how it lines up
with what Modelica's own (still-present, optional) symbolic computation does.

## 2. The physical building block: the Finite Line Source (FLS) solution

A borehole is modeled as a vertical line buried in the ground. When you inject heat at one line
(the "source"), the temperature rises at another line (the "receiver") some distance away —
this is the **Finite Line Source (FLS)** solution. It has two parts:

- **Real source**: the direct effect of the source line on the receiver line.
- **Mirror source**: the ground surface is at a fixed temperature, which behaves mathematically
  like a mirror — the source's effect also has to include a "mirror image" source reflected
  above ground. Both real and mirror contributions are added together.

Both parts are built from the *error function integral*, `erfint`:

```
erfint(X) = X·erf(X) - (1/√π)·(1 - e^(-X²))
```

The full FLS integrand combines several `erfint` evaluations at different depth combinations.
This is Modelica's version (`finiteLineSource_Integrand_Equivalent.mo`):

```modelica
// Real source part:
f := erfint((D2 - D1 + H2)*u)
   - erfint((D2 - D1)*u)
   + erfint((D2 - D1 - H1)*u)
   - erfint((D2 - D1 + H2 - H1)*u);

// Mirror source part (added to f):
f := f + erfint((D2 + D1 + H2)*u)
        - erfint((D2 + D1)*u)
        + erfint((D2 + D1 + H1)*u)
        - erfint((D2 + D1 + H2 + H1)*u);

y := 0.5/(nBor2*len2*u^2) * f * (wDis · exp(-dis²·u²));
```

where `D1`/`H1` are the source's buried depth/length, `D2`/`H2` are the receiver's, `u` is an
integration variable, and `dis`/`wDis` are (as explained in §3) a list of distances and their
weights. `y` is then integrated over `u`, from a lower bound (set by time and soil diffusivity)
to infinity, to get the final response value `h`.

**pygfunction implements the mathematically identical formula**, in
`_finite_line_source_equivalent_boreholes_integrand` (`pygfunction/heat_transfer.py`):

```python
p = np.array([1, -1, 1, -1, 1, -1, 1, -1])
q = np.stack([D2 - D1 + H2, D2 - D1, D2 - D1 - H1, D2 - D1 + H2 - H1,
              D2 + D1 + H2, D2 + D1, D2 + D1 + H1, D2 + D1 + H2 + H1], axis=-1)
f = lambda s: s**-2 * (np.exp(-dis**2 * s**2) @ wDis).T * np.inner(p, erfint(q * s))
```

Same real+mirror structure (the first four `p`/`q` entries are the real source, matching
Modelica's first four `erfint` terms; the last four are the mirror source), same `1/u²`
(`s**-2`) weighting, same `wDis`-weighted distance summation inside the integral.

## 3. "Equivalent boreholes": grouping many boreholes into one calculation

A zone isn't one borehole, it's a *group* of boreholes (e.g. 10 boreholes in one zone). Instead
of computing the FLS response between every single pair of boreholes in group A and group B
(10×10=100 separate calculations for a 10-borehole zone), both pygfunction and Modelica use the
**equivalent borehole** method: collect all the source-to-receiver *distances* between the two
groups, and weight-average the FLS response across those distances.

### 3a. Building the distance list

Python (`kappaGenerator.py`, `build_unique_distance_set`):

```python
def build_unique_distance_set(zone_a, zone_b, same_zone, rel_tol, r_lin):
    unique_distances = []
    weights = []
    for bore_a in zone_a:
        for bore_b in zone_b:
            if same_zone and bore_a["borehole"] == bore_b["borehole"]:
                distance = r_lin   # a borehole's effect on itself
            else:
                distance = math.hypot(bore_a["x"] - bore_b["x"], bore_a["y"] - bore_b["y"])
            # merge into an existing bucket if within rel_tol of one already seen,
            # otherwise start a new bucket with weight 1
            ...
    return unique_distances, weights
```

For every pair of boreholes (one from zone A, one from zone B), we compute the physical distance
between them — *except* when it's the same borehole responding to itself, where a very small
stand-in "radius" `r_lin = 0.0005 * hBor` is used instead (representing the borehole's own
surface). Distances that are numerically close (within 2%, `relTol`) get merged into one bucket,
with a weight equal to how many borehole-pairs share that distance.

For our 3-zone/10-boreholes-per-zone example, the zone-1-to-zone-1 distance list is:

```
distances = [0.05, 6.0, 12.0, 18.0, 24.0, 30.0, 36.0, 42.0, 48.0, 54.0]   (meters)
weights   = [10,   18,  16,   14,   12,   10,   8,    6,    4,    2   ]   (sum = 100)
```

The `0.05 m` entry (weight 10) is the "self" term. The rest are the real physical distances
between the 10 different boreholes in the zone.

Modelica's `temperatureResponseMatrix.mo` builds the equivalent list the same way, via its own
nested loop over all borehole pairs (`for i in 1:nBor, for j in i:nBor`), using the same
`relTol=0.02` binning logic:

```modelica
for i in 1:nBor loop
  for j in i:nBor loop
    if i <> j then
      dis_ij := sqrt((cooBor[i,1]-cooBor[j,1])^2 + (cooBor[i,2]-cooBor[j,2])^2);
    else
      dis_ij := rLin;
    end if;
    // search existing bins for a match within relTol, otherwise start a new one
    // (increments both wDis[zoneI,zoneJ,n] and, if i<>j, the reciprocal wDis[zoneJ,zoneI,n])
  end for;
end for;
```

### 3b. The equivalent-borehole averaging formula

Given the distance list and weights, the equivalent-borehole response for one segment-pair is a
**weighted average** across all those distances:

```
h_equiv(t) = [ 1 / N2 ] · Σ_k  wDis[k] · h_single(dis[k], t)
```

where `h_single(dis, t)` is the ordinary single-pair FLS response at that one distance (§2), and
`N2` is the number of boreholes in the *receiving* zone — dividing by it turns "sum over all
100 borehole-pairs" into "average response felt by one receiving borehole." `H2` (segment
length) is already baked into `h_single` itself (see below), not applied separately here.

## 4. How `kappaGenerator.py` evaluates `h_single`

`kappaGenerator.py` gets `h_single(dis, t)` from `pygfunction.heat_transfer.
finite_line_source_equivalent_boreholes_vectorized`, which computes the equivalent-borehole FLS
response *exactly*, via `scipy.integrate.quad_vec` numerical integration of the §2 formula — no
closed-form or series shortcut. The `wDis`-weighted distance summation (§3b) happens *inside*
the integrand, so `dis`/`wDis` are passed straight through rather than summed afterward.

Segments can have unequal lengths (`segRatio`), so every `(u, v)` receiver/source segment pair
within a zone pair has its own depths and lengths and must be evaluated directly — there is no
`abs(u-v)`/`u+v`-offset shortcut available (that shortcut only holds for equal segments, since it
relies on the response depending only on the *offset* between segments, not their absolute
depths). Naively, this means one `quad_vec` call per `(u, v)` pair. In practice this is not just
slow but often **does not finish**: `quad_vec`'s convergence check is a single tolerance on the
norm of its entire output vector, and at certain times the true FLS value for a given depth
difference is vanishingly small (as low as ~1e-44) without being exactly zero — evaluated alone,
`quad_vec` cannot satisfy its tolerance that close to zero and keeps subdividing indefinitely.

The fix — and the reason `kappaGenerator.py` evaluates every `(u, v)` pair of a zone pair in a
**single batched call** rather than looping — is that pygfunction's own solver
(`solvers/equivalent.py`) does exactly this internally: batching many segment pairs together
means the aggregate tolerance check is dominated by the far larger, well-behaved majority of the
batch, and the near-zero outlier's imprecision becomes negligible to the aggregate norm.
`_compute_pair` in `kappaGenerator.py` builds flattened `H1/D1/H2/D2` arrays covering all
`n_seg × n_seg` combinations for one zone pair and makes one call:

```python
u_idx, v_idx = np.meshgrid(np.arange(n_seg), np.arange(n_seg), indexing="ij")
u_idx, v_idx = u_idx.ravel(), v_idx.ravel()
h = finite_line_source_equivalent_boreholes_vectorized(
    time=time_s, alpha=alpha, dis=dis, wDis=w_dis,
    H1=h_seg[v_idx], D1=d_seg[v_idx], H2=h_seg[u_idx], D2=d_seg[u_idx], N2=n_bor_per_zon_i,
)
block = h.reshape(n_seg, n_seg, i_tim)   # block[u, v, :] = response at receiver u due to source v
```

`reaSource`/`imgSource` both default to `True`, so one call already returns the real+mirror sum.
Batching an entire zone pair (`n_seg²` combinations) this way takes well under a second even for
`n_seg` in the 5-8 range that this project uses; a single unbatched pair can hang indefinitely.

## 5. Modelica's own equivalent path

Modelica's `finiteLineSource_Equivalent.mo` computes the exact same weighted-average quantity,
also via direct numerical integration (`Modelica.Math.Nonlinear.quadratureLobatto`), with the
`wDis`-weighted distance summation happening *inside* the integrand (§2's `y := ... * (wDis ·
exp(-dis²·u²))` line), same as §4 — mathematically equivalent, just evaluated with a different
quadrature routine (which is the source of the small residual discussed in §8).

This is only the case for the production path (`useExternalKappa=true`, i.e.
`kappaGenerator.py`, described above). The symbolic in-Modelica path
(`temperatureResponseMatrix.mo`, used when `useExternalKappa=false`) has **not** been
generalized for unequal segments and still uses the equal-segment-only offset shortcut, calling
`finiteLineSource_Equivalent` once per segment *offset* rather than once per `(u,v)` pair:

```modelica
for m in 1:nSeg loop
  hSegRea[m] := finiteLineSource_Equivalent(nu[k], aSoi, dis[i,j,1:n_dis[i,j]],
    wDis[i,j,1:n_dis[i,j]], hBor/nSeg, dBor, hBor/nSeg, dBor + (m-1)*hBor/nSeg,
    nBorPerZon[i], n_dis[i,j], includeMirrorSource=false);
end for;
for m in 1:(2*nSeg-1) loop
  hSegMir[m] := finiteLineSource_Equivalent(..., includeRealSource=false);
end for;
for u in 1:nSeg loop
  for v in 1:nSeg loop
    kappa[(i-1)*nSeg+u,(j-1)*nSeg+v,k] := hSegRea[abs(u-v)+1] + hSegMir[u+v-1];
  end for;
end for;
```

Using `useExternalKappa=false` with a non-uniform `segRatio` is rejected with an error (see
`PartialStorage.mo`) precisely because this path would otherwise silently give a wrong result.

## 6. Diagonal (self-response) correction: cylindrical vs. infinite line source

On top of the FLS contribution, a correction is applied only to "diagonal" entries (a segment's
effect on itself) to account for the borehole being a *cylinder*, not an infinitely thin *line*:

```python
# Python (kappaGenerator.py)
ils_vec = 0.5 * infinite_line_source(nu, a_soi, 0.0005*h_bor)
chs_vec = 2*pi * cylindrical_heat_source(t, a_soi, r_bor, r_bor)
diag_add = chs_vec - ils_vec
kappa[idx, idx, :] += diag_add   # applied to every diagonal entry
```

```modelica
// Modelica (temperatureResponseMatrix.mo)
ILS := 0.5 * infiniteLineSource(nu[k], aSoi, rLin);
CHS := 2*pi * cylindricalHeatSource(nu[k], aSoi, rBor, rBor);
kappa[(i-1)*nSeg+u, (i-1)*nSeg+u, k] += (CHS - ILS);
```

Both `infinite_line_source`/`infiniteLineSource` and `cylindrical_heat_source`/
`cylindricalHeatSource` implement the same formulas on both sides (an exponential-integral
formula for the infinite line source, a numerically-integrated Bessel-function formula for the
cylindrical heat source).

## 7. From cumulative response to the file Modelica actually loads

Everything above produces a *cumulative* response (the total effect up to time `t`). The
simulation needs the *incremental* response — how much the response changed *since the last
aggregation step* — because that's what gets multiplied by each time step's heat flow and summed
during simulation. Both sides convert the same way:

```python
denom = 2*pi*hBor/nSeg*kSoi
kappa[:,:,0] /= denom
for k in range(nTim-1, 0, -1):
    kappa[:,:,k] = (kappa[:,:,k] - kappa[:,:,k-1]) / denom
```

Finally, the 3D array `kappa[receiver, source, time]` is flattened into a 2D text file for the C
loader (`kappaExternal.c`) to read, with row `= receiver * nSegTot + source`:

```
#1
double kappaFlat(576,52)
<576 rows of 52 numbers each, in scientific notation>
```

`nSegTot = nZon * nSegBor` (24 for our 3-zone/8-segment test case), so the file has
`nSegTot² = 576` rows and one column per aggregation time step (52 in our case).

## 8. Why the two methods don't match bit-for-bit

Python (`kappaGenerator.py`, using pygfunction) and Modelica (`temperatureResponseMatrix.mo`)
are two *independently written* implementations of the same physics — same formulas (§2), same
distance-clustering logic (§3a), same weighted-average definition (§3b), same diagonal
correction (§6), same cumulative→incremental conversion (§7). They should therefore agree
closely, but not perfectly, because they use different numerical integration machinery:
`scipy.integrate.quad_vec` (Python, adaptive) vs. `Modelica.Math.Nonlinear.quadratureLobatto`
with a fixed `tolerance=1e-6` (Modelica). For our validated test case, the two methods currently
agree to about **0.9% mean / 0.2% median relative difference** on the final kappa values — a
small, expected numerical difference between two independent implementations of the same
integral, not a sign of a physics or formula mismatch.

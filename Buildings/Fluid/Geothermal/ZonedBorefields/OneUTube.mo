within Buildings.Fluid.Geothermal.ZonedBorefields;
model OneUTube "Borefield model containing single U-tube boreholes"
  extends Buildings.Fluid.Geothermal.ZonedBorefields.BaseClasses.PartialStorage(
    redeclare Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.OneUTube borHol[nZon]);

  annotation (
  defaultComponentName="borFie",
  Documentation(info="<html>
<p>
This model simulates a borehole thermal energy storage system with multiple
zones of single U-tube boreholes. Boreholes within the same zone are connected
in parallel. The borefield configuration and thermal parameters are defined in
the <code>borFieDat</code> record.
</p>
<p>
Heat transfer to the soil is modeled using only one borehole heat exchanger per
zone. The fluid mass flow rate into each borehole is divided to reflect the
per-borehole fluid mass flow rate. The borehole model calculates the dynamics
within the borehole itself using an axial discretization and a
resistance-capacitance network for the internal thermal resistances between the
individual pipes and between each pipe and the borehole wall.
</p>
<p>
The ground thermal response at each borehole segment is evaluated using
analytical thermal response factors. Spatial and temporal superposition are used
to evaluate the total temperature change at each of the borehole segments.
</p>
<h4>Computing the kappa matrix: <code>useExternalKappa</code></h4>
<p>
The kappa (borehole-to-borehole thermal response) matrix has size
<i>n<sub>SegTot</sub></i>&times;<i>n<sub>SegTot</sub></i>, where
<i>n<sub>SegTot</sub> = n<sub>Zon</sub>&times;n<sub>Seg</sub></i>. With
<code>useExternalKappa=false</code>, this matrix is built symbolically inside
Modelica at translation time; for anything but a small number of zones/segments
this computation grows large enough to run out of memory during compilation
(the original motivation for this parameter, see
<a href=\"https://github.com/LoneMeertens/modelica-buildings/issues/1\">
LoneMeertens/modelica-buildings#1</a>). With more than a handful of zones,
set <code>useExternalKappa=true</code> (the default) so the kappa matrix is
instead pre-computed in Python
(<code>Buildings/Resources/Data/Fluid/Geothermal/ZonedBorefields/kappaGenerator.py</code>,
using <code>pygfunction</code>) and loaded from a file
(<code>kappaFileName</code>/<code>kappaMatrixName</code>) at simulation start,
avoiding the translation-time blow-up entirely.
</p>
<h4>Segmentation (<code>nSeg</code>, <code>segRatio</code>)</h4>
<p>
Unlike <a href=\"modelica://Buildings.Fluid.Geothermal.Borefields\">
Buildings.Fluid.Geothermal.Borefields</a>, this model uses a single vertical
segmentation (<code>nSeg</code>/<code>segRatio</code>) for both the short-term
borehole model and the long-term kappa matrix, so the choice of segmentation is
a compromise between short-term and long-term accuracy rather than something
that can be tuned independently for each. The default is <code>nSeg=10</code>
with equal segments.
</p>
<p>
Setting <code>nSeg=5</code> (without also setting <code>segRatio</code>)
switches to an unequal, end-weighted <code>segRatio</code>
(<code>pygfunction.utilities.segment_ratios(5, end_length_ratio=0.05)</code>)
that keeps long-term g-function error to about 1% relative to a much finer
12-segment equal discretization, while short-term borehole-wall temperature
stays within about 0.1 K of a 10-equal-segment reference on both an 18.3 m
validation case and a more realistic 150 m borefield (see
<a href=\"modelica://Buildings.Fluid.Geothermal.Borefields.Validation.Sandbox_UnequalSegments\">
Buildings.Fluid.Geothermal.Borefields.Validation.Sandbox_UnequalSegments</a>
and
<a href=\"modelica://Buildings.Fluid.Geothermal.Borefields.Validation.ConstantHeatInjection_100Boreholes_UnequalSegments\">
Buildings.Fluid.Geothermal.Borefields.Validation.ConstantHeatInjection_100Boreholes_UnequalSegments</a>).
This is a useful way to reduce computational cost (fewer segments, both in the
short-term borehole model and in the kappa matrix) without giving up accuracy,
and is a natural pairing with <code>useExternalKappa=true</code> since large
borefields needing that setting anyway also benefit most from fewer segments.
Any other <code>nSeg</code> value defaults to equal segments; a fully custom
<code>segRatio</code> can also be set explicitly for any <code>nSeg</code>.
</p>
<p>
Only <code>useExternalKappa=true</code> supports a non-uniform
<code>segRatio</code>&mdash;the in-Modelica symbolic kappa computation used when
<code>useExternalKappa=false</code> has not been generalized for unequal
segments and an incompatible combination is rejected with an error message
rather than silently giving a wrong result. When using
<code>useExternalKappa=true</code> with a non-default <code>segRatio</code>,
the external kappa file must be regenerated to match it, using
<code>kappaGenerator.py</code> as above.
</p>
</html>", revisions="<html>
<ul>
<li>
August 20, 2026, by L. Meertens:<br/>
Added an error check rejecting <code>useExternalKappa=false</code> with a
non-uniform <code>segRatio</code>, and documented the accuracy/cost tradeoff
of switching to <code>nSeg=5</code>.
</li>
<li>
February 2024, by Massimo Cimmino:<br/>
First implementation.
</li>
</ul>
</html>"));
end OneUTube;

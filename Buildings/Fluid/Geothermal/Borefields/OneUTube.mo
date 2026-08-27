within Buildings.Fluid.Geothermal.Borefields;
model OneUTube
  "Borefield model containing single U-tube boreholes"
  extends Buildings.Fluid.Geothermal.Borefields.BaseClasses.PartialBorefield(
    redeclare Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.OneUTube borHol);

  annotation (
  defaultComponentName="borFie",
  Documentation(info="<html>
<p>
This model simulates a borefield containing one or many single U-tube boreholes
using the parameters in the <code>borFieDat</code> record.
</p>
<p>
Heat transfer to the soil is modeled using only one borehole heat exchanger. The
fluid mass flow rate into the borehole is divided to reflect the per-borehole
fluid mass flow rate. The borehole model calculates the dynamics within the
borehole itself using an axial discretization and a resistance-capacitance
network for the internal thermal resistances between the individual pipes and
between each pipe and the borehole wall.
</p>
<h4>Segmentation (<code>nSeg</code> vs. <code>nSegGFun</code>)</h4>
<p>
This model decouples the segmentation used by the short-term borehole model
(<code>nSeg</code>/<code>segRatio</code>, default 10 equal segments, unchanged)
from the segmentation used to evaluate the long-term g-function
(<code>nSegGFun</code>/<code>segRatioGFun</code>). Since the g-function
represents the ground response of the whole borefield rather than individual
borehole-to-borehole thermal response factors, using more (or unequal)
long-term segments has no effect on the short-term model, so the two can be
chosen independently&mdash;unlike
<a href=\"modelica://Buildings.Fluid.Geothermal.ZonedBorefields\">
Buildings.Fluid.Geothermal.ZonedBorefields</a>, where both are the same
parameter. The default <code>nSegGFun=8</code> with an unequal, end-weighted
<code>segRatioGFun</code>
(<code>pygfunction.utilities.segment_ratios(8, end_length_ratio=0.02)</code>)
follows Cimmino and Cook (2022), who show it is more accurate than 12 equal
segments at a lower computational cost. Equal g-function segments can still be
used by setting <code>segRatioGFun=fill(1/nSegGFun, nSegGFun)</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
August 20, 2026, by L. Meertens:<br/>
Changed default g-function segmentation to 8 unequal, end-weighted segments
(was 12 equal segments), following Cimmino and Cook (2022).
</li>
<li>
July 2018, by Alex Laferri&egrave;re:<br/>
Extended partial model and changed documentation to reflect the new approach
used by the borefield models.
</li>
<li>
July 2014, by Damien Picard:<br/>
First implementation.
</li>
</ul>
</html>"));
end OneUTube;

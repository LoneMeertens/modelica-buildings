within Buildings.Fluid.Geothermal.Borefields.Validation;
model Sandbox_Nseg4Equal
  "Short-term comparison variant of Sandbox: 4 equal segments instead of the default 10"
  extends Sandbox(
    borHol(nSeg=4));

  annotation (Documentation(info="<html>
<p>
Same short-term validation case as
<a href=\"modelica://Buildings.Fluid.Geothermal.Borefields.Validation.Sandbox\">
Buildings.Fluid.Geothermal.Borefields.Validation.Sandbox</a> (Beier et al. 2011
experiment), but with the borehole discretized into 4 equal segments instead of the default 10,
to directly compare short-term (RC-network) accuracy between this cheaper discretization and
both the 10-equal-segment baseline and the 5-unequal-segment variant against the same measured
reference data.
</p>
<p>
This model is part of the exploration described in
<code>Buildings/Resources/Data/Fluid/Geothermal/ZonedBorefields/unequal_segmentation_exploration.ipynb</code>
(Part 1c): the long-term g-function analysis there found that <code>nSeg=4</code> equal segments
stay within the same accuracy bar as <code>nSeg=12</code> equal segments through about 2 years,
only degrading materially from about 5 years onward - making <code>nSeg=4</code> equal a
candidate for the cheaper short-to-medium-term LKCC_3 experiment tiers (1 day through 1 year),
reserving the unequal 5-segment distribution for the 20-year sizing case. This model tests
whether that choice also holds up short-term (RC-network) dynamics, not just the long-term
g-function.
</p>
</html>"));
end Sandbox_Nseg4Equal;

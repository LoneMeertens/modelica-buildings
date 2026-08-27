within Buildings.Fluid.Geothermal.ZonedBorefields;
model OneUTube_ZeroInternalHEX
  "Zoned borefield with zero internal borehole heat exchanger for compilation testing"

  extends Buildings.Fluid.Geothermal.ZonedBorefields.BaseClasses.PartialStorage(
    redeclare Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.ZeroHeatTransferOneUTube
      borHol[nZon]);

  annotation (
    defaultComponentName="borFie",
    Documentation(info="<html>
<p>
This is a non-physical compilation test variant of the zoned single U-tube borefield.
It keeps the zoned borefield structure and ground temperature response component,
but replaces the internal borehole heat exchanger by an ideal hydraulic pass-through
with zero heat transfer at the borehole wall.
</p>
</html>"));
end OneUTube_ZeroInternalHEX;

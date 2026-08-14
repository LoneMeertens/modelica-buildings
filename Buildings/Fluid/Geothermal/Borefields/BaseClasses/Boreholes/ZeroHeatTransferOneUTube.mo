within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes;
model ZeroHeatTransferOneUTube
  "Compilation test borehole: ideal hydraulic pass-through and zero wall heat flow"

  extends Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.PartialBorehole;

equation
  connect(port_a, port_b);

  for i in 1:nSeg loop
    port_wall[i].Q_flow = 0;
  end for;

  annotation (
    Documentation(info="<html>
<p>
This is a non-physical compilation test model.
It bypasses the internal U-tube heat exchanger and sets all borehole wall heat flows to zero.
Use only to isolate compilation cost from the internal borehole discretization.
</p>
</html>"));
end ZeroHeatTransferOneUTube;

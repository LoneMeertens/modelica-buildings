within Testing.HorizontalPipes.BaseClasses;
model PassThroughPipe
  "No-op pipe used to validate insertion of horizontal runout pipe structure"

  replaceable package Medium =
      .Modelica.Media.Interfaces.PartialMedium
    "Medium model";

  .Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare package Medium = Medium)
    "Inlet port";

  .Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare package Medium = Medium)
    "Outlet port";

equation
  connect(port_a, port_b);

end PassThroughPipe;

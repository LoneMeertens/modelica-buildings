within Buildings.Fluid.Geothermal.ZonedBorefields;
model OneUTube_PassThrough
  "Compilation test model: zoned borefield replaced by ideal fluid pass-through"

  parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template borFieDat
    "Borefield data record";

  final parameter Integer nZon(min=1) = borFieDat.conDat.nZon
    "Total number of independent bore field zones";

  extends Buildings.Fluid.Geothermal.ZonedBorefields.Interfaces.PartialTwoNPortsInterface(
    final nPorts=nZon,
    final m_flow_nominal=borFieDat.conDat.mZon_flow_nominal);

  parameter Modelica.Units.SI.Time tLoaAgg = 3600.0
    "Dummy parameter for modifier compatibility";

  parameter Integer nCel(min=1) = 5
    "Dummy parameter for modifier compatibility";

  parameter Integer nSeg(min=1) = 10
    "Dummy parameter for modifier compatibility";

  parameter Modelica.Fluid.Types.Dynamics energyDynamics =
    Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
    "Dummy parameter for modifier compatibility";

  parameter Medium.AbsolutePressure p_start = Medium.p_default
    "Dummy parameter for modifier compatibility";

  parameter Modelica.Units.SI.Temperature TExt0_start = 283.15
    "Dummy parameter for output value";

  parameter Real dT_dz(final unit="K/m", min=0) = 0.01
    "Dummy parameter for modifier compatibility";

  parameter Boolean computePressureDrop = true
    "Dummy parameter for modifier compatibility";

  parameter Boolean use_detailedPressureDrop = false
    "Dummy parameter for modifier compatibility";

  parameter Buildings.Fluid.Types.FluidProperties fluidProperties =
    Buildings.Fluid.Types.FluidProperties.DefaultTemperature
    "Dummy parameter for modifier compatibility";

  parameter Boolean use_TDepRConv = false
    "Dummy parameter for modifier compatibility";

  Modelica.Blocks.Interfaces.RealOutput TBorAve[nZon](
    each quantity="ThermodynamicTemperature",
    each unit="K",
    each displayUnit="degC")
    "Dummy average borehole wall temperature";

  Modelica.Blocks.Interfaces.RealOutput QBorAve[nZon](
    each quantity="HeatFlowRate",
    each unit="W")
    "Dummy average borehole heat flow rate";

equation
  for i in 1:nZon loop
    connect(port_a[i], port_b[i]);
    TBorAve[i] = TExt0_start;
    QBorAve[i] = 0;
  end for;

  annotation (
    defaultComponentName="borFie",
    Documentation(info="<html>
<p>
This is a non-physical compilation test model.
It replaces the complete zoned borefield by ideal hydraulic pass-throughs.
It keeps the same vectorized fluid-port interface and common top-level modifiers,
but removes the borehole, ground-response, heat-port, and load-aggregation models.
</p>
</html>"));
end OneUTube_PassThrough;

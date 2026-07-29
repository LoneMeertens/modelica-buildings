within Testing.HorizontalPipes.BaseClasses;
model DynamicGroundRunoutPipe
  "Horizontal runout pipe with plug-flow transport, dynamic ground coupling and optional Darcy pressure drop"

  replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium
    "Medium in the pipe"
    annotation (choicesAllMatching=true);

  parameter Modelica.Units.SI.Length length = 20
    "Horizontal runout pipe length";

  parameter Modelica.Units.SI.Diameter dh = 0.032
    "Hydraulic diameter of the pipe";

  parameter Modelica.Units.SI.Radius rPip = dh/2
    "Pipe radius used by the ground-coupling model";

  parameter Modelica.Units.SI.Length thickness = 0.0032
    "Pipe wall thickness";

  parameter Modelica.Units.SI.Length dIns = 0.0001
    "Insulation thickness used by plug-flow pipe";

  parameter Modelica.Units.SI.ThermalConductivity kIns = 1
    "Insulation thermal conductivity used by plug-flow pipe";

  parameter Modelica.Units.SI.SpecificHeatCapacity cPip = 2300
    "Pipe material specific heat capacity";

  parameter Modelica.Units.SI.Density rhoPip = 930
    "Pipe material density";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal
    "Nominal mass flow rate";

  parameter Modelica.Units.SI.MassFlowRate m_flow_start = m_flow_nominal
    "Initial mass flow rate";

  parameter Modelica.Units.SI.Temperature T_start =
      .Testing.BorefieldComparisonTests.Data.TGround
    "Initial pipe and ground temperature";

  parameter Modelica.Units.SI.Length thiGroLay = 1.1
    "Thickness of dynamic ground layer";

  parameter Integer nSta = 5
    "Number of radial states in ground layer";

  parameter Integer nSeg = 1
    "Number of pipe/ground segments";

  parameter Boolean steadyStateInitial = false
    "Use steady-state initialization for ground layer";

  parameter Boolean computePressureDrop = false
    "Set to true to compute Darcy-Weisbach pressure drop";

  parameter Boolean use_TDepPressureDrop = true
    "Set to true to evaluate density and viscosity from the current fluid state"
    annotation (Dialog(enable=computePressureDrop));

  parameter Modelica.Units.SI.Radius rTub =
      .Testing.BorefieldComparisonTests.Data.rTub
    "Outer tube radius used for Darcy pressure drop";

  parameter Modelica.Units.SI.Length eTub =
      .Testing.BorefieldComparisonTests.Data.eTub
    "Tube wall thickness used for Darcy pressure drop";

  parameter Modelica.Units.SI.Length roughness = 0.001e-3
    "Absolute pipe wall roughness";

  parameter Integer nUBend(min=0) = 0
    "Number of U-bends or equivalent minor-loss elements in horizontal runout";

  parameter Real KUBend(unit="1", min=0) = 2
    "Minor-loss coefficient per U-bend or equivalent minor-loss element";

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare package Medium = Medium)
    "Inlet port"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));

  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare package Medium = Medium)
    "Outlet port"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));

  .Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.PressureDropCircularPipe
    preDro(
      redeclare package Medium = Medium,
      m_flow_nominal = m_flow_nominal,
      computePressureDrop = computePressureDrop,
      length = length,
      rTub = rTub,
      eTub = eTub,
      roughness = roughness,
      rhoMed = rhoMed,
      muMed = muMed,
      nUBend = nUBend,
      KUBend = KUBend,
      use_TDepPressureDrop = use_TDepPressureDrop)
    "Darcy-Weisbach pressure drop using the borefield implementation"
    annotation (Placement(transformation(extent={{-75,-10},{-55,10}})));

  .Testing.HorizontalPipes.BaseClasses.PlugFlowPipe pipe(
    redeclare package Medium = Medium,
    dh = dh,
    length = length,
    dIns = dIns,
    kIns = kIns,
    m_flow_nominal = m_flow_nominal,
    cPip = cPip,
    thickness = thickness,
    initDelay = true,
    m_flow_start = m_flow_start,
    rhoPip = rhoPip,
    T_start_in = T_start,
    T_start_out = T_start,
    disableComputeFlowResistance = true)
    "Plug-flow pipe with thermal inertia; hydraulic resistance handled separately"
    annotation (Placement(transformation(
      extent={{-17.87,-13.28},{25.87,13.28}},
      rotation=0.0,
      origin={0.0,0.0})));

  .Testing.HorizontalPipes.BaseClasses.PipeGroundCoupling groundCoupling(
    lPip = length,
    rPip = rPip,
    thiGroLay = thiGroLay,
    nSta = nSta,
    nSeg = nSeg,
    TpipSta = T_start,
    TGrouBouSta = T_start,
    steadyStateInitial = steadyStateInitial,
    cliCon = cliCon,
    soiDat = soiDat)
    "Dynamic ground coupling around horizontal pipe"
    annotation (Placement(transformation(
      extent={{-7.62,67.13},{15.62,88.87}},
      rotation=0.0,
      origin={0.0,0.0})));

protected
  parameter Medium.ThermodynamicState sta_nominal =
    Medium.setState_pTX(
      p = Medium.p_default,
      T = T_start,
      X = Medium.X_default)
    "Nominal medium state used only to bind fallback pressure-drop properties";

  parameter Modelica.Units.SI.Density rhoMed =
    Medium.density(sta_nominal)
    "Fallback nominal density required by pressure-drop component";

  parameter Modelica.Units.SI.DynamicViscosity muMed =
    Medium.dynamicViscosity(sta_nominal)
    "Fallback nominal dynamic viscosity required by pressure-drop component";

  replaceable parameter
    Buildings.BoundaryConditions.GroundTemperature.ClimaticConstants.Boston
    cliCon
    "Surface temperature climatic conditions";

  replaceable parameter Buildings.HeatTransfer.Data.Soil.Generic soiDat(
    k = .Testing.BorefieldComparisonTests.Data.kSoi,
    c = .Testing.BorefieldComparisonTests.Data.cSoi,
    d = .Testing.BorefieldComparisonTests.Data.dSoi)
    "Soil thermal properties";

equation
  connect(port_a, preDro.port_a)
    annotation (Line(points={{-100,0},{-75,0}}, color={0,127,255}));

  connect(preDro.port_b, pipe.port_a)
    annotation (Line(points={{-55,0},{-17.87,0}}, color={0,127,255}));

  connect(pipe.port_b, port_b)
    annotation (Line(points={{25.87,0},{100,0}}, color={0,127,255}));

  connect(pipe.heatPort, groundCoupling.heatPorts[1])
    annotation (Line(points={{4,13.28},{4,72.56}}, color={191,0,0}));

  annotation (
    Icon(
      coordinateSystem(extent={{-100,-100},{100,100}}),
      graphics={
        Rectangle(
          extent={{-90,30},{90,-30}},
          lineColor={0,0,0},
          fillColor={215,202,187},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-90,15},{90,-15}},
          lineColor={0,127,255},
          fillColor={0,127,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-10,80},{10,60}},
          lineColor={191,0,0},
          fillColor={191,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{0,60},{0,30}},
          color={191,0,0}),
        Text(
          extent={{-100,-50},{100,-80}},
          textString="%name",
          textColor={0,0,0})}),
    Diagram(coordinateSystem(extent={{-120,-100},{120,100}})));

end DynamicGroundRunoutPipe;

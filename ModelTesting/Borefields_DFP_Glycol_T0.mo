within ModelTesting;
model Borefields_DFP_Glycol_T0
  "Validation model of borefields with different media specifications operating simultaneously"
  extends .Modelica.Icons.Example;

  constant Real X_a = 0.25 "Glycol mass fraction (0..1)";
  constant .Modelica.Units.SI.Temperature property_T = 273.15
    "Reference temperature for glycol property evaluation";

  package Medium = .Buildings.Media.Antifreeze.PropyleneGlycolWater(
      property_T=property_T, X_a=X_a);

  parameter .Modelica.Units.SI.Time tLoaAgg=300
    "Time resolution of load aggregation";
  parameter .Modelica.Units.SI.MassFlowRate m_flow_nominal=borFieUTubDat.conDat.mBorFie_flow_nominal/4;
  parameter .Modelica.Units.SI.Temperature TGro=283.15 "Ground temperature";

  parameter .Buildings.Fluid.Geothermal.Borefields.Data.Borefield.Example borFieUTubDat(
    filDat=.Buildings.Fluid.Geothermal.Borefields.Data.Filling.Bentonite(
      steadyState=true),
    conDat=.Buildings.Fluid.Geothermal.Borefields.Data.Configuration.Example(
      borCon=.Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube))
    annotation (Placement(transformation(extent={{-88,72},{-68,92}})));

  .Buildings.Fluid.Geothermal.Borefields.OneUTube borFieUTub1(
    redeclare package Medium = Medium,
    borFieDat=borFieUTubDat,
    tLoaAgg=tLoaAgg,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.FixedInitial,
    TExt0_start=TGro)
    annotation (Placement(transformation(extent={{32.4,44.0},{52.4,64.0}},rotation=0.0,origin={0.0,0.0})));

  .Buildings.Fluid.Geothermal.Borefields.OneUTubeTdep borFieUTub2(
    redeclare package Medium = Medium,
    useGlycol=true,
    X_a=X_a,
    borFieDat=borFieUTubDat,
    tLoaAgg=tLoaAgg,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.FixedInitial,
    TExt0_start=TGro)
    annotation (Placement(transformation(extent={{34,4},{54,24}})));

  // --- sources, sinks, sensors unchanged ---
  .Buildings.Fluid.Sources.MassFlowSource_T sou1(
    redeclare package Medium = Medium,
    nPorts=1, use_T_in=false, m_flow=m_flow_nominal, T=303.15)
    annotation (Placement(transformation(extent={{-49.6,44.0},{-29.6,64.0}},rotation=0.0,origin={0.0,0.0})));
  .Buildings.Fluid.Sensors.TemperatureTwoPort TUTubIn1(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal, tau=0)
    annotation (Placement(transformation(extent={{-17.6,44.0},{2.4,64.0}},rotation=0.0,origin={0.0,0.0})));
  .Buildings.Fluid.Sources.Boundary_pT sin1(
    redeclare package Medium = Medium,
    nPorts=1, p=101330, T=283.15)
    annotation (Placement(transformation(extent={{132.0,44.0},{112.0,64.0}},rotation=0.0,origin={0.0,0.0})));
  .Buildings.Fluid.Sensors.TemperatureTwoPort TUTubOut1(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal, tau=0)
    annotation (Placement(transformation(extent={{82.0,44.0},{102.0,64.0}},rotation=0.0,origin={0.0,0.0})));
  .Buildings.Fluid.Sources.MassFlowSource_T sou2(
    redeclare package Medium = Medium,
    nPorts=1, use_T_in=false, m_flow=m_flow_nominal, T=303.15)
    annotation (Placement(transformation(extent={{-48,4},{-28,24}},rotation=0)));
  .Buildings.Fluid.Sensors.TemperatureTwoPort TUTubIn2(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal, tau=0)
    annotation (Placement(transformation(extent={{-16,4},{4,24}})));
  .Buildings.Fluid.Sources.Boundary_pT sin2(
    redeclare package Medium = Medium,
    nPorts=1, p=101330, T=283.15)
    annotation (Placement(transformation(extent={{134,4},{114,24}},rotation=0)));
  .Buildings.Fluid.Sensors.TemperatureTwoPort TUTubOut2(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal, tau=0)
    annotation (Placement(transformation(extent={{84,4},{104,24}})));
    
equation
  connect(TUTubIn2.port_b,borFieUTub2. port_a)
    annotation (Line(points={{4,14},{34,14}},   color={0,127,255}));
  connect(borFieUTub2.port_b,TUTubOut2. port_a)
    annotation (Line(points={{54,14},{84,14}},   color={0,127,255}));
  connect(TUTubOut2.port_b,sin2. ports[1])
    annotation (Line(points={{104,14},{114,14}},   color={0,127,255}));
  connect(TUTubIn2.port_a,sou2. ports[1])
    annotation (Line(points={{-16,14},{-28,14}},   color={0,127,255}));
    connect(TUTubIn1.port_a,sou1.ports[1]) annotation(Line(points = {{-17.6,54},{-29.6,54}},color = {0,127,255}));
    connect(TUTubIn1.port_b,borFieUTub1.port_a) annotation(Line(points = {{2.4,54},{32.4,54}},color = {0,127,255}));
    connect(borFieUTub1.port_b,TUTubOut1.port_a) annotation(Line(points = {{52.4,54},{82,54}},color = {0,127,255}));
    connect(TUTubOut1.port_b,sin1.ports[1]) annotation(Line(points = {{102,54},{112,54}},color = {0,127,255}));
end Borefields_DFP_Glycol_T0;

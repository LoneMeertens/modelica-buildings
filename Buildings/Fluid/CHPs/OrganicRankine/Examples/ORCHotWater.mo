within Buildings.Fluid.CHPs.OrganicRankine.Examples;
model ORCHotWater "ORC that outputs hot water at a fixed temperature"
  extends Modelica.Icons.Example;
  Buildings.Fluid.CHPs.OrganicRankine.Cycle orc(
    redeclare final package Medium1 = MediumHot,
    redeclare final package Medium2 = MediumCol,
    tau1=10,
    tau2=10,
    T2_start=TCol_start,
    redeclare Buildings.Fluid.CHPs.OrganicRankine.Data.WorkingFluids.R123 pro,
    final mHot_flow_nominal=mHot_flow_nominal,
    dTPinEva_set=5,
    TWorEva=373.15,
    pWorEva(displayUnit="bar"),
    final mCol_flow_nominal=mCol_flow_nominal,
    dTPinCon=5,
    mWor_flow_max=100,
    mWor_flow_min=0.01,
    mWor_flow_hysteresis=0.01,
    etaExp=0.8,
    etaPum=0.6) "Organic Rankine cycle"
    annotation (Placement(transformation(extent={{-10,40},{10,60}})));

  package MediumHot = Buildings.Media.Air "Evaporator hot fluid";
  package MediumCol = Buildings.Media.Water "Condenser cold fluid";
  parameter Modelica.Units.SI.MassFlowRate mHot_flow_nominal = 1
    "Nominal mass flow rate of evaporator hot fluid";
  parameter Modelica.Units.SI.MassFlowRate mCol_flow_nominal = 1.4
    "Nominal mass flow rate of condenser cold fluid";
  parameter Modelica.Units.SI.PressureDifference dpCon_nominal(
    displayUnit = "Pa") = 10000
    "Nominal pressure drop across the ORC condenser";
  parameter Modelica.Units.SI.PressureDifference dpValCol_nominal(
    displayUnit = "Pa") = 10000
    "Nominal pressure difference used for valves in the cold fluid loop";
  parameter Modelica.Units.SI.ThermodynamicTemperature TCol_start = 25 + 273.15
    "Start value for cold fluid temperature";

  Modelica.Units.SI.Efficiency etaThe = orc.PEle / max(orc.QEva_flow,1)
    "Thermal efficiency of the ORC";

  Buildings.Fluid.Sources.MassFlowSource_T souHot(
    redeclare final package Medium = MediumHot,
    m_flow=mHot_flow_nominal,
    T=423.15,
    nPorts=1)      "Evaporator hot fluid source"
    annotation (Placement(transformation(extent={{-140,60},{-120,80}})));
  Buildings.Fluid.Sources.Boundary_pT sinHot(
    redeclare final package Medium = MediumHot,
    nPorts=1) "Evaporator hot fluid sink"
    annotation (Placement(transformation(extent={{120,60},{100,80}})));
  Buildings.Controls.Continuous.LimPID conPI(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=0.4,
    Ti=30,
    initType=Modelica.Blocks.Types.Init.InitialOutput,
    y_start=0,
    reverseActing=false)
                        "PI controller"
    annotation (Placement(transformation(extent={{80,20},{60,0}})));
  Modelica.Blocks.Sources.Constant TWatOut_set(k=45 + 273.15)
    "Set point of hot water output"
    annotation (Placement(transformation(extent={{120,0},{100,20}})));
  Buildings.Fluid.Sources.Boundary_pT       colBou(
    redeclare final package Medium = MediumCol,
    use_T_in=true,
    nPorts=2) "Cold fluid boundary conditions"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},rotation=0,origin={110,-60})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTWatSup(redeclare final package
      Medium = MediumCol, m_flow_nominal=mCol_flow_nominal,
    T_start=TCol_start)
    "Water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={70,-80})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTWatRet(redeclare final package
      Medium = MediumCol, m_flow_nominal=mCol_flow_nominal,
    T_start=TCol_start)
    "Water return temperature" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={70,-40})));
  Modelica.Blocks.Sources.TimeTable TWatRet(
    y(final unit="K", displayUnit="degC"),
    table=[0,25; 3,25; 6,35; 9,35],
    timeScale=100,
    offset=273.15) "Water return temperature values"
    annotation (Placement(transformation(extent={{170,-70},{150,-50}})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear val(
    redeclare final package Medium = MediumCol,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=TCol_start,
    from_dp=false,
    use_inputFilter=false,
    final m_flow_nominal=mCol_flow_nominal,
    final dpValve_nominal=dpValCol_nominal,
    final dpFixed_nominal=fill(dpCon_nominal, 2))    "Control valve"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={40,-40})));
  Movers.Preconfigured.FlowControlled_m_flow pum(
    redeclare final package Medium = MediumCol,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    T_start=TCol_start,
    addPowerToMedium=false,
    riseTime=10,
    m_flow_nominal=mCol_flow_nominal,
    dp_nominal=dpCon_nominal + dpValCol_nominal,
    m_flow_start=0)                              "Cooling water pump"
    annotation (Placement(transformation(extent={{-60,-50},{-80,-30}})));
  DHC.ETS.BaseClasses.Junction spl(redeclare final package Medium = MediumCol,
    T_start=TCol_start,
      final m_flow_nominal=mCol_flow_nominal .* {1,-1,-1})     "Flow splitter"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-130,-40})));
  Controls.OBC.CDL.Conversions.BooleanToReal           booToRea
    "Constant speed primary pumps control signal"
    annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
  Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=mCol_flow_nominal)
    "Scale to nominal mass flow rate" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-90,10})));
  Modelica.Blocks.Logical.GreaterThreshold greThr(threshold=mCol_flow_nominal/2)
    "Greather threshold"
    annotation (Placement(transformation(extent={{-180,40},{-160,60}})));
  Modelica.Blocks.Logical.And and1
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  Modelica.Blocks.Sources.BooleanConstant Tru(k=true) "Logical true"
    annotation (Placement(transformation(extent={{-180,0},{-160,20}})));
  Sensors.TemperatureTwoPort senTColOut(redeclare final package Medium =
        MediumCol, m_flow_nominal=mCol_flow_nominal,
    T_start=TCol_start)                              annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-40,-40})));
equation
  connect(orc.port_b1, sinHot.ports[1]) annotation (Line(points={{10,56},{20,56},
          {20,70},{100,70}},color={0,127,255}));
  connect(souHot.ports[1], orc.port_a1) annotation (Line(points={{-120,70},{-20,
          70},{-20,56},{-10,56}},
                              color={0,127,255}));
  connect(TWatOut_set.y, conPI.u_s)
    annotation (Line(points={{99,10},{82,10}}, color={0,0,127}));
  connect(colBou.ports[1], senTWatSup.port_b) annotation (Line(points={{100,-61},
          {100,-80},{80,-80}}, color={0,127,255}));
  connect(senTWatRet.port_a, colBou.ports[2]) annotation (Line(points={{80,-40},
          {100,-40},{100,-59}}, color={0,127,255}));
  connect(TWatRet.y, colBou.T_in) annotation (Line(points={{149,-60},{132,-60},
          {132,-56},{122,-56}},color={0,0,127}));
  connect(senTWatRet.port_b, val.port_1)
    annotation (Line(points={{60,-40},{50,-40}}, color={0,127,255}));
  connect(spl.port_3, val.port_3) annotation (Line(points={{-130,-50},{-130,-56},
          {40,-56},{40,-50}}, color={0,127,255}));
  connect(spl.port_2, senTWatSup.port_a) annotation (Line(points={{-140,-40},{
          -160,-40},{-160,-80},{60,-80}},
                                     color={0,127,255}));
  connect(conPI.y, val.y)
    annotation (Line(points={{59,10},{40,10},{40,-28}}, color={0,0,127}));
  connect(booToRea.y, gai.u)
    annotation (Line(points={{-118,10},{-102,10}}, color={0,0,127}));
  connect(gai.y, pum.m_flow_in)
    annotation (Line(points={{-78,10},{-70,10},{-70,-28}},
                                                         color={0,0,127}));
  connect(pum.m_flow_actual, greThr.u) annotation (Line(points={{-81,-35},{-90,-35},
          {-90,-20},{-190,-20},{-190,50},{-182,50}},    color={0,0,127}));
  connect(Tru.y, booToRea.u)
    annotation (Line(points={{-159,10},{-142,10}}, color={255,0,255}));
  connect(greThr.y, and1.u1) annotation (Line(points={{-159,50},{-82,50}},
                          color={255,0,255}));
  connect(and1.y, orc.ena) annotation (Line(points={{-59,50},{-8,50}},
                     color={255,0,255}));
  connect(and1.u2, Tru.y) annotation (Line(points={{-82,42},{-150,42},{-150,10},
          {-159,10}}, color={255,0,255}));
  connect(orc.port_b2,senTColOut. port_a) annotation (Line(points={{-10,44},{-20,
          44},{-20,-40},{-30,-40}}, color={0,127,255}));
  connect(senTColOut.port_b, pum.port_a)
    annotation (Line(points={{-50,-40},{-60,-40}},   color={0,127,255}));
  connect(spl.port_1, pum.port_b)
    annotation (Line(points={{-120,-40},{-80,-40}},  color={0,127,255}));
  connect(senTColOut.T, conPI.u_m) annotation (Line(points={{-40,-29},{-40,28},
          {70,28},{70,22}},              color={0,0,127}));
  connect(val.port_2, orc.port_a2) annotation (Line(points={{30,-40},{20,-40},{
          20,44},{10,44}}, color={0,127,255}));
annotation(experiment(StopTime=900,Tolerance=1E-6),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/CHPs/OrganicRankine/Examples/ORCHotWater.mos"
  "Simulate and plot"),
  Documentation(info="<html>
<p>
[documentation pending]
Three-way valve controlled to track hot water (cold fluid of the ORC) output at a set point of 45 C.
System and control similar to Buildings.DHC.ETS.Combined.Subsystems.Validation.Chiller.
</p>
</html>",revisions="<html>
<ul>
<li>
April 15, 2024, by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3433\">#3433</a>.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(extent={{-200,-100},{180,100}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end ORCHotWater;

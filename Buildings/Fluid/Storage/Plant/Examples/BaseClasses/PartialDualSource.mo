within Buildings.Fluid.Storage.Plant.Examples.BaseClasses;
partial model PartialDualSource
  "Idealised district system model with two sources and three users"

  package Medium = Buildings.Media.Water "Medium model for CHW";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=1
    "Nominal mass flow rate, slightly larger than needed by one user load";
  parameter Modelica.Units.SI.PressureDifference dp_nominal(
    final displayUnit="Pa")=
     300000
    "Nominal pressure difference";
  parameter Modelica.Units.SI.Temperature T_CHWR_nominal(
    final displayUnit="degC")=
     12+273.15
    "Nominal temperature of CHW return";
  parameter Modelica.Units.SI.Temperature T_CHWS_nominal(
    final displayUnit="degC")=
     7+273.15
    "Nominal temperature of CHW supply";

// First source: chiller only
  Buildings.Fluid.Storage.Plant.BaseClasses.IdealTemperatureSource chi1(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final TSet=T_CHWS_nominal)
    "Chiller 1 represented by an ideal temperature source" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,70})));
  Buildings.Fluid.Movers.SpeedControlled_y pumSup1(
    redeclare final package Medium = Medium,
    per(pressure(dp=dp_nominal*{1.14,1,0.42},
                 V_flow=(m_flow_nominal)/1000*{0,1,2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    addPowerToMedium=false,
    y_start=0,
    T_start=T_CHWS_nominal) "CHW supply pump for chi1"
                                                 annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-10,90})));
  Buildings.Controls.Continuous.LimPID conPI_pumChi1(
    final controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=0.2,
    Ti=10,
    final reverseActing=true) "PI controller" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-92,170})));

// Second source: chiller and tank
  Buildings.Fluid.Storage.Plant.BaseClasses.IdealTemperatureSource chi2(
    redeclare final package Medium = Medium,
    final m_flow_nominal=nom.mChi_flow_nominal,
    final TSet=T_CHWS_nominal)
    "Chiller 2 represented by an ideal temperature source" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-150,-90})));
  final parameter Buildings.Fluid.Storage.Plant.Data.NominalValues nom(
    m_flow_nominal=2*m_flow_nominal,
    mTan_flow_nominal=m_flow_nominal,
    mChi_flow_nominal=2*m_flow_nominal,
    dp_nominal=dp_nominal,
    T_CHWS_nominal=T_CHWS_nominal,
    T_CHWR_nominal=T_CHWR_nominal) "Nominal values for the second plant"
    annotation (Placement(transformation(extent={{-100,-140},{-80,-120}})));
  Buildings.Fluid.Movers.FlowControlled_m_flow pumChi2(
    redeclare final package Medium = Medium,
    per(pressure(dp=chi2PreDro.dp_nominal*{1.14,1,0.42},
                 V_flow=nom.mChi_flow_nominal/1000*{0,1,2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=nom.mChi_flow_nominal,
    allowFlowReversal=true,
    addPowerToMedium=false,
    m_flow_start=0,
    T_start=nom.T_CHWS_nominal) "Primary CHW pump for plant 2"
                                                              annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-130,-70})));
  Buildings.Fluid.FixedResistances.PressureDrop chi2PreDro(
    redeclare final package Medium = Medium,
    final m_flow_nominal=nom.mChi_flow_nominal,
    dp_nominal=0.1*nom.dp_nominal)
    "Pressure drop of the chiller branch in plant 2"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-130,-110})));
  Buildings.Fluid.Storage.Plant.TankBranch tanBra(
    redeclare final package Medium = Medium,
    final nom=nom,
    VTan=1.5,
    hTan=3,
    dIns=0.3,
    nSeg=3)
    "Tank branch, tank can be charged remotely" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-90,-90})));
  Buildings.Fluid.Storage.Plant.IdealReversibleConnection ideRevConSup(
    redeclare final package Medium = Medium,
    final m_flow_nominal=nom.m_flow_nominal)
                   "Ideal reversable connection on supply side"
    annotation (Placement(transformation(extent={{0,-80},{20,-60}})));

// Users
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse1(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    dp_nominal=0.2*dp_nominal,
    final T_CHWS_nominal=T_CHWS_nominal,
    final T_CHWR_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={90,150})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse2(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    dp_nominal=0.2*dp_nominal,
    final T_CHWS_nominal=T_CHWS_nominal,
    final T_CHWR_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={90,-10})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse3(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    dp_nominal=0.2*dp_nominal,
    final T_CHWS_nominal=T_CHWS_nominal,
    final T_CHWR_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={90,-170})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMin mulMin_dpUse(nin=3)
    "Min of pressure head measured from all users"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-130,130})));
  Modelica.Blocks.Sources.Constant set_dpUse(final k=1)
    "Normalised consumer differential pressure setpoint"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-130,170})));
  Modelica.Blocks.Sources.TimeTable mLoa1_flow(table=[0,0; 3000,0; 3000,ideUse1.m_flow_nominal;
        6000,ideUse1.m_flow_nominal; 6000,0; 9000,0])
    "Cooling load of user 1 represented by flow rate"
    annotation (Placement(transformation(extent={{100,180},{80,200}})));
  Modelica.Blocks.Sources.TimeTable mLoa2_flow(table=[0,0; 3500,0; 3500,ideUse2.m_flow_nominal;
        5500,ideUse2.m_flow_nominal; 5500,0; 9000,0])
    "Cooling load of user 2 represented by flow rate"
    annotation (Placement(transformation(extent={{100,20},{80,40}})));
  Modelica.Blocks.Sources.TimeTable mLoa3_flow(table=[0,0; 4000,0; 4000,ideUse3.m_flow_nominal;
        5000,ideUse3.m_flow_nominal; 5000,0; 9000,0])
    "Cooling load of user 3 represented by flow rate"
    annotation (Placement(transformation(extent={{100,-140},{80,-120}})));
  Modelica.Blocks.Math.Gain gaiUse1(final k=1/ideUse1.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={130,170})));
  Modelica.Blocks.Math.Gain gaiUse2(final k=1/ideUse2.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={130,12})));
  Modelica.Blocks.Math.Gain gaiUse3(final k=1/ideUse3.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={130,-150})));

// District pipe network
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelJunctions
    parJunUse1(
    redeclare final package Medium = Medium,
    T1_start=nom.T_CHWR_nominal,
    T2_start=nom.T_CHWS_nominal)
    "Parallel junctions for breaking algebraic loops" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={50,150})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelJunctions
    parJunPla1(
    redeclare final package Medium = Medium,
    T1_start=nom.T_CHWS_nominal,
    T2_start=nom.T_CHWR_nominal)
    "Parallel junctions for breaking algebraic loops" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={50,70})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelJunctions
    parJunUse2(
    redeclare final package Medium = Medium,
    T1_start=nom.T_CHWR_nominal,
    T2_start=nom.T_CHWS_nominal)
    "Parallel junctions for breaking algebraic loops" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={50,-10})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelJunctions
    parJunPla2(
    redeclare final package Medium = Medium,
    T1_start=nom.T_CHWS_nominal,
    T2_start=nom.T_CHWR_nominal)
    "Parallel junctions for breaking algebraic loops" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={50,-90})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelJunctions
    parJunUse3(
    redeclare final package Medium = Medium,
    T1_start=nom.T_CHWR_nominal,
    T2_start=nom.T_CHWS_nominal)
    "Parallel junctions for breaking algebraic loops" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={50,-170})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelPipes parPipS1U1(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.15*dp_nominal)
                               "Parallel pipes" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={50,110})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelPipes parPipS1U2(
    redeclare package Medium = Medium,
    m_flow_nominal=2*m_flow_nominal,
    dp_nominal=0.15*dp_nominal)
                               "Parallel pipes" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={50,30})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelPipes parPipS2U2(
    redeclare package Medium = Medium,
    m_flow_nominal=2*m_flow_nominal,
    dp_nominal=0.15*dp_nominal)
                               "Parallel pipes" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={50,-50})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ParallelPipes parPipS2U3(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.15*dp_nominal)
                               "Parallel pipes" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={50,-130})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.PipeEnd pipEnd1(
    redeclare final package Medium = Medium)
    "End of distribution pipe lines" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={50,190})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.PipeEnd pipEnd2(
    redeclare final package Medium = Medium)
    "End of distribution pipe lines" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,-210})));
  Modelica.Blocks.Sources.TimeTable mPla2Set_flow(table=[0,0; 9000,0])
    "Flow rate setpoint of the second plant"
    annotation (Placement(transformation(extent={{-160,0},{-140,20}})));
  Modelica.Blocks.Sources.TimeTable mChi2Set_flow(table=[0,0; 500,0; 500,nom.mChi_flow_nominal;
        3000,nom.mChi_flow_nominal; 3000,0; 9000,0])
    "Flow rate setpoint for the chiller in the storage plant"
    annotation (Placement(transformation(extent={{-160,-40},{-140,-20}})));

  Modelica.Blocks.Routing.Multiplex muxDp(n=3) "Multiplexer block for routing"
    annotation (Placement(transformation(extent={{180,140},{200,160}})));
  Modelica.Blocks.Routing.Multiplex muxVal(n=3) "Multiplexer block for routing"
    annotation (Placement(transformation(extent={{180,-180},{200,-160}})));
equation
  connect(set_dpUse.y,conPI_pumChi1.u_s)
    annotation (Line(points={{-119,170},{-104,170}},
                                                   color={0,0,127}));
  connect(mLoa1_flow.y, ideUse1.mPre_flow) annotation (Line(points={{79,190},{
          74,190},{74,158},{79,158}},
                                   color={0,0,127}));
  connect(mLoa2_flow.y, ideUse2.mPre_flow) annotation (Line(points={{79,30},{74,
          30},{74,-2},{79,-2}}, color={0,0,127}));
  connect(mLoa3_flow.y, ideUse3.mPre_flow) annotation (Line(points={{79,-130},{
          74,-130},{74,-162},{79,-162}}, color={0,0,127}));
  connect(ideUse1.dp, gaiUse1.u) annotation (Line(points={{101,154},{110,154},{
          110,170},{118,170}}, color={0,0,127}));
  connect(ideUse2.dp, gaiUse2.u) annotation (Line(points={{101,-6},{110,-6},{
          110,12},{118,12}},   color={0,0,127}));
  connect(ideUse3.dp, gaiUse3.u) annotation (Line(points={{101,-166},{110,-166},
          {110,-150},{118,-150}}, color={0,0,127}));
  connect(mulMin_dpUse.y,conPI_pumChi1.u_m)
    annotation (Line(points={{-118,130},{-92,130},{-92,158}},color={0,0,127}));
  connect(conPI_pumChi1.y,pumSup1. y) annotation (Line(points={{-81,170},{-10,170},
          {-10,102}},      color={0,0,127}));
  connect(parJunUse1.port_a2, pipEnd1.port_a)
    annotation (Line(points={{44,160},{44,180}}, color={0,127,255}));
  connect(pipEnd1.port_b, parJunUse1.port_b1)
    annotation (Line(points={{56,180},{56,160}}, color={0,127,255}));
  connect(parJunUse1.port_c2, ideUse1.port_a) annotation (Line(points={{60,156},
          {80,156}},                          color={0,127,255}));
  connect(parJunUse1.port_c1, ideUse1.port_b) annotation (Line(points={{60,144},
          {80,144}},                       color={0,127,255}));
  connect(parJunUse2.port_c2, ideUse2.port_a) annotation (Line(points={{60,-4},
          {80,-4}},                     color={0,127,255}));
  connect(ideUse2.port_b,parJunUse2.port_c1)  annotation (Line(points={{80,-16},
          {60,-16}},                            color={0,127,255}));
  connect(parJunUse3.port_a1, pipEnd2.port_a)
    annotation (Line(points={{56,-180},{56,-200}}, color={0,127,255}));
  connect(pipEnd2.port_b, parJunUse3.port_b2)
    annotation (Line(points={{44,-200},{44,-180}}, color={0,127,255}));
  connect(parJunUse3.port_c2, ideUse3.port_a) annotation (Line(points={{60,-164},
          {80,-164}},                               color={0,127,255}));
  connect(ideUse3.port_b,parJunUse3.port_c1)  annotation (Line(points={{80,-176},
          {60,-176}},                               color={0,127,255}));
  connect(parPipS1U1.port_a2, parJunUse1.port_b2)
    annotation (Line(points={{44,120},{44,140}}, color={0,127,255}));
  connect(parPipS1U1.port_b2, parJunPla1.port_a1)
    annotation (Line(points={{44,100},{44,80}}, color={0,127,255}));
  connect(parJunPla1.port_b2, parPipS1U1.port_a1)
    annotation (Line(points={{56,80},{56,100}}, color={0,127,255}));
  connect(parPipS1U1.port_b1, parJunUse1.port_a1)
    annotation (Line(points={{56,120},{56,140}}, color={0,127,255}));
  connect(parJunPla1.port_b1, parPipS1U2.port_a2)
    annotation (Line(points={{44,60},{44,40}}, color={0,127,255}));
  connect(parPipS1U2.port_b2, parJunUse2.port_a2)
    annotation (Line(points={{44,20},{44,0}}, color={0,127,255}));
  connect(parJunUse2.port_b1, parPipS1U2.port_a1)
    annotation (Line(points={{56,0},{56,20}}, color={0,127,255}));
  connect(parPipS1U2.port_b1, parJunPla1.port_a2)
    annotation (Line(points={{56,40},{56,60}}, color={0,127,255}));
  connect(parJunUse2.port_b2, parPipS2U2.port_a2)
    annotation (Line(points={{44,-20},{44,-40}}, color={0,127,255}));
  connect(parPipS2U2.port_b1, parJunUse2.port_a1)
    annotation (Line(points={{56,-40},{56,-20}}, color={0,127,255}));
  connect(parPipS2U2.port_a1, parJunPla2.port_b2)
    annotation (Line(points={{56,-60},{56,-80}}, color={0,127,255}));
  connect(parJunPla2.port_a1, parPipS2U2.port_b2)
    annotation (Line(points={{44,-80},{44,-60}}, color={0,127,255}));
  connect(parPipS2U3.port_a2, parJunPla2.port_b1)
    annotation (Line(points={{44,-120},{44,-100}}, color={0,127,255}));
  connect(parJunPla2.port_a2, parPipS2U3.port_b1)
    annotation (Line(points={{56,-100},{56,-120}}, color={0,127,255}));
  connect(parPipS2U3.port_a1, parJunUse3.port_b1)
    annotation (Line(points={{56,-140},{56,-160}}, color={0,127,255}));
  connect(parJunUse3.port_a2, parPipS2U3.port_b2)
    annotation (Line(points={{44,-160},{44,-140}}, color={0,127,255}));
  connect(pumSup1.port_b, parJunPla1.port_c1) annotation (Line(points={{0,90},{20,
          90},{20,76},{40,76}},     color={0,127,255}));
  connect(pumChi2.port_b,tanBra.port_aSupChi)  annotation (Line(points={{-120,
          -70},{-110,-70},{-110,-84},{-100,-84}},
                                          color={0,127,255}));
  connect(tanBra.port_bRetChi, chi2PreDro.port_a) annotation (Line(points={{-100,
          -96},{-110,-96},{-110,-110},{-120,-110}}, color={0,127,255}));
  connect(mChi2Set_flow.y,pumChi2. m_flow_in) annotation (Line(points={{-139,
          -30},{-130,-30},{-130,-58}},
                                  color={0,0,127}));
  connect(tanBra.port_bSupNet, ideRevConSup.port_a) annotation (Line(points={{-80,
          -84},{-70,-84},{-70,-70},{0,-70}}, color={0,127,255}));
  connect(ideRevConSup.port_b, parJunPla2.port_c1) annotation (Line(points={{20,-70},
          {30,-70},{30,-84},{40,-84}}, color={0,127,255}));
  connect(pumSup1.port_a, chi1.port_b)
    annotation (Line(points={{-20,90},{-50,90},{-50,80}}, color={0,127,255}));
  connect(chi1.port_a, parJunPla1.port_c2) annotation (Line(points={{-50,60},{
          -50,54},{20,54},{20,64},{40,64}}, color={0,127,255}));
  connect(chi2PreDro.port_b, chi2.port_a) annotation (Line(points={{-140,-110},
          {-150,-110},{-150,-100}}, color={0,127,255}));
  connect(chi2.port_b, pumChi2.port_a) annotation (Line(points={{-150,-80},{
          -150,-70},{-140,-70}}, color={0,127,255}));
  connect(mPla2Set_flow.y, ideRevConSup.mSet_flow) annotation (Line(points={{
          -139,10},{-10,10},{-10,-65},{-1,-65}}, color={0,0,127}));
  connect(gaiUse1.y, muxDp.u[1]) annotation (Line(points={{141,170},{160,170},{
          160,147.667},{180,147.667}},
                                   color={0,0,127}));
  connect(gaiUse2.y, muxDp.u[2]) annotation (Line(points={{141,12},{160,12},{
          160,150},{180,150}},
                           color={0,0,127}));
  connect(gaiUse3.y, muxDp.u[3]) annotation (Line(points={{141,-150},{160,-150},
          {160,152.333},{180,152.333}}, color={0,0,127}));
  connect(muxDp.y[:], mulMin_dpUse.u[:]) annotation (Line(points={{201,150},{
          206,150},{206,206},{-152,206},{-152,130},{-142,130}},     color={0,0,127}));
  connect(ideUse1.yVal_actual, muxVal.u[1]) annotation (Line(points={{101,158},
          {106,158},{106,-172.333},{180,-172.333}}, color={0,0,127}));
  connect(ideUse2.yVal_actual, muxVal.u[2]) annotation (Line(points={{101,-2},{
          106,-2},{106,-170},{180,-170}}, color={0,0,127}));
  connect(ideUse3.yVal_actual, muxVal.u[3]) annotation (Line(points={{101,-162},
          {106,-162},{106,-170},{162,-170},{162,-167.667},{180,-167.667}},
        color={0,0,127}));
    annotation (__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Storage/Plant/Examples/IdealDualSource.mos"
        "Simulate and plot"),
        experiment(Tolerance=1e-06, StopTime=3600),
        Diagram(coordinateSystem(extent={{-180,-240},{220,220}})),
        Icon(coordinateSystem(extent={{-180,-240},{220,220}})),
    Documentation(info="<html>
<p>
This is the base model for the example models.
The modelled system is described in
<a href=\"Modelica://Buildings.Fluid.Storage.Plant.UsersGuide\">
Buildings.Fluid.Storage.Plant.UsersGuide</a>.
</p>
<p>
This base model provides common components and connections.
Two elements are left to be specified in the extended models:
</p>
<ul>
<li>
The return side of plant 2 is not connected to the district network.
It can take a direct or reversible connection in the extended models.
</li>
<li>
The pressurisation point (pressure boundary) is not specified.
The extended models can specify pressurisation point(s) at either or both
of the two plants.
</li>
</ul>
<p>
The source blocks give the system the following operation schedule during
simulation:
</p>
<table summary= \"system modes\" border=\"1\" cellspacing=\"0\" cellpadding=\"2\">
<thead>
  <tr>
    <th>Time Slot</th>
    <th>Plant 1 Flow</th>
    <th colspan=\"4\">Plant 2 Flows</th>
    <th colspan=\"3\">Users</th>
    <th>Description</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td></td>
    <td></td>
    <td>Chiller</td>
    <td>Tank*</td>
    <td>Charging</td>
    <td>Overall**</td>
    <td>1</td>
    <td>2</td>
    <td>3</td>
    <td></td>
  </tr>
  <tr>
    <td>1</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>N/A</td>
    <td>0</td>
    <td></td>
    <td></td>
    <td></td>
    <td>No load. No flow.</td>
  </tr>
  <tr>
    <td>2</td>
    <td>0</td>
    <td>+</td>
    <td>-</td>
    <td>Local</td>
    <td>0</td>
    <td></td>
    <td></td>
    <td></td>
    <td>No load. Tank is being charged locally.</td>
  </tr>
  <tr>
    <td>3</td>
    <td>+</td>
    <td>+</td>
    <td>-</td>
    <td>Local</td>
    <td>0</td>
    <td>Has load</td>
    <td></td>
    <td></td>
    <td>Plant 1 outputs CHW to satisfy load. Plant 2 still offline and in local charging.</td>
  </tr>
  <tr>
    <td>4</td>
    <td>+</td>
    <td>+</td>
    <td>0</td>
    <td>N/A</td>
    <td>+</td>
    <td>Has load</td>
    <td>Has load</td>
    <td></td>
    <td>Both plants output CHW. Tank holding.</td>
  </tr>
  <tr>
    <td>5</td>
    <td>+</td>
    <td>+</td>
    <td>+</td>
    <td>N/A</td>
    <td>+</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Both plants including tank output CHW.</td>
  </tr>
  <tr>
    <td>6</td>
    <td>+</td>
    <td>0</td>
    <td>+</td>
    <td>N/A</td>
    <td>+</td>
    <td></td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Plant 1 and tank output CHW, chiller 2 off.</td>
  </tr>
  <tr>
    <td>7</td>
    <td>+</td>
    <td>0</td>
    <td>0</td>
    <td>N/A</td>
    <td>0</td>
    <td></td>
    <td></td>
    <td>Has load</td>
    <td>Plant 1 outputs CHW to satisfy load. Plant 2 off.</td>
  </tr>
  <tr>
    <td>8</td>
    <td>+</td>
    <td>0</td>
    <td>-</td>
    <td>Remote</td>
    <td>-</td>
    <td></td>
    <td></td>
    <td>Has load</td>
    <td>Plant 1 outputs CHW to satisfy load and remotely charge tank.</td>
  </tr>
  <tr>
    <td>9</td>
    <td>+</td>
    <td>0</td>
    <td>-</td>
    <td>Remote</td>
    <td>-</td>
    <td></td>
    <td></td>
    <td></td>
    <td>Plant 1 remotely charges tank.</td>
  </tr>
  <tr>
    <td>10</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>N/A</td>
    <td>0</td>
    <td></td>
    <td></td>
    <td></td>
    <td>No load. No flow.</td>
  </tr>
</tbody>
</table>
<p>
Notes:<br/>
*. A positive flow rate at the tank denotes that the tank is discharging
and a negative flow rate denotes that it is being charged.<br/>
**. A positive flow rate denotes that the flow direction of Plant 2 is the same
as the nominal flow direction (outputting CHW to the network).
A negative flow only occurs when its tank is being charged remotely.
</p>
</html>", revisions="<html>
<ul>
<li>
January 11, 2023 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end PartialDualSource;
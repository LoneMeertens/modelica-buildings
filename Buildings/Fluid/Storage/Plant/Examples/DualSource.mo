within Buildings.Fluid.Storage.Plant.Examples;
model DualSource
  "A district system model with two sources and three users"

  extends Modelica.Icons.Example;

  package MediumCHW = Buildings.Media.Water "Medium model for CHW";
  package MediumCDW1 = Buildings.Media.Water "Medium model for CDW of chi1";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=1
    "Nominal mass flow rate to satisfy nominal load of one user";
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
  parameter Modelica.Units.SI.Power QCooLoa_flow_nominal=5*4200*0.6
    "Nominal cooling load of one consumer";

// First source: chiller only
  Buildings.Fluid.Chillers.ElectricEIR chi1(
    redeclare final package Medium1 = MediumCDW1,
    redeclare final package Medium2 = MediumCHW,
    m1_flow_nominal=1.2*chi1.m2_flow_nominal,
    m2_flow_nominal=m_flow_nominal,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    p2_start=500000,
    T2_start=T_CHWS_nominal,
    final per=perChi1)
    "Water cooled chiller (ports indexed 1 are on condenser side)"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={-130,60})));
  parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic perChi1(
    QEva_flow_nominal=-1E6,
    COP_nominal=3,
    PLRMax=1,
    PLRMinUnl=0.3,
    PLRMin=0.3,
    etaMotor=1,
    mEva_flow_nominal=m_flow_nominal,
    mCon_flow_nominal=1.2*perChi1.mEva_flow_nominal,
    TEvaLvg_nominal=280.15,
    capFunT={1,0,0,0,0,0},
    EIRFunT={1,0,0,0,0,0},
    EIRFunPLR={1,0,0},
    TEvaLvgMin=276.15,
    TEvaLvgMax=288.15,
    TConEnt_nominal=310.15,
    TConEntMin=303.15,
    TConEntMax=333.15) "Performance data for the chiller in plant 1"
                                                  annotation (
      choicesAllMatching=true, Placement(transformation(extent={{-120,100},{-100,
            120}})));
 Buildings.Fluid.Movers.SpeedControlled_y pumSup1(
    redeclare package Medium = MediumCHW,
    per(pressure(dp=dp_nominal*{2,0},
                 V_flow=(chi1.m2_flow_nominal)/1.2*{0,2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    allowFlowReversal=false,
    addPowerToMedium=false,
    y_start=0,
    T_start=T_CHWS_nominal) "CHW supply pump for chi1"
                                                 annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-70,30})));
  Buildings.Fluid.FixedResistances.CheckValve cheValPumChi1(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=chi1.m2_flow_nominal,
    dpValve_nominal=0.1*dp_nominal) "Check valve" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,30})));
  Buildings.Controls.Continuous.LimPID conPI_pumChi1(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=0.2,
    Ti=10,
    reverseActing=true) "PI controller" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-90,170})));
  Buildings.Fluid.Sources.MassFlowSource_T souCDW1(
    redeclare package Medium = MediumCDW1,
    m_flow=1.2*chi1.m2_flow_nominal,
    T=305.15,
    nPorts=1) "Source representing CDW supply line" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,80})));
  Buildings.Fluid.Sources.Boundary_pT sinCDW1(
    redeclare final package Medium = MediumCDW1,
    final p=300000,
    final T=310.15,
    nPorts=1) "Sink representing CDW return line" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-170,40})));
  Modelica.Blocks.Sources.Constant TEvaLvgSet(k=T_CHWS_nominal)
    "Evaporator leaving temperature setpoint" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,140})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant on(k=true)
    "Placeholder, chiller always on"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,110})));

// Second source: chiller and tank
  final parameter Buildings.Fluid.Storage.Plant.Data.NominalValues nomPla2(
    allowRemoteCharging=true,
    mTan_flow_nominal=m_flow_nominal,
    mChi_flow_nominal=2*m_flow_nominal,
    dp_nominal=dp_nominal,
    T_CHWS_nominal=T_CHWS_nominal,
    T_CHWR_nominal=T_CHWS_nominal) "Nominal values for the second plant"
    annotation (Placement(transformation(extent={{-80,-140},{-60,-120}})));
  Buildings.Fluid.Storage.Plant.TankBranch tanBra(
    redeclare final package Medium = MediumCHW,
    final nom=nomPla2,
    final TTan_start=nomPla2.T_CHWR_nominal)
                       "Tank branch, tank can be charged remotely" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-70,-90})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ChillerBranch chiBra2(
    redeclare final package Medium = MediumCHW,
    final nom=nomPla2) "Chiller branch"
    annotation (Placement(transformation(extent={{-120,-100},{-100,-80}})));
  Buildings.Fluid.Storage.Plant.NetworkConnection netCon(
    redeclare final package Medium = MediumCHW,
    final nom=nomPla2,
    final allowRemoteCharging=nomPla2.allowRemoteCharging,
    per(pressure(V_flow=nomPla2.m_flow_nominal/1.2*{0,2},
                 dp=nomPla2.dp_nominal*{2,0})))
    "Supply pump and valves that connect the plant to the district network"
    annotation (Placement(transformation(extent={{0,-100},{20,-80}})));
  Modelica.Blocks.Sources.BooleanTable uRemCha(table={360*7,360*9},
    startValue=false) "Tank is being charged remotely" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,-10})));
  Buildings.Fluid.Storage.Plant.Controls.RemoteCharging conRemCha
    "Control block for the secondary pump and valves"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-30,-50})));
  Buildings.Controls.OBC.CDL.Logical.Or or2
    "Tank charging remotely OR there is load"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-130,-10})));

// Users
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse1(
    redeclare final package Medium = MediumCHW,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.7*dp_nominal,
    T_a_nominal=T_CHWS_nominal,
    T_b_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={90,90})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse2(
    redeclare final package Medium = MediumCHW,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.7*dp_nominal,
    T_a_nominal=T_CHWS_nominal,
    T_b_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={90,-10})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse3(
    redeclare final package Medium = MediumCHW,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.7*dp_nominal,
    T_a_nominal=T_CHWS_nominal,
    T_b_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={90,-130})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMin mulMin_dpUse(nin=3)
    "Min of pressure head measured from all users"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-30,150})));
  Modelica.Blocks.Sources.Constant set_dpUse(final k=1)
    "Normalised consumer differential pressure setpoint"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,170})));
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis hysCat(uLow=0.05, uHigh=0.1)
    "Shut off at con.yVal = 0.05 and restarts at 0.1" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={50,-210})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMax mulMax_yVal(nin=3)
    "Max of valve positions"
    annotation (Placement(transformation(extent={{100,-220},{80,-200}})));
  Modelica.Blocks.Sources.TimeTable set_QCooLoa1_flow(table=[0,0; 360*2,0; 360*2,
        QCooLoa_flow_nominal; 360*5,QCooLoa_flow_nominal; 360*5,0; 3600,0])
    "Cooling load"
    annotation (Placement(transformation(extent={{140,100},{120,120}})));
  Modelica.Blocks.Sources.TimeTable set_QCooLoa2_flow(table=[0,0; 360*3,0; 360*3,
        QCooLoa_flow_nominal; 360*6,QCooLoa_flow_nominal; 360*6,0; 3600,0])
    "Cooling load"
    annotation (Placement(transformation(extent={{140,0},{120,20}})));
  Modelica.Blocks.Sources.TimeTable set_QCooLoa3_flow(table=[0,0; 360*4,0; 360*4,
        QCooLoa_flow_nominal; 360*8,QCooLoa_flow_nominal; 360*8,0; 3600,0])
                                                          "Cooling load"
    annotation (Placement(transformation(extent={{140,-120},{120,-100}})));
  Modelica.Blocks.Math.Gain gaiUse1(k=1/ideUse1.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={130,70})));
  Modelica.Blocks.Math.Gain gaiUse2(k=1/ideUse2.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={130,-30})));
  Modelica.Blocks.Math.Gain gaiUse3(k=1/ideUse3.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={130,-150})));

// District pipe network
  Buildings.Experimental.DHC.Networks.Connection2Pipe con2PipPla1(
    redeclare package Medium = MediumCHW,
    final mDis_flow_nominal=m_flow_nominal,
    final mCon_flow_nominal=chi1.m2_flow_nominal,
    final allowFlowReversal=true,
    final dpDis_nominal=0,
    final junConSup(T_start=T_CHWS_nominal),
    final junConRet(T_start=T_CHWS_nominal))
    "Two-pipe connection to the chiller-only plant"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={50,50})));
  Buildings.Experimental.DHC.Networks.Connection2Pipe con2PipPla2(
    redeclare package Medium = MediumCHW,
    final mDis_flow_nominal=m_flow_nominal,
    final mCon_flow_nominal=nomPla2.m_flow_nominal,
    final allowFlowReversal=true,
    final dpDis_nominal=0,
    final junConSup(T_start=T_CHWS_nominal),
    final junConRet(T_start=T_CHWS_nominal))
    "Two-pipe connection to the storage plant"
    annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={50,-90})));
  Buildings.Experimental.DHC.Networks.Connection2Pipe con2PipUse1(
    redeclare package Medium = MediumCHW,
    final mDis_flow_nominal=m_flow_nominal,
    final mCon_flow_nominal=ideUse2.m_flow_nominal,
    final allowFlowReversal=true,
    final dpDis_nominal=0,
    final junConSup(T_start=T_CHWS_nominal),
    final junConRet(T_start=T_CHWS_nominal)) "Two-pipe connection to the user(s)"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={50,90})));
  Buildings.Experimental.DHC.Networks.Connection2Pipe con2PipUse2(
    redeclare package Medium = MediumCHW,
    final mDis_flow_nominal=m_flow_nominal,
    final mCon_flow_nominal=ideUse2.m_flow_nominal,
    final allowFlowReversal=true,
    final dpDis_nominal=0,
    final junConSup(T_start=T_CHWS_nominal),
    final junConRet(T_start=T_CHWS_nominal)) "Two-pipe connection to the user(s)"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={50,-10})));
  Buildings.Experimental.DHC.Networks.Connection2Pipe con2PipUse3(
    redeclare package Medium = MediumCHW,
    final mDis_flow_nominal=m_flow_nominal,
    final mCon_flow_nominal=ideUse2.m_flow_nominal,
    final allowFlowReversal=true,
    final dpDis_nominal=0,
    final junConSup(T_start=T_CHWS_nominal),
    final junConRet(T_start=T_CHWS_nominal)) "Two-pipe connection to the user(s)"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={50,-130})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.PipeEnd pipEnd1(
    redeclare final package Medium = MediumCHW)
    "End of distribution pipe lines" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={50,130})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.PipeEnd pipEnd2(
    redeclare final package Medium = MediumCHW)
    "End of distribution pipe lines" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,-170})));
  Buildings.Fluid.FixedResistances.Junction junBou(
    redeclare final package Medium = MediumCHW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=nomPla2.T_CHWS_nominal,
    tau=30,
    final m_flow_nominal={-nomPla2.m_flow_nominal,nomPla2.m_flow_nominal,1},
    final dp_nominal={0,0,0}) "Junction connected to the pressure boundary"
    annotation (Placement(transformation(extent={{-40,-106},{-20,-86}})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    p(final displayUnit="Pa") = 101325,
    redeclare final package Medium = MediumCHW,
    nPorts=1) "Pressure boundary"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-30,-130})));
  Modelica.Blocks.Sources.TimeTable mTanSet_flow(table=[0,0; 360*1,0;
    360*1,-nomPla2.mTan_flow_nominal; 360*3,-nomPla2.mTan_flow_nominal; 360*3,0;
    360*4,0; 360*4,nomPla2.mTan_flow_nominal; 360*6,nomPla2.mTan_flow_nominal;
    360*6,0; 360*7,0; 360*7,-nomPla2.mTan_flow_nominal;
    360*9,-nomPla2.mTan_flow_nominal;360*9,0]) "Tank flow rate setpoint"
    annotation (Placement(transformation(extent={{-140,-60},{-120,-40}})));
  Modelica.Blocks.Sources.TimeTable mChi2Set_flow(table=[0,0; 360*1,0;
    360*1,nomPla2.mTan_flow_nominal; 360*3,nomPla2.mTan_flow_nominal;
    360*3,m_flow_nominal; 360*5,m_flow_nominal; 360*5,0])
    "Flow rate setpoint for the chiller in the storage plant"
    annotation (Placement(transformation(extent={{-140,-140},{-120,-120}})));

equation
  connect(ideUse3.yVal_actual, mulMax_yVal.u[1]) annotation (Line(points={{101,
          -134},{110,-134},{110,-210.667},{102,-210.667}},                color=
         {0,0,127}));
  connect(ideUse2.yVal_actual, mulMax_yVal.u[2]) annotation (Line(points={{101,-14},
          {110,-14},{110,-210},{102,-210}},
                                          color={0,0,127}));
  connect(mulMax_yVal.y, hysCat.u)
    annotation (Line(points={{78,-210},{62,-210}}, color={0,0,127}));
  connect(set_dpUse.y,conPI_pumChi1.u_s)
    annotation (Line(points={{-159,170},{-102,170}},
                                                   color={0,0,127}));
  connect(ideUse1.yVal_actual, mulMax_yVal.u[3]) annotation (Line(points={{101,86},
          {110,86},{110,-209.333},{102,-209.333}},        color={0,0,127}));
  connect(set_QCooLoa1_flow.y, ideUse1.QCooLoa_flow) annotation (Line(points={{119,110},
          {114,110},{114,94},{101,94}},    color={0,0,127}));
  connect(set_QCooLoa2_flow.y, ideUse2.QCooLoa_flow) annotation (Line(points={{119,10},
          {114,10},{114,-6},{101,-6}},      color={0,0,127}));
  connect(set_QCooLoa3_flow.y, ideUse3.QCooLoa_flow) annotation (Line(points={{119,
          -110},{114,-110},{114,-126},{101,-126}},
                                               color={0,0,127}));
  connect(ideUse1.dpUse,gaiUse1.u)
    annotation (Line(points={{101,82},{114,82},{114,70},{118,70}},
                                                       color={0,0,127}));
  connect(ideUse2.dpUse,gaiUse2.u) annotation (Line(points={{101,-18},{114,-18},
          {114,-30},{118,-30}},color={0,0,127}));
  connect(ideUse3.dpUse,gaiUse3.u)
    annotation (Line(points={{101,-138},{114,-138},{114,-150},{118,-150}},
                                                          color={0,0,127}));
  connect(gaiUse1.y,mulMin_dpUse.u[1]) annotation (Line(points={{141,70},{150,
          70},{150,150},{-18,150}},  color={0,0,127}));
  connect(gaiUse2.y,mulMin_dpUse.u[2]) annotation (Line(points={{141,-30},{150,
          -30},{150,150},{-18,150}},               color={0,0,127}));
  connect(gaiUse3.y,mulMin_dpUse.u[3]) annotation (Line(points={{141,-150},{150,
          -150},{150,150},{-18,150}},     color={0,0,127}));
  connect(mulMin_dpUse.y,conPI_pumChi1.u_m)
    annotation (Line(points={{-42,150},{-90,150},{-90,158}}, color={0,0,127}));
  connect(conPI_pumChi1.y,pumSup1. y) annotation (Line(points={{-79,170},{-70,
          170},{-70,42}},  color={0,0,127}));
  connect(pumSup1.port_b, cheValPumChi1.port_a)
    annotation (Line(points={{-80,30},{-100,30}}, color={0,127,255}));
  connect(cheValPumChi1.port_b, chi1.port_a2) annotation (Line(points={{-120,30},
          {-124,30},{-124,50}},           color={0,127,255}));
  connect(souCDW1.ports[1], chi1.port_a1) annotation (Line(points={{-160,80},{-136,
          80},{-136,70}},                       color={0,127,255}));
  connect(chi1.port_b1, sinCDW1.ports[1]) annotation (Line(points={{-136,50},{-136,
          40},{-160,40}},           color={0,127,255}));
  connect(TEvaLvgSet.y, chi1.TSet)
    annotation (Line(points={{-159,140},{-127,140},{-127,72}},
                                                           color={0,0,127}));
  connect(on.y, chi1.on) annotation (Line(points={{-158,110},{-133,110},{-133,72}},
                    color={255,0,255}));
  connect(uRemCha.y, or2.u1) annotation (Line(points={{-159,-10},{-142,-10}},
                                          color={255,0,255}));
  connect(hysCat.y, or2.u2) annotation (Line(points={{38,-210},{-148,-210},{-148,
          -18},{-142,-18}},
        color={255,0,255}));
  connect(conRemCha.uAva, or2.y) annotation (Line(points={{-42,-44},{-58,-44},{-58,
          -10},{-118,-10}},
                     color={255,0,255}));
  connect(uRemCha.y,conRemCha. uRemCha) annotation (Line(points={{-159,-10},{-152,
          -10},{-152,-24},{-62,-24},{-62,-48},{-42,-48}},
        color={255,0,255}));
  connect(conRemCha.yPum, netCon.yPum)
    annotation (Line(points={{-19,-56},{8,-56},{8,-79}}, color={0,0,127}));
  connect(conRemCha.yVal, netCon.yVal)
    annotation (Line(points={{-19,-52},{12,-52},{12,-79}}, color={0,0,127}));
  connect(chiBra2.port_b, tanBra.port_aFroChi)
    annotation (Line(points={{-100,-84},{-80,-84}},  color={0,127,255}));
  connect(chiBra2.port_a, tanBra.port_bToChi)
    annotation (Line(points={{-100,-96},{-80,-96}},  color={0,127,255}));
  connect(tanBra.mTan_flow, conRemCha.mTan_flow)
    annotation (Line(points={{-66,-79},{-66,-56},{-41,-56}}, color={0,0,127}));
  connect(junBou.port_3, bou.ports[1])
    annotation (Line(points={{-30,-106},{-30,-120}},
                                                   color={0,127,255}));
  connect(netCon.port_aFroNet, con2PipPla2.port_aCon)
    annotation (Line(points={{20,-96},{40,-96}},   color={0,127,255}));
  connect(con2PipPla2.port_bCon, netCon.port_bToNet) annotation (Line(points={{40,-90},
          {28,-90},{28,-84},{20,-84}},             color={0,127,255}));
  connect(con2PipPla1.port_bCon, chi1.port_b2) annotation (Line(points={{40,50},
          {-114,50},{-114,80},{-124,80},{-124,70}},        color={0,127,255}));
  connect(pumSup1.port_a, con2PipPla1.port_aCon) annotation (Line(points={{-60,30},
          {32,30},{32,44},{40,44}},          color={0,127,255}));
  connect(junBou.port_1, tanBra.port_aFroNet)
    annotation (Line(points={{-40,-96},{-60,-96}},  color={0,127,255}));
  connect(junBou.port_2, netCon.port_bToChi)
    annotation (Line(points={{-20,-96},{0,-96}},   color={0,127,255}));
  connect(netCon.port_aFroChi, tanBra.port_bToNet)
    annotation (Line(points={{0,-84},{-60,-84}},    color={0,127,255}));
  connect(mTanSet_flow.y, conRemCha.mTanSet_flow) annotation (Line(points={{-119,
          -50},{-66,-50},{-66,-52},{-41,-52}},   color={0,0,127}));
  connect(mChi2Set_flow.y, chiBra2.mPumSet_flow) annotation (Line(points={{-119,
          -130},{-106,-130},{-106,-101}}, color={0,0,127}));
  connect(con2PipUse2.port_aDisSup, con2PipPla1.port_aDisRet) annotation (Line(
        points={{50,0},{50,8},{56,8},{56,40}}, color={0,127,255}));
  connect(con2PipPla1.port_bDisSup, con2PipUse2.port_bDisRet) annotation (Line(
        points={{50,40},{50,30},{44,30},{44,1.77636e-15}}, color={0,127,255}));
  connect(con2PipPla2.port_aDisSup, con2PipUse2.port_aDisRet) annotation (Line(
        points={{50,-80},{50,-70},{44,-70},{44,-20}}, color={0,127,255}));
  connect(con2PipUse2.port_bDisSup, con2PipPla2.port_bDisRet) annotation (Line(
        points={{50,-20},{50,-30},{56,-30},{56,-80}}, color={0,127,255}));
  connect(con2PipPla1.port_aDisSup, con2PipUse1.port_aDisRet) annotation (Line(
        points={{50,60},{50,66},{44,66},{44,80}}, color={0,127,255}));
  connect(con2PipPla1.port_bDisRet, con2PipUse1.port_bDisSup) annotation (Line(
        points={{56,60},{56,72},{50,72},{50,80}}, color={0,127,255}));
  connect(con2PipUse1.port_bCon, ideUse1.port_a) annotation (Line(points={{60,90},
          {74,90},{74,106},{90,106},{90,100}}, color={0,127,255}));
  connect(ideUse1.port_b, con2PipUse1.port_aCon) annotation (Line(points={{90,80},
          {90,74},{74,74},{74,84},{60,84}}, color={0,127,255}));
  connect(con2PipUse2.port_bCon, ideUse2.port_a) annotation (Line(points={{60,-10},
          {74,-10},{74,6},{90,6},{90,0}}, color={0,127,255}));
  connect(ideUse2.port_b, con2PipUse2.port_aCon) annotation (Line(points={{90,-20},
          {90,-26},{74,-26},{74,-16},{60,-16}}, color={0,127,255}));
  connect(con2PipUse3.port_bCon, ideUse3.port_a) annotation (Line(points={{60,-130},
          {74,-130},{74,-114},{90,-114},{90,-120}}, color={0,127,255}));
  connect(ideUse3.port_b, con2PipUse3.port_aCon) annotation (Line(points={{90,-140},
          {90,-146},{74,-146},{74,-136},{60,-136}}, color={0,127,255}));
  connect(con2PipUse3.port_bDisRet, con2PipPla2.port_bDisSup) annotation (Line(
        points={{44,-120},{44,-108},{50,-108},{50,-100}}, color={0,127,255}));
  connect(con2PipUse3.port_aDisSup, con2PipPla2.port_aDisRet) annotation (Line(
        points={{50,-120},{50,-114},{56,-114},{56,-100}}, color={0,127,255}));
  connect(con2PipUse1.port_bDisRet, pipEnd1.port_a)
    annotation (Line(points={{44,100},{44,120}}, color={0,127,255}));
  connect(con2PipUse1.port_aDisSup, pipEnd1.port_b) annotation (Line(points={{50,100},
          {50,114},{56,114},{56,120}},      color={0,127,255}));
  connect(pipEnd2.port_b, con2PipUse3.port_aDisRet)
    annotation (Line(points={{44,-160},{44,-140}}, color={0,127,255}));
  connect(con2PipUse3.port_bDisSup, pipEnd2.port_a) annotation (Line(points={{50,
          -140},{50,-154},{56,-154},{56,-160}}, color={0,127,255}));
    annotation (__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Storage/Plant/Examples/DualSource.mos"
        "Simulate and plot"),
        experiment(Tolerance=1e-06, StopTime=3600),
        Diagram(coordinateSystem(extent={{-200,-240},{160,200}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})),
    Documentation(info="<html>
<p>
This is a district system model with two CHW plants and three users
with the following architecture:
</p>
<p align=\"center\">
<img alt=\"DualSource\"
src=\"modelica://Buildings/Resources/Images/Fluid/Storage/DualSource.png\"/>
</p>
<p>
The first CHW source is a simplified CHW plant with only a chiller and
a single supply pump.
This supply pump is controlled to ensure that all users have enough pressure head.
</p>
<p>
The second CHW source has a chiller and a stratified CHW tank. Its piping is
arranged in a way that allows the tank to be charged remotely by the other source.
The secondary pump is controlled to maintain the flow rate setpoint of the tank.
This plant is disconnected when the largest position of user control valves
less than 5% open and connected back when this value is higher than 10%.
</p>
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
September 28, 2022 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end DualSource;

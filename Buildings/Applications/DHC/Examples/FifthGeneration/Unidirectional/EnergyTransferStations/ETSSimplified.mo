﻿within Buildings.Applications.DHC.Examples.FifthGeneration.Unidirectional.EnergyTransferStations;
model ETSSimplified
  "Simplified model of a substation producing heating hot water (heat pump) and chilled water (HX)"
  replaceable package Medium =
    Modelica.Media.Interfaces.PartialMedium
    "Medium model for water"
    annotation (choicesAllMatching = true);
  outer
    Buildings.Applications.DHC.Examples.FifthGeneration.Unidirectional.Data.DesignDataSeries
    datDes "DHC systenm design data";
  // SYSTEM GENERAL
  parameter Integer nSup = 0
    "Number of supply lines"
    annotation(Evaluate=true, Dialog(connectorSizing=true));
  parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal(
    min=Modelica.Constants.eps)
    "Design cooling thermal power (always positive)"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)
    "Design heating thermal power (always positive)"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.TemperatureDifference dT_nominal = 5
    "Water temperature drop/increase accross load and source-side HX (always positive)"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature TChiWatSup_nominal = 273.15 + 18
    "Chilled water supply temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature TChiWatRet_nominal=
    TChiWatSup_nominal + dT_nominal
    "Chilled water return temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature THeaWatSup_nominal = 273.15 + 40
    "Heating water supply temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature THeaWatRet_nominal=
    THeaWatSup_nominal - dT_nominal
    "Heating water return temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Pressure dp_nominal(displayUnit="Pa") = 50000
    "Pressure difference at nominal flow rate (for each flow leg)"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mHeaWat_flow_nominal(min=0)=
    abs(QHea_flow_nominal / cp_default / (THeaWatSup_nominal - THeaWatRet_nominal))
    "Heating water mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mChiWat_flow_nominal(min=0)=
    abs(QCoo_flow_nominal / cp_default / (TChiWatSup_nominal - TChiWatRet_nominal))
    "Heating water mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.SpecificHeatCapacity cp_default=
    Medium.specificHeatCapacityCp(Medium.setState_pTX(
      p = Medium.p_default,
      T = Medium.T_default,
      X = Medium.X_default))
    "Specific heat capacity of the fluid";
  final parameter Boolean allowFlowReversal = false
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  // HEAT PUMP
  parameter Real COP_nominal(unit="1") = 5
    "Heat pump COP"
    annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TConLvg_nominal = THeaWatSup_nominal
    "Condenser leaving temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TConEnt_nominal = THeaWatRet_nominal
    "Condenser entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TEvaLvg_nominal=
    TEvaEnt_nominal - dT_nominal
    "Evaporator leaving temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TEvaEnt_nominal = datDes.TLooMin
    "Evaporator entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mCon_flow_nominal(min=0)=
    abs(QHea_flow_nominal / cp_default / (TConLvg_nominal - TConEnt_nominal))
    "Condenser mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mEva_flow_nominal(min=0)=
    abs(heaPum.QEva_flow_nominal / cp_default / (TEvaLvg_nominal - TEvaEnt_nominal))
    "Evaporator mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  // CHW HX
  final parameter Modelica.SIunits.Temperature T1HexChiEnt_nominal=
    datDes.TLooMax
    "CHW HX primary entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature T2HexChiEnt_nominal=
    TChiWatRet_nominal
    "CHW HX secondary entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate m1HexChi_flow_nominal(min=0)=
    abs(QCoo_flow_nominal / cp_default / dT_nominal)
    "CHW HX primary mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate m2HexChi_flow_nominal(min=0)=
    abs(QCoo_flow_nominal / cp_default / (THeaWatSup_nominal - THeaWatRet_nominal))
    "CHW HX secondary mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  // Diagnostics
   parameter Boolean show_T = true
    "= true, if actual temperature at port is computed"
    annotation(Dialog(tab="Advanced",group="Diagnostics"));
  parameter Modelica.Fluid.Types.Dynamics mixingVolumeEnergyDynamics=
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Formulation of energy balance for mixing volume at inlet and outlet"
     annotation(Dialog(tab="Dynamics"));
  // IO CONNECTORS
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = Medium,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connector a"
    annotation (Placement(transformation(extent={{-290,-410},{-270,-390}}),
        iconTransformation(extent={{-300,-20},{-260,20}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = Medium,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connector b"
    annotation (Placement(transformation(extent={{290,-410},{270,-390}}),
        iconTransformation(extent={{300,-20},{260,20}})));
  Modelica.Fluid.Interfaces.FluidPorts_a ports_a1[nSup](
    redeclare each final package Medium = Medium,
    each m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    each h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connectors a (positive design flow direction is from port_a to ports_b)"
    annotation (Placement(transformation(extent={{-290,80},{-270,160}}),
      iconTransformation(extent={{-300,-260},{-260,-100}})));
  Modelica.Fluid.Interfaces.FluidPorts_b ports_b1[nSup](
    redeclare each final package Medium = Medium,
    each m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    each h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connectors b (positive design flow direction is from port_a to ports_b)"
    annotation (Placement(transformation(extent={{270,80},{290,160}}),
      iconTransformation(extent={{260,-260},{300,-100}})));
  Modelica.Blocks.Interfaces.RealInput TSetHeaWat
    "Heating water set point"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,200}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,240})));
  Modelica.Blocks.Interfaces.RealInput TSetChiWat "Chilled water set point"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,40}),   iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,160})));
  Modelica.Blocks.Interfaces.RealOutput mHea_flow
    "District water mass flow rate used for heating service"
    annotation ( Placement(transformation(extent={{280,260},{320,300}}),
        iconTransformation(extent={{280,80},{320,120}})));
  Modelica.Blocks.Interfaces.RealOutput mCoo_flow
    "District water mass flow rate used for cooling service"
    annotation ( Placement(transformation(extent={{280,220},{320,260}}),
        iconTransformation(extent={{280,40},{320,80}})));
  Modelica.Blocks.Interfaces.RealOutput PCom(final unit="W")
    "Power drawn by compressor"
    annotation (Placement(transformation(extent={{280,420},{320,460}}),
        iconTransformation(extent={{280,240},{320,280}})));
  Modelica.Blocks.Interfaces.RealOutput PPum(final unit="W")
    "Power drawn by pumps motors"
    annotation (Placement(transformation(extent={{280,380},{320,420}}),
        iconTransformation(extent={{280,200},{320,240}})));
  Modelica.Blocks.Interfaces.RealOutput PHea(unit="W")
    "Total power consumed for space heating"
    annotation (Placement(transformation(extent={{280,340},{320,380}}),
        iconTransformation(extent={{280,160},{320,200}})));
  Modelica.Blocks.Interfaces.RealOutput PCoo(unit="W")
    "Total power consumed for space cooling"
    annotation (Placement(transformation(extent={{280,300},{320,340}}),
        iconTransformation(extent={{280,120},{320,160}})));
  // COMPONENTS
  Buildings.Fluid.Delays.DelayFirstOrder volMix_a(
    redeclare final package Medium = Medium,
    nPorts=3,
    final m_flow_nominal=(mEva_flow_nominal + m1HexChi_flow_nominal)/2,
    final allowFlowReversal=true,
    tau=600,
    final energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume to break algebraic loops and to emulate the delay of the substation"
    annotation (Placement(transformation(extent={{-270,-400},{-250,-420}})));
  Buildings.Fluid.Delays.DelayFirstOrder volMix_b(
    redeclare final package Medium = Medium,
    nPorts=3,
    final m_flow_nominal=(mEva_flow_nominal + m1HexChi_flow_nominal)/2,
    final allowFlowReversal=true,
    tau=600,
    final energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume to break algebraic loops and to emulate the delay of the substation"
    annotation (Placement(transformation(extent={{250,-400},{270,-420}})));
  Buildings.Fluid.HeatPumps.Carnot_TCon heaPum(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    final m1_flow_nominal=mCon_flow_nominal,
    final m2_flow_nominal=mEva_flow_nominal,
    final dTEva_nominal=TEvaLvg_nominal - TEvaEnt_nominal,
    final dTCon_nominal=TConLvg_nominal - TConEnt_nominal,
    final allowFlowReversal1=false,
    final allowFlowReversal2=allowFlowReversal,
    final use_eta_Carnot_nominal=false,
    final COP_nominal=COP_nominal,
    final QCon_flow_nominal=QHea_flow_nominal,
    final dp1_nominal=dp_nominal,
    final dp2_nominal=dp_nominal)
    "Heat pump (index 1 for condenser side)"
    annotation (Placement(transformation(extent={{10,116},{-10,136}})));
  Networks.BaseClasses.Pump_m_flow pumEva(redeclare final package Medium =
        Medium, final m_flow_nominal=mEva_flow_nominal) "Evaporator pump"
    annotation (Placement(transformation(extent={{-110,110},{-90,130}})));
  Networks.BaseClasses.Pump_m_flow pum1HexChi(redeclare final package Medium =
        Medium, final m_flow_nominal=m1HexChi_flow_nominal)
    "Chilled water HX primary pump"
    annotation (Placement(transformation(extent={{-110,-270},{-90,-250}})));
  Buildings.Fluid.HeatExchangers.DryCoilEffectivenessNTU hexChi(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    final m1_flow_nominal=m1HexChi_flow_nominal,
    final m2_flow_nominal=m2HexChi_flow_nominal,
    final dp1_nominal=dp_nominal/2,
    final dp2_nominal=dp_nominal/2,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    final Q_flow_nominal=QCoo_flow_nominal,
    final T_a1_nominal=T1HexChiEnt_nominal,
    final T_a2_nominal=T2HexChiEnt_nominal,
    final allowFlowReversal1=allowFlowReversal,
    final allowFlowReversal2=allowFlowReversal) "Chilled water HX"
    annotation (Placement(transformation(extent={{-10,-244},{10,-264}})));
  Buildings.Fluid.Delays.DelayFirstOrder volHeaWatRet(
    redeclare final package Medium = Medium,
    nPorts=3,
    m_flow_nominal=mCon_flow_nominal,
    allowFlowReversal=allowFlowReversal,
    tau=60,
    energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume representing HHW primary"
    annotation (Placement(transformation(extent={{12,220},{32,240}})));
  Networks.BaseClasses.Pump_m_flow pumCon(redeclare package Medium = Medium,
      final m_flow_nominal=mCon_flow_nominal) "Condenser pump"
    annotation (Placement(transformation(extent={{110,150},{90,170}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senT2HexChiLvg(
    redeclare final package Medium = Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=m2HexChi_flow_nominal)
    "CHW HX secondary water leaving temperature (sensed)"
    annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-160,-220})));
  Buildings.Controls.OBC.CDL.Continuous.HysteresisWithHold hysWitHol(
    uLow=1E-4*mHeaWat_flow_nominal,
    uHigh=0.01*mHeaWat_flow_nominal,
    trueHoldDuration=0,
    falseHoldDuration=30)
    annotation (Placement(transformation(extent={{-210,270},{-190,290}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloHeaWat(
    redeclare final package Medium = Medium,
    allowFlowReversal=allowFlowReversal)
    "Heating water mass flow rate (sensed)"
    annotation (Placement(transformation(extent={{-230,370},{-210,350}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai(k=mCon_flow_nominal)
    annotation (Placement(transformation(extent={{-140,270},{-120,290}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{-180,270},{-160,290}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai1(k=mEva_flow_nominal)
    annotation (Placement(transformation(extent={{-140,230},{-120,250}})));
  Buildings.Fluid.Delays.DelayFirstOrder volChiWat(
    redeclare final package Medium = Medium,
    nPorts=3,
    m_flow_nominal=m1HexChi_flow_nominal,
    allowFlowReversal=allowFlowReversal,
    tau=60,
    energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume representing CHW primary"
    annotation (Placement(transformation(extent={{10,-160},{30,-140}})));
  Networks.BaseClasses.Pump_m_flow pum2CooHex(redeclare package Medium = Medium,
      final m_flow_nominal=m2HexChi_flow_nominal)
    "Chilled water HX secondary pump"
    annotation (Placement(transformation(extent={{110,-230},{90,-210}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloChiWat(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversal)
    "Chilled water mass flow rate (sensed)"
    annotation (Placement(transformation(extent={{-230,-90},{-210,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.HysteresisWithHold hysWitHol1(
    uLow=1E-4*mChiWat_flow_nominal,
    uHigh=0.01*mChiWat_flow_nominal,
    trueHoldDuration=0,
    falseHoldDuration=30)
    annotation (Placement(transformation(extent={{-212,-10},{-192,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1
    annotation (Placement(transformation(extent={{-186,-10},{-166,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai2(k=m1HexChi_flow_nominal)
    annotation (Placement(transformation(extent={{-140,-10},{-120,10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTConLvg(
    redeclare final package Medium = Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=mCon_flow_nominal)
    "Condenser water leaving temperature (sensed)"
    annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-160,160})));
  Buildings.Controls.OBC.CDL.Continuous.LimPID conTChiWat(
    Ti=120,
    yMax=1,
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    reverseAction=true,
    yMin=0)
    "PI controller for chilled water supply"
    annotation (Placement(transformation(extent={{-170,30},{-150,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Product pro
    annotation (Placement(transformation(extent={{-88,-10},{-68,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai4(k=1.1)
    annotation (Placement(transformation(extent={{-140,-50},{-120,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(nin=1)
    annotation (Placement(transformation(extent={{230,310},{250,330}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum1(nin=1)
    annotation (Placement(transformation(extent={{230,350},{250,370}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PPumHea(nin=2)
    "Total power drawn by pumps motors for space heating (ETS included, building excluded)"
    annotation (Placement(transformation(extent={{170,410},{190,430}})));
  Buildings.Fluid.Sources.Boundary_pT bouHea(
    redeclare final package Medium = Medium, nPorts=1)
    "Pressure boundary condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{60,230},{40,250}})));
  Buildings.Fluid.Sources.Boundary_pT bouChi(
    redeclare final package Medium = Medium, nPorts=1)
              "Pressure boundary condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{60,-150},{40,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PPumCoo(nin=2)
    "Total power drawn by pumps motors for space cooling (ETS included, building excluded)"
    annotation (Placement(transformation(extent={{170,370},{190,390}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum2(nin=2)
    annotation (Placement(transformation(extent={{230,390},{250,410}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTHeaWatSup(
    redeclare final package Medium=Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=mHeaWat_flow_nominal)
    "Heating water supply temperature (sensed)" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={40,360})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTChiWatSup(
    redeclare final package Medium=Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=mHeaWat_flow_nominal)
    "Chilled water supply temperature (sensed)" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={40,-80})));
  Buildings.Applications.DHC.EnergyTransferStations.BaseClasses.HydraulicHeader
  decHeaWat(
    redeclare final package Medium=Medium,
    m_flow_nominal=mHeaWat_flow_nominal,
    nPorts_a=2,
    nPorts_b=2) "Primary-secondary decoupler"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,350})));
  Buildings.Applications.DHC.EnergyTransferStations.BaseClasses.HydraulicHeader
  decChiWat(
    redeclare final package Medium=Medium,
    m_flow_nominal=mChiWat_flow_nominal,
    nPorts_a=2,
    nPorts_b=2) "Primary-secondary decoupler"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,-90})));
  // MISCELLANEOUS VARIABLES
  Medium.ThermodynamicState sta_a=if allowFlowReversal then
    Medium.setState_phX(port_a.p,
      noEvent(actualStream(port_a.h_outflow)),
      noEvent(actualStream(port_a.Xi_outflow))) else
  Medium.setState_phX(port_a.p,
      inStream(port_a.h_outflow),
      inStream(port_a.Xi_outflow)) if show_T
    "Medium properties in port_a";
  Medium.ThermodynamicState sta_b=if allowFlowReversal then
    Medium.setState_phX(port_b.p,
      noEvent(actualStream(port_b.h_outflow)),
      noEvent(actualStream(port_b.Xi_outflow))) else
    Medium.setState_phX(port_b.p,
      port_b.h_outflow,
      port_b.Xi_outflow) if  show_T
    "Medium properties in port_b";
initial equation
  assert(QCoo_flow_nominal > 0,
    "In " + getInstanceName() +
    "Nominal cooling rate must be strictly positive. Obtained QCoo_flow_nominal = " +
    String(QCoo_flow_nominal));
  assert(QHea_flow_nominal > 0,
    "In " + getInstanceName() +
    "Nominal heating rate must be strictly positive. Obtained QHea_flow_nominal = " +
    String(QHea_flow_nominal));
equation
  connect(volMix_a.ports[1], port_a) annotation (Line(points={{-262.667,-400},{
          -280,-400}},       color={0,127,255}));
  connect(pumEva.port_a, volMix_a.ports[2])
    annotation (Line(points={{-110,120},{-260,120},{-260,-400}},
                                                           color={0,127,255}));
  connect(port_b, volMix_b.ports[1]) annotation (Line(points={{280,-400},{
          257.333,-400}},
                color={0,127,255}));
  connect(senMasFloHeaWat.m_flow, hysWitHol.u) annotation (Line(points={{-220,349},
          {-220,280},{-212,280}}, color={0,0,127}));
  connect(TSetHeaWat, heaPum.TSet) annotation (Line(points={{-300,200},{20,200},
          {20,135},{12,135}}, color={0,0,127}));
  connect(hysWitHol.y, booToRea.u)
    annotation (Line(points={{-188,280},{-182,280}}, color={255,0,255}));
  connect(booToRea.y, gai.u)
    annotation (Line(points={{-158,280},{-142,280}}, color={0,0,127}));
  connect(gai.y, pumCon.m_flow_in) annotation (Line(points={{-118,280},{100,280},
          {100,172}},  color={0,0,127}));
  connect(gai1.y, pumEva.m_flow_in)
    annotation (Line(points={{-118,240},{-100,240},{-100,132}},
                                                             color={0,0,127}));
  connect(booToRea.y, gai1.u) annotation (Line(points={{-158,280},{-150,280},{-150,
          240},{-142,240}},
                          color={0,0,127}));
  connect(senMasFloChiWat.m_flow, hysWitHol1.u) annotation (Line(points={{-220,-69},
          {-220,0},{-214,0}},       color={0,0,127}));
  connect(hysWitHol1.y, booToRea1.u)
    annotation (Line(points={{-190,0},{-188,0}},       color={255,0,255}));
  connect(booToRea1.y, gai2.u)
    annotation (Line(points={{-164,0},{-142,0}},       color={0,0,127}));
  connect(senT2HexChiLvg.T, conTChiWat.u_m) annotation (Line(points={{-160,-209},
          {-160,28}},                        color={0,0,127}));
  connect(TSetChiWat, conTChiWat.u_s) annotation (Line(points={{-300,40},{-172,40}},
                  color={0,0,127}));
  connect(gai2.y, pro.u2) annotation (Line(points={{-118,0},{-100,0},{-100,-6},{
          -90,-6}},          color={0,0,127}));
  connect(pro.y, pum1HexChi.m_flow_in)
    annotation (Line(points={{-66,0},{-60,0},{-60,-60},{-100,-60},{-100,-248}},
                                                            color={0,0,127}));
  connect(conTChiWat.y, pro.u1) annotation (Line(points={{-148,40},{-100,40},{-100,
          6},{-90,6}},             color={0,0,127}));
  connect(gai4.y, pum2CooHex.m_flow_in) annotation (Line(points={{-118,-40},{100,
          -40},{100,-208}},   color={0,0,127}));
  connect(senMasFloChiWat.m_flow, gai4.u) annotation (Line(points={{-220,-69},{-220,
          -40},{-142,-40}},        color={0,0,127}));
  connect(PPum, PPum)
    annotation (Line(points={{300,400},{300,400}}, color={0,0,127}));
  connect(heaPum.P, PCom) annotation (Line(points={{-11,126},{-28,126},{-28,100},
          {160,100},{160,440},{300,440}},
                 color={0,0,127}));
  connect(mulSum.y, PCoo)
    annotation (Line(points={{252,320},{300,320}}, color={0,0,127}));
  connect(mulSum1.y, PHea)
    annotation (Line(points={{252,360},{300,360}}, color={0,0,127}));
  connect(pumCon.P, PPumHea.u[1]) annotation (Line(points={{89,169},{40,169},{40,
          200},{168,200},{168,421}},     color={0,0,127}));
  connect(pumEva.P, PPumHea.u[2]) annotation (Line(points={{-89,129},{-89,128},{
          -80,128},{-80,180},{162,180},{162,420},{168,420},{168,419}},
                                              color={0,0,127}));
  connect(pum1HexChi.P, PPumCoo.u[1]) annotation (Line(points={{-89,-251},{-78,-251},
          {-78,-278},{160,-278},{160,381},{168,381}},
                                          color={0,0,127}));
  connect(pum2CooHex.P, PPumCoo.u[2]) annotation (Line(points={{89,-211},{80,-211},
          {80,2},{162,2},{162,379},{168,379}},                  color={0,0,127}));
  connect(PPumHea.y, mulSum1.u[1]) annotation (Line(points={{192,420},{220,420},
          {220,360},{228,360}}, color={0,0,127}));
  connect(PPumCoo.y, mulSum.u[1]) annotation (Line(points={{192,380},{210,380},{
          210,320},{228,320}}, color={0,0,127}));
  connect(PPumHea.y, mulSum2.u[1]) annotation (Line(points={{192,420},{200,420},
          {200,401},{228,401}}, color={0,0,127}));
  connect(PPumCoo.y, mulSum2.u[2]) annotation (Line(points={{192,380},{200,380},
          {200,340},{214,340},{214,399},{228,399}},
                                color={0,0,127}));
  connect(mulSum2.y, PPum)
    annotation (Line(points={{252,400},{300,400}}, color={0,0,127}));
  connect(pum1HexChi.port_b, hexChi.port_a1) annotation (Line(points={{-90,-260},
          {-10,-260}},                             color={0,127,255}));
  connect(hexChi.port_b1, volMix_b.ports[2]) annotation (Line(points={{10,-260},
          {260,-260},{260,-400}},                      color={0,127,255}));
  connect(pum2CooHex.port_b, hexChi.port_a2)
    annotation (Line(points={{90,-220},{20,-220},{20,-248},{10,-248}},
                                                  color={0,127,255}));
  connect(hexChi.port_b2, senT2HexChiLvg.port_a)
    annotation (Line(points={{-10,-248},{-20,-248},{-20,-220},{-150,-220}},
                                                      color={0,127,255}));
  connect(volMix_a.ports[3], pum1HexChi.port_a) annotation (Line(points={{
          -257.333,-400},{-260,-400},{-260,-260},{-110,-260}},
                                                         color={0,127,255}));
  connect(pumEva.port_b, heaPum.port_a2)
    annotation (Line(points={{-90,120},{-10,120}}, color={0,127,255}));
  connect(heaPum.port_b2, volMix_b.ports[3]) annotation (Line(points={{10,120},
          {260,120},{260,-398},{262,-398},{262,-400},{262.667,-400}},
                                               color={0,127,255}));
  connect(heaPum.port_b1, senTConLvg.port_a) annotation (Line(points={{-10,132},
          {-30,132},{-30,160},{-150,160}},     color={0,127,255}));
  connect(pumCon.port_b, heaPum.port_a1) annotation (Line(points={{90,160},{40,160},
          {40,132},{10,132}},         color={0,127,255}));
  connect(ports_a1[1], senMasFloHeaWat.port_a) annotation (Line(points={{-280,120},
          {-240,120},{-240,360},{-230,360}}, color={0,127,255}));
  connect(ports_a1[2], senMasFloChiWat.port_a) annotation (Line(points={{-280,120},
          {-240,120},{-240,-80},{-230,-80}},   color={0,127,255}));
  connect(senTHeaWatSup.port_b, ports_b1[1]) annotation (Line(points={{50,360},{
          180,360},{180,120},{280,120}}, color={0,127,255}));
  connect(senTChiWatSup.port_b, ports_b1[2]) annotation (Line(points={{50,-80},{
          240,-80},{240,120},{280,120}},   color={0,127,255}));
  connect(pum1HexChi.m_flow_actual, mCoo_flow) annotation (Line(points={{-89,-255},
          {-80,-255},{-80,-280},{162,-280},{162,240},{300,240}}, color={0,0,127}));
  connect(pumEva.m_flow_actual, mHea_flow) annotation (Line(points={{-89,125},{-78,
          125},{-78,180},{162,180},{162,280},{300,280}}, color={0,0,127}));
  connect(bouHea.ports[1], volHeaWatRet.ports[1]) annotation (Line(points={{40,240},
          {40,220},{19.3333,220}}, color={0,127,255}));
  connect(bouChi.ports[1], volChiWat.ports[1]) annotation (Line(points={{40,-140},
          {40,-160},{17.3333,-160}},
                                  color={0,127,255}));
  connect(volHeaWatRet.ports[2], pumCon.port_a) annotation (Line(points={{22,220},
          {140,220},{140,160},{110,160}},      color={0,127,255}));
  connect(volChiWat.ports[2], pum2CooHex.port_a) annotation (Line(points={{20,-160},
          {140,-160},{140,-220},{110,-220}},       color={0,127,255}));
  connect(senTConLvg.port_b, decHeaWat.ports_a[1]) annotation (Line(points={{
          -170,160},{-200,160},{-200,220},{-20,220},{-20,360},{2,360}}, color={
          0,127,255}));
  connect(decHeaWat.ports_a[2], senTHeaWatSup.port_a) annotation (Line(points={
          {-2,360},{14.85,360},{14.85,360},{30,360}}, color={0,127,255}));
  connect(senMasFloHeaWat.port_b, decHeaWat.ports_b[1]) annotation (Line(points=
         {{-210,360},{-40,360},{-40,340},{-2,340}}, color={0,127,255}));
  connect(decHeaWat.ports_b[2], volHeaWatRet.ports[3]) annotation (Line(points={{2,340},
          {0,340},{0,220},{24.6667,220}},          color={0,127,255}));
  connect(decChiWat.ports_a[1], senTChiWatSup.port_a) annotation (Line(points={
          {2,-80},{14.85,-80},{14.85,-80},{30,-80}}, color={0,127,255}));
  connect(senT2HexChiLvg.port_b, decChiWat.ports_a[2]) annotation (Line(points=
          {{-170,-220},{-220,-220},{-220,-160},{-20,-160},{-20,-80},{-2,-80}},
        color={0,127,255}));
  connect(senMasFloChiWat.port_b, decChiWat.ports_b[1]) annotation (Line(points=
         {{-210,-80},{-40,-80},{-40,-100},{-2,-100}}, color={0,127,255}));
  connect(decChiWat.ports_b[2], volChiWat.ports[3]) annotation (Line(points={{2,-100},
          {0,-100},{0,-160},{22.6667,-160}},       color={0,127,255}));
  annotation (
  defaultComponentName="ets",
  Documentation(info="<html>
<p>
Heating hot water is produced at low temperature (typically 40°C) with a water-to-water heat pump.
Chilled water is produced at high temperature (typically 19°C) with a heat exchanger.
</p>
<p>
The time series data are interpolated using
Fritsch-Butland interpolation. This uses
cubic Hermite splines such that y preserves the monotonicity and
der(y) is continuous, also if extrapolated.
</p>
<p>
There is a control volume at each of the two fluid ports
that are exposed by this model. These approximate the dynamics
of the substation, and they also generally avoid nonlinear system
of equations if multiple substations are connected to each other.
</p>
</html>",
  revisions="<html>
<ul>
<li>
December 12, 2017, by Michael Wetter:<br/>
Removed call to <code>Modelica.Utilities.Files.loadResource</code>.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1097\">issue 1097</a>.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-280,-280},{280,280}}, preserveAspectRatio=false),
     graphics={Rectangle(
        extent={{-280,-280},{280,280}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{18,-38},{46,-10}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-169,-344},{131,-384}},
          lineColor={0,0,255},
          textString="%name"),
        Rectangle(
          extent={{-280,0},{280,8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-280,0},{280,-8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(extent={{-280,-460},{280,460}},
          preserveAspectRatio=false), graphics={Text(
          extent={{-106,-16},{-38,-44}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="Add minimum pump flow rate")}));
end ETSSimplified;

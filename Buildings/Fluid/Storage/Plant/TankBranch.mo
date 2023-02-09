within Buildings.Fluid.Storage.Plant;
model TankBranch
  "Model of the tank branch of a storage plant"

  replaceable package Medium =
    Modelica.Media.Interfaces.PartialMedium "Medium package";

  parameter Buildings.Fluid.Storage.Plant.Data.NominalValues nom
    "Nominal values";

  // Storage tank parameters
  parameter Modelica.Units.SI.Volume VTan "Tank volume";
  parameter Modelica.Units.SI.Length hTan "Height of tank (without insulation)";
  parameter Modelica.Units.SI.Length dIns "Thickness of insulation";
  parameter Modelica.Units.SI.ThermalConductivity kIns=0.04
    "Specific heat conductivity of insulation";
  parameter Integer nSeg(min=2) = 2 "Number of volume segments";
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Formulation of energy balance"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Conservation equations"));
  parameter Medium.AbsolutePressure p_start = Medium.p_default
    "Start value of pressure"
    annotation(Dialog(tab = "Initialization"));
  parameter Medium.Temperature T_start=nom.T_CHWS_nominal
    "Start value of temperature"
    annotation(Dialog(tab = "Initialization"));
  parameter Modelica.Units.SI.Temperature TFlu_start[nSeg]=T_start*ones(nSeg)
    "Initial temperature of the tank segments, with TFlu_start[1] being the top segment"
    annotation (Dialog(tab="Initialization"));
  parameter Modelica.Units.SI.Time tau=1 "Time constant for mixing";

  Modelica.Fluid.Interfaces.FluidPort_a port_aRetNet(
    redeclare final package Medium = Medium,
    p(final displayUnit="Pa"))
    "Port that connects to the return side of the district network"
    annotation (Placement(transformation(extent={{90,-70},{110,-50}}),
        iconTransformation(extent={{90,-70},{110,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bSupNet(redeclare final package
      Medium = Medium, p(final displayUnit="Pa"))
    "Port that connects to the supply side of the district network" annotation
    (Placement(transformation(extent={{90,50},{110,70}}), iconTransformation(
          extent={{90,50},{110,70}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bRetChi(redeclare final package
      Medium = Medium, p(final displayUnit="Pa"))
    "Port that connects to the return side of the chiller" annotation (
      Placement(transformation(extent={{-110,-70},{-90,-50}}),
        iconTransformation(extent={{-110,-70},{-90,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_aSupChi(
    redeclare final package Medium = Medium,
    p(final displayUnit="Pa"))
    "Port that connects to the supply side of the chiller"  annotation (
      Placement(transformation(extent={{-110,50},{-90,70}}), iconTransformation(
          extent={{-110,50},{-90,70}})));

  Buildings.Fluid.Storage.Stratified tan(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true,
    final VTan=VTan,
    final hTan=hTan,
    final dIns=dIns,
    final kIns=kIns,
    final nSeg=nSeg,
    final energyDynamics=energyDynamics,
    final p_start=p_start,
    final T_start=T_start,
    final TFlu_start=TFlu_start,
    final tau=tau,
    final m_flow_nominal=nom.mTan_flow_nominal,
    show_T=true) "Tank"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Fluid.Sensors.MassFlowRate senFlo(redeclare final package Medium =
        Medium, final allowFlowReversal=true) "Flow rate sensor for the tank,"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,-30})));
  Modelica.Blocks.Interfaces.RealOutput mTan_flow "Mass flow rate of the tank"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,110}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={40,110})));
  Modelica.Blocks.Interfaces.RealOutput Ql_flow
    "Heat loss of tank (positive if heat flows from tank to ambient)"
    annotation (Placement(transformation(extent={{100,0},{120,20}}),
        iconTransformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={80,-110})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorTop
    "Heat port tank top (outside insulation)"
    annotation (Placement(transformation(extent={{14,22},{26,34}}),
        iconTransformation(extent={{14,34},{26,46}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorSid
    "Heat port tank side (outside insulation)"
    annotation (Placement(transformation(extent={{34,-36},{46,-24}}),
        iconTransformation(extent={{26,-6},{38,6}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorBot
    "Heat port tank bottom (outside insulation). Leave unconnected for adiabatic condition"
    annotation (Placement(transformation(extent={{14,-56},{26,-44}}),
        iconTransformation(extent={{14,-46},{26,-34}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[tan.nSeg] heaPorVol
    "Heat port that connects to the control volumes of the tank"
    annotation (Placement(transformation(extent={{-26,-36},{-14,-24}}),
        iconTransformation(extent={{-6,-6},{6,6}})));
  Buildings.Fluid.FixedResistances.Junction junSup(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=nom.T_CHWS_nominal,
    tau=30,
    m_flow_nominal={-nom.mChi_flow_nominal,nom.mTan_flow_nominal,nom.m_flow_nominal},
    dp_nominal={0,0,0}) "Junction on the supply side"
    annotation (Placement(transformation(extent={{40,50},{60,70}})));
  Buildings.Fluid.FixedResistances.Junction junRet(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=nom.T_CHWR_nominal,
    tau=30,
    m_flow_nominal={-nom.m_flow_nominal,nom.mChi_flow_nominal,nom.mTan_flow_nominal},
    dp_nominal={0,0,0}) "Junction on the return side" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-50,-60})));
equation
  connect(senFlo.m_flow, mTan_flow) annotation (Line(points={{-61,-30},{-66,-30},
          {-66,80},{50,80},{50,110}}, color={0,0,127}));
  connect(tan.Ql_flow, Ql_flow)
    annotation (Line(points={{11,7.2},{11,10},{110,10}},
                                                       color={0,0,127}));
  connect(tan.heaPorTop, heaPorTop) annotation (Line(points={{2,7.4},{2,16},{20,
          16},{20,28}}, color={191,0,0}));
  connect(tan.heaPorSid, heaPorSid) annotation (Line(points={{5.6,0},{6,0},{6,
          -30},{40,-30}},   color={191,0,0}));
  connect(tan.heaPorBot, heaPorBot)
    annotation (Line(points={{2,-7.4},{2,-50},{20,-50}}, color={191,0,0}));
  connect(heaPorVol, tan.heaPorVol) annotation (Line(points={{-20,-30},{-8,-30},
          {-8,-4},{0,-4},{0,0}}, color={191,0,0}));
  connect(port_aSupChi, junSup.port_1)
    annotation (Line(points={{-100,60},{40,60}}, color={0,127,255}));
  connect(junSup.port_2, port_bSupNet)
    annotation (Line(points={{60,60},{100,60}}, color={0,127,255}));
  connect(port_bRetChi, junRet.port_2)
    annotation (Line(points={{-100,-60},{-60,-60}}, color={0,127,255}));
  connect(junRet.port_3, senFlo.port_a)
    annotation (Line(points={{-50,-50},{-50,-40}}, color={0,127,255}));
  connect(junRet.port_1,port_aRetNet)
    annotation (Line(points={{-40,-60},{100,-60}}, color={0,127,255}));
  connect(senFlo.port_b, tan.port_a)
    annotation (Line(points={{-50,-20},{-50,0},{-10,0}}, color={0,127,255}));
  connect(tan.port_b, junSup.port_3)
    annotation (Line(points={{10,0},{50,0},{50,50}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}),       graphics={
                               Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{-100,-60},{100,-60}}, color={28,108,200}),
        Line(points={{-100,60},{100,60}}, color={28,108,200}),
        Line(points={{-42,-60}}, color={28,108,200}),
        Line(points={{-60,-58},{-60,50},{0,50},{0,-52},{60,-52},{60,60}}, color
            ={28,108,200}),
        Rectangle(
          extent={{-28,40},{32,-40}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{38,0},{80,0},{80,-100}},
          color={127,0,0},
          pattern=LinePattern.Dot),
        Line(
          points={{26,-44},{52,-44},{52,0}},
          color={127,0,0},
          pattern=LinePattern.Dot),
        Line(
          points={{26,44},{52,44},{52,-2}},
          color={127,0,0},
          pattern=LinePattern.Dot)}),                            Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})),
    defaultComponentName = "tanBra",
    Documentation(info="<html>
<p>
This model is part of a storage plant model. This branch has a stratified tank.
This tank can potentially be charged remotely by a chiller from the district
CHW network other than its own local chiller.
</p>
</html>", revisions="<html>
<ul>
<li>
October 4, 2022 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end TankBranch;

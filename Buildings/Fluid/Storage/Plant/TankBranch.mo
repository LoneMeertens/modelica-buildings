within Buildings.Fluid.Storage.Plant;
model TankBranch
  "Model of the tank branch of a storage plant"
  extends Buildings.Fluid.Storage.Plant.BaseClasses.PartialBranchPorts;

  parameter Modelica.Units.SI.Temperature TTan_start=nom.T_CHWS_nominal
    "Start temperature of the tank";

  Buildings.Fluid.Storage.Stratified tan(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true,
    hTan=3,
    dIns=0.3,
    VTan=10,
    nSeg=7,
    show_T=true,
    m_flow_nominal=nom.mTan_flow_nominal,
    final T_start=TTan_start,
    TFlu_start=linspace(
        nom.T_CHWR_nominal,
        nom.T_CHWS_nominal,
        tan.nSeg)) "Tank"
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
  connect(port_aFroChi, junSup.port_1)
    annotation (Line(points={{-100,60},{40,60}}, color={0,127,255}));
  connect(junSup.port_2, port_bToNet)
    annotation (Line(points={{60,60},{100,60}}, color={0,127,255}));
  connect(port_bToChi, junRet.port_2)
    annotation (Line(points={{-100,-60},{-60,-60}}, color={0,127,255}));
  connect(junRet.port_3, senFlo.port_a)
    annotation (Line(points={{-50,-50},{-50,-40}}, color={0,127,255}));
  connect(junRet.port_1, port_aFroNet)
    annotation (Line(points={{-40,-60},{100,-60}}, color={0,127,255}));
  connect(senFlo.port_b, tan.port_a)
    annotation (Line(points={{-50,-20},{-50,0},{-10,0}}, color={0,127,255}));
  connect(tan.port_b, junSup.port_3)
    annotation (Line(points={{10,0},{50,0},{50,50}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}),       graphics={
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

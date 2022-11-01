within Buildings.Fluid.Storage.Plant.Examples.BaseClasses;
model ChillerBranch
  "A branch with a pump, a check valve, and a chiller"
  replaceable package Medium =
    Modelica.Media.Interfaces.PartialMedium "Medium package";
  package MediumCDW = Buildings.Media.Water "Medium model for CDW";

  parameter Buildings.Fluid.Storage.Plant.Data.NominalValues nom
    "Nominal values";

  Modelica.Units.SI.MassFlowRate m_flow=pum.m_flow "Mass flow rate";

  Buildings.Fluid.Movers.FlowControlled_m_flow pum(
    redeclare final package Medium = Medium,
    per(pressure(dp=preDro.dp_nominal*{2,0},
                 V_flow=nom.mChi_flow_nominal/1000*{0,2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=nom.mChi_flow_nominal,
    allowFlowReversal=true,
    addPowerToMedium=false,
    m_flow_start=0,
    T_start=nom.T_CHWR_nominal) "Primary CHW pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,-50})));
  Buildings.Fluid.FixedResistances.PressureDrop preDro(
    redeclare final package Medium = Medium,
    final m_flow_nominal=nom.mChi_flow_nominal,
    dp_nominal=0.1*nom.dp_nominal) "Pressure drop of the chiller branch"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,-10})));
  Buildings.Fluid.Chillers.ElectricEIR chi(
    redeclare final package Medium1 = MediumCDW,
    redeclare final package Medium2 = Medium,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    p2_start=500000,
    T2_start=nom.T_CHWS_nominal,
    final per=perChi)
    "Water cooled chiller (ports indexed 1 are on condenser side)"
    annotation (Placement(transformation(extent={{20,20},{0,40}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant on(final k=true)
    "Placeholder, chiller always on"
    annotation (Placement(transformation(extent={{20,-40},{40,-20}})));
  Modelica.Blocks.Sources.Constant set_TEvaLvg(final k=nom.T_CHWS_nominal)
    "Evaporator leaving temperature setpoint" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={30,0})));
  Buildings.Fluid.Sources.MassFlowSource_T souCDW(
    redeclare final package Medium = MediumCDW,
    final m_flow=1.2*nom.m_flow_nominal,
    final T=305.15,
    nPorts=1) "Source representing CDW supply line" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={30,70})));
  Buildings.Fluid.Sources.Boundary_pT sinCDW(
    redeclare final package Medium = MediumCDW,
    final p=300000,
    final T=310.15,
    nPorts=1) "Sink representing CDW return line" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=90,
        origin={-10,70})));
  Modelica.Blocks.Interfaces.RealInput mPumSet_flow
    "Primary pump mass flow rate setpoint" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-20,-110}),iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={40,-110})));
  replaceable parameter
      Buildings.Fluid.Chillers.Data.ElectricEIR.Generic perChi(
    QEva_flow_nominal=-1E6,
    COP_nominal=3,
    PLRMax=1,
    PLRMinUnl=0.3,
    PLRMin=0.3,
    etaMotor=1,
    mEva_flow_nominal=nom.m_flow_nominal,
    mCon_flow_nominal=1.2*perChi.mEva_flow_nominal,
    TEvaLvg_nominal=nom.T_CHWS_nominal,
    capFunT={1,0,0,0,0,0},
    EIRFunT={1,0,0,0,0,0},
    EIRFunPLR={1,0,0},
    TEvaLvgMin=nom.T_CHWS_nominal-4,
    TEvaLvgMax=nom.T_CHWS_nominal+8,
    TConEnt_nominal=310.15,
    TConEntMin=303.15,
    TConEntMax=333.15)
    "Chiller performance data"
    annotation (choicesAllMatching=true,
      Placement(transformation(extent={{-80,60},{-60,80}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    p(start=Medium.p_default),
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{90,-70},{110,-50}}),
        iconTransformation(extent={{90,-70},{110,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    p(start=Medium.p_default),
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{110,50},{90,70}}),
        iconTransformation(extent={{110,50},{90,70}})));
equation
  connect(on.y, chi.on) annotation (Line(points={{42,-30},{48,-30},{48,33},{22,33}},
                color={255,0,255}));
  connect(set_TEvaLvg.y, chi.TSet) annotation (Line(points={{41,0},{46,0},{46,27},
          {22,27}},   color={0,0,127}));
  connect(pum.m_flow_in, mPumSet_flow)
    annotation (Line(points={{-12,-50},{-20,-50},{-20,-110}},
                                                           color={0,0,127}));
  connect(souCDW.ports[1], chi.port_a1)
    annotation (Line(points={{30,60},{30,36},{20,36}}, color={0,127,255}));
  connect(sinCDW.ports[1], chi.port_b1)
    annotation (Line(points={{-10,60},{-10,36},{0,36}},color={0,127,255}));
  connect(pum.port_a, port_a) annotation (Line(points={{-5.55112e-16,-60},{100,-60}},
        color={0,127,255}));
  connect(chi.port_b2, port_b) annotation (Line(points={{20,24},{86,24},{86,60},
          {100,60}}, color={0,127,255}));
  connect(chi.port_a2, preDro.port_b) annotation (Line(points={{0,24},{0,12},{6.10623e-16,
          12},{6.10623e-16,0}}, color={0,127,255}));
  connect(preDro.port_a, pum.port_b) annotation (Line(points={{-5.55112e-16,-20},
          {0,-34},{6.10623e-16,-34},{6.10623e-16,-40}}, color={0,127,255}));
  annotation (Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{100,60},{0,60},{0,20}},
          color={28,108,200},
          thickness=1),
        Text(
          extent={{-18,-94},{42,-74}},
          textColor={0,0,255},
          textString="m_flow"),
        Line(
          points={{100,-60},{0,-60},{0,28}},
          color={28,108,200},
          thickness=1),
        Ellipse(extent={{-20,20},{20,-20}},lineColor={0,0,0},
          origin={0,28},
          rotation=90,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{64,35},{56,5}}, color={0,0,0},
          origin={47,52},
          rotation=180),
        Line(points={{-35,-64},{-5,-56}},
                                      color={0,0,0},
          origin={73,12},
          rotation=-90),
        Ellipse(extent={{-20,20},{20,-20}},  lineColor={0,0,0},
          origin={0,-28},
          rotation=90,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(points={{-16,16},{-16,-16},{16,0},{-16,16}},  lineColor={0,0,0},
          origin={0,-24},
          rotation=90)}),
    defaultComponentName = "chiBra",
    Documentation(info="<html>
<p>
This is a simple chiller branch model used by example models under
<a href=\"Modelica://Buildings.Fluid.Storage.Plant.Examples\">
Buildings.Fluid.Storage.Plant.Examples</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
May 16, 2022 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end ChillerBranch;

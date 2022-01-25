within Buildings.Fluid.Movers.Examples;
model StaticReset
  "Comparing different computation paths with a static pressure reset"
  extends Modelica.Icons.Example;

  package Medium = Buildings.Media.Air;
  Buildings.Fluid.Movers.Data.Fans.EnglanderNorford1992.Supply per1
    "Performance record for PowerCharacteristic";
  Buildings.Fluid.Movers.Data.Generic per2(
    pressure=per1.pressure,
    powMet=
      Buildings.Fluid.Movers.BaseClasses.Types.PowerMethod.EulerNumber,
    peak=Buildings.Fluid.Movers.BaseClasses.Euler.getPeak(
      pressure=per1.pressure,
      power=per1.power))
    "Performance record for EulerNumber";
  Buildings.Fluid.Movers.Data.Generic per3(
    pressure=per1.pressure,
    powMet=
      Buildings.Fluid.Movers.BaseClasses.Types.PowerMethod.MotorEfficiency,
    hydraulicEfficiency(eta = {1}),
    motorEfficiency(eta = {per2.peak.eta}))
    "Performance record for MotorEfficiency";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=25/1.2
    "Nominal mass flow rate, see documentation";
  parameter Modelica.Units.SI.PressureDifference dp_nominal=1244.2
    "Nominal pressure rise, see documentation";

  Buildings.Fluid.Sources.Boundary_pT sou(
    redeclare package Medium = Medium,
    use_p_in=false,
    p=101325,
    T=293.15,
    nPorts=6) "Boundary"
    annotation (Placement(transformation(extent={{-100,-90},{-80,-70}})));
  Buildings.Fluid.Sources.Boundary_pT sin(
    redeclare package Medium = Medium,
    use_p_in=false,
    p=101325,
    T=293.15,
    nPorts=3) "Boundary"
    annotation (Placement(transformation(extent={{160,-90},{140,-70}})));

  Buildings.Fluid.Movers.SpeedControlled_y fan1(
    redeclare package Medium = Medium,
    per = per1,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Fan using PowerCharacteristic"
    annotation (Placement(transformation(extent={{-10,170},{10,190}})));
  Buildings.Fluid.Movers.SpeedControlled_y fan2(
    redeclare package Medium = Medium,
    per = per2,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Fan using EulerNumber"
    annotation (Placement(transformation(extent={{-10,70},{10,90}})));
  Buildings.Fluid.Movers.SpeedControlled_y fan3(
    redeclare package Medium = Medium,
    per = per3,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Fan using MotorEfficiency"
    annotation (Placement(transformation(extent={{-10,-30},{10,-10}})));

  Buildings.Fluid.FixedResistances.PressureDrop dp11(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal/2)
    "Duct pressure drop before the static pressure measurement point"
    annotation (Placement(transformation(extent={{20,170},{40,190}})));
  Buildings.Fluid.FixedResistances.PressureDrop dp12(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal/2)
    "Duct pressure drop after the static pressure measurement point"
    annotation (Placement(transformation(extent={{60,170},{80,190}})));
  Buildings.Fluid.FixedResistances.PressureDrop dp21(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal/2)
    "Duct pressure drop before the static pressure measurement point"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Buildings.Fluid.FixedResistances.PressureDrop dp22(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal/2)
    "Duct pressure drop after the static pressure measurement point"
    annotation (Placement(transformation(extent={{60,70},{80,90}})));
  Buildings.Fluid.FixedResistances.PressureDrop dp31(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal/2)
    "Duct pressure drop before the static pressure measurement point"
    annotation (Placement(transformation(extent={{20,-30},{40,-10}})));
  Buildings.Fluid.FixedResistances.PressureDrop dp32(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal/2)
    "Duct pressure drop after the static pressure measurement point"
    annotation (Placement(transformation(extent={{60,-30},{80,-10}})));

  Buildings.Controls.Continuous.LimPID conPID1(
    Td=1,
    k=0.5,
    Ti=15,
    yMax=2) "PI controller"
    annotation (Placement(transformation(extent={{-60,202},{-40,222}})));
  Buildings.Controls.Continuous.LimPID conPID2(
    Td=1,
    k=0.5,
    Ti=15,
    yMax=2) "PI controller"
    annotation (Placement(transformation(extent={{-60,100},{-40,120}})));
  Buildings.Controls.Continuous.LimPID conPID3(
    Td=1,
    k=0.5,
    Ti=15,
    yMax=2) "PI controller"
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));

  Buildings.Fluid.Sensors.RelativePressure pDucSta1(
    redeclare package Medium = Medium)
    "Duct static pressure"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-50,152})));
  Buildings.Fluid.Sensors.RelativePressure pDucSta2(
    redeclare package Medium = Medium)
    "Duct static pressure"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-50,50})));
  Buildings.Fluid.Sensors.RelativePressure pDucSta3(
    redeclare package Medium = Medium)
    "Duct static pressure"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-50,-50})));

  Buildings.Controls.OBC.CDL.Continuous.Gain gai1(k=1/dp_nominal) "Gain"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,180})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai2(k=1/dp_nominal) "Gain"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,78})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai3(k=1/dp_nominal) "Gain"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,-22})));

  BaseClasses.IdealSource ideSou1(
    redeclare final package Medium = Medium,
    final dp_start=0,
    final m_flow_start=m_flow_nominal,
    final show_T=false,
    final show_V_flow=false,
    final control_m_flow=true,
    final control_dp=false,
    final allowFlowReversal=false,
    final m_flow_small=m_flow_nominal*1E-5)
    "Ideal source to force a flow rate"
    annotation (Placement(transformation(extent={{100,170},{120,190}})));
  BaseClasses.IdealSource ideSou2(
    redeclare final package Medium = Medium,
    final dp_start=0,
    final m_flow_start=m_flow_nominal,
    final show_T=false,
    final show_V_flow=false,
    final control_m_flow=true,
    final control_dp=false,
    final allowFlowReversal=false,
    final m_flow_small=m_flow_nominal*1E-5)
    "Ideal source to force a flow rate"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));
  BaseClasses.IdealSource ideSou3(
    redeclare final package Medium = Medium,
    final dp_start=0,
    final m_flow_start=m_flow_nominal,
    final show_T=false,
    final show_V_flow=false,
    final control_m_flow=true,
    final control_dp=false,
    final allowFlowReversal=false,
    final m_flow_small=m_flow_nominal*1E-5)
    "Ideal source to force a flow rate"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));

  Modelica.Blocks.Sources.Constant y(k=1)
    "Duct static pressure setpoint"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-90,220})));
  Modelica.Blocks.Sources.Ramp yRam(
    height=m_flow_nominal*1.2,
    duration=3600,
    offset=0)
    "Ramp input for forced flow rate"
    annotation (Placement(transformation(extent={{60,210},{80,230}})));


equation
  connect(y.y, conPID3.u_s) annotation (Line(points={{-79,220},{-68,220},{-68,10},
          {-62,10}}, color={0,0,127}));
  connect(pDucSta3.p_rel, gai3.u)
    annotation (Line(points={{-50,-41},{-50,-34}}, color={0,0,127}));
  connect(gai3.y, conPID3.u_m)
    annotation (Line(points={{-50,-10},{-50,-2}}, color={0,0,127}));
  connect(conPID3.y, fan3.y)
    annotation (Line(points={{-39,10},{0,10},{0,-8}}, color={0,0,127}));
  connect(fan3.port_b, dp31.port_a)
    annotation (Line(points={{10,-20},{20,-20}}, color={0,127,255}));
  connect(dp31.port_b, dp32.port_a)
    annotation (Line(points={{40,-20},{60,-20}}, color={0,127,255}));
  connect(fan2.port_b, dp21.port_a)
    annotation (Line(points={{10,80},{20,80}}, color={0,127,255}));
  connect(dp21.port_b, dp22.port_a)
    annotation (Line(points={{40,80},{60,80}}, color={0,127,255}));
  connect(pDucSta2.p_rel, gai2.u)
    annotation (Line(points={{-50,59},{-50,66}}, color={0,0,127}));
  connect(gai2.y, conPID2.u_m)
    annotation (Line(points={{-50,90},{-50,98}}, color={0,0,127}));
  connect(pDucSta2.port_a, dp22.port_a) annotation (Line(
      points={{-40,50},{60,50},{60,80}},
      color={0,127,255},
      pattern=LinePattern.Dot));
  connect(y.y, conPID2.u_s) annotation (Line(points={{-79,220},{-68,220},{-68,110},
          {-62,110}}, color={0,0,127}));
  connect(conPID2.y, fan2.y)
    annotation (Line(points={{-39,110},{0,110},{0,92}}, color={0,0,127}));
  connect(fan1.port_b, dp11.port_a)
    annotation (Line(points={{10,180},{20,180}}, color={0,127,255}));
  connect(dp11.port_b, dp12.port_a)
    annotation (Line(points={{40,180},{60,180}}, color={0,127,255}));
  connect(pDucSta1.p_rel,gai1. u)
    annotation (Line(points={{-50,161},{-50,168}},
                                                 color={0,0,127}));
  connect(gai1.y,conPID1. u_m)
    annotation (Line(points={{-50,192},{-50,200}},
                                                 color={0,0,127}));
  connect(y.y, conPID1.u_s) annotation (Line(points={{-79,220},{-68,220},{-68,212},
          {-62,212}}, color={0,0,127}));
  connect(pDucSta1.port_a, dp12.port_a) annotation (Line(
      points={{-40,152},{60,152},{60,180}},
      color={0,127,255},
      pattern=LinePattern.Dot));
  connect(conPID1.y, fan1.y)
    annotation (Line(points={{-39,212},{0,212},{0,192}}, color={0,0,127}));
  connect(pDucSta3.port_a, dp32.port_a) annotation (Line(
      points={{-40,-50},{60,-50},{60,-20}},
      color={0,127,255},
      pattern=LinePattern.Dot));
  connect(fan3.port_a, sou.ports[1]) annotation (Line(points={{-10,-20},{-18,
          -20},{-18,-81.6667},{-80,-81.6667}},
                                          color={0,127,255}));
  connect(fan2.port_a, sou.ports[2]) annotation (Line(points={{-10,80},{-18,80},
          {-18,-81},{-80,-81}}, color={0,127,255}));
  connect(fan1.port_a, sou.ports[3]) annotation (Line(points={{-10,180},{-18,
          180},{-18,-80.3333},{-80,-80.3333}},
                                          color={0,127,255}));
  connect(pDucSta3.port_b, sou.ports[4]) annotation (Line(
      points={{-60,-50},{-78,-50},{-78,-79.6667},{-80,-79.6667}},
      color={0,127,255},
      pattern=LinePattern.Dot));
  connect(pDucSta2.port_b, sou.ports[5]) annotation (Line(
      points={{-60,50},{-78,50},{-78,-79},{-80,-79}},
      color={0,127,255},
      pattern=LinePattern.Dot));
  connect(pDucSta1.port_b, sou.ports[6]) annotation (Line(
      points={{-60,152},{-78,152},{-78,-78},{-80,-78},{-80,-78.3333}},
      color={0,127,255},
      pattern=LinePattern.Dot));
  connect(dp12.port_b, ideSou1.port_a)
    annotation (Line(points={{80,180},{100,180}}, color={0,127,255}));
  connect(ideSou1.port_b, sin.ports[1]) annotation (Line(points={{120,180},{134,
          180},{134,-81.3333},{140,-81.3333}}, color={0,127,255}));
  connect(yRam.y, ideSou1.m_flow_in) annotation (Line(points={{81,220},{88,220},
          {88,198},{104,198},{104,188}}, color={0,0,127}));
  connect(dp22.port_b, ideSou2.port_a)
    annotation (Line(points={{80,80},{100,80}}, color={0,127,255}));
  connect(ideSou2.port_b, sin.ports[2]) annotation (Line(points={{120,80},{134,80},
          {134,-80},{140,-80}}, color={0,127,255}));
  connect(yRam.y, ideSou2.m_flow_in) annotation (Line(points={{81,220},{88,220},
          {88,96},{104,96},{104,88}}, color={0,0,127}));
  connect(dp32.port_b, ideSou3.port_a)
    annotation (Line(points={{80,-20},{100,-20}}, color={0,127,255}));
  connect(ideSou3.port_b, sin.ports[3]) annotation (Line(points={{120,-20},{134,
          -20},{134,-78.6667},{140,-78.6667}}, color={0,127,255}));
  connect(yRam.y, ideSou3.m_flow_in) annotation (Line(points={{81,220},{88,220},
          {88,-4},{104,-4},{104,-12}}, color={0,0,127}));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{160,
            240}})),
    Documentation(info="<html>
<p>
Draft test. Documentation pending.
</p>
</html>", revisions="<html>
<ul>
<li>
January 24, 2022, by Hongxiang Fu:<br/>
First implementation.
</li>
</ul>
</html>"),
    __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Movers/Examples/StaticReset.mos"
        "Simulate and plot"),
    experiment(
      StopTime=3600,
      Tolerance=1e-06));
end StaticReset;
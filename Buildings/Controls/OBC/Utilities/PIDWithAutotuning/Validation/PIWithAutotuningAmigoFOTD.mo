within Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Validation;
model PIWithAutotuningAmigoFOTD "Test model for PIDWithAutotuning"
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant SetPoint(k=0.8)
    "Setpoint value"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  .Buildings.Controls.OBC.Utilities.PIDWithAutotuning.PIDWithAutotuningAmigoFOTD
    PIDWitAutotuning(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    yHig=1,
    yLow=0.1,
    deaBan=0.1,
    setPoint=0.8)
    "PID controller with an autotuning feature"
    annotation (Placement(transformation(extent={{-20,-30},{0,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.PIDWithReset PID(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    k=1,
    Ti=0.5,
    Td=0.1)
    "PID controller with constant gains"
     annotation (Placement(transformation(extent={{-20,50},{0,70}})));
  CDL.Logical.Sources.Constant resSig(k=false)
    "Reset signal"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));

  CDL.Discrete.UnitDelay uniDel2(samplePeriod=240)
    "A dealy process for control process 2"
    annotation (Placement(transformation(extent={{10,-30},{30,-10}})));
  CDL.Discrete.UnitDelay uniDel1(samplePeriod=240)
    "A dealy process for control process 1"
    annotation (Placement(transformation(extent={{10,50},{30,70}})));
  CDL.Continuous.Sources.Constant k(k=1) "Gain of the first order process"
    annotation (Placement(transformation(extent={{180,20},{160,40}})));
  CDL.Continuous.Sources.Constant T(k=10)
    "Time constant of the first order process"
    annotation (Placement(transformation(extent={{180,-20},{160,0}})));
  CDL.Continuous.Subtract
                     sub
    annotation (Placement(transformation(extent={{60,70},{80,90}})));
  CDL.Continuous.Subtract
                     add1
    annotation (Placement(transformation(extent={{60,-20},{80,0}})));
  CDL.Continuous.Derivative derivative
    annotation (Placement(transformation(extent={{78,26},{58,46}})));
  CDL.Continuous.Derivative derivative1
    annotation (Placement(transformation(extent={{80,-60},{60,-40}})));
equation
  connect(resSig.y, PID.trigger) annotation (Line(points={{-58,70},{-30,70},{
          -30,40},{-16,40},{-16,48}},
                            color={255,0,255}));
  connect(PIDWitAutotuning.trigger, PID.trigger) annotation (Line(points={{-16,-32},
          {-16,-38},{-30,-38},{-30,40},{-16,40},{-16,48}},
                                                    color={255,0,255}));
  connect(PIDWitAutotuning.u_s, PID.u_s) annotation (Line(points={{-22,-20},{
          -48,-20},{-48,60},{-22,60}},
                            color={0,0,127}));
  connect(SetPoint.y, PID.u_s) annotation (Line(points={{-58,10},{-48,10},{-48,
          60},{-22,60}},           color={0,0,127}));
  connect(PIDWitAutotuning.y, uniDel2.u)
    annotation (Line(points={{2,-20},{8,-20}},  color={0,0,127}));
  connect(uniDel1.u, PID.y)
    annotation (Line(points={{8,60},{2,60}},  color={0,0,127}));
  connect(uniDel1.y, sub.u1) annotation (Line(points={{32,60},{40,60},{40,86},{
          58,86}}, color={0,0,127}));
  connect(k.y, derivative.k)
    annotation (Line(points={{158,30},{148,30},{148,44},{80,44}},
                                                            color={0,0,127}));
  connect(derivative.T, T.y)
    annotation (Line(points={{80,40},{112,40},{112,-46},{148,-46},{148,-10},{
          158,-10}},                                         color={0,0,127}));
  connect(derivative.y, sub.u2) annotation (Line(points={{56,36},{50,36},{50,74},
          {58,74}}, color={0,0,127}));
  connect(sub.y, PID.u_m) annotation (Line(points={{82,80},{88,80},{88,54},{46,
          54},{46,42},{-10,42},{-10,48}}, color={0,0,127}));
  connect(add1.u1, uniDel2.y) annotation (Line(points={{58,-4},{40,-4},{40,-20},
          {32,-20}}, color={0,0,127}));
  connect(derivative1.y, add1.u2) annotation (Line(points={{58,-50},{52,-50},{
          52,-16},{58,-16}},
                          color={0,0,127}));
  connect(add1.y, PIDWitAutotuning.u_m) annotation (Line(points={{82,-10},{88,
          -10},{88,-26},{46,-26},{46,-38},{-10,-38},{-10,-32}},
                                         color={0,0,127}));
  connect(derivative1.k, derivative.k) annotation (Line(points={{82,-42},{92,
          -42},{92,44},{80,44}},
                          color={0,0,127}));
  connect(derivative1.T, T.y) annotation (Line(points={{82,-46},{148,-46},{148,
          -10},{158,-10}},         color={0,0,127}));
  connect(derivative.u, sub.u1) annotation (Line(points={{80,36},{88,36},{88,20},
          {40,20},{40,86},{58,86}}, color={0,0,127}));
  connect(derivative1.u, uniDel2.y) annotation (Line(points={{82,-50},{92,-50},
          {92,-66},{40,-66},{40,-20},{32,-20}}, color={0,0,127}));
  annotation (
    experiment(
      StopTime=10000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    __Dymola_Commands(
      file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/Utilities/PIDWithAutotuning/Validation/PIWithAutotuningAmigoFOTD.mos" "Simulate and plot"),
    Documentation(
      info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Controls.OBC.Utilities.PIDWithAutotuning.PIDWithAutotuningAmigoFOTD\">
Buildings.Controls.OBC.Utilities.PIDWithAutotuning.PIDWithAutotuningAmigoFOTD</a>.
</p>
<p>
This example is to compare the output of a PI controller with an autotuning feature to that of another PI controller with arbitary gains
</p>
</html>",
      revisions="<html>
<ul>
<li>
June 1, 2022, by Sen Huang:<br/>
First implementation<br/>
</li>
</ul>
</html>"),
    Icon(
      graphics={
        Ellipse(
          lineColor={75,138,73},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}),
        Polygon(
          lineColor={0,0,255},
          fillColor={75,138,73},
          pattern=LinePattern.None,
          fillPattern=FillPattern.Solid,
          points={{-36,60},{64,0},{-36,-60},{-36,60}})}),
    Diagram(coordinateSystem(extent={{-100,-80},{200,100}})));
end PIWithAutotuningAmigoFOTD;

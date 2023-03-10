within Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay;
block HalfPeriodRatio
  "Calculate the half period ratio of a response from a relay controller"
  Buildings.Controls.OBC.CDL.Interfaces.RealInput tOn(
    final quantity="Time",
    final unit="s",
    min=100*Buildings.Controls.OBC.CDL.Constants.eps)
    "Length for the On period"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
    iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput tOff(
    final quantity="Time",
    final unit="s",
    min=100*Buildings.Controls.OBC.CDL.Constants.eps)
    "Length for the Off period"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
    iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput rho
    "Real signal of the half period ratio"
    annotation (Placement(transformation(extent={{100,60},{140,100}}),
        iconTransformation(extent={{100,50},{120,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput triSta
    "A boolean signal, true if the tuning starts"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-10},{120,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput triEnd
    "A boolean signal, true if the tuning completes"
    annotation (Placement(transformation(extent={{100,-50},{140,-10}}),
        iconTransformation(extent={{100,-70},{120,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Min tmin
    "Minimum value of the length for the On period and the length for the off period "
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Greater gretOntOff
    "Check if both the length for the On period and the length for the off period are larger than 0"
    annotation (Placement(transformation(extent={{-20,50},{0,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minLen(
     final k=0)
    "Minimum value for the horizon length"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler tOnSample(
    final y_start=Buildings.Controls.OBC.CDL.Constants.eps)
    "Sample tOn when the tuning period ends"
    annotation (Placement(transformation(extent={{-80,70},{-60,90}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler tOffSample(
    final y_start=Buildings.Controls.OBC.CDL.Constants.eps)
    "Sample tOff when the tuning period ends"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-80}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler samAddtOntOff
    "Sample the tmin when tmin is larger than 0"
    annotation (Placement(transformation(extent={{20,30},{40,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Greater tIncrease
    "Check if either the length for the On period or the length for the off period increases after they both becomes positive"
    annotation (Placement(transformation(extent={{30,-40},{50,-20}})));
  Buildings.Controls.OBC.CDL.Continuous.Min mintOntOff
    "Find the smaller one between the length for the On period and the length for the off period"
    annotation (Placement(transformation(extent={{-20,-80},{0,-60}})));
  Buildings.Controls.OBC.CDL.Continuous.Max maxtOntOff
    "Find the larger one between the length for the On period and the length for the off period"
    annotation (Placement(transformation(extent={{-20,70},{0,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Divide halPerRat
    "Calculate the half period ratio"
    annotation (Placement(transformation(extent={{60,70},{80,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Add AddtOntOff
    "Calculate the sum of the length for the On period and the length for the off period"
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
  Buildings.Controls.OBC.CDL.Continuous.Multiply mul
    "Detect if the the length for the On period or the length for the off period changes after both of them are larger than 0"
    annotation (Placement(transformation(extent={{-34,-40},{-14,-20}})));
  Buildings.Controls.OBC.CDL.Continuous.Greater gretmaxtOntOff
    "Check if either the length for the On period or the length for the off period is larger than 0"
    annotation (Placement(transformation(extent={{-20,10},{0,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Less tDecrease
    "Check if either the length for the On period or the length for the off period decreases after they both becomes positive"
    annotation (Placement(transformation(extent={{30,-90},{50,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Or tChanges
    "Check if the length for the On period or the length for the off period changes"
    annotation (Placement(transformation(extent={{70,-40},{90,-20}})));

equation
  connect(tmin.u1, tOn) annotation (Line(points={{-82,46},{-94,46},{-94,60},{
          -120,60}}, color={0,0,127}));
  connect(tmin.u2, tOff) annotation (Line(points={{-82,34},{-88,34},{-88,-60},{
          -120,-60}}, color={0,0,127}));
  connect(minLen.y, gretOntOff.u2) annotation (Line(points={{-58,10},{-40,10},{
          -40,48},{-22,48}},color={0,0,127}));
  connect(tOnSample.u, tOn)
    annotation (Line(points={{-82,80},{-94,80},{-94,60},{-120,60}}, color={0,0,127}));
  connect(tOffSample.u, tOff) annotation (Line(points={{-82,-70},{-88,-70},{-88,
          -60},{-120,-60}}, color={0,0,127}));
  connect(samAddtOntOff.y, tIncrease.u2) annotation (Line(points={{42,20},{60,
          20},{60,-6},{18,-6},{18,-38},{28,-38}},   color={0,0,127}));
  connect(gretOntOff.y, samAddtOntOff.trigger) annotation (Line(points={{2,40},{
          30,40},{30,32}}, color={255,0,255}));
  connect(tOnSample.y, maxtOntOff.u1) annotation (Line(points={{-58,80},{-52,80},
          {-52,86},{-22,86}}, color={0,0,127}));
  connect(maxtOntOff.u2, tOffSample.y) annotation (Line(points={{-22,74},{-48,
          74},{-48,-70},{-58,-70}}, color={0,0,127}));
  connect(mintOntOff.u2, tOffSample.y) annotation (Line(points={{-22,-76},{-48,
          -76},{-48,-70},{-58,-70}}, color={0,0,127}));
  connect(maxtOntOff.y, halPerRat.u1) annotation (Line(points={{2,80},{52,80},{
          52,86},{58,86}}, color={0,0,127}));
  connect(halPerRat.u2, mintOntOff.y) annotation (Line(points={{58,74},{14,74},
          {14,-70},{2,-70}}, color={0,0,127}));
  connect(halPerRat.y, rho) annotation (Line(points={{82,80},{120,80}},
                color={0,0,127}));
  connect(AddtOntOff.u2, tOff) annotation (Line(points={{-82,-36},{-88,-36},{
          -88,-60},{-120,-60}}, color={0,0,127}));
  connect(AddtOntOff.u1, tOn) annotation (Line(points={{-82,-24},{-94,-24},{-94,
          60},{-120,60}}, color={0,0,127}));
  connect(gretmaxtOntOff.y, triSta)
    annotation (Line(points={{2,0},{120,0}},  color={255,0,255}));
  connect(tChanges.u1, tIncrease.y)
    annotation (Line(points={{68,-30},{52,-30}}, color={255,0,255}));
  connect(samAddtOntOff.y, tDecrease.u2) annotation (Line(points={{42,20},{60,
          20},{60,-6},{18,-6},{18,-88},{28,-88}}, color={0,0,127}));
  connect(gretmaxtOntOff.u1, AddtOntOff.y) annotation (Line(points={{-22,0},{
          -40,0},{-40,-30},{-58,-30}}, color={0,0,127}));
  connect(gretmaxtOntOff.u2, minLen.y) annotation (Line(points={{-22,8},{-40,8},
          {-40,10},{-58,10}},color={0,0,127}));
  connect(gretOntOff.u1, tmin.y) annotation (Line(points={{-22,40},{-58,40}},
                                       color={0,0,127}));
  connect(mul.u1, tmin.y) annotation (Line(points={{-36,-24},{-44,-24},{-44,40},
          {-58,40}},         color={0,0,127}));
  connect(mul.u2, AddtOntOff.y) annotation (Line(points={{-36,-36},{-40,-36},{
          -40,-30},{-58,-30}}, color={0,0,127}));
  connect(mul.y, tIncrease.u1)
    annotation (Line(points={{-12,-30},{28,-30}}, color={0,0,127}));
  connect(tDecrease.u1, mul.y) annotation (Line(points={{28,-80},{10,-80},{10,
          -30},{-12,-30}}, color={0,0,127}));
  connect(samAddtOntOff.u, mul.y) annotation (Line(points={{18,20},{10,20},{10,
          -30},{-12,-30}},  color={0,0,127}));
  connect(tOnSample.trigger, tChanges.y) annotation (Line(points={{-70,68},{-70,
          60},{94,60},{94,-30},{92,-30}}, color={255,0,255}));
  connect(triEnd, tChanges.y) annotation (Line(points={{120,-30},{92,-30}},
                          color={255,0,255}));
  connect(tOnSample.y, mintOntOff.u1) annotation (Line(points={{-58,80},{-52,80},
          {-52,-64},{-22,-64}}, color={0,0,127}));
  connect(tChanges.y, tOffSample.trigger) annotation (Line(points={{92,-30},{94,
          -30},{94,-54},{-70,-54},{-70,-58}}, color={255,0,255}));
  connect(tDecrease.y, tChanges.u2) annotation (Line(points={{52,-80},{60,-80},
          {60,-38},{68,-38}}, color={255,0,255}));
  annotation (defaultComponentName = "halPerRat",
        Diagram(
           coordinateSystem(
           extent={{-100,-100},{100,100}})),
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{80,
            100}}),                                      graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-154,148},{146,108}},
          textString="%name",
          textColor={0,0,255})}),
    Documentation(revisions="<html>
<ul>
<li>
June 1, 2022, by Sen Huang:<br/>
First implementation<br/>
</li>
</ul>
</html>", info="<html>
<p>This block calculates the half-period ratio of the output from a relay controller.</p>
<h4>Main equations</h4>
<p align=\"center\" style=\"font-style:italic;\">
&rho; = max(t<sub>on</sub>,t<sub>off</sub>)/ min(t<sub>on</sub>,t<sub>off</sub>),
</p>
<p>
where <code>t<sub>on</sub></code> and <code>t<sub>off</sub></code> are the
length of the On period and the Off period, respectively.
</p>
<p>An On period is defined as the period when the switch output of the relay controller is True;
Likewise, an Off period is defined as the period when the switch output is False.
See details of the switch output in <a href=\"modelica://Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay.Controller\">
Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay.Controller</a> </p>
<p>Note that only the first On period and the first Off period are considered.</p>
<h4>Algorithm</h4>
<p>
The algorithm for calculating <code>&rho;</code> is as follows:
</p>
<h5>Step 1: detects when the tuning period begins.</h5>
<p>
The  tuning period is triggered to begin when either <code>t<sub>on</sub></code>
or <code>t<sub>off</sub></code> are larger than 0.
In this implementation, we detect the beginning time by monitoring the sum of
<code>t<sub>on</sub></code> and <code>t<sub>off</sub></code>.
</p>

<h5>Step 2: detects when both <code>t<sub>on</sub></code> and <code>t<sub>off</sub></code>
are larger than 0.</h5>
<p>
We then record the value of the minimum value between
<code>(t<sub>on</sub>+t<sub>off</sub>)*min(t<sub>on</sub>,t<sub>off</sub>)</code>
at the momement when both <code>t<sub>on</sub></code> and <code>t<sub>off</sub></code>
become postive.
</p>

<h5>Step 3: detects when the tuning period ends.</h5>
<p>
The tuning period is triggered to end when either <code>t<sub>on</sub></code>
or <code>t<sub>off</sub></code> changes after they become positive.
In this implementation, we detect the end time by checking if the value of
<code>(t<sub>on</sub>+t<sub>off</sub>)*min(t<sub>on</sub>,t<sub>off</sub>)</code>
is different from the output of step2.
</p>

<h4>References</h4>
<p>Josefin Berner (2017)
\"Automatic Controller Tuning using Relay-based Model Identification.\"
Department of Automatic Control, Lund Institute of Technology, Lund University. </p>
</html>"));
end HalfPeriodRatio;

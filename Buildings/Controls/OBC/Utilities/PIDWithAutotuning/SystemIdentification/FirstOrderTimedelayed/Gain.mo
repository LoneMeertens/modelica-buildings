within Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed;
block Gain "Identifies the gain of a first order time delayed model"
  parameter Real yHig(min=1E-6) = 1
    "Higher value for the output (assuming the reference output is 0)";
  parameter Real yLow(min=1E-6) = 0.5
    "Lower value for the output (assuming the reference output is 0)";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput u
    "Connector for a signal of a relay controller output"
    annotation (Placement(transformation(extent={{-140,60},{-100,100}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput tOn
    "Connector for a signal of the length for the On period"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
    iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput tOff
    "Connector for a signal of the length for the Off period"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}),
    iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput triggerStart
    "Relay tuning status, true if the tuning starts"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={0,-120})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput k
    "Connector for a real signal of the gain"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Add Iu
    "Integral of the relay output"
    annotation (Placement(transformation(extent={{-40,-50},{-20,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.IntegratorWithReset Iy(
     k=1,y_start=1E-11)
    "Integral of the process output"
    annotation (Placement(transformation(extent={{-40,30},{-20,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant referenceRelayOutpit(k=0)
    "Reference value of the relay control output"
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Divide divIyIu
    "Calculates the gain"
    annotation (Placement(transformation(extent={{32,-10},{52,10}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addPar(p=1E-11)
    "Avoid divide-by-zero errors"
    annotation (Placement(transformation(extent={{0,-50},{20,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter gaitOnyHig(k=yHig)
    "Product of tOn and yHig"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter gaitOffyLow(k=-yLow)
    "Product of tOff and yLow"
    annotation (Placement(transformation(extent={{-80,-90},{-60,-70}})));
equation
  connect(Iy.u, u) annotation (Line(points={{-42,40},{-90,40},{-90,80},{-120,80}},
        color={0,0,127}));
  connect(referenceRelayOutpit.y, Iy.y_reset_in) annotation (Line(points={{-58,20},
          {-50,20},{-50,32},{-42,32}}, color={0,0,127}));
  connect(Iy.trigger, triggerStart) annotation (Line(points={{-30,28},{-30,-20},
          {-10,-20},{-10,-96},{0,-96},{0,-120}}, color={255,0,255}));
  connect(divIyIu.u1, Iy.y) annotation (Line(points={{30,6},{0,6},{0,40},{-18,40}},
                color={0,0,127}));
  connect(Iu.y, addPar.u) annotation (Line(points={{-18,-40},{-2,-40}},color={0,0,127}));
  connect(addPar.y, divIyIu.u2) annotation (Line(points={{22,-40},{26,-40},{26,-6},
          {30,-6}},                  color={0,0,127}));
  connect(divIyIu.y, k) annotation (Line(points={{54,0},{110,0}}, color={0,0,127}));
  connect(gaitOnyHig.u, tOn) annotation (Line(points={{-82,-20},{-90,-20},{-90,0},
          {-120,0}}, color={0,0,127}));
  connect(gaitOnyHig.y, Iu.u1) annotation (Line(points={{-58,-20},{-50,-20},{-50,
          -34},{-42,-34}}, color={0,0,127}));
  connect(gaitOffyLow.u, tOff)
    annotation (Line(points={{-82,-80},{-120,-80}}, color={0,0,127}));
  connect(gaitOffyLow.y, Iu.u2) annotation (Line(points={{-58,-80},{-50,-80},{-50,
          -46},{-42,-46}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-154,148},{146,108}},
          textString="%name",
          textColor={0,0,255})}), Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 1, 2022, by Sen Huang:<br/>
First implementation<br/>
</li>
</ul>
</html>", info="<html>
<p>This block calculates the gain of a first-order time-delayed model.</p>
<h4>Main equations</h4>
<p align=\"center\" style=\"font-style:italic;\">
k = I<sub>y</sub>/I<sub>u</sub>,
</p>
<p>where <i>I<sub>y</i></sub> and <i>I<sub>u</i></sub> are the integral of the process output and the integral of the relay output, respectively.</p>
<p><i>I<sub>y</i></sub> is calculated by </p>
<p>I<sub>y</sub> = &int; u(t) dt;</p>
<p>where <i>u</i> is the process output.</p>
<p><i>I<sub>u</i></sub> is calculated by </p>
<p align=\"center\" style=\"font-style:italic;\">
I<sub>u</sub> = t<sub>on</sub> (y<sub>hig</sub> - y<sub>ref</sub>)+ t<sub>off</sub>(-y<sub>low</sub> - y<sub>ref</sub>),
</p>
<p>where <i>y<sub>hig</i></sub> and <i>y<sub>low</i></sub> are the higher value and the lower value of the relay control output, respectively.</p>
<p><i>y<sub>ref</i></sub> is the reference value of the relay output.</p>
<p><i>t<sub>on</i></sub> and <i>t<sub>off</i></sub> are the length of the On period and the Off period, respectively.</p>
<p>During an On period, the relay switch signal becomes True;</p>
<p>During an Off period, the relay switch signal becomes False.</p>
<h4>References</h4>
<p>Josefin Berner (2017). &quot;Automatic Controller Tuning using Relay-based Model Identification.&quot; Department of Automatic Control, Lund Institute of Technology, Lund University. </p>
</html>"),
    __Dymola_Commands(file="../../123.mos" "123"));
end Gain;

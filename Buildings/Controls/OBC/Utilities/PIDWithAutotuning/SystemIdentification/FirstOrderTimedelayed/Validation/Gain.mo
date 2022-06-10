within Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.Validation;
model Gain "Test model for Gain"
  extends Modelica.Icons.Example;
  Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.Gain
    gain "Calculates the gain"
         annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.TimeTable tOn(
    table=[0,0; 0.1,0.1; 0.3,0.1; 0.7,0.1; 0.83,0.1; 0.9,0.07],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    extrapolation=Buildings.Controls.OBC.CDL.Types.Extrapolation.HoldLastPoint)
    "The length of the On period"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.TimeTable tOff(
    table=[0,0; 0.1,0; 0.3,0; 0.7,0; 0.83,0.73; 0.85,0.73],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    extrapolation=Buildings.Controls.OBC.CDL.Types.Extrapolation.HoldLastPoint)
    "The length of the Off period"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.TimeTable u(
    table=[0,1; 0.1,0.5; 0.3,0.5; 0.7,0.5; 0.83,1; 0.9,0.5],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    extrapolation=Buildings.Controls.OBC.CDL.Types.Extrapolation.HoldLastPoint)
    "The response of a relay controller"
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  CDL.Logical.Sources.TimeTable tuningStart(table=[0,0; 0.1,1; 0.3,1; 0.7,1;
        0.83,1; 0.85,1], period=2)
    "Mimicking the signal for the tuning period start"
    annotation (Placement(transformation(extent={{-60,-80},{-40,-60}})));
equation
  connect(tOn.y[1], gain.tOn)
    annotation (Line(points={{-38,0},{-12,0}}, color={0,0,127}));
  connect(gain.tOff, tOff.y[1]) annotation (Line(points={{-12,-8},{-20,-8},{-20,
          -40},{-38,-40}}, color={0,0,127}));
  connect(u.y[1], gain.u) annotation (Line(points={{-38,40},{-20,40},{-20,8},{-12,
          8}}, color={0,0,127}));
  connect(tuningStart.y[1], gain.triggerStart)
    annotation (Line(points={{-38,-70},{0,-70},{0,-12}}, color={255,0,255}));
  annotation (
      experiment(
      StopTime=1.0,
      Tolerance=1e-06),
    __Dymola_Commands(
      file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/Utilities/PIDWithAutotuning/SystemIdentification/FirstOrderTimedelayed/Validation/Gain.mos" "Simulate and plot"),
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 1, 2022, by Sen Huang:<br/>
First implementation<br/>
</li>
</ul>
</html>", info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.Gain\">
Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.Gain</a>.
</p>
</html>"));
end Gain;

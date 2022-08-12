within Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay.Validation;
model OnOffPeriod "Test model for OnOffPeriod"
  Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay.OnOffPeriod
    onOffPeriod "Calculate the length of the On period and the Off period"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.TimeTable relayResponse(
     table=[0,1;0.1,0; 0.3,0; 0.7,1; 0.83,0; 0.85,1], period=2)
    "Mimicks the response for a relay controller"
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.ModelTime modTim
    "Simulation time"
    annotation (Placement(transformation(extent={{-60,10},{-40,30}})));
	
equation
  connect(onOffPeriod.On, relayResponse.y[1]) annotation (Line(points={{-12,-6},
          {-20,-6},{-20,-10},{-38,-10}}, color={255,0,255}));
  connect(modTim.y, onOffPeriod.tim) annotation (Line(points={{-38,20},{-20,20},
          {-20,6},{-12,6}}, color={0,0,127}));
  annotation (
      experiment(
      StopTime=1.0,
      Tolerance=1e-06),
    __Dymola_Commands(
      file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/Utilities/PIDWithAutotuning/Relay/Validation/OnOffPeriod.mos" "Simulate and plot"),
      Icon(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-100,-100},{100,100}}),
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
          points={{-36,60},{64,0},{-36,-60},{-36,60}})}),Diagram(
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
<a href=\"modelica://Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay.OnOffPeriod\">
Buildings.Controls.OBC.Utilities.PIDWithAutotuning.Relay.OnOffPeriod</a>.
</p>
</html>"));
end OnOffPeriod;

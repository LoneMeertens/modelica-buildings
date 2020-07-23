within Buildings.Experimental.RadiantControl.Lockouts.SubLockouts;
block NightFlush "Locks out heating if building is in night flush mode"
  Controls.OBC.CDL.Interfaces.BooleanInput nightFlushSignal
    "True if night flush mode is on; false otherwise"
    annotation (Placement(transformation(extent={{-142,-20},{-102,20}})));
  Controls.OBC.CDL.Interfaces.BooleanOutput heatingSignal_NightFlush
    "True if heating is allowed, false if heating is locked out"
    annotation (Placement(transformation(extent={{100,-20},{140,20}})));
  Controls.OBC.CDL.Logical.Not           not1
    "If night flush mode is on, heating should not be on"
    annotation (Placement(transformation(extent={{-8,-10},{12,10}})));
equation
  connect(not1.y, heatingSignal_NightFlush)
    annotation (Line(points={{14,0},{120,0}}, color={255,0,255}));
  connect(nightFlushSignal, not1.u)
    annotation (Line(points={{-122,0},{-10,0}}, color={255,0,255}));
  annotation (Documentation(info="<html>
<p>
If night flush mode is on, heating is locked out. 
</p>
</html>"),Icon(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}}),graphics={
        Text(
          lineColor={0,0,255},
          extent={{-148,104},{152,144}},
          textString="%name"),
        Rectangle(extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
        Polygon(points={{-80,90},{-88,68},{-72,68},{-80,90}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-90,0},{68,0}}, color={192,192,192}),
        Polygon(points={{90,0},{68,8}, {68,-8},{90,0}},
          lineColor={192,192,192}, fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-80,0},{80,0}}),
         Text(
        extent={{-56,90},{48,-88}},
        lineColor={0,0,0},
        fillColor={0,0,0},
        fillPattern=FillPattern.Solid,
        textString="N"),
        Text(
          extent={{226,60},{106,10}},
          lineColor={0,0,0},
          textString=DynamicSelect("", String(y, leftjustified=false, significantDigits=3)))}), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end NightFlush;

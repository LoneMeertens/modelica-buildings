within Buildings.Experimental.OpenBuildingControl.CDL.SetPoints.Validation;
model TimeTable "Validation model for TimeTable block"
  extends Modelica.Icons.Example;
  Buildings.Experimental.OpenBuildingControl.CDL.SetPoints.TimeTable
    timTabLin(smoothness=
        Buildings.Experimental.OpenBuildingControl.CDL.Types.Smoothness.LinearSegments, table=[0,
        0; 6*3600,1; 18*3600,0.5; 24*3600,0])
    "Time table with smoothness method of linear segments"
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  Buildings.Experimental.OpenBuildingControl.CDL.SetPoints.TimeTable
    timTabLinHol(smoothness=
      Buildings.Experimental.OpenBuildingControl.CDL.Types.Smoothness.LinearSegments,
      extrapolation=Buildings.Experimental.OpenBuildingControl.CDL.Types.Extrapolation.HoldLastPoint,
    table=[0,0; 6*3600,1; 18*3600,0.5; 24*3600,0])
    "Time table with smoothness method of linear segments, hold first and last value"
    annotation (Placement(transformation(extent={{-10,10},{10,30}})));
  Buildings.Experimental.OpenBuildingControl.CDL.SetPoints.TimeTable
    timTabLinDer(smoothness=
      Buildings.Experimental.OpenBuildingControl.CDL.Types.Smoothness.LinearSegments,
      extrapolation=Buildings.Experimental.OpenBuildingControl.CDL.Types.Extrapolation.LastTwoPoints,
    table=[0,0; 6*3600,1; 18*3600,0.5; 24*3600,0])
    "Time table with smoothness method of linear segments, extrapolate with der"
    annotation (Placement(transformation(extent={{50,10},{70,30}})));
  Buildings.Experimental.OpenBuildingControl.CDL.SetPoints.TimeTable
    timTabCon(smoothness=
        Buildings.Experimental.OpenBuildingControl.CDL.Types.Smoothness.ConstantSegments, table=[0,
        0; 6*3600,1; 18*3600,0.5; 24*3600,0])
    "Time table with smoothness method of constant segments"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));

  annotation (experiment(Tolerance=1e-6, StopTime=172800),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/CDL/SetPoints/Validation/TimeTable.mos"
        "Simulate and plot"),
        Documentation(info="<html>
<p>
This model validates the TimeTable block. It takes as a parameter a time table of 
the format
</p>
<pre>
table = [ 0*3600, 0;
          6*3600, 1;
         18*3600, 0.5;
         24*3600, 0];
</pre>
<p>
The block <code>timTabLin</code> applies smoothness method of linear segments 
between table points, periodically repeat the table scope.
</p>
<p>
The block <code>timTabLinHol</code> applies smoothness method of linear segments 
between table points, hold the last table points when it becomes outside of 
table scope.
</p>
<p>
The block <code>timTabLinDer</code> applies smoothness method of linear segments 
between table points, extrapolate by using the derivative at the last table 
points to find points outside the table scope.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 18, 2017, by Jianjun Hu:<br/>
First implementation in CDL.
</li>
</ul>
</html>"));
end TimeTable;

within Buildings.Controls.OBC.UsersGuide;
class Naming "Naming conventions in OBC package"
  annotation (preferredView="info",
  defaultComponentName="obcNam",
  Documentation(info="<html>
<p>
The <code>Buildings.Control.OBC</code> package follows the naming conventions of
the <code>Buildings</code> Library,
see <a href=\"modelica://Buildings.UsersGuide.Conventions\">Buildings.UsersGuide.Conventions</a>.
The table below shows some examples of commonly used names.
</p>
<table summary=\"summary\" border=\"1\">
<tr><td colspan=\"2\"><b>Instance names</b></td></tr>
<tr><th>Name</th><th>Comments</th></tr>
<tr><td><code>TOut</code> (<code>hOut</code>)</td><td>Outdoor air temperature (enthalpy)</td></tr>
<tr><td><code>TZonHeaSet</code> (<code>TZonCooSet</code>)</td><td>Zone heating (cooling) setpoint temperature</td></tr>
<tr><td><code>VDis_flow</code></td><td>Measured discharge airflow rate</td></tr>
<tr><td><code>dpBui</code></td><td>Building static pressure difference, relative to ambient</td></tr>
<tr><td><code>uOpeMod</code></td><td>Zone group operating mode</td></tr>
<tr><td><code>uResReq</code></td><td>Number of reset requests</td></tr>
<tr><td><code>uSupFan</code></td><td>Current supply fan enabling status, true: fan is enabled</td></tr>
<tr><td><code>uSupFanSpe</code></td><td>Current supply fan speed</td></tr>
<tr><td><code>uDam</code></td><td>Measured damper position</td></tr>
<tr><td><code>uHea</code> (<code>uCoo</code>)</td><td>Heating (cooling) loop signal</td></tr>
<tr><td><code>yPosMin</code> (<code>yPosMax</code>)</td><td>Minimum (maximum) position</td></tr>
<tr><td><code>yDamSet</code> (<code>yValSet</code>)</td><td>Damper (valve) position setpoint</td></tr>
<tr><td><code>yHeaCoi</code> (<code>yCooCoi</code>)</td><td>Heating (cooling) coil control signal</td></tr>
<tr><td colspan=\"2\"><b>Parameter names</b></td></tr>
<tr><th>Name</th> <th>Comments</th></tr>
<tr><td><code>use_TMix</code></td><td>Set to true if mixed air temperature measurement is used</td></tr>
<tr><td><code>have_occSen</code> (<code>have_winSen</code>)</td><td>Set to true if the zone has occupancy (window) sensor</td></tr>
<tr><td><code>AFlo</code></td><td>Area of the zone</td></tr>
<tr><td><code>VDisHeaSetMax_flow</code> (<code>VDisCooSetMax_flow</code>)</td><td>Zone maximum heating (cooling) airflow setpoint</td></tr>
<tr><td><code>VOutPerAre_flow</code> (<code>VOutPerPer_flow</code>)</td><td>Outdoor air rate per unit area (person)</td></tr>
<tr><td><code>V_flow_nominal</code></td><td>Nominal volume flow rate</td></tr>
<tr><td><code>VOutMin_flow</code></td><td>Calculated minimum outdoor airflow rate at design stage</td></tr>
<tr><td><code>pMinSet</code> (<code>pMaxSet</code>)</td><td>Minimum (maximum) pressure setpoint for fan speed control</td></tr>
<tr><td><code>TSupSetMin</code> (<code>TSupSetMax</code>)</td><td>Lowest (Highest) cooling supply air temperature</td></tr>
<tr><td><code>TOccHeaSet</code> (<code>TUnoHeaSet</code>)</td><td>Zone occupied (unoccupied) heating setpoint</td></tr>
<tr><td><code>TZonCooMax</code> (<code>TZonCooMin</code>)</td><td>Maximum (minimum) zone cooling setpoint when cooling is on</td></tr>
<tr><td><code>retDamPhyPosMax</code> (<code>outDamPhyPosMax</code>)</td><td>Physically fixed maximum position of the return (outdoor) air damper</td></tr>
<tr><td><code>samplePeriod</code></td><td>Sample period</td></tr>
<tr><td><code>zonDisEffHea</code> (<code>zonDisEffCoo</code>)</td><td>Zone air distribution effectiveness during heating (cooling)</td></tr>
<tr><td><code>kCoo</code></td><td>Gain for cooling control loop signal</td></tr>
<tr><td><code>TiCoo</code></td><td>Time constant of integrator block for cooling control loop signal</td></tr>
<tr><td><code>TdCoo</code></td><td>Time constant of derivative block for cooling control loop signal</td></tr>
</table>
<br/>
</html>"),
    Icon(graphics={
        Ellipse(
          lineColor={75,138,73},
          fillColor={75,138,73},
          pattern=LinePattern.None,
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}),
        Polygon(origin={-4.167,-15},
          fillColor={255,255,255},
          pattern=LinePattern.None,
          fillPattern=FillPattern.Solid,
          points={{-15.833,20.0},{-15.833,30.0},{14.167,40.0},{24.167,20.0},{4.167,-30.0},{14.167,-30.0},{24.167,-30.0},{24.167,-40.0},{-5.833,-50.0},{-15.833,-30.0},{4.167,20.0},{-5.833,20.0}},
          smooth=Smooth.Bezier),
        Ellipse(origin={7.5,56.5},
          fillColor={255,255,255},
          pattern=LinePattern.None,
          fillPattern=FillPattern.Solid,
          extent={{-12.5,-12.5},{12.5,12.5}})}));
end Naming;

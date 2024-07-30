within Buildings.Fluid.SolarCollectors.PVT.BaseClasses;
block Tcell_calc
  "Partial heat loss model on which ASHRAEHeatLoss and EN12975HeatLoss are based"
  extends Modelica.Blocks.Icons.Block;
  extends SolarCollectors.BaseClasses.PartialParameters;

  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    "Medium in the component";

  Modelica.Blocks.Interfaces.RealInput qth(
    quantity="ThermodynamicTemperature",
    unit="K",
    displayUnit="degC") "Temperature of surrounding environment"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));

  Modelica.Blocks.Interfaces.RealInput Upvt
    annotation (Placement(transformation(extent={{-140,24},{-100,64}})));
  Modelica.Blocks.Interfaces.RealInput Tm
    annotation (Placement(transformation(extent={{-140,-66},{-100,-26}})));
  Modelica.Blocks.Interfaces.RealOutput Tcell
    annotation (Placement(transformation(extent={{100,2},{120,22}})));




  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductor
    annotation (Placement(transformation(extent={{-12,16},{8,36}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalResistor thermalResistor
    annotation (Placement(transformation(extent={{-10,-24},{10,-4}})));
  annotation (
defaultComponentName="heaLos",
Documentation(info="<html>
<p>
This component is a partial model used as the base for
<a href=\"modelica://Buildings.Fluid.SolarCollectors.BaseClasses.ASHRAEHeatLoss\">
Buildings.Fluid.SolarCollectors.BaseClasses.ASHRAEHeatLoss</a> and
<a href=\"modelica://Buildings.Fluid.SolarCollectors.BaseClasses.EN12975HeatLoss\">
Buildings.Fluid.SolarCollectors.BaseClasses.EN12975HeatLoss</a>. It contains the
input, output and parameter declarations which are common to both models. More
detailed information is available in the documentation of the extending classes.
</p>
</html>", revisions="<html>
<ul>
<li>
February 15, 2024, by Jelger Jansen:<br/>
Refactor model.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3604\">Buildings, #3604</a>.
</li>
<li>
December 17, 2017, by Michael Wetter:<br/>
Revised computation of heat loss.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1100\">
issue 1100</a>.
</li>
<li>
June 29, 2015, by Michael Wetter:<br/>
Revised implementation of heat loss near <code>Medium.T_min</code>
to make it more efficient.
</li>
<li>
November 20, 2014, by Michael Wetter:<br/>
Added missing <code>each</code> keyword.
</li>
<li>
Apr 17, 2013, by Peter Grant:<br/>
First implementation
</li>
</ul>
</html>"));
end Tcell_calc;

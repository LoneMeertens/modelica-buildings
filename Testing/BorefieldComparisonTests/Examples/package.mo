within Testing.BorefieldComparisonTests;
package Examples
  "Runnable borefield comparison models"

  extends Modelica.Icons.ExamplesPackage;

  annotation (
    preferredView = "info",
    Documentation(info="
<html>
<p>
This package contains runnable comparison models for aggregate and zoned
geothermal borefield representations.
</p>

<p>
The examples use the same borefield geometry, material data, nominal flow rates
and annual inlet temperature profile. They differ mainly in the thermal and
hydraulic discretisation of the borefield.
</p>

<p>
The intended comparison quantities are:
</p>

<ul>
<li>borefield inlet temperature,</li>
<li>borefield outlet temperature,</li>
<li>temperature difference across the borefield,</li>
<li>resulting heat flow,</li>
<li>zone outlet temperatures for zoned models.</li>
</ul>
</html>"));

end Examples;

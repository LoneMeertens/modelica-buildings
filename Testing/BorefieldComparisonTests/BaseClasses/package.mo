within Testing.BorefieldComparisonTests;
package BaseClasses
  "Partial models and reusable base classes for borefield comparison models"

  extends Modelica.Icons.BasesPackage;

  annotation (
    preferredView = "info",
    Documentation(info="
<html>
<p>
This package contains partial models and reusable base classes used by the
borefield comparison examples.
</p>

<p>
The classes in this package are not intended to be simulated directly.
They provide common boundary conditions, sensors, KPI definitions and hydraulic
structure for the runnable comparison models.
</p>

<p>
Typical contents are:
</p>

<ul>
<li><code>PartialAnnualTinProfile</code>: annual sinusoidal inlet temperature profile,</li>
<li><code>PartialZonedBTES</code>: common source, sensor and KPI structure for zoned BTES models.</li>
</ul>
</html>"));

end BaseClasses;

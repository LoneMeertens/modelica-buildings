within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions;
function pressureLossCircularPipe
  "Pressure loss of a circular pipe using Darcy-Weisbach friction factor"
  extends Modelica.Icons.Function;

  input Modelica.Units.SI.Length length
    "Pipe length";

  input Modelica.Units.SI.Radius rTub
    "Outer tube radius";

  input Modelica.Units.SI.Length eTub
    "Tube wall thickness";

  input Modelica.Units.SI.Length roughness = 0.001e-3
    "Absolute pipe wall roughness";

  input Modelica.Units.SI.Density rhoMed
    "Fluid density";

  input Modelica.Units.SI.DynamicViscosity muMed
    "Fluid dynamic viscosity";

  input Modelica.Units.SI.MassFlowRate m_flow
    "Mass flow rate";

  output Modelica.Units.SI.PressureDifference dp
    "Pressure drop";

protected
  constant Real Re_min = 1e-6
    "Small Reynolds number below which the laminar limit is used";

  Modelica.Units.SI.Radius rTub_in = rTub - eTub
    "Inner tube radius";

  Modelica.Units.SI.Diameter diameter = 2*rTub_in
    "Inner tube diameter";

  Modelica.Units.SI.Area crossArea =
    Modelica.Constants.pi*rTub_in^2
    "Inner cross-sectional area";

  Real eps_D = roughness/diameter
    "Relative roughness";

  Modelica.Units.SI.ReynoldsNumber Re
    "Reynolds number";

  Real lambda2
    "Modified friction coefficient, lambda*Re^2";

algorithm
  assert(rTub > eTub,
    "The outer tube radius rTub must be larger than the tube wall thickness eTub.");

  assert(rhoMed > 0,
    "The fluid density rhoMed must be positive.");

  assert(muMed > 0,
    "The fluid dynamic viscosity muMed must be positive.");

  Re := diameter*abs(m_flow)/(crossArea*muMed);

  /*
    Use lambda2 = lambda*Re^2 for pressure drop.

    For very small Reynolds numbers, do not call the Churchill function with
    Re limited by ReEff and then multiply by Re^2, because that would give
    an artificial quadratic pressure drop below ReEff.

    Instead, use the exact laminar limit:
      lambda = 64/Re
      lambda2 = lambda*Re^2 = 64*Re
  */
  lambda2 :=
    if Re <= Re_min then
      64*Re
    else
      Buildings.Fluid.FixedResistances.Functions.churchillFrictionFactor(
        Re=Re,
        eps_D=eps_D)*Re^2;

  dp :=
    length*muMed^2/(2*rhoMed*diameter^3)*
    (if m_flow >= 0 then lambda2 else -lambda2);

    annotation (
    smoothOrder=1,
    Documentation(info="<html>
<p>
This function computes the pressure loss in a circular pipe using the
Darcy-Weisbach equation. The Darcy friction factor is computed using the
Churchill correlation.
</p>
<p>
The implementation uses the modified friction coefficient
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &lambda;<sub>2</sub> = &lambda; Re<sup>2</sup>
</p>
<p>
and evaluates the pressure drop as
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &Delta;p =
  L &mu;<sup>2</sup> &lambda;<sub>2</sub> /
  (2 &rho; D<sup>3</sup>).
</p>
<p>
For very small Reynolds numbers, the laminar limit
&lambda;<sub>2</sub> = 64 Re is used. This avoids evaluating the pressure drop
from a Reynolds-number-limited friction factor, which would otherwise give an
artificial quadratic pressure-flow relation near zero flow.
</p>
<h4>References</h4>
<p>
Churchill, S. W. (1977). Friction-factor equation spans all fluid-flow regimes.
<i>Chemical Engineering</i>, 84(24), 91&ndash;92.
</p>
</html>",
revisions="<html>
<ul>
<li>
17 July, 2026, by L. Meertens:<br/>
First implementation.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/4656\">Buildings, #4656</a>.
</li>
</ul>
</html>"));

end pressureLossCircularPipe;

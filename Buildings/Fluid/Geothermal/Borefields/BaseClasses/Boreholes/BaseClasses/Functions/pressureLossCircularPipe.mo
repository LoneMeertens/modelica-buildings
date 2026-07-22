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

    The raw Darcy friction factor lambda is singular at Re = 0.
    Therefore, evaluate the modified coefficient lambda2 directly.

    For very small Reynolds numbers, churchillFrictionFactorRe2 uses
    the laminar limit:
      lambda = 64/Re
      lambda2 = lambda*Re^2 = 64*Re

    This gives the correct linear pressure-flow relation near zero flow.
  */

  lambda2 :=
    Buildings.Fluid.FixedResistances.Functions.churchillFrictionFactorRe2(
        Re=Re,
        eps_D=eps_D);

  dp :=
    length*muMed^2/(2*rhoMed*diameter^3)*
    (if m_flow >= 0 then lambda2 else -lambda2);

    annotation (
    smoothOrder=1,
Documentation(info="<html>
<p>
This function computes the pressure loss in a circular pipe using the
Darcy-Weisbach equation.
</p>
<p>
The implementation uses the modified friction coefficient
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &lambda;<sub>2</sub> = f Re<sup>2</sup>,
</p>
<p>
where <i>f</i> is the Darcy-Weisbach friction factor. The modified coefficient
is evaluated by
<a href=\"modelica://Buildings.Fluid.FixedResistances.Functions.churchillFrictionFactorRe2\">
Buildings.Fluid.FixedResistances.Functions.churchillFrictionFactorRe2</a>,
which uses the Churchill (1977) friction-factor correlation for positive
Reynolds numbers and the laminar limit
<i>&lambda;<sub>2</sub> = 64 Re</i> near zero flow.
</p>
<p>
The Reynolds number is
</p>
<p align=\"center\" style=\"font-style:italic;\">
  Re = D |m&#775;| / (A &mu;),
</p>
<p>
where <i>D</i> is the inner pipe diameter, <i>A</i> is the inner pipe
cross-sectional area, <i>&mu;</i> is the dynamic viscosity, and
<i>m&#775;</i> is the mass flow rate.
</p>
<p>
The pressure drop is evaluated as
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &Delta;p =
  sign(m&#775;) L &mu;<sup>2</sup> &lambda;<sub>2</sub> /
  (2 &rho; D<sup>3</sup>).
</p>
<p>
Using <i>&lambda;<sub>2</sub></i> avoids evaluating the singular raw friction
factor at zero flow. In the laminar limit, this gives the correct linear
pressure-flow relation.
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

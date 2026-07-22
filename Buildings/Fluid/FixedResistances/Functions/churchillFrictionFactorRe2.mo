within Buildings.Fluid.FixedResistances.Functions;
function churchillFrictionFactorRe2
  "Modified friction coefficient lambda2 = f*Re^2 using Churchill correlation"
  extends .Modelica.Icons.Function;

  input Real Re(min=0)
    "Reynolds number";
  input Real eps_D(min=0)
    "Relative roughness";
  input Real Re_min(min=0) = 1e-6
    "Below this Reynolds number, use laminar limit lambda2 = 64*Re";

  output Real lambda2
    "Modified friction coefficient f*Re^2";

algorithm
  lambda2 :=
    if Re <= Re_min then
      64*Re
    else
      Buildings.Fluid.FixedResistances.Functions.churchillFrictionFactor(
        Re=Re,
        eps_D=eps_D)*Re^2;

  annotation (
    Documentation(info="<html>
<p>
This function computes the modified Darcy friction coefficient
<i>&lambda;<sub>2</sub></i>,
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &lambda;<sub>2</sub> = f Re<sup>2</sup>,
</p>
<p>
where <i>f</i> is the Darcy-Weisbach friction factor computed with the
Churchill (1977) correlation.
</p>
<p>
Using <i>&lambda;<sub>2</sub></i> is convenient for pressure-drop calculations
because the raw friction factor <i>f</i> is singular at <i>Re</i> = 0, whereas
<i>&lambda;<sub>2</sub></i> has a finite laminar limit.
For laminar flow,
</p>
<p align=\"center\" style=\"font-style:italic;\">
  f = 64/Re,
  &nbsp;&nbsp;
  &lambda;<sub>2</sub> = f Re<sup>2</sup> = 64 Re.
</p>
<p>
For <i>Re</i> &le; <code>Re_min</code>, this function therefore returns the
exact laminar limit <i>&lambda;<sub>2</sub> = 64 Re</i>. For larger Reynolds
numbers, it evaluates the Churchill friction factor and returns
<i>f Re<sup>2</sup></i>.
</p>
<p>
The switch at <code>Re_min</code> is not the laminar-to-turbulent transition.
It is only a numerical guard to avoid evaluating the singular raw friction
factor at zero flow. The Churchill correlation itself provides the continuous
all-regime friction-factor behavior for positive Reynolds numbers.
</p>
<p>
This function should be used in Darcy-Weisbach pressure-drop calculations that
need to include zero or near-zero mass flow.
</p>
<h4>References</h4>
<p>
Churchill, S. W. (1977). Friction-factor equation spans all fluid-flow regimes.
<i>Chemical Engineering</i>, 84(24), 91&ndash;92.
</p>
</html>", revisions="<html>
<ul>
<li>
July 22, 2026, by L. Meertens:<br/>
First implementation.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/4656\">Buildings, #4656</a>.
</li>
</ul>
</html>"));
end churchillFrictionFactorRe2;

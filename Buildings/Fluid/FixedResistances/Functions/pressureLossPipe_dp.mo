within Buildings.Fluid.FixedResistances.Functions;
function pressureLossPipe_dp
  "Single-output wrapper for pressureLossPipe, returning only the total pressure drop"
  extends .Modelica.Icons.Function;

  input .Modelica.Units.SI.Length length
    "Pipe length";
  input .Modelica.Units.SI.Radius rTub
    "Outer tube radius";
  input .Modelica.Units.SI.Length eTub
    "Tube wall thickness";
  input .Modelica.Units.SI.Length roughness = 0.001e-3
    "Absolute pipe wall roughness";
  input .Modelica.Units.SI.Density rhoMed
    "Fluid density";
  input .Modelica.Units.SI.DynamicViscosity muMed
    "Fluid dynamic viscosity";
  input .Modelica.Units.SI.MassFlowRate m_flow
    "Mass flow rate";
  input Real kMinor(unit="1", min=0) = 0
    "Sum of minor-loss coefficients";
  input .Modelica.Units.SI.MassFlowRate m_flow_small(min=.Modelica.Constants.eps) = 1e-4
    "Small mass flow rate for regularization";
  output .Modelica.Units.SI.PressureDifference dp
    "Pressure drop";

protected
  .Modelica.Units.SI.PressureDifference dpMajor
    "Major Darcy-Weisbach pressure drop (discarded)";
  .Modelica.Units.SI.PressureDifference dpMinor
    "Minor pressure drop (discarded)";
  .Modelica.Units.SI.ReynoldsNumber Re
    "Reynolds number (discarded)";

algorithm
  (dp, dpMajor, dpMinor, Re) :=
    .Buildings.Fluid.FixedResistances.Functions.pressureLossPipe(
      length=length,
      rTub=rTub,
      eTub=eTub,
      roughness=roughness,
      rhoMed=rhoMed,
      muMed=muMed,
      m_flow=m_flow,
      kMinor=kMinor,
      m_flow_small=m_flow_small);

  annotation (
    smoothOrder=1,
    Documentation(info="<html>
<p>
Thin wrapper around
<a href=\"modelica://Buildings.Fluid.FixedResistances.Functions.pressureLossPipe\">
Buildings.Fluid.FixedResistances.Functions.pressureLossPipe</a>
that returns only the total pressure drop <code>dp</code>, discarding the
major/minor/Reynolds-number breakdown outputs. Exists so <code>dp_nominal</code>
parameters can be bound directly to a single-expression function call (Modelica
parameter bindings cannot destructure a multi-output function call inline),
making a component's nominal pressure drop a genuine, geometry-and-flow-derived
formula instead of a hand-typed literal that silently goes stale if the
geometry or nominal flow ever changes.
</p>
</html>", revisions="<html>
<ul>
<li>
September 14, 2026:<br/>
First implementation, to let dp_nominal parameters across
ConferenceCollab_2026 be formula-derived from real pipe geometry instead of
left at the library default of 0.
</li>
</ul>
</html>"));
end pressureLossPipe_dp;

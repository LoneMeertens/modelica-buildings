within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.Validation;
model PressureLossCircularPipe
  "Validation model for pressureLossCircularPipe"
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.Length hSeg = 100
    "Length of the pipe";

  parameter Modelica.Units.SI.Radius rTub = 0.02
    "Outer tube radius";

  parameter Modelica.Units.SI.Length eTub = 0.002
    "Tube wall thickness";

  parameter Modelica.Units.SI.Length roughness = 0.001e-3
    "Absolute pipe wall roughness";

  parameter Modelica.Units.SI.Density rhoMed = 1000
    "Density of the fluid";

  parameter Modelica.Units.SI.DynamicViscosity muMed = 1E-3
    "Dynamic viscosity of the fluid";

  final parameter Modelica.Units.SI.Radius rTub_in = rTub - eTub
    "Inner tube radius";

  final parameter Modelica.Units.SI.Diameter diameter = 2*rTub_in
    "Inner tube diameter";

  final parameter Modelica.Units.SI.Area crossArea =
    Modelica.Constants.pi*rTub_in^2
    "Inner cross-sectional area";

  Modelica.Units.SI.ReynoldsNumber Re
    "Reynolds number";

  Modelica.Units.SI.MassFlowRate m_flow
    "Mass flow rate";

  Modelica.Units.SI.PressureDifference dp
    "Pressure drop";

  Real f
    "Darcy-Weisbach friction factor";

  Real lambda2
    "Modified friction coefficient lambda*Re^2";

equation
  Re = time;

  m_flow = Re*crossArea*muMed/diameter;

  dp =
    Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.pressureLossCircularPipe(
      length=hSeg,
      rTub=rTub,
      eTub=eTub,
      roughness=roughness,
      rhoMed=rhoMed,
      muMed=muMed,
      m_flow=m_flow);

  f =
    Buildings.Fluid.FixedResistances.Functions.churchillFrictionFactor(
      Re=Re,
      eps_D=roughness/diameter);

  lambda2 =
    if Re <= 1E-6 then
      64*Re
    else
      f*Re^2;

  annotation (
    __Dymola_Commands(file=
      "modelica://Buildings/Resources/Scripts/Dymola/Fluid/Geothermal/Borefields/BaseClasses/Boreholes/BaseClasses/Functions/Validation/PressureLossCircularPipe.mos"
      "Simulate and plot"),
    experiment(
      StopTime=10000.0,
      Tolerance=1E-6),
    Documentation(info="<html>
<p>
This validation model evaluates
<a href=\"modelica://Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.pressureLossCircularPipe\">
Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.pressureLossCircularPipe</a>
for Reynolds numbers between 0 and 10000.
</p>
<p>
The Reynolds number is prescribed as <code>Re = time</code>. The corresponding
mass flow rate is computed from the pipe geometry and fluid viscosity. This
allows plotting the pressure drop as a direct function of Reynolds number.
</p>
<p>
The validation checks that the pressure drop is finite at zero flow, increases
smoothly with Reynolds number, and follows the laminar pressure-loss limit for
small Reynolds numbers.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 2026, by L. Meertens:<br/>
First implementation.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/4656\">Buildings, #4656</a>.
</li>
</ul>
</html>"));
end PressureLossCircularPipe;

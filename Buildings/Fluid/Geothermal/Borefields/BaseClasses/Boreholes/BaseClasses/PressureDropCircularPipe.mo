within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses;
model PressureDropCircularPipe
  "Major pressure loss of a circular vertical GHE pipe"
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface;

  parameter Boolean computePressureDrop = true
    "Set to true to compute pressure drop";

  parameter Modelica.Units.SI.Length length
    "Pipe length";

  parameter Modelica.Units.SI.Radius rTub
    "Outer tube radius";

  parameter Modelica.Units.SI.Length eTub
    "Tube wall thickness";

  parameter Modelica.Units.SI.Length roughness = 0.001e-3
    "Absolute pipe wall roughness";

  parameter Modelica.Units.SI.Density rhoMed
    "Fluid density";

  parameter Modelica.Units.SI.DynamicViscosity muMed
    "Fluid dynamic viscosity";

equation
  port_a.m_flow + port_b.m_flow = 0;
  m_flow = port_a.m_flow;

  dp =
    if computePressureDrop then
      Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.pressureLossCircularPipe(
        length=length,
        rTub=rTub,
        eTub=eTub,
        roughness=roughness,
        rhoMed=rhoMed,
        muMed=muMed,
        m_flow=m_flow)
    else
      0;

  port_a.h_outflow = inStream(port_b.h_outflow);
  port_b.h_outflow = inStream(port_a.h_outflow);

  port_a.Xi_outflow = inStream(port_b.Xi_outflow);
  port_b.Xi_outflow = inStream(port_a.Xi_outflow);

  port_a.C_outflow = inStream(port_b.C_outflow);
  port_b.C_outflow = inStream(port_a.C_outflow);

  annotation (
    Documentation(info="<html>
<p>
This model computes the major pressure loss of a circular pipe using the
Darcy-Weisbach equation with a Churchill friction factor.
</p>
<p>
It is used for the vertical GHE pipe pressure drop in borehole models. The
pressure drop is evaluated from the instantaneous mass-flow rate.
</p>
<p>
If <code>computePressureDrop=false</code>, the component imposes zero pressure
drop and acts as a hydraulic pass-through. This allows the component to be
inserted without changing the previous nominal-pressure-drop behavior.
</p>
<p>
The fluid density and dynamic viscosity are provided as parameters. A later
extension can replace these with temperature-dependent medium properties.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 18, 2026, by L. Meertens:<br/>
First implementation for Darcy-Weisbach pressure-drop calculation in vertical
GHE pipes.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/4656\">Buildings, #4656</a>.
</li>
</ul>
</html>"));

end PressureDropCircularPipe;

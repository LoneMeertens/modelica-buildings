within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions;

function convectionResistanceCircularPipeOutputsFluProTemDep_Glycol25
  "Convection resistance, with fluid properties computed from current T and p"
  extends .Modelica.Icons.Function;

  // Allow selecting any compatible medium (default to your temperature-dependent water)
  replaceable package Medium = .Buildings.Media.Specialized.Water.TemperatureDependentDensity
    "Medium used to evaluate thermophysical properties";
  // Geometry of the borehole
  input .Modelica.Units.SI.Height hSeg "Height of the element";
  input .Modelica.Units.SI.Radius rTub "Tube radius";
  input .Modelica.Units.SI.Length eTub "Tube thickness";

  // Current state (make p and T inputs so function is purely algebraic)
  input .Modelica.Units.SI.Temperature T "Fluid temperature (K) at which to evaluate properties";
  input .Modelica.Units.SI.Pressure    p = Medium.p_default "Pressure (Pa)";

  // Mass flow inputs (same as before)
  input .Modelica.Units.SI.MassFlowRate m_flow "Mass flow rate";
  input .Modelica.Units.SI.MassFlowRate m_flow_nominal "Nominal mass flow rate";

  // Outputs
  output .Modelica.Units.SI.ThermalResistance RFluPip "Convection resistance";
  output Real Nu "Nusselt";
  output .Modelica.Units.SI.CoefficientOfHeatTransfer h "Convective heat transfer coeff";
  output Real Re "Reynolds number";
  output Real NuTurb "Nusselt at Re=2400";

  // media property outputs ──
  output .Modelica.Units.SI.SpecificHeatCapacity cp
    "Specific heat capacity of fluid [J/kg·K]";
  output .Modelica.Units.SI.ThermalConductivity k
    "Thermal conductivity of fluid [W/m·K]";
  output .Modelica.Units.SI.DynamicViscosity mu
    "Dynamic viscosity of fluid [Pa·s]";
  output .Modelica.Units.SI.Density rho
    "Density of fluid [kg/m³]";
  output Real Pr
    "Prandtl number [-]";

protected
  .Modelica.Units.SI.Radius rTub_in = rTub - eTub "Pipe inner radius";
  Real k_coef "aux coefficient used in Re computation";
  .Modelica.Units.SI.MassFlowRate m_flow_abs;

  // Evaluate medium properties at (p, T) 
algorithm
  cp  := Buildings.Media.Antifreeze.PropyleneGlycolWater.specificHeatCapacityCp_TX_a(
           T=T, X_a=0.25);
  k   := Buildings.Media.Antifreeze.PropyleneGlycolWater.thermalConductivity_TX_a(
           T=T, X_a=0.25);
  mu  := Buildings.Media.Antifreeze.PropyleneGlycolWater.dynamicViscosity_TX_a(
           T=T, X_a=0.25);
  rho := Buildings.Media.Antifreeze.PropyleneGlycolWater.density_TX_a(
           T=T, X_a=0.25);
  Pr  := cp * mu / k;

  // Convection resistance and Reynolds number 
  k_coef := 2 / (mu * .Modelica.Constants.pi * rTub_in);
  m_flow_abs := .Buildings.Utilities.Math.Functions.spliceFunction(
                   m_flow, -m_flow, m_flow, m_flow_nominal / 30);
  Re := m_flow_abs * k_coef;

  if Re >= 2400 then
    Nu := 0.023 * (cp * mu / k)^(0.35) *
          .Buildings.Utilities.Math.Functions.regNonZeroPower(
            x=Re, n=0.8, delta=0.01 * m_flow_nominal * k_coef);
  else
    NuTurb := 0.023 * (cp * mu / k)^(0.35) * (2400)^(0.8);
    Nu := .Buildings.Utilities.Math.Functions.spliceFunction(
            NuTurb, 3.66, Re - (2300 + 2400) / 2, ((2300 + 2400) / 2) - 2300);
  end if;

  h      := Nu * k / (2 * rTub_in);
  RFluPip := 1 / (2 * .Modelica.Constants.pi * rTub_in * hSeg * h);

end convectionResistanceCircularPipeOutputsFluProTemDep_Glycol25;

within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions;
function convectionResistanceCircularPipeTdep
  extends Modelica.Icons.Function;

  input Modelica.Units.SI.Height hSeg;
  input Modelica.Units.SI.Radius rTub;
  input Modelica.Units.SI.Length eTub;
  input Modelica.Units.SI.Temperature T;
  input Modelica.Units.SI.Pressure p;
  input Modelica.Units.SI.MassFlowRate m_flow;
  input Modelica.Units.SI.MassFlowRate m_flow_nominal;
  input Boolean useGlycol = false "True = PropyleneGlycolWater 25%, False = Water";
  input Real X_a = 0.25 "Glycol mass fraction (used only if useGlycol=true)";

  output Modelica.Units.SI.ThermalResistance RFluPip;
  output Real Nu;
  output Modelica.Units.SI.CoefficientOfHeatTransfer h;
  output Real Re;
  output Real NuTurb;
  output Modelica.Units.SI.SpecificHeatCapacity cp;
  output Modelica.Units.SI.ThermalConductivity k;
  output Modelica.Units.SI.DynamicViscosity mu;
  output Modelica.Units.SI.Density rho;
  output Real Pr;

protected
  Modelica.Units.SI.Radius rTub_in = rTub - eTub;
  Real k_coef;
  Modelica.Units.SI.MassFlowRate m_flow_abs;

algorithm
  if useGlycol then
    cp  := Buildings.Media.Antifreeze.PropyleneGlycolWater.specificHeatCapacityCp_TX_a(T=T, X_a=X_a);
    k   := Buildings.Media.Antifreeze.PropyleneGlycolWater.thermalConductivity_TX_a(T=T, X_a=X_a);
    mu  := Buildings.Media.Antifreeze.PropyleneGlycolWater.dynamicViscosity_TX_a(T=T, X_a=X_a);
    rho := Buildings.Media.Antifreeze.PropyleneGlycolWater.density_TX_a(T=T, X_a=X_a);
  else
    cp  := Buildings.Media.Specialized.Water.TemperatureDependentDensity.specificHeatCapacityCp(
               Buildings.Media.Specialized.Water.TemperatureDependentDensity.setState_pTX(p, T, fill(0,0)));
    k   := Buildings.Media.Specialized.Water.TemperatureDependentDensity.thermalConductivity(
               Buildings.Media.Specialized.Water.TemperatureDependentDensity.setState_pTX(p, T, fill(0,0)));
    mu  := Buildings.Media.Specialized.Water.TemperatureDependentDensity.dynamicViscosity(
               Buildings.Media.Specialized.Water.TemperatureDependentDensity.setState_pTX(p, T, fill(0,0)));
    rho := Buildings.Media.Specialized.Water.TemperatureDependentDensity.density(
               Buildings.Media.Specialized.Water.TemperatureDependentDensity.setState_pTX(p, T, fill(0,0)));
  end if;

  Pr     := cp * mu / k;
  k_coef := 2 / (mu * Modelica.Constants.pi * rTub_in);
  m_flow_abs := Buildings.Utilities.Math.Functions.spliceFunction(
                    m_flow, -m_flow, m_flow, m_flow_nominal / 30);
  Re := m_flow_abs * k_coef;

  if Re >= 2400 then
    Nu := 0.023 * Pr^0.35 *
          Buildings.Utilities.Math.Functions.regNonZeroPower(
            x=Re, n=0.8, delta=0.01 * m_flow_nominal * k_coef);
  else
    NuTurb := 0.023 * Pr^0.35 * (2400)^0.8;
    Nu := Buildings.Utilities.Math.Functions.spliceFunction(
            NuTurb, 3.66, Re - (2300 + 2400)/2, ((2300 + 2400)/2) - 2300);
  end if;

  h       := Nu * k / (2 * rTub_in);
  RFluPip := 1 / (2 * Modelica.Constants.pi * rTub_in * hSeg * h);

end convectionResistanceCircularPipeTdep;

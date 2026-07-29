within Testing.BorefieldComparisonTests.BaseClasses;
partial model PartialAnnualTinProfile
  "Common annual sinusoidal borefield inlet temperature profile"

  import Modelica.Units.SI;

  parameter .Modelica.Units.SI.Temperature TInMin = 275.15
    "Minimum borefield inlet temperature, 0 degC";

  parameter .Modelica.Units.SI.Temperature TInMax = 298.15
    "Maximum borefield inlet temperature, 25 degC";

  parameter .Modelica.Units.SI.Time year = 31536000
    "One year";

  parameter .Modelica.Units.SI.SpecificHeatCapacity cp_nominal = 4180
    "Approximate fluid heat capacity used for KPI heat-flow calculation";

  parameter .Modelica.Units.SI.TemperatureDifference TInNoiseAmplitude = 2
    "Maximum random inlet-temperature noise amplitude, +/-5 K = +/-5 degC";

  parameter .Modelica.Units.SI.Time TInNoiseSamplePeriod = 3600
    "Noise sampling period";

  .Modelica.Blocks.Sources.Sine TInSin(
    amplitude = (TInMax - TInMin)/2,
    offset = (TInMax + TInMin)/2,
    f = 1/year,
    phase = -.Modelica.Constants.pi/2)
    "Annual sinusoidal inlet temperature: starts at minimum, peaks mid-year"
    annotation (Placement(transformation(extent={{-164.0,52.0},{-144.0,72.0}},rotation = 0.0,origin = {0.0,0.0})));

  annotation (
    Diagram(coordinateSystem(extent={{-120,-100},{120,100}})),
    Icon(coordinateSystem(extent={{-120,-100},{120,100}})),
    Documentation(info="
<html>
<p>
Common annual sinusoidal borefield inlet temperature profile.
The signal varies between 0 degC and 25 degC over one year.
</p>
</html>"));

end PartialAnnualTinProfile;

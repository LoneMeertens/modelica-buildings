within Testing;
package BorefieldComparisonTests
  "Comparison models for aggregate and zoned geothermal borefield representations"

  package Medium = Buildings.Media.Water
    "Medium used in all borefield comparison cases";
package Data
  "Common geometry, material and zone data for borefield comparison models"

  extends Modelica.Icons.RecordsPackage;

    import Modelica.Units.SI;

  constant Integer nBor = 30
    "Total number of boreholes";

  constant Integer nRow = 3
    "Number of borehole rows";

  constant Integer nCol = 10
    "Number of boreholes per row";

  constant Integer nSeg = 10
    "Vertical discretization per representative borehole";

  constant SI.Length borHolDepth = 100
    "Active borehole length";

  constant SI.Length borHolRadius = 0.075
    "Borehole radius";

  constant SI.Length burDep = 2
    "Burial depth";

  constant SI.Length spacingX = 6
    "Borehole spacing in row direction";

  constant SI.Length spacingY = 6
    "Borehole spacing between rows";

  constant SI.Temperature TGround = 283.15
    "Undisturbed ground temperature";

  constant SI.MassFlowRate mBor_flow_nominal = 0.25
    "Nominal mass flow rate per physical borehole";

  constant SI.MassFlowRate mField_flow_nominal = nBor*mBor_flow_nominal
    "Nominal total borefield mass flow rate";

  constant SI.PressureDifference dp_nominal = 10000
    "Nominal pressure drop of the complete aggregate borefield";

  constant SI.PressureDifference dpZon_nominal = 5000
    "Nominal pressure drop per zone";

  constant SI.Radius rTub = 0.02
    "Outer radius of U-tube pipe";

  constant SI.Length eTub = 0.003
    "Pipe wall thickness";

  constant SI.ThermalConductivity kTub = 0.4
    "Pipe thermal conductivity";

  constant SI.Length xC = 0.025
    "Shank spacing from borehole center to pipe center";

  constant SI.ThermalConductivity kSoi = 2.5
    "Soil thermal conductivity";

  constant SI.SpecificHeatCapacity cSoi = 1000
    "Soil specific heat capacity";

  constant SI.Density dSoi = 2000
    "Soil density";

  constant SI.ThermalConductivity kFil = 1.0
    "Grout/filling thermal conductivity";

  constant SI.SpecificHeatCapacity cFil = 1000
    "Grout/filling specific heat capacity";

  constant SI.Density dFil = 1500
    "Grout/filling density";

  constant SI.Position cooBor[nBor, 2] = {
    {spacingX*mod(k - 1, nCol), spacingY*div(k - 1, nCol)}
    for k in 1:nBor}
    "Physical borehole coordinates for a 3 x 10 rectangular field";

  constant Integer rowZone[nBor] = {
    div(k - 1, nCol) + 1
    for k in 1:nBor}
    "Zone assignment for 3-zone row model";
  
  constant Integer fiveZone[nBor] = {
    if div(k - 1, nCol) == 0 then
      if mod(k - 1, nCol) <= 5 then 1 else 2
    elseif div(k - 1, nCol) == 1 then
      3
    else
      if mod(k - 1, nCol) <= 3 then 4 else 5
    for k in 1:nBor}
    "Zone assignment for 5-zone model";


  constant Integer nineZone[nBor] = {
    3*div(k - 1, nCol) +
      (if mod(k - 1, nCol) <= 2 then 1
       elseif mod(k - 1, nCol) <= 6 then 2
       else 3)
    for k in 1:nBor}
    "Zone assignment for 9-zone model: row x start/middle/end";

  constant Integer boreholeZone[nBor] = {
    k for k in 1:nBor}
    "Zone assignment for 30-zone model: one zone per borehole";

  constant Integer nBorPerZone_3[3] = {10, 10, 10}
    "Number of boreholes per zone for 3-zone model";

  constant Integer nBorPerZone_9[9] = {3, 4, 3, 3, 4, 3, 3, 4, 3}
    "Number of boreholes per zone for 9-zone model";

  constant Integer nBorPerZone_30[30] = fill(1, 30)
    "Number of boreholes per zone for 30-zone model";

  constant Integer nBorPerZone_5[5] = {6, 4, 10, 4, 6}
  "Number of boreholes per zone for 5-zone model";

  // 10x10 borefield

  constant Integer nBor_10x10 = 100
  "Total number of boreholes for 10 x 10 test field";

  constant Integer nRow_10x10 = 10
    "Number of borehole rows for 10 x 10 test field";

  constant Integer nCol_10x10 = 10
    "Number of boreholes per row for 10 x 10 test field";

  constant SI.MassFlowRate mField_flow_nominal_10x10 =
    nBor_10x10*mBor_flow_nominal
    "Nominal total borefield mass flow rate for 10 x 10 test field";

  constant SI.Position cooBor_10x10[nBor_10x10, 2] = {
    {spacingX*mod(k - 1, nCol_10x10), spacingY*div(k - 1, nCol_10x10)}
    for k in 1:nBor_10x10}
    "Physical borehole coordinates for a 10 x 10 rectangular field";

  constant Integer rowBandZone_10x10[nBor_10x10] = {
    if div(k - 1, nCol_10x10) + 1 <= 3 then 1
    elseif div(k - 1, nCol_10x10) + 1 <= 7 then 2
    else 3
    for k in 1:nBor_10x10}
    "Zone assignment for 10 x 10 field split into three row bands";

  constant Integer nBorPerZone_3Bands_10x10[3] = {30, 40, 30}
    "Number of boreholes per zone for 10 x 10 field with three row-band zones";


  annotation (
    preferredView = "info",
    Documentation(info="
<html>
<p>
This package contains common data used by the borefield comparison models.
</p>

<p>
The data includes:
</p>

<ul>
<li>borefield geometry,</li>
<li>borehole coordinates,</li>
<li>zone assignment arrays,</li>
<li>soil, grout and pipe properties,</li>
<li>nominal mass-flow rates and pressure drops.</li>
</ul>

<p>
The same data is used by the aggregate and zoned borefield models to make the
comparison as consistent as possible.
</p>
</html>"));

end Data;

end BorefieldComparisonTests;

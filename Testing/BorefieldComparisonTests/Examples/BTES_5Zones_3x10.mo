within Testing.BorefieldComparisonTests.Examples;
model BTES_5Zones_3x10
  "Zoned BTES model with 5 zones for 3 x 10 borefield"

  extends Modelica.Icons.Example;
  extends Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
    nZon = 5,
    nBorPerZon = Testing.BorefieldComparisonTests.Data.nBorPerZone_5);

  Buildings.Fluid.Geothermal.ZonedBorefields.OneUTube borFie(
    redeclare package Medium = Testing.BorefieldComparisonTests.Medium,
    borFieDat(
      filDat(
        kFil = Testing.BorefieldComparisonTests.Data.kFil,
        cFil = Testing.BorefieldComparisonTests.Data.cFil,
        dFil = Testing.BorefieldComparisonTests.Data.dFil),
      soiDat(
        kSoi = Testing.BorefieldComparisonTests.Data.kSoi,
        cSoi = Testing.BorefieldComparisonTests.Data.cSoi,
        dSoi = Testing.BorefieldComparisonTests.Data.dSoi),
      conDat(
        borCon = Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube,
        use_Rb = false,
        nZon = 5,
        iZon = Testing.BorefieldComparisonTests.Data.fiveZone,
        mBor_flow_nominal = fill(Testing.BorefieldComparisonTests.Data.mBor_flow_nominal, 5),
        dp_nominal = fill(Testing.BorefieldComparisonTests.Data.dpZon_nominal, 5),
        hBor = Testing.BorefieldComparisonTests.Data.borHolDepth,
        rBor = Testing.BorefieldComparisonTests.Data.borHolRadius,
        dBor = Testing.BorefieldComparisonTests.Data.burDep,
        cooBor = Testing.BorefieldComparisonTests.Data.cooBor,
        rTub = Testing.BorefieldComparisonTests.Data.rTub,
        kTub = Testing.BorefieldComparisonTests.Data.kTub,
        eTub = Testing.BorefieldComparisonTests.Data.eTub,
        xC = Testing.BorefieldComparisonTests.Data.xC)),
    nSeg = Testing.BorefieldComparisonTests.Data.nSeg,
    tLoaAgg = 3600,
    nCel = 5,
    TExt0_start = Testing.BorefieldComparisonTests.Data.TGround,
    energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Zoned BTES model with five representative zones"
    annotation (Placement(transformation(extent={{20,-20},{60,20}})));

equation
  for i in 1:nZon loop
    connect(senTIn[i].port_b, borFie.port_a[i])
      annotation (Line(points={{12,0},{20,0}}, color={0,127,255}));

    connect(borFie.port_b[i], senTOut[i].port_a)
      annotation (Line(points={{60,0},{68,0}}, color={0,127,255}));
  end for;

  annotation (
    Diagram(coordinateSystem(extent={{-120,-100},{120,100}})),
    Icon(coordinateSystem(extent={{-120,-100},{120,100}})),
    experiment(
      StartTime = 0,
      StopTime = 31536000,
      Tolerance = 1e-6,
      Interval = 3600),
    Documentation(info="
<html>
<p>
This test model uses a 3 x 10 borefield with five thermal/hydraulic zones.
It is intended as an intermediate compilation stress test between the low-zone
and high-zone BTES cases.
</p>

<p>
The zone grouping is:
</p>

<ul>
<li>zone 1: first row, first six boreholes,</li>
<li>zone 2: first row, last four boreholes,</li>
<li>zone 3: full middle row,</li>
<li>zone 4: last row, first four boreholes,</li>
<li>zone 5: last row, last six boreholes.</li>
</ul>
</html>"));

end BTES_5Zones_3x10;

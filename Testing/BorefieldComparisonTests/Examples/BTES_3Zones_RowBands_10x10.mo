within Testing.BorefieldComparisonTests.Examples;
model BTES_3Zones_RowBands_10x10
  "Zoned BTES model for 10 x 10 borefield with three row-band zones"

  extends Modelica.Icons.Example;
  extends Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
    nZon = 3,
    nBorPerZon = Testing.BorefieldComparisonTests.Data.nBorPerZone_3Bands_10x10);

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
        nZon = 3,
        iZon = Testing.BorefieldComparisonTests.Data.rowBandZone_10x10,
        mBor_flow_nominal = fill(Testing.BorefieldComparisonTests.Data.mBor_flow_nominal, 3),
        dp_nominal = fill(Testing.BorefieldComparisonTests.Data.dpZon_nominal, 3),
        hBor = Testing.BorefieldComparisonTests.Data.borHolDepth,
        rBor = Testing.BorefieldComparisonTests.Data.borHolRadius,
        dBor = Testing.BorefieldComparisonTests.Data.burDep,
        cooBor = Testing.BorefieldComparisonTests.Data.cooBor_10x10,
        rTub = Testing.BorefieldComparisonTests.Data.rTub,
        kTub = Testing.BorefieldComparisonTests.Data.kTub,
        eTub = Testing.BorefieldComparisonTests.Data.eTub,
        xC = Testing.BorefieldComparisonTests.Data.xC)),
    nSeg = Testing.BorefieldComparisonTests.Data.nSeg,
    tLoaAgg = 3600,
    nCel = 5,
    TExt0_start = Testing.BorefieldComparisonTests.Data.TGround,
    energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Zoned BTES model with three row-band zones for a 10 x 10 borefield"
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
This test model uses a 10 x 10 borefield with 100 physical boreholes.
The field is split into three row-band zones:
</p>

<ul>
<li>zone 1: rows 1 to 3, 30 boreholes,</li>
<li>zone 2: rows 4 to 7, 40 boreholes,</li>
<li>zone 3: rows 8 to 10, 30 boreholes.</li>
</ul>

<p>
The model is intended as a compilation and simulation stress test for the
zoned BTES implementation. It increases the number of physical boreholes from
30 to 100 while keeping the number of zones low.
</p>
</html>"));

end BTES_3Zones_RowBands_10x10;

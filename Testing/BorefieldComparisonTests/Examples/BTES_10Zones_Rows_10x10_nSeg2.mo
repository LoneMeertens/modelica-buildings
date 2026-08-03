within Testing.BorefieldComparisonTests.Examples;
model BTES_10Zones_Rows_10x10_nSeg2
  "Zoned BTES model for 10 x 10 borefield with 10 row zones and nSeg = 2"

  extends Modelica.Icons.Example;
  extends .Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
    nZon = 10,
    nBorPerZon = fill(10, 10));

  .Buildings.Fluid.Geothermal.ZonedBorefields.OneUTube borFie(
    redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
    borFieDat(
      filDat(
        kFil = .Testing.BorefieldComparisonTests.Data.kFil,
        cFil = .Testing.BorefieldComparisonTests.Data.cFil,
        dFil = .Testing.BorefieldComparisonTests.Data.dFil),
      soiDat(
        kSoi = .Testing.BorefieldComparisonTests.Data.kSoi,
        cSoi = .Testing.BorefieldComparisonTests.Data.cSoi,
        dSoi = .Testing.BorefieldComparisonTests.Data.dSoi),
      conDat(
        borCon = .Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube,
        use_Rb = false,
        nZon = 10,
        iZon = {
          div(k - 1, .Testing.BorefieldComparisonTests.Data.nCol_10x10) + 1
          for k in 1:.Testing.BorefieldComparisonTests.Data.nBor_10x10},
        mBor_flow_nominal = fill(.Testing.BorefieldComparisonTests.Data.mBor_flow_nominal, 10),
        dp_nominal = fill(.Testing.BorefieldComparisonTests.Data.dpZon_nominal, 10),
        hBor = .Testing.BorefieldComparisonTests.Data.borHolDepth,
        rBor = .Testing.BorefieldComparisonTests.Data.borHolRadius,
        dBor = .Testing.BorefieldComparisonTests.Data.burDep,
        cooBor = .Testing.BorefieldComparisonTests.Data.cooBor_10x10,
        rTub = .Testing.BorefieldComparisonTests.Data.rTub,
        kTub = .Testing.BorefieldComparisonTests.Data.kTub,
        eTub = .Testing.BorefieldComparisonTests.Data.eTub,
        xC = .Testing.BorefieldComparisonTests.Data.xC)),
    nSeg = 2,
    tLoaAgg = 3600,
    nCel = 5,
    TExt0_start = .Testing.BorefieldComparisonTests.Data.TGround,
    energyDynamics = .Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Zoned BTES model with one equivalent borehole row per zone"
    annotation (Placement(transformation(extent={{20,-20},{60,20}})));

equation
  for i in 1:nZon loop
    connect(senTIn[i].port_b, borFie.port_a[i])
      annotation (Line(points={{-65,0},{20,0}}, color={0,127,255}));

    connect(borFie.port_b[i], senTOut[i].port_a)
      annotation (Line(points={{60,0},{110,0}}, color={0,127,255}));
  end for;

  annotation (
    Diagram(coordinateSystem(extent={{-120,-100},{120,100}})),
    Icon(coordinateSystem(extent={{-120,-100},{120,100}})),
    experiment(
      StartTime = 0,
      StopTime = 31536000,
      Tolerance = 1e-6,
      Interval = 3600),
    Documentation(info = "
<html>
<p>
This case uses <code>Buildings.Fluid.Geothermal.ZonedBorefields.OneUTube</code>
with ten zones for a 10 x 10 borefield.
</p>
<p>
Each zone represents one row of ten boreholes. The vertical discretization is
set to <code>nSeg = 2</code>.
</p>
</html>"));

end BTES_10Zones_Rows_10x10_nSeg2;

within Testing.BorefieldComparisonTests.Examples;


  model BTES_30Zones_OnePerBorehole
    "Case 4: zoned BTES model with one zone per physical borehole"

    extends Modelica.Icons.Example;
    extends .Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
      nZon = 30,
      nBorPerZon = .Testing.BorefieldComparisonTests.Data.nBorPerZone_30);

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
          nZon = 30,
          iZon = .Testing.BorefieldComparisonTests.Data.boreholeZone,
          mBor_flow_nominal = fill(.Testing.BorefieldComparisonTests.Data.mBor_flow_nominal, 30),
          dp_nominal = fill(.Testing.BorefieldComparisonTests.Data.dpZon_nominal, 30),
          hBor = .Testing.BorefieldComparisonTests.Data.borHolDepth,
          rBor = .Testing.BorefieldComparisonTests.Data.borHolRadius,
          dBor = .Testing.BorefieldComparisonTests.Data.burDep,
          cooBor = .Testing.BorefieldComparisonTests.Data.cooBor,
          rTub = .Testing.BorefieldComparisonTests.Data.rTub,
          kTub = .Testing.BorefieldComparisonTests.Data.kTub,
          eTub = .Testing.BorefieldComparisonTests.Data.eTub,
          xC = .Testing.BorefieldComparisonTests.Data.xC)),
      nSeg = .Testing.BorefieldComparisonTests.Data.nSeg,
      tLoaAgg = 3600,
      nCel = 5,
      TExt0_start = .Testing.BorefieldComparisonTests.Data.TGround,
      energyDynamics = .Modelica.Fluid.Types.Dynamics.FixedInitial)
      "Zoned BTES model with one representative borehole per physical borehole"
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
      Documentation(info = "
      <html>
      <p>
      This case uses thirty zones, one per physical borehole.
      </p>
      <p>
      It is the highest-fidelity model in this comparison set. It can represent
      edge, corner and center-borehole differences much better than the 3-zone
      and 9-zone models, but the response-factor matrix is much larger and
      compilation/runtime cost can increase substantially.
      </p>
      </html>"));

  end BTES_30Zones_OnePerBorehole;

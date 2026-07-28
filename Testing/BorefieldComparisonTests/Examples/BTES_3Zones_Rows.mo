within Testing.BorefieldComparisonTests.Examples;


  model BTES_3Zones_Rows
    "Case 2: zoned BTES model with 3 row zones"

    extends Modelica.Icons.Example;
    extends .Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
      nZon = 3,
      nBorPerZon = .Testing.BorefieldComparisonTests.Data.nBorPerZone_3);

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
          nZon = 3,
          iZon = .Testing.BorefieldComparisonTests.Data.rowZone,
          mBor_flow_nominal = fill(.Testing.BorefieldComparisonTests.Data.mBor_flow_nominal, 3),
          dp_nominal = fill(.Testing.BorefieldComparisonTests.Data.dpZon_nominal, 3),
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
      "Zoned BTES model with one equivalent borehole per row"
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
      This case uses <code>Buildings.Fluid.Geothermal.ZonedBorefields.OneUTube</code>
      with three zones. Each zone represents one row of ten boreholes.
      </p>
      <p>
      This captures row-level differences, such as middle-row versus edge-row
      response, but still averages the ten boreholes inside each row.
      </p>
      </html>"));

  end BTES_3Zones_Rows;

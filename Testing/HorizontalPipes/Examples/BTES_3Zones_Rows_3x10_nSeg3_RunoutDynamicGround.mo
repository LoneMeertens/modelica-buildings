within Testing.HorizontalPipes.Examples;
model BTES_3Zones_Rows_3x10_nSeg3_RunoutDynamicGround
  "3-zone BTES validation model with dynamic-ground horizontal runout pipes"

  extends Modelica.Icons.Example;
  extends .Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
    nZon = 3,
    nBorPerZon = .Testing.BorefieldComparisonTests.Data.nBorPerZone_3);

  parameter Modelica.Units.SI.Length lRunoutSup[nZon] = fill(20, nZon)
    "Supply runout length per zone";

  parameter Modelica.Units.SI.Length lRunoutRet[nZon] = fill(20, nZon)
    "Return runout length per zone";

  parameter Modelica.Units.SI.Diameter dhRunout = 2*
    (.Testing.BorefieldComparisonTests.Data.rTub -
     .Testing.BorefieldComparisonTests.Data.eTub)
    "Runout pipe hydraulic diameter";

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
    nSeg = 3,
    tLoaAgg = 3600,
    nCel = 5,
    TExt0_start = .Testing.BorefieldComparisonTests.Data.TGround,
    energyDynamics = .Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Zoned BTES model with one equivalent borehole per row"
    annotation (Placement(transformation(extent={{-10,-30},{50,30}})));

  .Testing.HorizontalPipes.BaseClasses.DynamicGroundRunoutPipe
    runoutSup[nZon](
      redeclare each package Medium = .Testing.BorefieldComparisonTests.Medium,
      length = lRunoutSup,
      each dh = dhRunout,
      m_flow_nominal = mZon_flow_nominal,
      m_flow_start = mZon_flow_nominal,
      each T_start = .Testing.BorefieldComparisonTests.Data.TGround,
      each computePressureDrop = true,
      each use_TDepPressureDrop = true)
    "Supply-side dynamic-ground horizontal runout pipes"
    annotation (Placement(transformation(extent={{-60.0,-15.0},{-30.0,15.0}},rotation = 0.0,origin = {0.0,0.0})));

  .Testing.HorizontalPipes.BaseClasses.DynamicGroundRunoutPipe
    runoutRet[nZon](
      redeclare each package Medium = .Testing.BorefieldComparisonTests.Medium,
      length = lRunoutRet,
      each dh = dhRunout,
      m_flow_nominal = mZon_flow_nominal,
      m_flow_start = mZon_flow_nominal,
      each T_start = .Testing.BorefieldComparisonTests.Data.TGround,
      each computePressureDrop = true,
      each use_TDepPressureDrop = true)
    "Return-side dynamic-ground horizontal runout pipes"
    annotation (Placement(transformation(extent={{70,-15},{100,15}})));


equation
  for i in 1:nZon loop
    connect(senTIn[i].port_b, runoutSup[i].port_a)
      annotation (Line(points={{-65,0},{-60,0}}, color={0,127,255}));

    connect(runoutSup[i].port_b, borFie.port_a[i])
      annotation (Line(points={{-30,0},{-10,0}}, color={0,127,255}));

    connect(borFie.port_b[i], runoutRet[i].port_a)
      annotation (Line(points={{50,0},{70,0}}, color={0,127,255}));

    connect(runoutRet[i].port_b, senTOut[i].port_a)
      annotation (Line(points={{100,0},{110,0}}, color={0,127,255}));
  end for;

  annotation (
    Diagram(coordinateSystem(extent={{-180,-100},{180,100}})),
    Icon(coordinateSystem(extent={{-180,-100},{180,100}})),
    experiment(
      StartTime = 0,
      StopTime = 31536000,
      Tolerance = 1e-6,
      Interval = 3600));

end BTES_3Zones_Rows_3x10_nSeg3_RunoutDynamicGround;

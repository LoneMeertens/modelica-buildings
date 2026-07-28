within Testing.BorefieldComparisonTests.Examples;
model BTES_3Zones_Rows_3x10_UnequalFlow
  "Zoned BTES model with 3 row zones and unequal mass-flow distribution"

  extends Modelica.Icons.Example;

  extends Testing.BorefieldComparisonTests.BaseClasses.PartialZonedBTES(
    nZon = 3,
    nBorPerZon = Testing.BorefieldComparisonTests.Data.nBorPerZone_3,
    mZon_flow_nominal = {
      1.2*Testing.BorefieldComparisonTests.Data.nBorPerZone_3[1]
        *Testing.BorefieldComparisonTests.Data.mBor_flow_nominal,
      1.0*Testing.BorefieldComparisonTests.Data.nBorPerZone_3[2]
        *Testing.BorefieldComparisonTests.Data.mBor_flow_nominal,
      0.8*Testing.BorefieldComparisonTests.Data.nBorPerZone_3[3]
        *Testing.BorefieldComparisonTests.Data.mBor_flow_nominal});

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
        iZon = Testing.BorefieldComparisonTests.Data.rowZone,
        mBor_flow_nominal = {
          1.2*Testing.BorefieldComparisonTests.Data.mBor_flow_nominal,
          1.0*Testing.BorefieldComparisonTests.Data.mBor_flow_nominal,
          0.8*Testing.BorefieldComparisonTests.Data.mBor_flow_nominal},
        dp_nominal = fill(Testing.BorefieldComparisonTests.Data.dpZon_nominal, 3),
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
    "Zoned BTES model with unequal row mass-flow distribution"
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
This model is based on the three-row zoned BTES comparison case, but applies an
unequal mass-flow distribution over the three row zones.
</p>

<p>
The nominal equal-flow case has 10 boreholes per zone and a nominal per-borehole
mass flow rate of <code>Data.mBor_flow_nominal</code>. This gives the same mass
flow in each row zone.
</p>

<p>
In this model, the zone flow distribution is modified as follows:
</p>

<ul>
<li>zone 1: +20 percent relative to equal distribution,</li>
<li>zone 2: nominal equal-distribution flow,</li>
<li>zone 3: -20 percent relative to equal distribution.</li>
</ul>

<p>
For the default data this gives:
</p>

<ul>
<li>zone 1: 3.0 kg/s,</li>
<li>zone 2: 2.5 kg/s,</li>
<li>zone 3: 2.0 kg/s.</li>
</ul>

<p>
The total field mass flow remains equal to the original total mass flow. This
makes the model suitable for comparing the effect of unequal row flow
distribution against the equal-flow three-zone reference case.
</p>
</html>"));

end BTES_3Zones_Rows_3x10_UnequalFlow;

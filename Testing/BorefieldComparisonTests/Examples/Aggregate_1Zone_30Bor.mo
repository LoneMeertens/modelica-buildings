within Testing.BorefieldComparisonTests.Examples;
  model Aggregate_1Zone_30Bor
    "Case 1: normal aggregate borefield model with 30 physical boreholes"

    extends Modelica.Icons.Example;
    extends .Testing.BorefieldComparisonTests.BaseClasses.PartialAnnualTinProfile;

    import Modelica.Units.SI;

    parameter .Modelica.Units.SI.MassFlowRate m_flow_nominal = .Testing.BorefieldComparisonTests.Data.mField_flow_nominal
      "Total nominal mass flow rate through the aggregate borefield";

    .Buildings.Fluid.Sources.MassFlowSource_T sou(
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      use_m_flow_in = false,
      use_T_in = true,
      m_flow = m_flow_nominal,
      T = (TInMin + TInMax)/2,
      nPorts = 1)
      "Total-field mass-flow source with prescribed annual inlet temperature"
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));

    .Buildings.Fluid.Geothermal.Borefields.OneUTube borFie(
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
          mBor_flow_nominal = .Testing.BorefieldComparisonTests.Data.mBor_flow_nominal,
          dp_nominal = .Testing.BorefieldComparisonTests.Data.dp_nominal,
          use_DarcyPressureDrop = false,
          use_TDepPressureDrop = false,
          use_TDepRConv = false,
          hBor = .Testing.BorefieldComparisonTests.Data.borHolDepth,
          rBor = .Testing.BorefieldComparisonTests.Data.borHolRadius,
          dBor = .Testing.BorefieldComparisonTests.Data.burDep,
          cooBor = .Testing.BorefieldComparisonTests.Data.cooBor,
          rTub = .Testing.BorefieldComparisonTests.Data.rTub,
          kTub = .Testing.BorefieldComparisonTests.Data.kTub,
          eTub = .Testing.BorefieldComparisonTests.Data.eTub,
          xC = .Testing.BorefieldComparisonTests.Data.xC)),
      nSeg = .Testing.BorefieldComparisonTests.Data.nSeg,
      nSegGFun = .Testing.BorefieldComparisonTests.Data.nSeg,
      nClu = 5,
      tLoaAgg = 3600,
      nCel = 5,
      TExt0_start = .Testing.BorefieldComparisonTests.Data.TGround,
      energyDynamics = .Modelica.Fluid.Types.Dynamics.FixedInitial)
      "Normal aggregate borefield model: one equivalent hydraulic borehole"
      annotation (Placement(transformation(extent={{20,-20},{60,20}})));


    .Buildings.Fluid.Sources.Boundary_pT sin(
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      nPorts = 1)
      "Pressure boundary"
      annotation (Placement(transformation(extent={{112,-10},{92,10}})));

    .Modelica.Fluid.Sensors.TemperatureTwoPort senTIn(
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      m_flow_nominal = m_flow_nominal)
      "Borefield inlet temperature sensor"
      annotation (Placement(transformation(extent={{-8,-10},{12,10}})));

    .Modelica.Fluid.Sensors.TemperatureTwoPort senTOut(
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      m_flow_nominal = m_flow_nominal)
      "Borefield outlet temperature sensor"
      annotation (Placement(transformation(extent={{68,-10},{88,10}})));

    .Modelica.Fluid.Sensors.MassFlowRate senMasFlo(
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium)
      "Total borefield mass-flow sensor"
      annotation (Placement(transformation(extent={{-42,-10},{-22,10}})));

    output .Modelica.Units.SI.Temperature KPI_T_in = senTIn.T
      "Common KPI: borefield inlet temperature";

    output .Modelica.Units.SI.Temperature KPI_T_out = senTOut.T
      "Common KPI: borefield outlet temperature";

    output .Modelica.Units.SI.TemperatureDifference KPI_dT = KPI_T_out - KPI_T_in
      "Common KPI: outlet minus inlet temperature";

    output .Modelica.Units.SI.MassFlowRate KPI_m_flow = senMasFlo.m_flow
      "Common KPI: total borefield mass flow rate";

    output .Modelica.Units.SI.HeatFlowRate KPI_Q_flow =
      KPI_m_flow*cp_nominal*(KPI_T_in - KPI_T_out)
      "Common KPI: resulting heat flow from fluid to ground";

    output .Modelica.Units.SI.Energy KPI_E(start = 0, fixed = true)
      "Common KPI: time integral of resulting borefield heat flow";

    output Real KPI_T_in_C(unit = "degC") = KPI_T_in - 273.15
      "Common KPI: borefield inlet temperature in degC";

    output Real KPI_T_out_C(unit = "degC") = KPI_T_out - 273.15
      "Common KPI: borefield outlet temperature in degC";

  equation
    der(KPI_E) = KPI_Q_flow;

    connect(sou.ports[1], senMasFlo.port_a)
      annotation (Line(points={{-90,0},{-42,0}}, color={0,127,255}));

    connect(senMasFlo.port_b, senTIn.port_a)
      annotation (Line(points={{-22,0},{-8,0}}, color={0,127,255}));

    connect(senTIn.port_b, borFie.port_a)
      annotation (Line(points={{12,0},{20,0}}, color={0,127,255}));

    connect(borFie.port_b, senTOut.port_a)
      annotation (Line(points={{60,0},{68,0}}, color={0,127,255}));

    connect(senTOut.port_b, sin.ports[1])
      annotation (Line(points={{88,0},{92,0}}, color={0,127,255}));
        connect(TInSin.y,sou.T_in) annotation(Line(points = {{-69,60},{-63,60},{-63,32},{-116,32},{-116,4},{-112,4}},color = {0,0,127}));

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
      This case uses <code>Buildings.Fluid.Geothermal.Borefields.OneUTube</code>
      for the complete 3 x 10 field. The external hydraulic model sees one
      field-level inlet and outlet. Internally, the borefield model represents
      the field by one equivalent borehole and scales the mass flow and heat
      transfer according to the total number of boreholes.
      </p>
      <p>
      Use this as the low-order reference case.
      </p>
      </html>"));


  end Aggregate_1Zone_30Bor;

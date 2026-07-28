within Testing.BorefieldComparisonTests.BaseClasses;


  partial model PartialZonedBTES
    "Common structure for zoned BTES comparison cases"

    extends .Testing.BorefieldComparisonTests.BaseClasses.PartialAnnualTinProfile;

    import Modelica.Units.SI;

    parameter Integer nZon(min = 1)
      "Number of hydraulic/thermal zones";

    parameter Integer nBorPerZon[nZon]
      "Number of physical boreholes represented by each zone";

    parameter .Modelica.Units.SI.MassFlowRate mZon_flow_nominal[nZon] =
      {nBorPerZon[i]*.Testing.BorefieldComparisonTests.Data.mBor_flow_nominal for i in 1:nZon}
      "Nominal mass flow rate per zone";

    parameter .Modelica.Units.SI.MassFlowRate m_flow_nominal = sum(mZon_flow_nominal)
      "Total nominal mass flow rate through all zones";

    .Buildings.Fluid.Sources.MassFlowSource_T sou[nZon](
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      each use_m_flow_in = false,
      each use_T_in = true,
      m_flow = mZon_flow_nominal,
      each T = (TInMin + TInMax)/2,
      each nPorts = 1)
      "One mass-flow source per zone with prescribed annual inlet temperature"
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));

    .Buildings.Fluid.Sources.Boundary_pT sin[nZon](
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      each nPorts = 1)
      "One pressure boundary per zone"
      annotation (Placement(transformation(extent={{112,-10},{92,10}})));

    .Modelica.Fluid.Sensors.TemperatureTwoPort senTIn[nZon](
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      m_flow_nominal = mZon_flow_nominal)
      "Zone inlet temperature sensors"
      annotation (Placement(transformation(extent={{-8,-10},{12,10}})));

    .Modelica.Fluid.Sensors.TemperatureTwoPort senTOut[nZon](
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium,
      m_flow_nominal = mZon_flow_nominal)
      "Zone outlet temperature sensors"
      annotation (Placement(transformation(extent={{68,-10},{88,10}})));

    .Modelica.Fluid.Sensors.MassFlowRate senMasFlo[nZon](
      redeclare package Medium = .Testing.BorefieldComparisonTests.Medium)
      "Zone mass-flow sensors"
      annotation (Placement(transformation(extent={{-42,-10},{-22,10}})));

    output .Modelica.Units.SI.Temperature KPI_T_in =
      sum({max(0, senMasFlo[i].m_flow)*senTIn[i].T for i in 1:nZon}) /
      max(1e-6, sum({max(0, senMasFlo[i].m_flow) for i in 1:nZon}))
      "Common KPI: mass-flow-weighted average zone inlet temperature";

    output .Modelica.Units.SI.Temperature KPI_T_out =
      sum({max(0, senMasFlo[i].m_flow)*senTOut[i].T for i in 1:nZon}) /
      max(1e-6, sum({max(0, senMasFlo[i].m_flow) for i in 1:nZon}))
      "Common KPI: mass-flow-weighted average zone outlet temperature";

    output .Modelica.Units.SI.TemperatureDifference KPI_dT = KPI_T_out - KPI_T_in
      "Common KPI: outlet minus inlet temperature";

    output .Modelica.Units.SI.MassFlowRate KPI_m_flow =
      sum({senMasFlo[i].m_flow for i in 1:nZon})
      "Common KPI: total borefield mass flow rate";

    output .Modelica.Units.SI.HeatFlowRate KPI_Q_flow =
      sum({max(0, senMasFlo[i].m_flow)*cp_nominal*(senTIn[i].T - senTOut[i].T)
          for i in 1:nZon})
      "Common KPI: resulting total heat flow from fluid to ground";

    output .Modelica.Units.SI.Energy KPI_E(start = 0, fixed = true)
      "Common KPI: time integral of resulting total borefield heat flow";

    output Real KPI_T_in_C(unit = "degC") = KPI_T_in - 273.15
      "Common KPI: average inlet temperature in degC";

    output Real KPI_T_out_C(unit = "degC") = KPI_T_out - 273.15
      "Common KPI: average outlet temperature in degC";

    output .Modelica.Units.SI.Temperature KPI_T_out_zon[nZon] =
      {senTOut[i].T for i in 1:nZon}
      "Zone KPI: outlet temperature per zone";

    output .Modelica.Units.SI.MassFlowRate KPI_m_flow_zon[nZon] =
      {senMasFlo[i].m_flow for i in 1:nZon}
      "Zone KPI: mass flow per zone";

    output .Modelica.Units.SI.HeatFlowRate KPI_Q_flow_zon[nZon] =
      {max(0, senMasFlo[i].m_flow)*cp_nominal*(senTIn[i].T - senTOut[i].T)
      for i in 1:nZon}
      "Zone KPI: resulting heat flow from fluid to ground per zone";

  equation
    der(KPI_E) = KPI_Q_flow;

    for i in 1:nZon loop
      connect(TInSin.y,sou[i].T_in) 
      annotation(Line(points = {{-69,60},{-63,60},{-63,32},{-116,32},{-116,4},{-112,4}},color = {0,0,127}));

      connect(sou[i].ports[1], senMasFlo[i].port_a)
        annotation (Line(points={{-90,0},{-42,0}}, color={0,127,255}));

      connect(senMasFlo[i].port_b, senTIn[i].port_a)
        annotation (Line(points={{-22,0},{-8,0}}, color={0,127,255}));

      connect(senTOut[i].port_b, sin[i].ports[1])
        annotation (Line(points={{88,0},{92,0}}, color={0,127,255}));
    end for;
        

    annotation (
      Diagram(coordinateSystem(extent={{-120,-100},{120,100}})),
      Icon(coordinateSystem(extent={{-120,-100},{120,100}})),
      Documentation(info = "
      <html>
      <p>
      Base class for zoned BTES comparison cases. Each zone has its own
      hydraulic branch, heat input, inlet sensor, outlet sensor and mass-flow
      sensor. The derived models only need to instantiate the appropriate
      zoned borefield component and connect its zone ports.
      </p>
      </html>"));


  end PartialZonedBTES;

within ModelTesting;
model BorefieldsDynFluPropWater_OneUTubeTdep_MediumTdep
  "Validation model of borefields with different media specifications operating simultaneously"
  extends .Modelica.Icons.Example;

  package MediumTdep = .Buildings.Media.Specialized.Water.TemperatureDependentDensity;
  package Medium = .Buildings.Media.Water;
  parameter .Modelica.Units.SI.Time tLoaAgg=300
    "Time resolution of load aggregation";

  parameter .Modelica.Units.SI.MassFlowRate m_flow_nominal=borFieUTubDat.conDat.mBorFie_flow_nominal/4;
  parameter Real freq = 1/3600 "sinusoid frequency in Hz (1/3600 = 1 cycle per hour)";
  parameter Real phase = 0 "phase shift (rad)";

  parameter .Modelica.Units.SI.Temperature TGro=283.15 "Ground temperature";
  parameter .Buildings.Fluid.Geothermal.Borefields.Data.Borefield.Example borFieUTubDat(
    filDat=.Buildings.Fluid.Geothermal.Borefields.Data.Filling.Bentonite(
    steadyState=true),
    conDat=.Buildings.Fluid.Geothermal.Borefields.Data.Configuration.Example(
    borCon=.Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube))
    annotation (Placement(transformation(extent={{-88,72},{-68,92}})));

  .Buildings.Fluid.Geothermal.Borefields.OneUTubeTdep borFieUTub1(
    redeclare package Medium = MediumTdep,
    borFieDat=borFieUTubDat,
    tLoaAgg=tLoaAgg,
    energyDynamics=.Modelica.Fluid.Types.Dynamics.FixedInitial,
    TExt0_start=TGro) "Borefield with a U-tube borehole configuration"
    annotation (Placement(transformation(extent={{30,50},{50,70}})));
  .Buildings.Fluid.Sources.MassFlowSource_T sou1(
    redeclare package Medium = MediumTdep,
    nPorts=1,
    use_T_in=false,
    m_flow=m_flow_nominal,
    T=303.15) "Source" annotation (Placement(transformation(extent={{-52,50},{-32,
            70}}, rotation=0)));
  .Buildings.Fluid.Sensors.TemperatureTwoPort TUTubIn1(
    redeclare package Medium = MediumTdep,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Inlet temperature of the borefield with UTube configuration"
    annotation (Placement(transformation(extent={{-20,50},{0,70}})));
  .Buildings.Fluid.Sources.Boundary_pT sin1(
    redeclare package Medium = MediumTdep,
    use_p_in=false,
    use_T_in=false,
    nPorts=1,
    p=101330,
    T=283.15) "Sink" annotation (Placement(transformation(extent={{130,50},{110,
            70}}, rotation=0)));
  .Buildings.Fluid.Sensors.TemperatureTwoPort TUTubOut1(
    redeclare package Medium = MediumTdep,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Inlet temperature of the borefield with UTube configuration"
    annotation (Placement(transformation(extent={{80,50},{100,70}})));
equation

  connect(TUTubIn1.port_b,borFieUTub1. port_a)
    annotation (Line(points={{0,60},{30,60}}, color={0,127,255}));
  connect(borFieUTub1.port_b,TUTubOut1. port_a)
    annotation (Line(points={{50,60},{80,60}}, color={0,127,255}));
  connect(TUTubOut1.port_b,sin1. ports[1])
    annotation (Line(points={{100,60},{110,60}}, color={0,127,255}));
  connect(TUTubIn1.port_a,sou1. ports[1])
    annotation (Line(points={{-20,60},{-32,60}}, color={0,127,255}));
  annotation (__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Geothermal/Borefields/Examples/Borefields.mos"
        "Simulate and plot"),
  Documentation(info="<html>
<p>
This example shows three different borefields, each with a different configuration
(single U-tube, double U-tube in parallel, and double U-tube in series) and compares
the thermal behaviour of the circulating fluid in each case.
</p>
</html>",
revisions="<html>
<ul>
<li>
May 17, 2024, by Michael Wetter:<br/>
Updated model due to removal of parameter <code>dynFil</code>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1885\">IBPSA, #1885</a>.
</li>
<li>
April 8, 2021, by Michael Wetter:<br/>
Added missing <code>parameter</code> keyword.<br/>
For <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1464\">IBPSA, issue 1464</a>.
</li>
<li>
June 2018, by Damien Picard:<br/>
First implementation.
</li>
</ul>
</html>"),
    experiment(
      StopTime=36000,Tolerance=1e-6),
    Diagram(coordinateSystem(extent={{-100,-100},{180,100}}), graphics={
        Rectangle(extent={{-60,76},{140,42}}, lineColor={28,108,200}),
        Text(
          extent={{-58,84},{168,78}},
          textColor={28,108,200},
          textString=
              "Temperature-dependent fluid properties (MediumTdep = Buildings.Media.Specialized.Water.TemperatureDependentDensity)")}));
end BorefieldsDynFluPropWater_OneUTubeTdep_MediumTdep;

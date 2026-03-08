within Buildings.Fluid.Geothermal.Borefields.Examples;
model BorefieldsDynFluPropWater_OneUTube_MediumTdep
  "Validation model of borefields with different media specifications operating simultaneously"
  extends Modelica.Icons.Example;

  package MediumTdep = Buildings.Media.Specialized.Water.TemperatureDependentDensity;
  package Medium = Buildings.Media.Water;
  parameter Modelica.Units.SI.Time tLoaAgg=300
    "Time resolution of load aggregation";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=borFieUTubDat.conDat.mBorFie_flow_nominal/4;
  parameter Real freq = 1/3600 "sinusoid frequency in Hz (1/3600 = 1 cycle per hour)";
  parameter Real phase = 0 "phase shift (rad)";

  parameter Modelica.Units.SI.Temperature TGro=283.15 "Ground temperature";
  parameter Buildings.Fluid.Geothermal.Borefields.Data.Borefield.Example borFieUTubDat(
    filDat=Buildings.Fluid.Geothermal.Borefields.Data.Filling.Bentonite(
    steadyState=true),
    conDat=Buildings.Fluid.Geothermal.Borefields.Data.Configuration.Example(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube))
    annotation (Placement(transformation(extent={{-88,72},{-68,92}})));

  Buildings.Fluid.Geothermal.Borefields.OneUTube borFieUTub3(
    redeclare package Medium = MediumTdep,
    borFieDat=borFieUTubDat,
    tLoaAgg=tLoaAgg,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    TExt0_start=TGro) "Borefield with a U-tube borehole configuration"
    annotation (Placement(transformation(extent={{34,-40},{54,-20}})));
  Buildings.Fluid.Sources.MassFlowSource_T sou3(
    redeclare package Medium = MediumTdep,
    nPorts=1,
    use_T_in=false,
    m_flow=m_flow_nominal,
    T=303.15) "Source" annotation (Placement(transformation(extent={{-48,-40},{-28,
            -20}}, rotation=0)));
  Buildings.Fluid.Sensors.TemperatureTwoPort TUTubIn3(
    redeclare package Medium = MediumTdep,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Inlet temperature of the borefield with UTube configuration"
    annotation (Placement(transformation(extent={{-16,-40},{4,-20}})));
  Buildings.Fluid.Sources.Boundary_pT sin3(
    redeclare package Medium = MediumTdep,
    use_p_in=false,
    use_T_in=false,
    nPorts=1,
    p=101330,
    T=283.15) "Sink" annotation (Placement(transformation(extent={{134,-40},{114,
            -20}}, rotation=0)));
  Buildings.Fluid.Sensors.TemperatureTwoPort TUTubOut3(
    redeclare package Medium = MediumTdep,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Inlet temperature of the borefield with UTube configuration"
    annotation (Placement(transformation(extent={{84,-40},{104,-20}})));
equation

  connect(TUTubIn3.port_b,borFieUTub3. port_a)
    annotation (Line(points={{4,-30},{34,-30}}, color={0,127,255}));
  connect(borFieUTub3.port_b,TUTubOut3. port_a)
    annotation (Line(points={{54,-30},{84,-30}}, color={0,127,255}));
  connect(TUTubOut3.port_b,sin3. ports[1])
    annotation (Line(points={{104,-30},{114,-30}}, color={0,127,255}));
  connect(TUTubIn3.port_a,sou3. ports[1])
    annotation (Line(points={{-16,-30},{-28,-30}}, color={0,127,255}));
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
        Rectangle(extent={{-60,-14},{140,-48}}, lineColor={28,108,200}),
        Text(
          extent={{-54,-8},{168,-10}},
          textColor={28,108,200},
          textString=
              "Temperature-dependent fluid properties (MediumTdep = Buildings.Media.Specialized.Water.TemperatureDependentDensity)")}));
end BorefieldsDynFluPropWater_OneUTube_MediumTdep;

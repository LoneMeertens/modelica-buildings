within Buildings.Fluid.Geothermal.Borefields.Examples;
model BorefieldsDynFluPropWater_OneUTubeTdep_Medium
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

  OneUTubeTdep                                       borFieUTub2(
    redeclare package Medium = Medium,
    borFieDat=borFieUTubDat,
    tLoaAgg=tLoaAgg,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    TExt0_start=TGro) "Borefield with a U-tube borehole configuration"
    annotation (Placement(transformation(extent={{34,4},{54,24}})));
  Sources.MassFlowSource_T                 sou2(
    redeclare package Medium = Medium,
    nPorts=1,
    use_T_in=false,
    m_flow=m_flow_nominal,
    T=303.15) "Source" annotation (Placement(transformation(extent={{-48,4},{
            -28,24}},
                  rotation=0)));
  Sensors.TemperatureTwoPort                 TUTubIn2(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Inlet temperature of the borefield with UTube configuration"
    annotation (Placement(transformation(extent={{-16,4},{4,24}})));
  Sources.Boundary_pT                 sin2(
    redeclare package Medium = Medium,
    use_p_in=false,
    use_T_in=false,
    nPorts=1,
    p=101330,
    T=283.15) "Sink" annotation (Placement(transformation(extent={{134,4},{114,
            24}},
          rotation=0)));
  Sensors.TemperatureTwoPort                 TUTubOut2(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Inlet temperature of the borefield with UTube configuration"
    annotation (Placement(transformation(extent={{84,4},{104,24}})));
equation

  connect(TUTubIn2.port_b,borFieUTub2. port_a)
    annotation (Line(points={{4,14},{34,14}},   color={0,127,255}));
  connect(borFieUTub2.port_b,TUTubOut2. port_a)
    annotation (Line(points={{54,14},{84,14}},   color={0,127,255}));
  connect(TUTubOut2.port_b,sin2. ports[1])
    annotation (Line(points={{104,14},{114,14}},   color={0,127,255}));
  connect(TUTubIn2.port_a,sou2. ports[1])
    annotation (Line(points={{-16,14},{-28,14}},   color={0,127,255}));
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
        Rectangle(extent={{-60,30},{140,-4}},  lineColor={28,108,200}),
        Text(
          extent={{-56,36},{156,38}},
          textColor={28,108,200},
          textString=
              "Fixed fluid properties for Medium, temperature varying heat transfer fluid properties (Medium = Buildings.Media.Water)")}));
end BorefieldsDynFluPropWater_OneUTubeTdep_Medium;

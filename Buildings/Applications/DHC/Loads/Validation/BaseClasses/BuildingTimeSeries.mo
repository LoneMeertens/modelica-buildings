within Buildings.Applications.DHC.Loads.Validation.BaseClasses;
model BuildingTimeSeries
  "Building model where heating and cooling loads are provided by time series and time functions"
  extends Buildings.Applications.DHC.Loads.BaseClasses.PartialBuilding(
    redeclare package Medium = Buildings.Media.Water,
    have_fan=false,
    have_pum=true,
    have_eleHea=false,
    have_eleCoo=false,
    have_weaBus=false);
  package Medium2 = Buildings.Media.Air
    "Load side medium";
  parameter String filPat
    "Library path of the file with thermal loads as time series";
  parameter Modelica.SIunits.Temperature T_aHeaWat_nominal(
    min=273.15, displayUnit="degC") = 273.15 + 40
    "Heating water inlet temperature at nominal conditions"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bHeaWat_nominal(
    min=273.15, displayUnit="degC") = T_aHeaWat_nominal - 5
    "Heating water outlet temperature at nominal conditions"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aChiWat_nominal(
    min=273.15, displayUnit="degC") = 273.15 + 18
    "Chilled water inlet temperature at nominal conditions "
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bChiWat_nominal(
    min=273.15, displayUnit="degC") = T_aChiWat_nominal + 5
    "Chilled water outlet temperature at nominal conditions"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aLoaHea_nominal(
    min=273.15, displayUnit="degC") = 273.15 + 20
    "Load side inlet temperature at nominal conditions in heating mode"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aLoaCoo_nominal(
    min=273.15, displayUnit="degC") = 273.15 + 24
    "Load side inlet temperature at nominal conditions in cooling mode"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal(max=-Modelica.Constants.eps)=
    Buildings.Experimental.DistrictHeatingCooling.SubStations.VaporCompression.BaseClasses.getPeakLoad(
    string="#Peak space cooling load",
    filNam=Modelica.Utilities.Files.loadResource(filPat))
    "Design cooling heat flow rate (<=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(min=Modelica.Constants.eps)=
    Buildings.Experimental.DistrictHeatingCooling.SubStations.VaporCompression.BaseClasses.getPeakLoad(
    string="#Peak space heating load",
    filNam=Modelica.Utilities.Files.loadResource(filPat))
    "Design heating heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  Modelica.Blocks.Sources.CombiTimeTable loa(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(filPat),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    y(each unit="W"),
    offset={0,0,0},
    columns={2,3,4},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Reader for thermal loads (y[1] is cooling load, y[2] is heating load)"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minTSet(k=20)
    "Minimum temperature setpoint"
    annotation (Placement(transformation(extent={{-298,250},{-278,270}})));
  Buildings.Controls.OBC.UnitConversions.From_degC from_degC1
    annotation (Placement(transformation(extent={{-258,250},{-238,270}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxTSet(k=24)
    "Maximum temperature setpoint"
    annotation (Placement(transformation(extent={{-298,210},{-278,230}})));
  Buildings.Controls.OBC.UnitConversions.From_degC from_degC2
    annotation (Placement(transformation(extent={{-258,210},{-238,230}})));
  Buildings.Applications.DHC.Loads.Validation.BaseClasses.Terminal4PipesHeatReq
    terUni(
      redeclare package Medium1 = Medium,
      redeclare package Medium2 = Medium2,
      final QHea_flow_nominal=QHea_flow_nominal,
      final QCoo_flow_nominal=QCoo_flow_nominal,
      final T_aHeaWat_nominal=T_aHeaWat_nominal,
      final T_aChiWat_nominal=T_aChiWat_nominal,
      final T_bHeaWat_nominal=T_bHeaWat_nominal,
      final T_bChiWat_nominal=T_bChiWat_nominal,
      final T_aLoaHea_nominal=T_aLoaHea_nominal,
      final T_aLoaCoo_nominal=T_aLoaCoo_nominal)
    "Terminal unit"
    annotation (Placement(transformation(extent={{70,-24},{90,-4}})));
  Buildings.Applications.DHC.Loads.BaseClasses.FlowDistribution disFloHea(
    redeclare package Medium = Medium,
    m_flow_nominal=terUni.mHeaWat_flow_nominal,
    have_pum=true,
    dp_nominal=100000,
    nPorts_a1=1,
    nPorts_b1=1)
    "Heating water distribution system"
    annotation (Placement(transformation(extent={{120,-80},{140,-60}})));
  Buildings.Applications.DHC.Loads.BaseClasses.FlowDistribution disFloCoo(
    redeclare package Medium = Medium,
    m_flow_nominal=terUni.mChiWat_flow_nominal,
    disTyp=Buildings.Applications.DHC.Loads.Types.DistributionType.ChilledWater,
    have_pum=true,
    dp_nominal=100000,
    nPorts_a1=1,
    nPorts_b1=1)
    "Chilled water distribution system"
    annotation (
      Placement(transformation(extent={{120,-120},{140,-100}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(nin=2)
    annotation (Placement(transformation(extent={{212,68},{232,88}})));
equation
  connect(minTSet.y,from_degC1. u)
    annotation (Line(points={{-276,260},{-260,260}}, color={0,0,127}));
  connect(maxTSet.y,from_degC2. u)
    annotation (Line(points={{-276,220},{-260,220}}, color={0,0,127}));
  connect(ports_a[1], disFloHea.port_a) annotation (Line(points={{-300,0},{
          -280,0},{-280,-70},{120,-70}},color={0,127,255}));
  connect(disFloHea.port_b, ports_b[1]) annotation (Line(points={{140,-70},{
          280,-70},{280,0},{300,0}}, color={0,127,255}));
  connect(ports_a[2], disFloCoo.port_a) annotation (Line(points={{-300,0},{
          -280,0},{-280,-110},{120,-110}},color={0,127,255}));
  connect(disFloCoo.port_b, ports_b[2]) annotation (Line(points={{140,-110},
          {280,-110},{280,0},{300,0}},color={0,127,255}));
  connect(from_degC1.y, terUni.TSetHea) annotation (Line(points={{-236,260},{60,
          260},{60,-7.33333},{69.1667,-7.33333}},
                                             color={0,0,127}));
  connect(from_degC2.y, terUni.TSetCoo) annotation (Line(points={{-236,220},{60,
          220},{60,-10.6667},{69.1667,-10.6667}},
                                             color={0,0,127}));
  connect(terUni.port_bHeaWat, disFloHea.ports_a1[1]) annotation (Line(points={{90,
          -22.3333},{90,-23.5833},{140,-23.5833},{140,-64}},      color={0,127,
          255}));
  connect(terUni.port_bChiWat, disFloCoo.ports_a1[1]) annotation (Line(points={{90,
          -20.6667},{160,-20.6667},{160,-104},{140,-104}},     color={0,127,255}));
  connect(disFloCoo.ports_b1[1], terUni.port_aChiWat) annotation (Line(points={{120,
          -104},{40,-104},{40,-20.6667},{70,-20.6667}},     color={0,127,255}));
  connect(disFloHea.ports_b1[1], terUni.port_aHeaWat) annotation (Line(points={{120,-64},
          {60,-64},{60,-22.3333},{70,-22.3333}},          color={0,127,255}));
  connect(loa.y[2], terUni.QReqHea_flow) annotation (Line(points={{21,0},{50,0},
          {50,-14},{69.1667,-14}},
                               color={0,0,127}));
  connect(loa.y[1], terUni.QReqCoo_flow) annotation (Line(points={{21,0},{50,0},
          {50,-17.3333},{69.1667,-17.3333}}, color={0,0,127}));
  connect(terUni.mReqHeaWat_flow, disFloHea.mReq_flow[1]) annotation (Line(points={{90.8333,
          -17.3333},{92,-17.3333},{92,-18},{100,-18},{100,-74},{119,-74}},
        color={0,0,127}));
  connect(disFloHea.QActTot_flow, QHea_flow) annotation (Line(points={{141,-76},
          {260,-76},{260,280},{320,280}}, color={0,0,127}));
  connect(disFloCoo.QActTot_flow, QCoo_flow) annotation (Line(points={{141,-116},
          {268,-116},{268,240},{320,240}}, color={0,0,127}));
  connect(mulSum.y, PPum) annotation (Line(points={{234,78},{308,78},{308,80},{320,
          80}}, color={0,0,127}));
  connect(disFloHea.PPum, mulSum.u[1]) annotation (Line(points={{141,-78},{176,-78},
          {176,79},{210,79}}, color={0,0,127}));
  connect(disFloCoo.PPum, mulSum.u[2]) annotation (Line(points={{141,-118},{180,
          -118},{180,77},{210,77}}, color={0,0,127}));
  connect(terUni.mReqChiWat_flow, disFloCoo.mReq_flow[1]) annotation (Line(
        points={{90.8333,-19},{90.8333,-20},{98,-20},{98,-114},{119,-114}},
        color={0,0,127}));
  annotation (
  Documentation(info="<html>
  <p>
  This is a simplified building model with:
  </p>
  <ul>
  <li> one heating load which temperature is computed with
  <a href=\"modelica://Buildings.DistrictEnergySystem.Loads.BaseClasses.FirstOrderODE\">
  Buildings.DistrictEnergySystem.Loads.BaseClasses.FirstOrderODE</a>
  and the required heating heat flow rate is provided by a time series;
  </li>
  <li>
  one additional heating load which temperature is prescribed with a time function
  and the required heating heat flow rate is also provided by a time function;
  </li>
  <li>
  one cooling load which temperature is computed with
  <a href=\"modelica://Buildings.DistrictEnergySystem.Loads.BaseClasses.FirstOrderODE\">
  Buildings.DistrictEnergySystem.Loads.BaseClasses.FirstOrderODE</a>
  and the required cooling heat flow rate is provided by a time series.
  </li>
  </ul>
  <p>
  </p>
  </html>"),
  Diagram(coordinateSystem(extent={{-300,-300},{300,300}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})));
end BuildingTimeSeries;

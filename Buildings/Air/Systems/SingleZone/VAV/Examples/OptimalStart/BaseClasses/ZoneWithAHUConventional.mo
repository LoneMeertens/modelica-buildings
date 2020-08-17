within Buildings.Air.Systems.SingleZone.VAV.Examples.OptimalStart.BaseClasses;
block ZoneWithAHUConventional
  "A single zone building with an air handling system, a conventional controller"

  package MediumA = Buildings.Media.Air(extraPropertiesNames={"CO2"})
    "Buildings library air media package";
  package MediumW = Buildings.Media.Water
    "Buildings library water media package";

  parameter Modelica.SIunits.Temperature TSupChi_nominal=279.15
    "Design value for chiller leaving water temperature";
  parameter Modelica.SIunits.Volume VRoo = 4555.7
    "Space volume of the floor";
  parameter Modelica.SIunits.MassFlowRate mAir_flow_nominal = VRoo*4*1.2/3600
    "Design air flow rate";
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal = 126000
    "Design heating flow rate";
  parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal = -110000
    "Design cooling flow rate";

  Buildings.Air.Systems.SingleZone.VAV.ChillerDXHeatingEconomizer hvac(
    redeclare package MediumA = MediumA,
    redeclare package MediumW = MediumW,
    mAir_flow_nominal=mAir_flow_nominal,
    etaHea_nominal=0.99,
    QHea_flow_nominal=QHea_flow_nominal,
    QCoo_flow_nominal=QCoo_flow_nominal,
    TSupChi_nominal=TSupChi_nominal)   "Single zone VAV system"
    annotation (Placement(transformation(extent={{-18,-20},{22,20}})));
  ChillerDXHeatingEconomizerController
    con(
    minAirFlo=0.1,
    minOAFra=0.4,
    kCoo=1,
    kFan=4,
    kEco=4,
    kHea=4,
    TSupChi_nominal=TSupChi_nominal,
    TSetSupAir=286.15) "Controller"
    annotation (Placement(transformation(extent={{-78,-12},{-58,8}})));
  ThermalZones.Detailed.Validation.BaseClasses.SingleZoneFloor
    sinZonFlo(redeclare package Medium = MediumA, lat=weaDat.lat)
    "Single zone floor building"
    annotation (Placement(transformation(extent={{38,-16},{78,24}})));
  Controls.OBC.CDL.Interfaces.RealOutput TZon(unit="K", displayUnit="degC")
    "Zone temperature"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Controls.OBC.CDL.Interfaces.RealInput TSetRooHea(unit="K", displayUnit="degC")
    "Room heating setpoint temperature" annotation (Placement(transformation(
          extent={{-140,40},{-100,80}}), iconTransformation(extent={{-140,40},{-100,
            80}})));
  Controls.OBC.CDL.Interfaces.RealInput TSetRooCoo(unit="K", displayUnit="degC")
    "Room cooling setpoint temperature" annotation (Placement(transformation(
          extent={{-140,-20},{-100,20}}),  iconTransformation(extent={{-140,-20},
            {-100,20}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        ModelicaServices.ExternalReferences.loadResource("modelica://Buildings/Resources/weatherdata/DRYCOLD.mos"),
      computeWetBulbTemperature=false)
    "Weather data"
    annotation (Placement(transformation(extent={{-40,50},{-20,70}})));
  BoundaryConditions.WeatherData.Bus weaBus "Weather bus" annotation (Placement(
        transformation(extent={{-4,50},{16,70}}),    iconTransformation(extent={{-78,70},
            {-58,90}})));
  Controls.OBC.CDL.Interfaces.BooleanInput uOcc
    "Current occupancy period, true if it is in occupant period"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
equation
  connect(con.yCooCoiVal,hvac. uCooVal) annotation (Line(points={{-57,-4},{-36,-4},
          {-36,5},{-20,5}}, color={0,0,127}));
  connect(hvac.uEco,con. yOutAirFra) annotation (Line(points={{-20,-2},{-34,-2},
          {-34,0},{-57,0}}, color={0,0,127}));
  connect(con.chiOn,hvac. chiOn) annotation (Line(points={{-57,-7.4},{-36,-7.4},
          {-36,-10},{-20,-10}},
                           color={255,0,255}));
  connect(con.yFan,hvac. uFan) annotation (Line(points={{-57,7},{-46,7},{-46,18},
          {-20,18}}, color={0,0,127}));
  connect(con.yHea,hvac. uHea) annotation (Line(points={{-57,3.4},{-40,3.4},{-40,
          12},{-20,12}},
                     color={0,0,127}));
  connect(hvac.TMix,con. TMix) annotation (Line(points={{23.2,-4},{28,-4},{28,-28},
          {-88,-28},{-88,1},{-79.4,1}},   color={0,0,127}));
  connect(hvac.TSup,con. TSup) annotation (Line(points={{23.2,-8},{26,-8},{26,-26},
          {-86,-26},{-86,-10.6},{-79.4,-10.6}},
                                          color={0,0,127}));
  connect(sinZonFlo.TRooAir,con. TRoo) annotation (Line(points={{75,14.2},{82,14.2},
          {82,-42},{-92,-42},{-92,-7.8},{-79.4,-7.8}},color={0,0,127}));
  connect(hvac.supplyAir,sinZonFlo. ports[1]) annotation (Line(points={{22.2,8},
          {40,8},{40,-8},{45.8,-8}},     color={0,127,255}));
  connect(hvac.returnAir,sinZonFlo. ports[2]) annotation (Line(points={{22.2,0},
          {32,0},{32,-8},{47.8,-8}},     color={0,127,255}));
  connect(con.TSetSupChi,hvac. TSetChi)
    annotation (Line(points={{-57,-11},{-40,-11},{-40,-18},{-20,-18}},
                                                             color={0,0,127}));
  connect(TSetRooHea, con.TSetRooHea) annotation (Line(points={{-120,60},{-90,60},
          {-90,6.6},{-79.4,6.6}},
                            color={0,0,127}));
  connect(TSetRooCoo, con.TSetRooCoo) annotation (Line(points={{-120,0},{-96,0},
          {-96,3.8},{-79.4,3.8}},
                            color={0,0,127}));
  connect(sinZonFlo.TRooAir,TZon)  annotation (Line(points={{75,14.2},{82,14.2},
          {82,0},{120,0}}, color={0,0,127}));
  connect(uOcc, con.uOcc) annotation (Line(points={{-120,-60},{-84,-60},{-84,-2},
          {-80.8,-2}}, color={255,0,255}));
  connect(weaBus, sinZonFlo.weaBus) annotation (Line(
      points={{6,60},{44,60},{44,21},{44.8,21}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus, hvac.weaBus) annotation (Line(
      points={{6,60},{6,32},{-13.8,32},{-13.8,17.8}},
      color={255,204,51},
      thickness=0.5));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-20,60},{6,60}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.TDryBul, con.TOut) annotation (Line(
      points={{6,60},{6,32},{-86,32},{-86,-5},{-79.4,-5}},
      color={255,204,51},
      thickness=0.5));
  annotation (choicesAllMatching = true,
              choicesAllMatching = true,
              defaultComponentName="zonAHUCon",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Text(
          extent={{-151,147},{149,107}},
          lineColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255},
          textString="%name")}),          Diagram(coordinateSystem(
          preserveAspectRatio=false)));
end ZoneWithAHUConventional;

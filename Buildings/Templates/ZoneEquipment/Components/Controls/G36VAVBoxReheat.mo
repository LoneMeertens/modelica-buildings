within Buildings.Templates.ZoneEquipment.Components.Controls;
block G36VAVBoxReheat
  "Guideline 36 controller for VAV terminal unit with reheat"
  extends
    Buildings.Templates.ZoneEquipment.Components.Controls.Interfaces.PartialVAVBox(
      final typ=Buildings.Templates.ZoneEquipment.Types.Controller.G36VAVBoxReheat);

  outer replaceable Buildings.Templates.Components.Coils.None coiHea
    "Heating coil";

  final parameter Boolean have_pressureIndependentDamper=
    damVAV.typ==Buildings.Templates.Components.Types.Damper.PressureIndependent
    "True: the VAV damper is pressure independent (with built-in flow controller)"
    annotation (Dialog(tab="Damper and valve control", group="Damper"));

  parameter Boolean have_occSen=false
    "Set to true if the zone has occupancy sensor"
    annotation (Dialog(tab="Airflow set point", group="Zone sensors"));

  parameter Boolean have_winSen=false
    "Set to true if the zone has window status sensor"
    annotation (Dialog(tab="Airflow set point", group="Zone sensors"));

  parameter Boolean have_CO2Sen=false
    "Set to true if the zone has CO2 sensor"
    annotation (Dialog(tab="Airflow set point", group="Zone sensors"));

  parameter Boolean permit_occStandby=true
    "Set to true if occupied-standby mode is permitted";

  final parameter Boolean have_hotWatCoi=
    coiHea.typ==Buildings.Templates.Components.Types.Coil.WaterBasedHeating
    "Set to true if the system has hot water coil";

  parameter Boolean have_locAdj=true
    "Set to true if the zone has local set point adjustment knob"
    annotation (Dialog(group="Set point adjustable setting"));

  parameter Boolean sepAdj=true
    "Set to true if cooling and heating set points can be adjusted separately"
    annotation (Dialog(group="Set point adjustable setting", enable=have_locAdj));

  parameter Boolean ignDemLim = true
    "Set to true to exempt the zone from demand limit set point adjustment"
    annotation(Dialog(group="Set point adjustable setting"));

  parameter Modelica.Units.SI.VolumeFlowRate VAir_flow_nominal=
    dat.getReal(varName=id + ".mechanical.mAir_flow_nominal.value") / 1.2
    "Zone design volume flow rate"
    annotation (Dialog(group="Nominal condition"));

  final parameter Modelica.Units.SI.VolumeFlowRate VAirCooSet_flow_max = VAir_flow_nominal
    "Zone maximum cooling airflow set point"
    annotation (Dialog(tab="Airflow set point", group="Nominal conditions"));
  parameter Modelica.Units.SI.VolumeFlowRate VAirSet_flow_min=
    dat.getReal(varName=id + ".control.VAirSet_flow_min.value")
    "Zone minimum airflow set point"
    annotation (Dialog(tab="Airflow set point", group="Nominal conditions"));
  parameter Modelica.Units.SI.VolumeFlowRate VAirHeaSet_flow_max=
    dat.getReal(varName=id + ".control.VAirHeaSet_flow_max.value")
    "Zone maximum heating airflow set point"
    annotation (Dialog(tab="Airflow set point", group="Nominal conditions"));
  parameter Modelica.Units.SI.VolumeFlowRate VAirHeaSet_flow_min=
    dat.getReal(varName=id + ".control.VAirHeaSet_flow_min.value")
    "Zone minimum heating airflow set point"
    annotation (Dialog(tab="Airflow set point", group="Nominal conditions"));

  parameter Real CO2Set=
    dat.getReal(varName=id + ".control.CO2Set.value")
    "CO2 set point in ppm"
    annotation (Dialog(tab="Airflow set point", group="Nominal conditions"));

  parameter Modelica.Units.SI.TemperatureDifference dTAirDisHea_max(
    displayUnit="K")=
    dat.getReal(varName=id + ".control.dTAirDisHea_max.value")
    "Zone maximum discharge air temperature above heating set point"
    annotation (Dialog(tab="Damper and valve", group="Parameters"));

  parameter Modelica.Units.SI.Temperature TAirDis_min(
    displayUnit = "degC")=
    dat.getReal(varName=id + ".control.TAirDis_min.value")
    "Minimum discharge air temperature"
    annotation (Dialog(tab="Damper and valve", group="Parameters"));

  parameter Real VAirOutPerAre_flow(
    final unit = "m3/(s.m2)", final min=0, start=3e-4)=
    dat.getReal(varName=id + ".control.VAirOutPerAre_flow.value")
    "Outdoor air flow rate per unit area"
    annotation(Dialog(group="Nominal condition"));

  parameter Real VAirOutPerPer_flow(
    final unit = "m3/s", final min=0, start=2.5e-3)=
    dat.getReal(varName=id + ".control.VAirOutPerPer_flow.value")
    "Outdoor air flow rate per person"
    annotation(Dialog(group="Nominal condition"));

  parameter Modelica.Units.SI.Area AFlo=
    dat.getReal(varName=id + ".control.AFlo.value")
    "Zone floor area"
    annotation(Dialog(group="Nominal condition"));

  parameter Real effAirDisHea(final unit = "1", final min=0, final max=1, start=0.8)=
     dat.getReal(varName=id + ".control.effAirDisHea.value")
    "Zone air distribution effectiveness during heating";

  parameter Real effAirDisCoo(final unit = "1", final min=0, final max=1, start=1.0)=
     dat.getReal(varName=id + ".control.effAirDisCoo.value")
    "Zone air distribution effectiveness during cooling";

  parameter Real effAirDis_nominal(final unit = "1", final min=0, final max=1)=
    effAirDisCoo
    "Zone air distribution effectiveness at design conditions"
    annotation(Dialog(group="Nominal condition"));

  parameter Modelica.Units.SI.VolumeFlowRate VAirPri_flow_min=
    dat.getReal(varName=id + ".control.VAirPri_flow_min.value")
    "Zone minimum expected primary air volume flow rate"
    annotation(Dialog(group="Nominal condition"));

  // FIXME: should be inputs such as in Buildings.Controls.OBC.ASHRAE.G36.ThermalZones.Setpoints
  parameter Modelica.Units.SI.Temperature TAirZonHeaOccSet(
    displayUnit="degC")=
    dat.getReal(varName=id + ".control.TAirZonHeaOccSet.value")
    "Zone occupied heating set point";

  parameter Modelica.Units.SI.Temperature TAirZonHeaUnoSet(
    displayUnit="degC")=
    dat.getReal(varName=id + ".control.TAirZonHeaUnoSet.value")
    "Zone unoccupied heating set point";

  parameter Modelica.Units.SI.Temperature TAirZonCooOccSet(
    displayUnit="degC")=
    dat.getReal(varName=id + ".control.TAirZonCooOccSet.value")
    "Zone occupied cooling set point";

  parameter Modelica.Units.SI.Temperature TAirZonCooUnoSet(
    displayUnit="degC")=
    dat.getReal(varName=id + ".control.TAirZonCooUnoSet.value")
    "Zone unoccupied cooling set point";

  parameter Real nPeo_nominal(final unit="1", final min=0, start=0.05*AFlo)=
    dat.getReal(varName=id + ".control.nPeo_nominal.value")
    "Design zone population";

  // FIXME: missing default parameter assignment, see non final binding below.
  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.Reheat.Controller ctl(
    controllerTypeVal=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    staPreMul=1,
    hotWatRes=1,
    floHys=1e-2,
    damPosHys=1e-2,
    valPosHys=1e-2,
    final desZonPop=nPeo_nominal,
    final AFlo=AFlo,
    final outAirRat_area=VAirOutPerAre_flow,
    final outAirRat_occupant=VAirOutPerPer_flow,
    final V_flow_nominal=VAir_flow_nominal,
    final have_occSen=have_occSen,
    final have_winSen=have_winSen,
    final have_CO2Sen=have_CO2Sen,
    final have_hotWatCoi=have_hotWatCoi,
    final permit_occStandby=permit_occStandby,
    final have_pressureIndependentDamper=have_pressureIndependentDamper,
    final VCooZonMax_flow=VAirCooSet_flow_max,
    final VZonMin_flow=VAirSet_flow_min,
    final VHeaZonMin_flow=VAirHeaSet_flow_min,
    final VHeaZonMax_flow=VAirHeaSet_flow_max,
    final CO2Set=CO2Set,
    final dTDisZonSetMax=dTAirDisHea_max,
    final TDisMin=TAirDis_min)
    "Terminal unit controller"
    annotation (Placement(transformation(extent={{0,-20},{20,20}})));

  Buildings.Controls.OBC.ASHRAE.G36.ThermalZones.Setpoints TZonSet(
    final have_occSen=have_occSen,
    final have_winSen=have_winSen,
    final have_locAdj=have_locAdj,
    final sepAdj=sepAdj,
    final ignDemLim=ignDemLim)
    "Compute zone temperature set points"
    annotation (Placement(transformation(extent={{-60,-20},{-40,20}})));

  // FIXME: occDen should not be exposed.
  Buildings.Controls.OBC.ASHRAE.G36.AHUs.MultiZone.VAV.SetPoints.OutdoorAirFlow.Zone zonOutAirSet(
    final VOutPerAre_flow=VAirOutPerAre_flow,
    final VOutPerPer_flow=VAirOutPerPer_flow,
    final AFlo=AFlo,
    final have_occSen=have_occSen,
    final have_winSen=have_winSen,
    final occDen=nPeo_nominal / AFlo,
    final desZonPop=nPeo_nominal,
    final zonDisEffHea=effAirDisHea,
    final zonDisEffCoo=effAirDisCoo,
    final desZonDisEff=effAirDis_nominal,
    final minZonPriFlo=VAirPri_flow_min)
    "Zone level calculation of the minimum outdoor airflow set point"
    annotation (Placement(transformation(extent={{120,40},{140,60}})));

  Buildings.Controls.OBC.ASHRAE.G36.ZoneGroups.ZoneStatus zonSta(
    final THeaSetOcc=TAirZonHeaOccSet,
    final THeaSetUno=TAirZonHeaUnoSet,
    final TCooSetOcc=TAirZonCooOccSet,
    final TCooSetUno=TAirZonCooUnoSet,
    final have_winSen=have_winSen)
    "Evaluate zone temperature status"
    annotation (Placement(transformation(extent={{120,-68},{140,-40}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant FIXME3(k=1800)
    "Optimal start using global outdoor air temperature not associated with any AHU"
    annotation (Placement(transformation(extent={{-240,-130},{-220,-110}})));

  Buildings.Controls.OBC.CDL.Logical.Sources.Constant FIXME_uHotPla(k=true)
    "Should be conditional, depending on have_hotWatCoi"
    annotation (Placement(transformation(extent={{-240,-90},{-220,-70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant FIXME_uOve(k=0)
    "Validate override logic: should not be used in simulation"
    annotation (Placement(transformation(extent={{-240,70},{-220,90}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant FIXME_uHeaOff(k=false)
    "Validate override logic: should not be used in simulation"
    annotation (Placement(transformation(extent={{-240,30},{-220,50}})));
  Modelica.Blocks.Routing.RealPassThrough FIXME_uVal
    "Should be conditional, depending on have_hotWatCoi"
    annotation (Placement(transformation(extent={{-240,-50},{-220,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant setAdj(k=0)
    "Set point adjustment by the occupant is not implemented"
    annotation (Placement(transformation(extent={{-160,170},{-140,190}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant cooSetAdj(k=0)
    "Set point adjustment by the occupant is not implemented"
    annotation (Placement(transformation(extent={{-160,130},{-140,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant heaSetAdj(k=0)
    "Set point adjustment by the occupant is not implemented"
    annotation (Placement(transformation(extent={{-160,90},{-140,110}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant uCooDemLimLev(k=0)
    "Set point adjustment by demand limit is not implemented"
    annotation (Placement(transformation(extent={{-120,170},{-100,190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant uHeaDemLimLev(k=0)
    "Set point adjustment by demand limit is not implemented"
    annotation (Placement(transformation(extent={{-120,130},{-100,150}})));
equation
  /* Control point connection - start */
  connect(ctl.yDamSet, bus.damVAV.y);
  connect(ctl.yValSet, bus.coiHea.y);

  connect(bus.VAirDis_flow, zonOutAirSet.VDis_flow);
  connect(bus.TAirDis, ctl.TDis);
  connect(bus.VAirDis_flow, ctl.VDis_flow);
  connect(bus.damVAV.y_actual, ctl.uDam);

  connect(bus.coiHea.y_actual, FIXME_uVal.u);

  connect(bus.yFanSup_actual, ctl.uFan);

  connect(bus.ppmCO2, ctl.ppmCO2);
  connect(bus.uWin, ctl.uWin);
  connect(bus.TAirZon, ctl.TZon);

  connect(bus.uOcc, TZonSet.uOcc);
  connect(bus.uWin, TZonSet.uWin);

  connect(bus.uWin, zonOutAirSet.uWin);
  connect(bus.TAirZon, zonOutAirSet.TZon);
  connect(bus.TAirDis, zonOutAirSet.TDis);
  connect(bus.uWin, zonSta.uWin);
  connect(bus.TAirZon, zonSta.TZon);

  connect(FIXME3.y, zonSta.cooDowTim);
  connect(FIXME3.y, zonSta.warUpTim);

  connect(bus.TAirSup, ctl.TSup);
  connect(bus.TAirSupSet, ctl.TSupSet);
  connect(bus.yOpeMod, ctl.uOpeMod);
  connect(bus.yOpeMod, TZonSet.uOpeMod);
  connect(bus.TAirZonCooOccSet, TZonSet.TZonCooSetOcc);
  connect(bus.TAirZonCooUnoSet, TZonSet.TZonCooSetUno);
  connect(bus.TAirZonHeaOccSet, TZonSet.TZonHeaSetOcc);
  connect(bus.TAirZonHeaUnoSet, TZonSet.TZonHeaSetUno);
  connect(bus.dTSetAdj, TZonSet.setAdj);
  connect(bus.dTHeaSetAdj, TZonSet.heaSetAdj);
  connect(bus.uCooDemLimLev, TZonSet.uCooDemLimLev);
  connect(bus.uHeaDemLimLev, TZonSet.uHeaDemLimLev);

  connect(ctl.yZonTemResReq, bus.yReqZonTemRes);
  connect(ctl.yZonPreResReq, bus.yReqZonPreRes);
  connect(bus.yReqOutAir, zonOutAirSet.uReqOutAir);
  connect(bus.VDesUncOutAir_flow, zonOutAirSet.VUncOut_flow_nominal);

  connect(zonOutAirSet.yDesZonPeaOcc, bus.yDesZonPeaOcc);
  connect(zonOutAirSet.VDesPopBreZon_flow, bus.VDesPopBreZon_flow);
  connect(zonOutAirSet.VDesAreBreZon_flow, bus.VDesAreBreZon_flow);
  connect(zonOutAirSet.yDesPriOutAirFra, bus.yDesPriOutAirFra);
  connect(zonOutAirSet.VUncOutAir_flow, bus.VUncOutAir_flow);
  connect(zonOutAirSet.yPriOutAirFra, bus.yPriOutAirFra);
  connect(zonOutAirSet.VPriAir_flow, bus.VPriAir_flow);

  connect(zonSta.yCooTim, bus.yCooTim);
  connect(zonSta.yWarTim, bus.yWarTim);
  connect(zonSta.THeaSetOn, bus.THeaSetOn);
  connect(zonSta.yOccHeaHig, bus.yOccHeaHig);
  connect(zonSta.TCooSetOn, bus.TCooSetOn);
  connect(zonSta.yHigOccCoo, bus.yHigOccCoo);
  connect(zonSta.THeaSetOff, bus.THeaSetOff);
  connect(zonSta.yUnoHeaHig, bus.yUnoHeaHig);
  connect(zonSta.yEndSetBac, bus.yEndSetBac);
  connect(zonSta.TCooSetOff, bus.TCooSetOff);
  connect(zonSta.yHigUnoCoo, bus.yHigUnoCoo);
  connect(zonSta.yEndSetUp, bus.yEndSetUp);
  /* Control point connection - end */

  connect(TZonSet.TZonCooSet, ctl.TZonCooSet)
    annotation (Line(points={{-38,8},{
          -22,8},{-22,17},{-2,17}}, color={0,0,127}));
  connect(TZonSet.TZonHeaSet, ctl.TZonHeaSet)
    annotation (Line(points={{-38,0},{
          -20,0},{-20,15},{-2,15}}, color={0,0,127}));
  connect(FIXME_uHotPla.y, ctl.uHotPla) annotation (Line(points={{-218,-80},{-8,
          -80},{-8,-18.8},{-2,-18.8}},  color={255,0,255}));
  connect(FIXME_uOve.y, ctl.oveFloSet) annotation (Line(points={{-218,80},{-10,80},
          {-10,-6},{-2,-6}}, color={255,127,0}));
  connect(FIXME_uOve.y, ctl.oveDamPos) annotation (Line(points={{-218,80},{-10,80},
          {-10,-8},{-2,-8}}, color={255,127,0}));
  connect(FIXME_uHeaOff.y, ctl.uHeaOff) annotation (Line(points={{-218,40},{-14,
          40},{-14,-10},{-2,-10}}, color={255,0,255}));
  connect(FIXME_uVal.y, ctl.uVal) annotation (Line(points={{-219,-40},{-12,-40},
          {-12,-14},{-2,-14}}, color={0,0,127}));
  connect(uCooDemLimLev.y, TZonSet.uCooDemLimLev) annotation (Line(points={{-98,
          180},{-70,180},{-70,-8},{-62,-8}}, color={255,127,0}));
  connect(uHeaDemLimLev.y, TZonSet.uHeaDemLimLev) annotation (Line(points={{-98,
          140},{-74,140},{-74,-11},{-62,-11}}, color={255,127,0}));
  connect(cooSetAdj.y, TZonSet.cooSetAdj) annotation (Line(points={{-138,140},{-134,
          140},{-134,-2},{-62,-2}}, color={0,0,127}));
  connect(heaSetAdj.y, TZonSet.heaSetAdj) annotation (Line(points={{-138,100},{-136,
          100},{-136,-4},{-62,-4}}, color={0,0,127}));
  connect(setAdj.y, TZonSet.setAdj) annotation (Line(points={{-138,180},{-132,180},
          {-132,0},{-62,0}}, color={0,0,127}));
  annotation (
    defaultComponentName="conTer",
    Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end G36VAVBoxReheat;

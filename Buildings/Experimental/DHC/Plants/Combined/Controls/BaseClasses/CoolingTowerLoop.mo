within Buildings.Experimental.DHC.Plants.Combined.Controls.BaseClasses;
block CoolingTowerLoop "Cooling tower loop control"

  parameter Integer nCoo(final min=1, start=1)
    "Number of cooling tower cells operating at design conditions"
    annotation (Evaluate=true);
  parameter Integer nPumConWatCoo(final min=1, start=1)
    "Number of CW pumps serving cooling towers at design conditions"
    annotation (Evaluate=true);
  parameter Modelica.Units.SI.HeatFlowRate QChiWat_flow_nominal
    "Design plant cooling heat flow rate (all units)";
  parameter Modelica.Units.SI.TemperatureDifference dTLifChi_min
    "Minimum chiller lift at minimum load";
  parameter Modelica.Units.SI.TemperatureDifference dTLifChi_nominal
    "Design chiller lift";
  parameter Modelica.Units.SI.Temperature TTanSet[2, 2]
    "Tank temperature setpoints: 2 cycles with 2 setpoints";
  parameter Modelica.Units.SI.TemperatureDifference dTHexCoo_nominal
    "Design heat exchanger approach";
  parameter Real yPumConWatCoo_min[nPumConWatCoo](
    each final unit="1",
    each final min=0,
    each final max=1)={0.2 / i for i in 1:nPumConWatCoo}
    "Tower pump speed needed to maintain minimum tower flow (each pump stage)";

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput mode(
    final min=Buildings.Experimental.DHC.Plants.Combined.Controls.ModeCondenserLoop.tankCharge,
    final max=Buildings.Experimental.DHC.Plants.Combined.Controls.ModeCondenserLoop.heatRejection)
    "Condenser loop operating mode"
    annotation (Placement(transformation(extent={{-220,240},{-180,280}}),
        iconTransformation(extent={{-140,140},{-100,180}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput idxCycTan(
    final min=1,
    final max=2)
    "Index of active tank cycle"
    annotation (Placement(transformation(extent={{-220,200},{-180,240}}),
    iconTransformation(extent={{-140,120},{-100,160}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatCooSup(final unit="K",
      displayUnit="degC") "Cooling tower loop CW supply tempetrature"
    annotation (Placement(transformation(extent={{-220,-200},{-180,-160}}),
        iconTransformation(extent={{-140,2},{-100,42}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mConWatHexCoo_flow(
    final unit="kg/s")
    "CW mass flow rate through secondary side of HX"
      annotation (
      Placement(transformation(extent={{-220,-40},{-180,0}}),
        iconTransformation(extent={{-140,-140},{-100,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput  QCooReq_flow(
    final unit="W")
    "Plant required cooling capacity (>0)" annotation (
      Placement(transformation(extent={{-220,140},{-180,180}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatConChiEnt(final unit=
        "K", displayUnit="degC") "Chiller and HRC entering CW temperature"
    annotation (Placement(transformation(extent={{-220,40},{-180,80}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatConChiLvg(final unit=
        "K", displayUnit="degC") "Chiller and HRC leaving CW temperature"
    annotation (Placement(transformation(extent={{-220,20},{-180,60}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(final unit="K",
      displayUnit="degC") "CHW supply temperature setpoint" annotation (
      Placement(transformation(extent={{-220,80},{-180,120}}),
        iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatCooRet(final unit="K",
      displayUnit="degC") "Cooling tower loop CW return tempetrature"
    annotation (Placement(transformation(extent={{-220,-220},{-180,-180}}),
        iconTransformation(extent={{-140,-18},{-100,22}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput yValBypTan(final unit="1")
    "TES tank bypass valve commanded position" annotation (Placement(
        transformation(extent={{-220,-100},{-180,-60}}),  iconTransformation(
          extent={{-140,-180},{-100,-140}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatHexCooEnt(final unit=
        "K", displayUnit="degC") "HX entering CW tempetrature" annotation (
      Placement(transformation(extent={{-220,-260},{-180,-220}}),
        iconTransformation(extent={{-140,-38},{-100,2}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatHexCooLvg(final unit=
        "K", displayUnit="degC") "HX leaving CW tempetrature" annotation (
      Placement(transformation(extent={{-220,-280},{-180,-240}}),
        iconTransformation(extent={{-140,-58},{-100,-18}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1PumConWatCoo[
    nPumConWatCoo] "Cooling tower pump Start command" annotation (Placement(
        transformation(extent={{180,40},{220,80}}),   iconTransformation(extent
          ={{100,100},{140,140}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Coo[nCoo]
    "Cooling tower Start command" annotation (Placement(transformation(extent={{180,
            -140},{220,-100}}),    iconTransformation(extent={{100,-80},{140,
            -40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yCoo
    "Cooling tower fan speed command" annotation (Placement(transformation(
          extent={{180,-80},{220,-40}}),  iconTransformation(extent={{100,-140},
            {140,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumConWatCoo
    "Cooling tower pump speed command" annotation (Placement(transformation(
          extent={{180,-240},{220,-200}}), iconTransformation(extent={{100,40},{
            140,80}})));

  Buildings.Controls.OBC.CDL.Continuous.Subtract delTemCon "Compute CW deltaT"
    annotation (Placement(transformation(extent={{-160,30},{-140,50}})));
  Buildings.Controls.OBC.CDL.Continuous.MovingAverage mea(delta=5*60)
    "Moving mean"
    annotation (Placement(transformation(extent={{-130,30},{-110,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Subtract delTem1 "Compute deltaT"
    annotation (Placement(transformation(extent={{-100,60},{-80,80}})));
  Buildings.Controls.OBC.CDL.Continuous.Add lifPlu "Add target lift"
    annotation (Placement(transformation(extent={{-140,70},{-120,90}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter subApp(final p=-
        dTHexCoo_nominal) "Substract HX approach"
    annotation (Placement(transformation(extent={{-70,60},{-50,80}})));
  Buildings.Controls.OBC.CDL.Continuous.Switch TSupSetUnb(y(unit="K",
        displayUnit="degC"))
    "Compute tower supply temperature setpoint, unbounded" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-20,260})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant modRej(
    final k=Buildings.Experimental.DHC.Plants.Combined.Controls.ModeCondenserLoop.heatRejection)
    "Heat rejection mode index"
    annotation (Placement(transformation(extent={{-150,230},{-130,250}})));
  Buildings.Controls.OBC.CDL.Integers.Equal isModRej "Heat rejection mode"
    annotation (Placement(transformation(extent={{-110,250},{-90,270}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant setOth[2](final k=
        TTanSet[:, 1] .- dTHexCoo_nominal .- 0.5)
    "Target setpoint in any mode other than heat rejection"
    annotation (Placement(transformation(extent={{-110,190},{-90,210}})));
  Buildings.Controls.OBC.CDL.Routing.RealExtractor extSet(final nin=2)
    "Extract setpoint value based on current mode"
    annotation (Placement(transformation(extent={{-70,230},{-50,250}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter ratDes(final k=abs(1
        /QChiWat_flow_nominal)) "Ratio to design capacity"
    annotation (Placement(transformation(extent={{-160,150},{-140,170}})));
  Buildings.Controls.OBC.CDL.Continuous.Line lif "Compute target chiller lift"
    annotation (Placement(transformation(extent={{-110,130},{-90,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant xLif[2](k={0.1,1})
    "x-value for lift reset"
    annotation (Placement(transformation(extent={{-150,180},{-130,200}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yLif[2](final k={
        dTLifChi_min,dTLifChi_nominal}) "y-value for lift reset"
    annotation (Placement(transformation(extent={{-150,120},{-130,140}})));
  StagingPump staPum(
    nPum=nPumConWatCoo,
    have_flowCriterion=false,
    yDow=0.4,
    yUp=0.8)
    "Stage pumps"
    annotation (Placement(transformation(extent={{100,50},{120,70}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold cmpFlo(t=3) "Compare"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold cmpFlo1(t=3) "Compare"
    annotation (Placement(transformation(extent={{-160,-50},{-140,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timFlo(t=60)
    "Timer for flow exceeding triggering limit"
    annotation (Placement(transformation(extent={{-130,-10},{-110,10}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timFlo1(t=5*60)
    "Timer for flow exceeding triggering limit"
    annotation (Placement(transformation(extent={{-130,-50},{-110,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold cmpOpe(t=1) "Compare"
    annotation (Placement(transformation(extent={{-160,-90},{-140,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timOpe(t=60)
    "Timer for valve opening exceeding triggering limit"
    annotation (Placement(transformation(extent={{-130,-90},{-110,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timOpe1(t=60)
    "Timer for valve opening exceeding triggering limit"
    annotation (Placement(transformation(extent={{-130,-130},{-110,-110}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Timer for valve opening exceeding triggering limit"
    annotation (Placement(transformation(extent={{-160,-130},{-140,-110}})));
  Buildings.Controls.OBC.CDL.Logical.Or dis "Disable condition"
    annotation (Placement(transformation(extent={{-90,-70},{-70,-50}})));
  Buildings.Controls.OBC.CDL.Logical.And ena "Enable condition"
    annotation (Placement(transformation(extent={{-90,-30},{-70,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Latch enaLea "Enable lead pump"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Subtract delTem2 "Compute deltaT"
    annotation (Placement(transformation(extent={{-160,-250},{-140,-230}})));
  Buildings.Controls.OBC.CDL.Continuous.Subtract delTem3 "Compute deltaT"
    annotation (Placement(transformation(extent={{-160,-210},{-140,-190}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addOff(final p=-1)
    "Add offset"
    annotation (Placement(transformation(extent={{-130,-250},{-110,-230}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addApp(final p=
        dTHexCoo_nominal) "Add HX approach"
    annotation (Placement(transformation(extent={{-40,-210},{-20,-190}})));
  EnergyTransferStations.Combined.Controls.PIDWithEnable ctlPum1(
    k=0.1,
    Ti=60,
    final reverseActing=false) "Pump control loop #1"
    annotation (Placement(transformation(extent={{-10,-210},{10,-190}})));
  EnergyTransferStations.Combined.Controls.PIDWithEnable ctlPum2(
    k=0.1,
    Ti=60,
    final reverseActing=false)
                              "Pump control loop #1"
    annotation (Placement(transformation(extent={{-10,-250},{10,-230}})));
  Buildings.Controls.OBC.CDL.Continuous.Min minCtlPum "Minimum loop output"
    annotation (Placement(transformation(extent={{30,-230},{50,-210}})));
  Buildings.Controls.OBC.CDL.Continuous.Line pum "Pump speed command"
    annotation (Placement(transformation(extent={{120,-230},{140,-210}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant xPum[2](k={0,1})
    "x-value for pump speed reset"
    annotation (Placement(transformation(extent={{90,-210},{110,-190}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(final k=1)
    "Constant"
    annotation (Placement(transformation(extent={{90,-260},{110,-240}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yPumMin[nPumConWatCoo](
     final k=yPumConWatCoo_min) "Minimum pump speed"
    annotation (Placement(transformation(extent={{30,-260},{50,-240}})));
  Buildings.Controls.OBC.CDL.Routing.RealExtractor extYPumMin(final nin=
        nPumConWatCoo)
    "Extract minimum pump speed value based on current pump stage"
    annotation (Placement(transformation(extent={{60,-260},{80,-240}})));
  Modelica.Blocks.Sources.IntegerExpression nPumBou(y=max(1, staPum.nPumEna))
    "Number of pumps commanded on, bounded by 1"
    annotation (Placement(transformation(extent={{30,-284},{50,-264}})));
  Buildings.Controls.OBC.CDL.Routing.BooleanScalarReplicator rep(final nout=
        nCoo) "Replicate"
    annotation (Placement(transformation(extent={{140,-130},{160,-110}})));
  Buildings.Controls.OBC.CDL.Continuous.Line fanMax "Compute maximum fan speed"
    annotation (Placement(transformation(extent={{70,150},{90,170}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant xFan[2](k={0,0.5})
    "x-value for maximum fan speed reset"
    annotation (Placement(transformation(extent={{30,180},{50,200}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yFan[2](final k={0.7,1.0})
    "y-value for maximum fan speed reset"
    annotation (Placement(transformation(extent={{30,120},{50,140}})));
  EnergyTransferStations.Combined.Controls.PIDWithEnable ctlFan(
    k=0.1,
    Ti=60,
    final reverseActing=false) "Fan control loop"
    annotation (Placement(transformation(extent={{80,-70},{100,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre1
    "Left limit of signal to avoid direct feedback"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-80,-150})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant setMax(k=25 + 273.15)
    "Maximum setpoint"
    annotation (Placement(transformation(extent={{-70,190},{-50,210}})));
  Buildings.Controls.OBC.CDL.Continuous.Min TSupSet(
    y(unit="K", displayUnit="degC"))
    "Compute tower supply temperature setpoint"
    annotation (Placement(transformation(extent={{-30,190},{-10,210}})));
  Buildings.Controls.OBC.CDL.Continuous.Line fan "Compute fan speed"
    annotation (Placement(transformation(extent={{150,-70},{170,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant xFan1
                                                             [2](k={0,1})
    "x-value for fan speed reset"
    annotation (Placement(transformation(extent={{110,-50},{130,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yFan1(final k=0)
    "y-value for fan speed reset"
    annotation (Placement(transformation(extent={{110,-90},{130,-70}})));
equation
  connect(QCooReq_flow, ratDes.u)
    annotation (Line(points={{-200,160},{-162,160}},
                                                   color={0,0,127}));
  connect(ratDes.y, lif.u)
    annotation (Line(points={{-138,160},{-126,160},{-126,140},{-112,140}},
                                                 color={0,0,127}));
  connect(xLif[1].y, lif.x1) annotation (Line(points={{-128,190},{-120,190},{-120,
          148},{-112,148}},
                     color={0,0,127}));
  connect(xLif[2].y, lif.x2) annotation (Line(points={{-128,190},{-120,190},{-120,
          136},{-112,136}},
                     color={0,0,127}));
  connect(yLif[1].y, lif.f1) annotation (Line(points={{-128,130},{-116,130},{-116,
          144},{-112,144}},
                     color={0,0,127}));
  connect(yLif[2].y, lif.f2) annotation (Line(points={{-128,130},{-116,130},{-116,
          132},{-112,132}},
                     color={0,0,127}));
  connect(TConWatConChiLvg, delTemCon.u1) annotation (Line(points={{-200,40},{-170,
          40},{-170,46},{-162,46}}, color={0,0,127}));
  connect(TConWatConChiEnt, delTemCon.u2) annotation (Line(points={{-200,60},{-174,
          60},{-174,34},{-162,34}}, color={0,0,127}));
  connect(delTemCon.y, mea.u)
    annotation (Line(points={{-138,40},{-132,40}}, color={0,0,127}));
  connect(lif.y, lifPlu.u1) annotation (Line(points={{-88,140},{-80,140},{-80,100},
          {-150,100},{-150,86},{-142,86}},color={0,0,127}));
  connect(TChiWatSupSet, lifPlu.u2) annotation (Line(points={{-200,100},{-160,100},
          {-160,74},{-142,74}}, color={0,0,127}));
  connect(lifPlu.y, delTem1.u1) annotation (Line(points={{-118,80},{-104,80},{-104,
          76},{-102,76}},  color={0,0,127}));
  connect(mea.y, delTem1.u2) annotation (Line(points={{-108,40},{-104,40},{-104,
          64},{-102,64}},  color={0,0,127}));
  connect(delTem1.y,subApp. u)
    annotation (Line(points={{-78,70},{-72,70}},  color={0,0,127}));
  connect(mode, isModRej.u1)
    annotation (Line(points={{-200,260},{-112,260}}, color={255,127,0}));
  connect(modRej.y, isModRej.u2) annotation (Line(points={{-128,240},{-120,240},
          {-120,252},{-112,252}}, color={255,127,0}));
  connect(isModRej.y, TSupSetUnb.u2)
    annotation (Line(points={{-88,260},{-32,260}}, color={255,0,255}));
  connect(subApp.y, TSupSetUnb.u1) annotation (Line(points={{-48,70},{-40,70},{-40,
          268},{-32,268}}, color={0,0,127}));
  connect(setOth.y,extSet. u) annotation (Line(points={{-88,200},{-80,200},{-80,
          240},{-72,240}}, color={0,0,127}));
  connect(extSet.y, TSupSetUnb.u3) annotation (Line(points={{-48,240},{-36,240},
          {-36,252},{-32,252}}, color={0,0,127}));
  connect(mConWatHexCoo_flow, cmpFlo.u) annotation (Line(points={{-200,-20},{-170,
          -20},{-170,0},{-162,0}},          color={0,0,127}));
  connect(mConWatHexCoo_flow, cmpFlo1.u) annotation (Line(points={{-200,-20},{-170,
          -20},{-170,-40},{-162,-40}},      color={0,0,127}));
  connect(cmpFlo.y, timFlo.u)
    annotation (Line(points={{-138,0},{-132,0}},     color={255,0,255}));
  connect(cmpFlo1.y, timFlo1.u)
    annotation (Line(points={{-138,-40},{-132,-40}}, color={255,0,255}));
  connect(yValBypTan, cmpOpe.u)
    annotation (Line(points={{-200,-80},{-162,-80}},   color={0,0,127}));
  connect(not1.y, timOpe1.u)
    annotation (Line(points={{-138,-120},{-132,-120}}, color={255,0,255}));
  connect(cmpOpe.y, timOpe.u)
    annotation (Line(points={{-138,-80},{-132,-80}},   color={255,0,255}));
  connect(cmpOpe.y, not1.u) annotation (Line(points={{-138,-80},{-134,-80},{-134,
          -100},{-170,-100},{-170,-120},{-162,-120}},      color={255,0,255}));
  connect(timFlo.passed, ena.u1) annotation (Line(points={{-108,-8},{-100,-8},{-100,
          -20},{-92,-20}},       color={255,0,255}));
  connect(timOpe.passed, ena.u2) annotation (Line(points={{-108,-88},{-100,-88},
          {-100,-28},{-92,-28}},       color={255,0,255}));
  connect(timFlo1.passed, dis.u1) annotation (Line(points={{-108,-48},{-96,-48},
          {-96,-60},{-92,-60}},   color={255,0,255}));
  connect(timOpe1.passed, dis.u2) annotation (Line(points={{-108,-128},{-96,-128},
          {-96,-68},{-92,-68}},         color={255,0,255}));
  connect(ena.y,enaLea. u)
    annotation (Line(points={{-68,-20},{-66,-20},{-66,-40},{-62,-40}},
                                                   color={255,0,255}));
  connect(dis.y,enaLea. clr) annotation (Line(points={{-68,-60},{-66,-60},{-66,-46},
          {-62,-46}},          color={255,0,255}));
  connect(enaLea.y, staPum.y1Ena) annotation (Line(points={{-38,-40},{-20,-40},{
          -20,66},{98,66}},     color={255,0,255}));
  connect(TConWatCooRet, delTem3.u1) annotation (Line(points={{-200,-200},{-166,
          -200},{-166,-194},{-162,-194}},                         color={0,0,127}));
  connect(TConWatCooSup, delTem3.u2) annotation (Line(points={{-200,-180},{-170,
          -180},{-170,-206},{-162,-206}}, color={0,0,127}));
  connect(TConWatHexCooEnt, delTem2.u1) annotation (Line(points={{-200,-240},{
          -166,-240},{-166,-234},{-162,-234}},
                                          color={0,0,127}));
  connect(delTem2.y, addOff.u)
    annotation (Line(points={{-138,-240},{-132,-240}}, color={0,0,127}));
  connect(addApp.y, ctlPum1.u_s)
    annotation (Line(points={{-18,-200},{-12,-200}}, color={0,0,127}));
  connect(delTem3.y, ctlPum2.u_m) annotation (Line(points={{-138,-200},{-90,
          -200},{-90,-260},{0,-260},{0,-252}},
                                         color={0,0,127}));
  connect(addOff.y, ctlPum2.u_s)
    annotation (Line(points={{-108,-240},{-12,-240}}, color={0,0,127}));
  connect(ctlPum1.y, minCtlPum.u1) annotation (Line(points={{12,-200},{20,-200},
          {20,-214},{28,-214}}, color={0,0,127}));
  connect(ctlPum2.y, minCtlPum.u2) annotation (Line(points={{12,-240},{20,-240},
          {20,-226},{28,-226}}, color={0,0,127}));
  connect(xPum[1].y, pum.x1) annotation (Line(points={{112,-200},{114,-200},{114,
          -212},{118,-212}},
                      color={0,0,127}));
  connect(xPum[2].y, pum.x2) annotation (Line(points={{112,-200},{114,-200},{114,
          -224},{118,-224}},
                      color={0,0,127}));
  connect(pum.y, yPumConWatCoo) annotation (Line(points={{142,-220},{200,-220}},
                             color={0,0,127}));
  connect(one.y, pum.f2) annotation (Line(points={{112,-250},{114,-250},{114,-228},
          {118,-228}},color={0,0,127}));
  connect(minCtlPum.y, pum.u)
    annotation (Line(points={{52,-220},{118,-220}},color={0,0,127}));
  connect(idxCycTan,extSet. index) annotation (Line(points={{-200,220},{-60,220},
          {-60,228}}, color={255,127,0}));
  connect(yPumMin.y, extYPumMin.u)
    annotation (Line(points={{52,-250},{58,-250}}, color={0,0,127}));
  connect(nPumBou.y, extYPumMin.index) annotation (Line(points={{51,-274},{70,-274},
          {70,-262}}, color={255,127,0}));
  connect(extYPumMin.y, pum.f1) annotation (Line(points={{82,-250},{84,-250},{84,
          -216},{118,-216}},color={0,0,127}));
  connect(rep.y, y1Coo)
    annotation (Line(points={{162,-120},{200,-120}}, color={255,0,255}));
  connect(xFan[1].y, fanMax.x1) annotation (Line(points={{52,190},{60,190},{60,168},
          {68,168}}, color={0,0,127}));
  connect(xFan[2].y, fanMax.x2) annotation (Line(points={{52,190},{60,190},{60,156},
          {68,156}}, color={0,0,127}));
  connect(yFan[1].y, fanMax.f1) annotation (Line(points={{52,130},{64,130},{64,164},
          {68,164}}, color={0,0,127}));
  connect(yFan[2].y, fanMax.f2) annotation (Line(points={{52,130},{64,130},{64,152},
          {68,152}}, color={0,0,127}));
  connect(ratDes.y, fanMax.u)
    annotation (Line(points={{-138,160},{68,160}}, color={0,0,127}));
  connect(enaLea.y, pre1.u) annotation (Line(points={{-38,-40},{-20,-40},{-20,-80},
          {-80,-80},{-80,-138}}, color={255,0,255}));
  connect(TConWatCooSup, ctlFan.u_m) annotation (Line(points={{-200,-180},{90,-180},
          {90,-72}},  color={0,0,127}));
  connect(pum.y, staPum.y) annotation (Line(points={{142,-220},{176,-220},{176,40},
          {94,40},{94,54},{98,54}},     color={0,0,127}));
  connect(pre1.y, ctlPum1.uEna) annotation (Line(points={{-80,-162},{-80,-216},{
          -4,-216},{-4,-212}}, color={255,0,255}));
  connect(pre1.y, ctlPum2.uEna) annotation (Line(points={{-80,-162},{-80,-256},{
          -4,-256},{-4,-252}}, color={255,0,255}));
  connect(staPum.y1, y1PumConWatCoo)
    annotation (Line(points={{122,66},{170,66},{170,60},{200,60}},
                                               color={255,0,255}));
  connect(setMax.y, TSupSet.u2) annotation (Line(points={{-48,200},{-44,200},{-44,
          194},{-32,194}}, color={0,0,127}));
  connect(TSupSetUnb.y, TSupSet.u1) annotation (Line(points={{-8,260},{0,260},{0,
          220},{-34,220},{-34,206},{-32,206}}, color={0,0,127}));
  connect(TSupSet.y, ctlFan.u_s) annotation (Line(points={{-8,200},{0,200},{0,-60},
          {78,-60}}, color={0,0,127}));
  connect(TSupSet.y, addApp.u) annotation (Line(points={{-8,200},{0,200},{0,-100},
          {-60,-100},{-60,-200},{-42,-200}},                   color={0,0,127}));
  connect(TConWatHexCooLvg, delTem2.u2) annotation (Line(points={{-200,-260},{
          -170,-260},{-170,-246},{-162,-246}}, color={0,0,127}));
  connect(TConWatHexCooLvg, ctlPum1.u_m) annotation (Line(points={{-200,-260},{
          -170,-260},{-170,-220},{0,-220},{0,-212}}, color={0,0,127}));
  connect(xFan1[1].y, fan.x1) annotation (Line(points={{132,-40},{144,-40},{144,
          -52},{148,-52}},   color={0,0,127}));
  connect(xFan1[2].y, fan.x2) annotation (Line(points={{132,-40},{144,-40},{144,
          -64},{148,-64}},   color={0,0,127}));
  connect(yFan1.y, fan.f1) annotation (Line(points={{132,-80},{146,-80},{146,-56},
          {148,-56}}, color={0,0,127}));
  connect(ctlFan.y, fan.u)
    annotation (Line(points={{102,-60},{148,-60}}, color={0,0,127}));
  connect(fan.y, yCoo)
    annotation (Line(points={{172,-60},{200,-60}}, color={0,0,127}));
  connect(fanMax.y, fan.f2) annotation (Line(points={{92,160},{140,160},{140,-68},
          {148,-68}}, color={0,0,127}));
  connect(enaLea.y, rep.u) annotation (Line(points={{-38,-40},{-20,-40},{-20,-120},
          {138,-120}}, color={255,0,255}));
  connect(enaLea.y, ctlFan.uEna) annotation (Line(points={{-38,-40},{-26,-40},{-26,
          -38},{-20,-38},{-20,-80},{86,-80},{86,-72}}, color={255,0,255}));
  annotation (Icon(coordinateSystem(extent={{-100,-180},{100,180}}),
                   graphics={
        Rectangle(
          extent={{-100,-180},{100,180}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          textColor={0,0,255},
          extent={{-150,190},{150,230}},
          textString="%name")}), Diagram(coordinateSystem(extent={{-180,-280},{
            180,280}})),
    Documentation(info="<html>
Fan enable/disable logic not included.
Implicitely modeled in the cooling tower component which uses
a low limit of the control signal to switch to free convection
and zero fan power.
</html>"));
end CoolingTowerLoop;
within Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.SeriesFanVVF.Validation;
model Controller
  "Validation of model that controls series-fan powered unit with variable volume fan"

  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.SeriesFanVVF.Controller serFanCon(
    final venStd=Buildings.Controls.OBC.ASHRAE.G36.Types.VentilationStandard.ASHRAE62_1_2016,
    final AFlo=20,
    final desZonPop=2,
    final VMin_flow=0.5,
    final VCooMax_flow=1.5,
    final maxRat=2,
    final controllerTypeVal=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    final have_preIndDam=false,
    final staPreMul=1,
    final hotWatRes=1,
    final floHys=0.01,
    final looHys=0.01,
    final damPosHys=0.01,
    final valPosHys=0.01) "Series-fan powered unit controller"
    annotation (Placement(transformation(extent={{100,70},{120,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Sine TZon(
    final freqHz=1/86400,
    final amplitude=4,
    final offset=299.15)
    "Zone temperature"
    annotation (Placement(transformation(extent={{-120,230},{-100,250}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp disAirTem(
    final height=2,
    final duration=43200,
    final offset=273.15 + 15,
    final startTime=28800)
    "Discharge airflow temperture"
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp damPos(
    final duration=43200,
    final height=0.7,
    final offset=0.3,
    final startTime=28800) "Damper position"
    annotation (Placement(transformation(extent={{-80,-170},{-60,-150}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Pulse winSta(
    final width=0.05,
    final period=43200,
    final shift=43200)
    "Window opening status"
    annotation (Placement(transformation(extent={{-80,170},{-60,190}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant cooSet(
    final k=273.15 + 24)
    "Zone cooling setpoint temperature"
    annotation (Placement(transformation(extent={{-80,210},{-60,230}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant heaSet(
    final k=273.15 + 20)
    "Zone heating setpoint temperature"
    annotation (Placement(transformation(extent={{-120,190},{-100,210}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Pulse occ(
    final width=0.75,
    final period=43200,
    final shift=28800) "Occupancy status"
    annotation (Placement(transformation(extent={{-120,150},{-100,170}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp opeMod(
    final offset=1,
    final height=2,
    final duration=28800,
    final startTime=28800)
    "Operation mode"
    annotation (Placement(transformation(extent={{-120,120},{-100,140}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt2
    "Convert real to integer"
    annotation (Placement(transformation(extent={{-40,120},{-20,140}})));
  Buildings.Controls.OBC.CDL.Continuous.Round round2(
    final n=0)
    "Round real number to given digits"
    annotation (Placement(transformation(extent={{-80,120},{-60,140}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Sine CO2(
    final amplitude=400,
    final freqHz=1/28800,
    final offset=600) "CO2 concentration"
    annotation (Placement(transformation(extent={{-80,70},{-60,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Sine parFanFlo(
    final offset=1.2,
    final amplitude=0.6,
    final freqHz=1/28800) "Parallel fan flow"
    annotation (Placement(transformation(extent={{-120,50},{-100,70}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp oveFlo(
    final height=2,
    final duration=10000,
    final startTime=35000)
    "Override flow setpoint"
    annotation (Placement(transformation(extent={{-120,-60},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt1
    "Convert real to integer"
    annotation (Placement(transformation(extent={{-40,-60},{-20,-40}})));
  Buildings.Controls.OBC.CDL.Continuous.Round round1(
    final n=0)
    "Round real number to given digits"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp oveDam(
    final height=2,
    final duration=5000,
    startTime=60000) "Override damper position"
    annotation (Placement(transformation(extent={{-120,-90},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt3
    "Convert real to integer"
    annotation (Placement(transformation(extent={{-40,-90},{-20,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Round round3(
    final n=0)
    "Round real number to given digits"
    annotation (Placement(transformation(extent={{-80,-90},{-60,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp oveTerFan(
    final height=2,
    final duration=5000,
    final startTime=60000) "Override terminal fan control"
    annotation (Placement(transformation(extent={{-120,-120},{-100,-100}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt4
    "Convert real to integer"
    annotation (Placement(transformation(extent={{-40,-120},{-20,-100}})));
  Buildings.Controls.OBC.CDL.Continuous.Round round4(
    final n=0)
    "Round real number to given digits"
    annotation (Placement(transformation(extent={{-80,-120},{-60,-100}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Ramp valPos(
    final duration=43200,
    final height=0.7,
    final offset=0.3,
    final startTime=28800) "Valve position"
    annotation (Placement(transformation(extent={{-120,-190},{-100,-170}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Sine TSup(
    final offset=273.15 + 13,
    final amplitude=1,
    final freqHz=1/28800) "Supply air temperature from air handling unit"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Pulse heaOff(
    final width=0.75,
    final period=3600)
    "Close heating valve"
    annotation (Placement(transformation(extent={{-120,-150},{-100,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Logical not"
    annotation (Placement(transformation(extent={{-40,-150},{-20,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant terFan(
    final k=true)
    "Terminal fan status"
    annotation (Placement(transformation(extent={{-120,-230},{-100,-210}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Pulse hotPla(
    final width=0.9,
    final period=7500)
    "Hot water plant status"
    annotation (Placement(transformation(extent={{-80,-250},{-60,-230}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Pulse supFan(
    final width=0.75,
    final period=7500)
    "AHU supply fan status"
    annotation (Placement(transformation(extent={{-80,-210},{-60,-190}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TSupSet(
    final k=273.15 + 13)
    "AHU supply air temperature setpoint"
    annotation (Placement(transformation(extent={{-120,-30},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Sine disFlo(
    final offset=1.3,
    final amplitude=0.6,
    final freqHz=1/28800) "Discharge airflow rate"
    annotation (Placement(transformation(extent={{-120,10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant CO2Set(final k=894)
    "CO2 concentration setpoint"
    annotation (Placement(transformation(extent={{-120,90},{-100,110}})));
equation
  connect(TZon.y,serFanCon. TZon) annotation (Line(points={{-98,240},{52,240},{52,
          110},{98,110}}, color={0,0,127}));
  connect(cooSet.y,serFanCon. TCooSet) annotation (Line(points={{-58,220},{48,
          220},{48,108},{98,108}}, color={0,0,127}));
  connect(heaSet.y,serFanCon. THeaSet) annotation (Line(points={{-98,200},{44,
          200},{44,106},{98,106}}, color={0,0,127}));
  connect(winSta.y, serFanCon.u1Win) annotation (Line(points={{-58,180},{40,180},
          {40,104},{98,104}}, color={255,0,255}));
  connect(occ.y, serFanCon.u1Occ) annotation (Line(points={{-98,160},{36,160},{
          36,102},{98,102}}, color={255,0,255}));
  connect(opeMod.y,round2. u)
    annotation (Line(points={{-98,130},{-82,130}}, color={0,0,127}));
  connect(round2.y,reaToInt2. u)
    annotation (Line(points={{-58,130},{-42,130}},
      color={0,0,127}));
  connect(reaToInt2.y,serFanCon. uOpeMod) annotation (Line(points={{-18,130},{32,
          130},{32,100},{98,100}}, color={255,127,0}));
  connect(CO2.y,serFanCon. ppmCO2) annotation (Line(points={{-58,80},{32,80},{32,
          96},{98,96}},    color={0,0,127}));
  connect(oveFlo.y,round1. u)
    annotation (Line(points={{-98,-50},{-82,-50}},   color={0,0,127}));
  connect(round1.y,reaToInt1. u)
    annotation (Line(points={{-58,-50},{-42,-50}},   color={0,0,127}));
  connect(oveDam.y, round3.u)
    annotation (Line(points={{-98,-80},{-82,-80}}, color={0,0,127}));
  connect(round3.y,reaToInt3. u)
    annotation (Line(points={{-58,-80},{-42,-80}},   color={0,0,127}));
  connect(reaToInt1.y,serFanCon. oveFloSet) annotation (Line(points={{-18,-50},{
          56,-50},{56,86},{98,86}},   color={255,127,0}));
  connect(oveTerFan.y, round4.u)
    annotation (Line(points={{-98,-110},{-82,-110}}, color={0,0,127}));
  connect(round4.y,reaToInt4. u)
    annotation (Line(points={{-58,-110},{-42,-110}}, color={0,0,127}));
  connect(disAirTem.y,serFanCon. TDis) annotation (Line(points={{-58,40},{40,40},
          {40,94},{98,94}}, color={0,0,127}));
  connect(reaToInt3.y,serFanCon. oveDamPos) annotation (Line(points={{-18,-80},{
          60,-80},{60,84},{98,84}}, color={255,127,0}));
  connect(reaToInt4.y,serFanCon. oveFan) annotation (Line(points={{-18,-110},{64,
          -110},{64,82},{98,82}}, color={255,127,0}));
  connect(damPos.y,serFanCon. uDam_actual) annotation (Line(points={{-58,-160},{72,-160},
          {72,78},{98,78}}, color={0,0,127}));
  connect(valPos.y,serFanCon. uVal_actual) annotation (Line(points={{-98,-180},{76,-180},
          {76,76},{98,76}}, color={0,0,127}));
  connect(heaOff.y, not1.u)
    annotation (Line(points={{-98,-140},{-42,-140}}, color={255,0,255}));
  connect(not1.y,serFanCon. uHeaOff) annotation (Line(points={{-18,-140},{68,-140},
          {68,80},{98,80}}, color={255,0,255}));
  connect(supFan.y, serFanCon.u1Fan) annotation (Line(points={{-58,-200},{80,-200},
          {80,74},{98,74}}, color={255,0,255}));
  connect(terFan.y, serFanCon.u1TerFan) annotation (Line(points={{-98,-220},{84,
          -220},{84,72},{98,72}}, color={255,0,255}));
  connect(hotPla.y, serFanCon.u1HotPla) annotation (Line(points={{-58,-240},{88,
          -240},{88,70},{98,70}}, color={255,0,255}));
  connect(TSupSet.y,serFanCon. TSupSet) annotation (Line(points={{-98,-20},{52,-20},
          {52,88},{98,88}}, color={0,0,127}));
  connect(TSup.y,serFanCon. TSup) annotation (Line(points={{-58,0},{48,0},{48,90},
          {98,90}},     color={0,0,127}));
  connect(disFlo.y,serFanCon.VPri_flow)  annotation (Line(points={{-98,20},{44,20},
          {44,92},{98,92}}, color={0,0,127}));
  connect(CO2Set.y, serFanCon.ppmCO2Set) annotation (Line(points={{-98,100},{28,
          100},{28,98},{98,98}}, color={0,0,127}));
annotation (
  experiment(StopTime=86400, Tolerance=1e-6),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/ASHRAE/G36/TerminalUnits/SeriesFanVVF/Validation/Controller.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This example validates
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.SeriesFanVVF.Controller\">
Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.SeriesFanVVF.Controller</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
February 10, 2022, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"),
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-140,-260},{140,260}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}), graphics={
        Ellipse(lineColor = {75,138,73},
                fillColor={255,255,255},
                fillPattern = FillPattern.Solid,
                extent = {{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points = {{-36,60},{64,0},{-36,-60},{-36,60}}),
                   Ellipse(
          lineColor={75,138,73},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}), Polygon(
          lineColor={0,0,255},
          fillColor={75,138,73},
          pattern=LinePattern.None,
          fillPattern=FillPattern.Solid,
          points={{-36,58},{64,-2},{-36,-62},{-36,58}})}));
end Controller;

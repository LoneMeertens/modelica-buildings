within Buildings.Experimental.DHC.Plants.Combined.Validation;
model AllElectricCWStorageLoads
  "Validation of all-electric plant model with buildings loads"
  extends Modelica.Icons.Example;

  replaceable package Medium=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common to CHW, HW and CW)";
  replaceable package MediumConWatCoo=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Medium in cooler circuit";

  parameter String filNam="modelica://Buildings/Resources/Data/Experimental/DHC/Loads/Examples/MediumOffice-90.1-2010-5A.mos"
    "Path to file with timeseries loads";
  parameter Modelica.Units.SI.Temperature TSetDisSupHea = 273.15+60 "District heating supply temperature set point";
  parameter Modelica.Units.SI.Temperature TSetDisSupCoo = 273.15+6 "District cooling supply temperature set point";

  replaceable parameter
    Fluid.Chillers.Data.ElectricReformulatedEIR.ReformEIRChiller_Carrier_19XR_1403kW_7_09COP_VSD datChi(
      EIRFunT={0.0101739374, 0.0607200115, 0.0003348647, 0.003162578, 0.0002388594, -0.0014121289},
      capFunT={0.0387084662, 0.2305017927, 0.0004779504, 0.0178244359, -8.48808e-05, -0.0032406711},
      EIRFunPLR={0.4304252832, -0.0144718912, 5.12039e-05, -0.7562386674, 0.5661683373,
        0.0406987748, 3.0278e-06, -0.3413411197, -0.000469572, 0.0055009208},
    QEva_flow_nominal=loaCoo.QCoo_flow_nominal/2,
      COP_nominal=2.5,
    mEva_flow_nominal=-datChi.QEva_flow_nominal/5/4186,
      mCon_flow_nominal=-datChi.QEva_flow_nominal * (1 + 1/datChi.COP_nominal) / 10 / 4186,
    TEvaLvg_nominal=TSetDisSupCoo,
    TEvaLvgMin=277.15,
    TEvaLvgMax=308.15,
    TConLvg_nominal=TSetDisSupHea,
    TConLvgMin=296.15,
    TConLvgMax=336.15)
    constrainedby Buildings.Fluid.Chillers.Data.BaseClasses.Chiller
    "Chiller parameters (each unit)"
    annotation (
      Dialog(group="CHW loop and cooling-only chillers"),
      Placement(transformation(extent={{140,200},{160,220}})));
  replaceable parameter Fluid.Chillers.Data.ElectricReformulatedEIR.Generic datChiHea=
    datChi
    constrainedby Buildings.Fluid.Chillers.Data.BaseClasses.Chiller
    "Chiller parameters (each unit)"
    annotation (
      Dialog(group="HW loop and heat recovery chillers"),
      Placement(transformation(extent={{170,200},{190,220}})));
  replaceable parameter Fluid.HeatPumps.Data.EquationFitReversible.Generic datHeaPum(
    dpHeaLoa_nominal=50000,
    dpHeaSou_nominal=100,
    hea(
      mLoa_flow=datHeaPum.hea.Q_flow/10/4186,
      mSou_flow=1E-4*datHeaPum.hea.Q_flow,
      Q_flow=loaHea.QHea_flow_nominal/2,
      P=datHeaPum.hea.Q_flow/2.2,
      coeQ={-5.64420084,1.95212447,9.96663913,0.23316322,-5.64420084},
      coeP={-3.96682255,6.8419453,1.99606939,0.01393387,-3.96682255},
      TRefLoa=298.15,
      TRefSou=253.15),
    coo(
      mLoa_flow=0,
      mSou_flow=0,
      Q_flow=-1,
      P=0,
      coeQ=fill(0, 5),
      coeP=fill(0, 5),
      TRefLoa=273.15,
      TRefSou=273.15))
    "Heat pump parameters (each unit)"
    annotation (Placement(transformation(extent={{200,200},{220,220}})));

  // Assumptions
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Conservation equations"));

  Buildings.Experimental.DHC.Plants.Combined.AllElectricCWStorage pla(
    redeclare final package Medium = Medium,
    redeclare final package MediumConWatCoo = MediumConWatCoo,
    allowFlowReversal=true,
    dpConWatCooFri_nominal=1E4,
    mAirCooUni_flow_nominal=pla.mConWatCoo_flow_nominal/pla.nCoo/1.45,
    TWetBulCooEnt_nominal=297.05,
    PFanCoo_nominal=340*pla.mConWatCoo_flow_nominal/pla.nCoo,
    chi(show_T=true),
    chiHea(show_T=true),
    heaPum(show_T=true),
    final datChi=datChi,
    final datChiHea=datChiHea,
    final datHeaPum=datHeaPum,
    nChi=2,
    dpChiWatSet_max=20E4,
    nChiHea=2,
    dpHeaWatSet_max=20E4,
    nHeaPum=2,
    nPumConWatCon=2,
    dInsTan=0.05,
    nCoo=3,
    final energyDynamics=energyDynamics)
    "CHW and HW plant"
    annotation (Placement(transformation(extent={{-30,-30},{30,30}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSet(final k=pla.TChiWatSup_nominal,
    y(final unit="K", displayUnit="degC"))
                   "Source signal for setpoint"
    annotation (Placement(transformation(extent={{-220,10},{-200,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupSet(final k=pla.THeaWatSup_nominal,
    y(final unit="K", displayUnit="degC"))
                   "Source signal for setpoint"
    annotation (Placement(transformation(extent={{-190,-10},{-170,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dpHeaWatSet_max(
    k=pla.dpHeaWatSet_max,
    y(final unit="Pa")) "Source signal for setpoint"
    annotation (Placement(transformation(extent={{-190,-70},{-170,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dpChiWatSet_max(
    k=pla.dpChiWatSet_max,
    y(final unit="Pa")) "Source signal for setpoint"
    annotation (Placement(transformation(extent={{-220,-50},{-200,-30}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    "Outdoor conditions"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-210,120})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatRet(k=pla.TChiWatRet_nominal,
              y(final unit="K", displayUnit="degC"))
    "Source signal for CHW return temperature"
    annotation (Placement(transformation(extent={{-190,-110},{-170,-90}})));
  Loads.Heating.BuildingTimeSeriesWithETS loaHea(THeaWatSup_nominal=pla.THeaWatSup_nominal,
      filNam=filNam) "Building heating load"
    annotation (Placement(transformation(extent={{10,60},{-10,80}})));
  Loads.Cooling.BuildingTimeSeriesWithETS loaCoo(
      TChiWatSup_nominal=pla.TChiWatSup_nominal,
      filNam=filNam,
      bui(w_aLoaCoo_nominal=0.015)) "Building cooling load"
    annotation (Placement(transformation(extent={{10,-78},{-10,-58}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatRet(k=pla.THeaWatRet_nominal,
      y(final unit="K", displayUnit="degC"))
    "Source signal for HW return temperature"
    annotation (Placement(transformation(extent={{-190,40},{-170,60}})));
  Modelica.Blocks.Sources.BooleanConstant ena "Always enabled"
    annotation (Placement(transformation(extent={{-220,80},{-200,100}})));
  Buildings.Controls.OBC.CDL.Logical.Not
                               onPla "On signal for the plant"
    annotation (Placement(transformation(extent={{-64,146},{-44,166}})));
  Buildings.Controls.OBC.CDL.Logical.Timer
                                 tim(t=3600)
    annotation (Placement(transformation(extent={{-104,154},{-84,174}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold offCoo(t=1e-4)
    "Threshold comparison to disable the plant"
    annotation (Placement(transformation(extent={{-144,154},{-124,174}})));
  Modelica.Blocks.Math.Gain norQFloHea(k=1/loaHea.QHea_flow_nominal)
    "Normalized Q_flow"
    annotation (Placement(transformation(extent={{-184,154},{-164,174}})));
  Buildings.Controls.OBC.CDL.Logical.Not
                               onPla1
                                     "On signal for the plant"
    annotation (Placement(transformation(extent={{-26,-168},{-6,-148}})));
  Buildings.Controls.OBC.CDL.Logical.Timer
                                 tim1(t=3600)
    annotation (Placement(transformation(extent={{-66,-160},{-46,-140}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold offCoo1(t=1e-4)
    "Threshold comparison to disable the plant"
    annotation (Placement(transformation(extent={{-106,-160},{-86,-140}})));
  Modelica.Blocks.Math.Gain norQFloCoo(k=1/loaCoo.QCoo_flow_nominal)
    "Normalized Q_flow"
    annotation (Placement(transformation(extent={{-146,-160},{-126,-140}})));
equation
  connect(TChiWatSupSet.y, pla.TChiWatSupSet) annotation (Line(points={{-198,20},
          {-34,20}},                   color={0,0,127}));
  connect(THeaWatSupSet.y, pla.THeaWatSupSet) annotation (Line(points={{-168,0},
          {-74,0},{-74,16},{-34,16}},   color={0,0,127}));
  connect(dpChiWatSet_max.y, pla.dpChiWatSet) annotation (Line(points={{-198,-40},
          {-70,-40},{-70,12},{-34,12}},color={0,0,127}));
  connect(dpHeaWatSet_max.y, pla.dpHeaWatSet) annotation (Line(points={{-168,-60},
          {-66,-60},{-66,8},{-34,8}},   color={0,0,127}));

  connect(weaDat.weaBus, pla.weaBus) annotation (Line(
      points={{-200,120},{-100,120},{-100,40},{0,40},{0,30}},
      color={255,204,51},
      thickness=0.5));
  connect(pla.port_bSerHea, loaHea.port_aSerHea) annotation (Line(points={{30,0},
          {40,0},{40,66},{10,66}}, color={0,127,255}));
  connect(loaHea.port_bSerHea, pla.port_aSerHea) annotation (Line(points={{-10,66},
          {-40,66},{-40,0},{-30,0}}, color={0,127,255}));
  connect(pla.port_bSerCoo, loaCoo.port_aSerCoo) annotation (Line(points={{30,-4},
          {40,-4},{40,-76},{10,-76}}, color={0,127,255}));
  connect(loaCoo.port_bSerCoo, pla.port_aSerCoo) annotation (Line(points={{-10,-76},
          {-40,-76},{-40,-4},{-30,-4}}, color={0,127,255}));
  connect(TChiWatRet.y, loaCoo.TSetDisRet) annotation (Line(points={{-168,-100},
          {16,-100},{16,-61},{11,-61}}, color={0,0,127}));
  connect(THeaWatRet.y, loaHea.TSetDisRet) annotation (Line(points={{-168,50},{-42,
          50},{-42,86},{16,86},{16,77},{11,77}}, color={0,0,127}));
  connect(norQFloHea.y, offCoo.u)
    annotation (Line(points={{-163,164},{-146,164}}, color={0,0,127}));
  connect(offCoo.y, tim.u)
    annotation (Line(points={{-122,164},{-106,164}}, color={255,0,255}));
  connect(tim.passed, onPla.u)
    annotation (Line(points={{-82,156},{-66,156}}, color={255,0,255}));
  connect(onPla.y, pla.u1Hea) annotation (Line(points={{-42,156},{-38,156},{-38,
          100},{-58,100},{-58,24},{-34,24}}, color={255,0,255}));
  connect(loaHea.QHea_flow, norQFloHea.u) annotation (Line(points={{-5,58},{-4,58},
          {-4,54},{-20,54},{-20,130},{-192,130},{-192,164},{-186,164}}, color={0,
          0,127}));
  connect(tim1.passed, onPla1.u)
    annotation (Line(points={{-44,-158},{-28,-158}}, color={255,0,255}));
  connect(offCoo1.y, tim1.u)
    annotation (Line(points={{-84,-150},{-68,-150}}, color={255,0,255}));
  connect(norQFloCoo.y, offCoo1.u)
    annotation (Line(points={{-125,-150},{-108,-150}}, color={0,0,127}));
  connect(loaCoo.QCoo_flow, norQFloCoo.u) annotation (Line(points={{-7,-80},{-8,
          -80},{-8,-110},{-160,-110},{-160,-150},{-148,-150}}, color={0,0,127}));
  connect(onPla1.y, pla.u1Coo) annotation (Line(points={{-4,-158},{8,-158},{8,-120},
          {-54,-120},{-54,28},{-34,28}}, color={255,0,255}));
  annotation (
    __Dymola_Commands(
      file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/DHC/Plants/Combined/Validation/AllElectricCWStorage.mos"
      "Simulate and plot"),
    experiment(
      StopTime=2592000,
      Interval=59.9999616,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"),
  Diagram(coordinateSystem(extent={{-240,-240},{240,240}})),
    Documentation(info="<html>
<p>
This model validates
<a href=\"modelica://Buildings.Experimental.DHC.Plants.Combined.AllElectricCWStorage\">
Buildings.Experimental.DHC.Plants.Combined.AllElectricCWStorage</a>
over a four-day simulation period where the load profile is characterized by
high cooling loads and low heating loads during the first day,
concomitant high cooling and heating loads during the second day,
low cooling loads and high heating loads during the third day,
and no cooling loads (cooling disabled) and high heating loads 
during the last day. 
</p>
</html>"));
end AllElectricCWStorageLoads;

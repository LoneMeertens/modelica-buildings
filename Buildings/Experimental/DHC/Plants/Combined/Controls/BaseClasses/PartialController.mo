within Buildings.Experimental.DHC.Plants.Combined.Controls.BaseClasses;
block PartialController "Interface class for plant controller"

  parameter Integer nChi(final min=1, start=1)
    "Number of units operating at design conditions"
    annotation (Dialog(group="CHW loop and cooling-only chillers"),
      Evaluate=true);
  parameter Integer nPumChiWat(final min=1, start=1)
    "Number of CHW pumps operating at design conditions"
    annotation (Dialog(group="CHW loop and cooling-only chillers"),
      Evaluate=true);
  parameter Modelica.Units.SI.Temperature TChiWatSup_nominal
    "Design (minimum) CHW supply temperature"
    annotation(Dialog(group="CHW loop and cooling-only chillers"));

  parameter Integer nChiHea(final min=1, start=1)
    "Number of units operating at design conditions"
    annotation (Dialog(group="HW loop and heat recovery chillers"),
      Evaluate=true);
  parameter Integer nPumHeaWat(final min=1, start=1)
    "Number of HW pumps operating at design conditions"
    annotation (Dialog(group="HW loop and heat recovery chillers"),
      Evaluate=true);
  parameter Modelica.Units.SI.Temperature THeaWatSup_nominal
    "Design (maximum) HW supply temperature"
    annotation (Dialog(group="HW loop and heat recovery chillers"));

  parameter Integer nHeaPum(final min=1, start=1)
    "Number of heat pumps operating at design conditions"
    annotation (Dialog(group="CW loop, TES tank and heat pumps"),
      Evaluate=true);
  parameter Integer nPumConWatCon(final min=1, start=1)
    "Number of CW pumps serving condenser barrels at design conditions"
    annotation (Dialog(group="CW loop, TES tank and heat pumps"),
      Evaluate=true);
  parameter Integer nPumConWatEva(final min=1, start=1)
    "Number of CW pumps serving evaporator barrels at design conditions"
    annotation (Dialog(group="CW loop, TES tank and heat pumps"),
      Evaluate=true);
  parameter Modelica.Units.SI.Temperature TTanSet[:, 2]
    "Tank temperature setpoints"
    annotation(Dialog(group="CW loop, TES tank and heat pumps"));
  final parameter Integer nCycTan = size(TTanSet, 1)
    "Number of tank cycles"
    annotation(Evaluate=true);

  parameter Integer nCoo(final min=1, start=1)
    "Number of cooling tower cells operating at design conditions"
    annotation (Dialog(group="Cooling tower loop"),
      Evaluate=true);
  parameter Integer nPumConWatCoo(final min=1, start=1)
    "Number of CW pumps serving cooling towers at design conditions"
    annotation (Dialog(group="Cooling tower loop"),
      Evaluate=true);

  parameter Modelica.Units.SI.HeatFlowRate QChiWatChi_flow_nominal
    "Cooling design heat flow rate of cooling-only chillers (all units)"
    annotation (Dialog(group="CHW loop and cooling-only chillers"));
  parameter Real PLRStaTra(final unit="1", final min=0, final max=1) = 0.85
    "Part load ratio triggering stage transition";
  parameter Modelica.Units.SI.HeatFlowRate QChiWatCasCoo_flow_nominal
    "Cooling design heat flow rate of HRC in cascading cooling mode (all units)"
    annotation (Dialog(group="HW loop and heat recovery chillers"));
  parameter Modelica.Units.SI.HeatFlowRate QHeaWat_flow_nominal
    "Heating design heat flow rate (all units)"
    annotation (Dialog(group="HW loop and heat recovery chillers"));
  parameter Modelica.Units.SI.SpecificHeatCapacity cp_default=
    Buildings.Utilities.Psychrometrics.Constants.cpWatLiq
    "Specific heat capacity of the fluid";

  parameter Modelica.Units.SI.MassFlowRate mChiWat_flow_nominal(
    final min=0)
    "CHW design mass flow rate (all units)"
    annotation(Dialog(group="CHW loop and cooling-only chillers"));
  parameter Modelica.Units.SI.PressureDifference dpChiWatSet_max(
    final min=0,
    displayUnit="Pa")
    "Design (maximum) CHW differential pressure setpoint"
    annotation(Dialog(group="CHW loop and cooling-only chillers"));
  parameter Modelica.Units.SI.MassFlowRate mHeaWat_flow_nominal
    "HW design mass flow rate (all units)"
    annotation (Dialog(group="HW loop and heat recovery chillers"));
  parameter Modelica.Units.SI.PressureDifference dpHeaWatSet_max(
    final min=0,
    displayUnit="Pa")
    "Design (maximum) HW differential pressure setpoint"
    annotation(Dialog(group="HW loop and heat recovery chillers"));
  parameter Modelica.Units.SI.MassFlowRate mConWatCon_flow_nominal(
    final min=0)
    "Design total CW mass flow rate through condenser barrels (all units)";
  parameter Modelica.Units.SI.MassFlowRate mConWatEva_flow_nominal(
    final min=0)
    "Design total CW mass flow rate through evaporator barrels (all units)"
    annotation(Dialog(group="CW loop, TES tank and heat pumps"));
  parameter Modelica.Units.SI.PressureDifference dpConWatConSet_max(
    final min=0,
    displayUnit="Pa")
    "Design (maximum) CW condenser loop differential pressure setpoint"
    annotation(Dialog(group="CW loop, TES tank and heat pumps"));
  parameter Modelica.Units.SI.PressureDifference dpConWatEvaSet_max(
    final min=0,
    displayUnit="Pa")
    "Design (maximum) CW evaporator loop differential pressure setpoint"
    annotation(Dialog(group="CW loop, TES tank and heat pumps"));

  parameter Real fraUslTan(final unit="1", final min=0, final max=1)
    "Useless fraction of TES"
    annotation(Dialog(group="CW loop, TES tank and heat pumps"));
  final parameter Integer nTTan = size(TTan, 1)
    "Number of tank temperature points"
    annotation(Evaluate=true);

  parameter Modelica.Units.SI.Time riseTimePum=30
    "Pump rise time of the filter (time to reach 99.6 % of the speed)"
    annotation (
      Dialog(
      tab="Dynamics",
      group="Filtered speed"));
  parameter Modelica.Units.SI.Time riseTimeVal=120
    "Pump rise time of the filter (time to reach 99.6 % of the opening)"
    annotation (
      Dialog(
      tab="Dynamics",
      group="Filtered opening"));

  Real fraChaTan(final unit="1")=
    (sum(TTan .- TTanSet[nCycTan, 2]) / (TTanSet[1, 2] - TTanSet[1, 1]) / nTTan - fraUslTan) /
    (1 - fraUslTan)
    "Tank charge fraction";
  Real ratFraChaTan(final unit="1/s")=
    fraChaTan - delay(fraChaTan, 5*60)
    "Rate of change of tank charge fraction";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Coo
    "Cooling enable signal"
    annotation (Placement(transformation(extent={{-300,320},{-260,360}}),
        iconTransformation(extent={{-260,270},{-220,310}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Hea
    "Heating enable signal"
    annotation (Placement(transformation(extent={{-300,280},{-260,320}}),
        iconTransformation(extent={{-260,240},{-220,280}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(final unit="K",
      displayUnit="degC") "CHW supply temperature setpoint"
    annotation (Placement(transformation(extent={{-300,240},{-260,280}}),
        iconTransformation(extent={{-260,200},{-220,240}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupSet(final unit="K",
      displayUnit="degC")
    "HW supply temperature setpoint"
    annotation (Placement(transformation(extent={{-300,200},{-260,240}}),
        iconTransformation(extent={{-260,170},{-220,210}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValEvaChi[nChi]
    "Cooling-only chiller evaporator isolation valve commanded position"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,320}),iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,270})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValConChi[nChi](
    each final unit="1")
    "Cooling-only chiller condenser isolation valve commanded position"
    annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,300}),iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,250})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Chi[nChi]
    "Cooling-only chiller On/Off command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,340}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,290})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1PumChiWat[nPumChiWat]
    "CHW pump Start command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,260}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,230})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumChiWat(
    final unit="1")
    "CHW pump speed signal"
    annotation (Placement(
        transformation(extent={{260,220},{300,260}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,210})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValEvaChiHea[nChiHea](
    each final unit="1")
    "HR chiller evaporator isolation valve commanded position"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,80}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,70})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1ChiHea[nChiHea]
    "HR chiller On/Off command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,160}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,160})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1CooChiHea[nChiHea]
    "HR chiller cooling mode switchover command: true for cooling, false for heating"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,140}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,140})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValConChiHea[nChiHea](
    each final unit="1")
    "HR chiller condenser isolation valve commanded position"
    annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,60}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,50})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1PumHeaWat[nPumHeaWat]
    "HW pump Start command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,20}),  iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,20})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumHeaWat(
    final unit="1")
    "HW pump speed signal"
    annotation (Placement(
        transformation(extent={{260,-20},{300,20}},  rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,0})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValChiWatMinByp(
    final unit="1")
    "CHW minimum flow bypass valve control signal"
    annotation (Placement(
        transformation(extent={{260,180},{300,220}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,190})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHeaWatMinByp(
    final unit="1")
    "HW minimum flow bypass valve control signal"
    annotation (Placement(
        transformation(extent={{260,-60},{300,-20}},  rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-30})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1PumConWatCon[nPumConWatCon]
    "CW pump serving condenser barrels Start command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,-80}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-58})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumConWatCon(
    final unit="1")
    "CW pump serving condenser barrels Speed command"
    annotation (Placement(
        transformation(extent={{260,-120},{300,-80}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-78})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1PumConWatEva[nPumConWatEva]
    "CW pump serving evaporator barrels Start command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,-120}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-98})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumConWatEva(
    final unit="1")
    "CW pump serving evaporator barrels Speed command"
    annotation (Placement(
        transformation(extent={{260,-160},{300,-120}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-118})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1HeaPum[nHeaPum]
    "Heat pump On/Off command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,-180}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-148})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput THeaPumSet(
    final unit="K", displayUnit="degC") "Heat pump supply temperature setpoint"
    annotation (Placement(
        transformation(extent={{260,-220},{300,-180}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-168})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValBypTan(
    final unit="1") "TES tank bypass valve commanded position"
    annotation (Placement(
        transformation(extent={{260,-280},{300,-240}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-290})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Coo[nCoo]
    "Cooling tower Start command"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,-300}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-228})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yCoo(
    final unit="1")
    "Cooling tower fan speed command" annotation (Placement(transformation(
          extent={{260,-340},{300,-300}}, rotation=0), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-248})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1PumConWatCoo[
    nPumConWatCoo] "Cooling tower pump Start command"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,-340}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-268})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TChiHeaSet[nChiHea](
    each final unit="K", each displayUnit="degC")
    "HR chiller supply temperature setpoint"
    annotation (Placement(transformation(extent={{260,80},{300,120}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,100})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1HeaCooChiHea[nChiHea]
    "HR chiller direct heat recovery switchover command: true for direct HR, false for cascading"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={280,120}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,120})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValConWatChiByp(final unit=
        "1") "CW chiller bypass valve commanded position" annotation (Placement(
        transformation(extent={{260,-240},{300,-200}}, rotation=0),
        iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={240,-200})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dpChiWatSet(final unit="Pa",
      final min=0) "CHW differential pressure setpoint (for local dp sensor)"
    annotation (Placement(transformation(extent={{-300,160},{-260,200}}),
        iconTransformation(extent={{-260,130},{-220,170}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dpHeaWatSet(final unit="Pa",
      final min=0)
    "HW differential pressure setpoint (for local dp sensor)"
    annotation (Placement(transformation(extent={{-300,120},{-260,160}}),
        iconTransformation(extent={{-260,100},{-220,140}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dpChiWat(final unit="Pa")
    "CHW differential pressure (from local dp sensor)"
    annotation (Placement(transformation(extent={{-300,-180},{-260,-140}}),
        iconTransformation(extent={{-260,-140},{-220,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dpHeaWat(final unit="Pa")
    "HW differential pressure (from local dp sensor)"
    annotation (Placement(transformation(extent={{-300,-220},{-260,-180}}),
        iconTransformation(extent={{-260,-170},{-220,-130}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mChiWatPri_flow(final unit=
        "kg/s") "Primary CHW mass flow rate"
    annotation (Placement(
        transformation(extent={{-300,-20},{-260,20}}), iconTransformation(
          extent={{-260,-20},{-220,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mHeaWatPri_flow(final unit=
        "kg/s") "Primary HW mass flow rate" annotation (Placement(
        transformation(extent={{-300,-60},{-260,-20}}),
                                                      iconTransformation(extent={{-260,
            -50},{-220,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dpConWatCon(final unit="Pa")
    "CW condenser loop differential pressure" annotation (Placement(
        transformation(extent={{-300,-260},{-260,-220}}), iconTransformation(
          extent={{-260,-200},{-220,-160}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dpConWatEva(final unit="Pa")
    "CW evaporator loop differential pressure" annotation (Placement(
        transformation(extent={{-300,-300},{-260,-260}}), iconTransformation(
          extent={{-260,-230},{-220,-190}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mConWatCon_flow(final unit=
        "kg/s") "CW condenser loop mass flow rate" annotation (Placement(
        transformation(extent={{-300,-100},{-260,-60}}),
                                                     iconTransformation(extent={{-260,
            -80},{-220,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mConWatEva_flow(final unit=
        "kg/s") "CW evaporator loop mass flow rate" annotation (Placement(
        transformation(extent={{-300,-140},{-260,-100}}),
                                                      iconTransformation(extent={{-260,
            -110},{-220,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatPriRet(final unit="K",
      displayUnit="degC") "Primary CHW return temperature " annotation (
      Placement(transformation(extent={{-300,60},{-260,100}}),
        iconTransformation(extent={{-260,40},{-220,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatPriRet(final unit="K",
      displayUnit="degC") "Primary HW return temperature " annotation (
      Placement(transformation(extent={{-300,20},{-260,60}}),
        iconTransformation(extent={{-260,10},{-220,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTan[:](
    each final unit="K",
    each  displayUnit="degC")
    "TES tank temperature" annotation (Placement(
        transformation(extent={{-300,-340},{-260,-300}}), iconTransformation(
          extent={{-260,-280},{-220,-240}})));
  annotation (Diagram(coordinateSystem(extent={{-260,-360},{260,360}})), Icon(
        coordinateSystem(extent={{-220,-300},{220,300}}),
        graphics={                      Text(
        extent={{-150,350},{150,310}},
        textString="%name",
        textColor={0,0,255})}));
end PartialController;

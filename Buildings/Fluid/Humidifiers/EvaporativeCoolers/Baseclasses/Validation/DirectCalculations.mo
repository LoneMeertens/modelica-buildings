within Buildings.Fluid.Humidifiers.EvaporativeCoolers.Baseclasses.Validation;
model DirectCalculations
  "Validation of the DirectCalculations block"
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.Area padAre = 0.6
    "Area of the rigid media evaporative pad";
  parameter Modelica.Units.SI.Length dep = 0.2
    "Depth of the rigid media evaporative pad";
  parameter Modelica.Units.SI.Length pAtm = 101325
    "Atmospheric pressure";
  parameter Modelica.Units.SI.ThermodynamicTemperature TDryBulSup_nominal = 296.15
    "Nominal supply air drybulb temperature";
  parameter Modelica.Units.SI.ThermodynamicTemperature TWetBulSup_nominal = 289.3
    "Nominal supply air wetbulb temperature";
  parameter Modelica.Units.SI.VolumeFlowRate V_flow_nominal = 1
    "Nominal supply air volume flowrate";

  Buildings.Fluid.Humidifiers.EvaporativeCoolers.Baseclasses.DirectCalculations
    dirEvaCoo(
    redeclare package Medium = Buildings.Media.Air,
    padAre=padAre,
    dep=dep)
    "Instance with time-varying volume flowrate signal"
     annotation (Placement(visible=true, transformation(
        origin={30,50},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Buildings.Fluid.Humidifiers.EvaporativeCoolers.Baseclasses.DirectCalculations
    dirEvaCoo1(
    redeclare package Medium = Buildings.Media.Air,
    padAre=padAre,
    dep=dep)
    "Instance with time-varying wetbulb temperature signal"    annotation (
      Placement(visible=true, transformation(
        origin={30,0},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Buildings.Fluid.Humidifiers.EvaporativeCoolers.Baseclasses.DirectCalculations
    dirEvaCoo2(
    redeclare package Medium = Buildings.Media.Air,
    padAre=padAre,
    dep=dep)
    "Instance with time-varying drybulb temperature signal"    annotation (
      Placement(visible=true, transformation(
        origin={30,-50},
        extent={{-10,-10},{10,10}},
        rotation=0)));

protected
  Modelica.Blocks.Sources.Constant TWetBulSupCon(k=TWetBulSup_nominal)
    "Constant wet bulb temperature signal" annotation (Placement(visible=true,
        transformation(
        origin={-80,80},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Modelica.Blocks.Sources.Constant TDryBulSupCon(k=TDryBulSup_nominal)
    "Constant drybulb temperature signal" annotation (Placement(visible=true,
        transformation(
        origin={-80,30},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Modelica.Blocks.Sources.Ramp TWetBulSupRam(
    duration=60,
    height=5,
    offset=TWetBulSup_nominal,
    startTime=0) "Ramp signal for wet-bulb temperature" annotation (Placement(
        visible=true, transformation(
        origin={-10,20},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Modelica.Blocks.Sources.Ramp TDryBulSupRam(
    duration=60,
    height=15,
    offset=TDryBulSup_nominal,
    startTime=0) "Ramp signal for drybulb temperature" annotation (Placement(
        visible=true, transformation(
        origin={-10,-26},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Modelica.Blocks.Sources.Constant V_flowCon(k=V_flow_nominal)
    "Constant volume flowrate signal" annotation (Placement(visible=true,
        transformation(
        origin={-80,-30},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Modelica.Blocks.Sources.Ramp V_flowRam(
    duration=60,
    height=0.5,
    offset=V_flow_nominal,
    startTime=0) "Ramp signal for volume flowrate" annotation (Placement(
        visible=true, transformation(
        origin={-10,80},
        extent={{-10,-10},{10,10}},
        rotation=0)));

  Modelica.Blocks.Sources.Constant pCon(k=pAtm) "Constant pressure signal"
    annotation (Placement(visible=true, transformation(
        origin={-80,-80},
        extent={{-10,-10},{10,10}},
        rotation=0)));

equation
  connect(TWetBulSupCon.y, dirEvaCoo.TWetBulIn) annotation (Line(points={{-69,80},
          {-40,80},{-40,56},{18,56}}, color={0,0,127}));
  connect(TDryBulSupCon.y, dirEvaCoo.TDryBulIn) annotation (Line(points={{-69,30},
          {-30,30},{-30,52},{18,52}}, color={0,0,127}));
  connect(V_flowRam.y, dirEvaCoo.V_flow) annotation (Line(points={{1,80},{10,80},
          {10,48},{18,48}}, color={0,0,127}));
  connect(TWetBulSupRam.y, dirEvaCoo1.TWetBulIn)
    annotation (Line(points={{1,20},{10,20},{10,6},{18,6}}, color={0,0,127}));
  connect(V_flowCon.y, dirEvaCoo1.V_flow) annotation (Line(points={{-69,-30},{-60,
          -30},{-60,-2},{18,-2}}, color={0,0,127}));
  connect(pCon.y, dirEvaCoo.p) annotation (Line(points={{-69,-80},{-50,-80},{-50,
          44},{18,44}}, color={0,0,127}));
  connect(TDryBulSupRam.y, dirEvaCoo2.TDryBulIn) annotation (Line(points={{1,-26},
          {10,-26},{10,-48},{18,-48}}, color={0,0,127}));
  connect(TWetBulSupCon.y, dirEvaCoo2.TWetBulIn) annotation (Line(points={{-69,80},
          {-40,80},{-40,-44},{18,-44}}, color={0,0,127}));
  connect(TDryBulSupCon.y, dirEvaCoo1.TDryBulIn) annotation (Line(points={{-69,30},
          {-30,30},{-30,2},{18,2}}, color={0,0,127}));
  connect(V_flowCon.y, dirEvaCoo2.V_flow) annotation (Line(points={{-69,-30},{-60,
          -30},{-60,-52},{18,-52}}, color={0,0,127}));
  connect(pCon.y, dirEvaCoo1.p) annotation (Line(points={{-69,-80},{-50,-80},{-50,
          -6},{18,-6}}, color={0,0,127}));
  connect(pCon.y, dirEvaCoo2.p) annotation (Line(points={{-69,-80},{-50,-80},{-50,
          -56},{18,-56}}, color={0,0,127}));
  annotation (Documentation(info="<html>
<p>This model implements a validation of the block <a href=\"modelica://Buildings.Fluid.Humidifiers.EvaporativeCoolers.Baseclasses.DirectCalculations\">Buildings.Fluid.Humidifiers.EvaporativeCoolers.Baseclasses.DirectCalculations</a> that applies the peformance curve to calucalte the water mass flow rate of a direct evaporative cooler. </p>
<p>This model considers three validation cases: time-varying inlet air dry bulb temperature, time-varying inlet air wet bulb temperature, and time-varying inlet air volume flow rate.</p>
<p>The pressure is the atmospheric pressure for all the three validation cases.</p>
</html>", revisions="<html>
<ul>
<li>
Semptember 14, 2023 by Cerrina Mouchref, Karthikeya Devaprasad, Lingzhe Wang:<br/>
First implementation.
</li>
</ul>
</html>"),
experiment(
    StopTime=60,
    Interval=1),
    __Dymola_Commands(file=
          "modelica://Buildings/Resources/Scripts/Dymola/Fluid/Humidifiers/EvaporativeCoolers/Baseclasses/Validation/DirectCalculations.mos"
        "Simulate and plot"));
end DirectCalculations;

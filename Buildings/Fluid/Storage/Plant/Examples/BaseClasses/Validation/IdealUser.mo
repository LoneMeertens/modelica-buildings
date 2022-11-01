within Buildings.Fluid.Storage.Plant.Examples.BaseClasses.Validation;
model IdealUser "Test model for the dummy user"
  extends Modelica.Icons.Example;

  package Medium = Buildings.Media.Water "Medium model";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=1
    "Nominal mass flow rate";
  parameter Modelica.Units.SI.PressureDifference dp_nominal=500000
    "Nominal pressure difference";
  parameter Modelica.Units.SI.AbsolutePressure p_Pressurisation=300000
    "Pressurisation point";
  parameter Modelica.Units.SI.Temperature T_CHWR_nominal(
    final displayUnit="degC")=12+273.15
    "Nominal temperature of CHW return";
  parameter Modelica.Units.SI.Temperature T_CHWS_nominal(
    final displayUnit="degC")=7+273.15
    "Nominal temperature of CHW supply";
  parameter Boolean allowFlowReversal=false
    "Flow reversal setting";
  parameter Modelica.Units.SI.Power QCooLoa_flow_nominal=5*4200*0.9
    "Nominal cooling load of one consumer";

  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.IdealUser ideUse(
    redeclare final package Medium = Medium,
    final vol(final T_start=15 + 273.15),
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=dp_nominal,
    final T_a_nominal=T_CHWS_nominal,
    final T_b_nominal=T_CHWR_nominal) "Ideal user" annotation (Placement(
        transformation(extent={{-10,-10},{10,10}}, rotation=0)));
  Buildings.Fluid.Sources.Boundary_pT sin(
    redeclare final package Medium = Medium,
    final p=p_Pressurisation,
    final T=T_CHWR_nominal,
    nPorts=1) "Sink representing CHW return line"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-70,-30})));
  Buildings.Fluid.Sources.Boundary_pT sou(
    redeclare final package Medium = Medium,
    final p=p_Pressurisation+dp_nominal,
    final T=T_CHWS_nominal,
    nPorts=1) "Source representing CHW supply line" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-70,30})));
  Modelica.Blocks.Sources.TimeTable preQCooLoa_flow(table=[0*3600,0; 0.5*3600,0;
        0.5*3600,QCooLoa_flow_nominal; 0.75*3600,QCooLoa_flow_nominal; 0.75*3600,
        0; 1*3600,0])
    "Placeholder, prescribed cooling load"
    annotation (Placement(transformation(extent={{-60,60},{-40,80}})));
equation
  connect(sou.ports[1],ideUse. port_a) annotation (Line(points={{-60,30},{-40,
          30},{-40,6},{-10,6}},                      color={0,127,255}));
  connect(ideUse.port_b, sin.ports[1])
    annotation (Line(points={{-10,-6},{-40,-6},{-40,-30},{-60,-30}},
                                             color={0,127,255}));
  connect(preQCooLoa_flow.y,ideUse. QCooLoa_flow) annotation (Line(points={{-39,70},
          {-11,70},{-11,8}},             color={0,0,127}));
annotation(__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Storage/Plant/Examples/BaseClasses/Validation/IdealUser.mos"
        "Simulate and plot"),
experiment(Tolerance=1e-06, StopTime=3600), Documentation(info="<html>
<p>
This is a simple test model for the ideal user.
</p>
</html>", revisions="<html>
<ul>
<li>
February 18, 2022 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end IdealUser;

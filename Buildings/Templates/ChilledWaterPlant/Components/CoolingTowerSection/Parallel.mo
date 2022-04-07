within Buildings.Templates.ChilledWaterPlant.Components.CoolingTowerSection;
model Parallel "Cooling tower in parallel"
  extends
    Buildings.Templates.ChilledWaterPlant.Components.CoolingTowerSection.Interfaces.PartialCoolingTowerSection(
     final typ=Buildings.Templates.ChilledWaterPlant.Components.Types.CoolingTowerSection.CoolingTowerParallel);

  replaceable Buildings.Templates.Components.CoolingTower.Merkel cooTow[nCooTow]
    constrainedby
    Buildings.Templates.Components.CoolingTower.Interfaces.PartialCoolingTower(
      redeclare each final package Medium=Medium,
      each final show_T=show_T,
      each final allowFlowReversal=allowFlowReversal,
      final dat = dat.cooTow) "Cooling tower type"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));

  inner replaceable Buildings.Templates.Components.Valves.TwoWayTwoPosition valCooTowInl[nCooTow]
    constrainedby
    Buildings.Templates.Components.Valves.Interfaces.PartialValve(
      redeclare each final package Medium = Medium,
      each final allowFlowReversal=allowFlowReversal,
      final dat = dat.valCooTowInl)
      "Cooling tower inlet valves"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  inner replaceable Buildings.Templates.Components.Valves.None valCooTowOut[nCooTow]
    constrainedby
    Buildings.Templates.Components.Valves.Interfaces.PartialValve(
      redeclare each final package Medium = Medium,
      each final allowFlowReversal=allowFlowReversal,
      final dat = dat.valCooTowOut)
      "Cooling tower outlet valves"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));

  Buildings.Fluid.Delays.DelayFirstOrder volInl(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final m_flow_nominal=m_flow_nominal,
    tau=1,
    nPorts=nCooTow+1)
    "Fluid volume at inlet"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-80,-30})));
  Buildings.Fluid.Delays.DelayFirstOrder volOut(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final m_flow_nominal=m_flow_nominal,
    tau=1,
    nPorts=nCooTow+1)
    "Fluid volume at outet"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={80,-30})));

equation
  connect(volInl.ports[1], port_a)
    annotation (Line(points={{-80,-20},{-80,0},{-100,0}}, color={0,127,255}));
  connect(volInl.ports[2:nCooTow+1], valCooTowInl.port_a)
    annotation (Line(points={{-80,-20},{-80,0},{-60,0}}, color={0,127,255}));
  connect(volOut.ports[1], port_b)
    annotation (Line(points={{80,-20},{80,0},{100,0}}, color={0,127,255}));
  connect(volOut.ports[2:nCooTow+1], valCooTowOut.port_b)
    annotation (Line(points={{80,-20},{80,0},{60,0}}, color={0,127,255}));
  connect(cooTow.port_b, valCooTowOut.port_a)
    annotation (Line(points={{10,0},{40,0}}, color={0,127,255}));
  connect(valCooTowInl.port_b, cooTow.port_a)
    annotation (Line(points={{-40,0},{-10,0}}, color={0,127,255}));
  connect(busCon.valCooTowInl, valCooTowInl.bus) annotation (Line(
      points={{0.1,100.1},{0.1,60},{-50,60},{-50,10}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(busCon.valCooTowOut, valCooTowOut.bus) annotation (Line(
      points={{0.1,100.1},{0.1,60},{50,60},{50,10}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));

  for i in 1:nCooTow loop
    connect(busCon.cooTow[i], cooTow[i].bus) annotation (Line(
        points={{0.1,100.1},{0.1,56},{0,56},{0,10}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-3,6},{-3,6}},
        horizontalAlignment=TextAlignment.Right));
    connect(weaBus, cooTow[i].weaBus) annotation (Line(
        points={{50,100},{50,80},{5,80},{5,10}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{6,3},{6,3}},
        horizontalAlignment=TextAlignment.Left));
  end for;
end Parallel;
within Buildings.Templates.AirHandlersFans.Validation;
model VAVMultiZoneOpenLoop
  extends BaseNoEconomizer(redeclare
      UserProject.AirHandlersFans.VAVMultiZoneOpenLoop VAV_1);

  Fluid.Sources.Boundary_pT bou2(
    redeclare final package Medium = MediumHea, nPorts=1)
    annotation (Placement(transformation(extent={{-60,-60},{-40,-40}})));
  Fluid.Sources.Boundary_pT bou3(redeclare final package Medium = MediumHea,
      nPorts=1)
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));

  Fluid.Sources.Boundary_pT bou4(redeclare final package Medium = MediumCoo,
      nPorts=1)
    annotation (Placement(transformation(extent={{60,-60},{40,-40}})));
  Fluid.Sources.Boundary_pT bou5(redeclare final package Medium = MediumCoo,
      nPorts=1)
    annotation (Placement(transformation(extent={{60,-90},{40,-70}})));
equation
  connect(bou2.ports[1], VAV_1.port_coiHeaPreSup) annotation (Line(points={{-40,-50},
          {-9,-50},{-9,-20}},        color={0,127,255}));
  connect(VAV_1.port_coiHeaPreRet, bou3.ports[1]) annotation (Line(points={{-15,-20},
          {-15,-80},{-40,-80}},       color={0,127,255}));
  connect(bou4.ports[1], VAV_1.port_coiCooRet)
    annotation (Line(points={{40,-50},{-3,-50},{-3,-20}}, color={0,127,255}));
  connect(VAV_1.port_coiCooSup, bou5.ports[1])
    annotation (Line(points={{3,-19.8},{3,-80},{40,-80}}, color={0,127,255}));
  annotation (
    experiment(Tolerance=1e-6, StopTime=1),
    Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end VAVMultiZoneOpenLoop;

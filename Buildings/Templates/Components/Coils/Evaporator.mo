within Buildings.Templates.Components.Coils;
model Evaporator "Evaporator coil (direct expansion)"
  extends Buildings.Templates.Components.Coils.Interfaces.PartialCoil(
    final typ=Buildings.Templates.Components.Types.Coil.Evaporator,
    final typHex=hex.typ,
    final typVal=Buildings.Templates.Components.Types.Valve.None,
    final have_sou=false,
    final have_weaBus=true);

  inner parameter Boolean have_dryCon = true
    "Set to true for purely sensible cooling of the condenser";

  replaceable
    Buildings.Templates.Components.HeatExchangers.Interfaces.PartialCoilDirectExpansion
    hex(
      redeclare final package Medium = MediumAir,
      final datRec=datRecHex)
    "Heat exchanger"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));

equation
  connect(port_a, hex.port_a)
    annotation (Line(points={{-100,0},{-10,0}}, color={0,127,255}));
  connect(busWea,hex.busWea)  annotation (Line(
      points={{-60,100},{-60,20},{-6,20},{-6,10}},
      color={255,204,51},
      thickness=0.5));
  connect(bus, hex.bus) annotation (Line(
      points={{0,100},{0,10}},
      color={255,204,51},
      thickness=0.5));
  connect(hex.port_b, port_b)
    annotation (Line(points={{10,0},{100,0}}, color={0,127,255}));
  annotation (
    Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end Evaporator;

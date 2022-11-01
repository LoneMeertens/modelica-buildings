within Buildings.Templates.AirHandlersFans.Components.OutdoorReliefReturnSection;
model EconomizerNoRelief "Air Economizer - No Relief Branch"
  extends
    .Buildings.Templates.AirHandlersFans.Components.OutdoorReliefReturnSection.Interfaces.PartialOutdoorReliefReturnSection(
    final typ=Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.EconomizerNoRelief,
    final typSecOut=secOut.typ,
    final typSecRel=secRel.typ,
    final typDamOut=secOut.typDamOut,
    final typDamOutMin=secOut.typDamOutMin,
    final typDamRel=secRel.typDamRel,
    final typDamRet=damRet.typ,
    final typFanRel=secRel.typFanRel,
    final typFanRet=secRel.typFanRet,
    final have_recHea=false);

  replaceable Buildings.Templates.AirHandlersFans.Components.OutdoorSection.SingleDamper
    secOut constrainedby
    Buildings.Templates.AirHandlersFans.Components.OutdoorSection.Interfaces.PartialOutdoorSection(
      redeclare final package MediumAir = MediumAir,
      final dat=dat)
    "Outdoor air section"
    annotation (
    choices(
      choice(redeclare replaceable
          Buildings.Templates.AirHandlersFans.Components.OutdoorSection.SingleDamper
          secOut "Single common OA damper (modulating) with AFMS"),
      choice(redeclare replaceable
          Buildings.Templates.AirHandlersFans.Components.OutdoorSection.DedicatedDampersAirflow
          secOut "Dedicated minimum OA damper (modulating) with AFMS"),
      choice(redeclare replaceable
          Buildings.Templates.AirHandlersFans.Components.OutdoorSection.DedicatedDampersPressure
          secOut
          "Dedicated minimum OA damper (two-position) with differential pressure sensor")),
    Dialog(group="Configuration"),
    Placement(transformation(extent={{-58,-94},{-22,-66}})));

  Buildings.Templates.AirHandlersFans.Components.ReliefReturnSection.NoRelief
    secRel(
      redeclare final package MediumAir = MediumAir,
      final dat=dat)
    "Relief/return air section"
    annotation (Dialog(group="Configuration"),
      Placement(transformation(extent={{-18,66},{18,94}})));

  Buildings.Templates.Components.Dampers.Modulating damRet(
    redeclare final package Medium = MediumAir,
    final dat=dat.damRet,
    final text_rotation=90)
    "Return air damper"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,0})));
equation
  /* Control point connection - start */
  connect(damRet.bus, bus.damRet);
  /* Control point connection - end */
  connect(secRel.port_a, port_Ret)
    annotation (Line(points={{18,80},{180,80}}, color={0,127,255}));
  connect(secRel.port_bRet, damRet.port_a)
    annotation (Line(points={{0,66},{0,10}}, color={0,127,255}));
  connect(damRet.port_b, port_Sup)
    annotation (Line(points={{0,-10},{0,-80},{180,-80}}, color={0,127,255}));
  connect(secOut.port_b, port_Sup)
    annotation (Line(points={{-22,-80},{180,-80}}, color={0,127,255}));
  connect(port_Out, secOut.port_a)
    annotation (Line(points={{-180,-80},{-58,-80}}, color={0,127,255}));
  connect(secOut.bus, bus) annotation (Line(
      points={{-40,-66},{-40,120},{0,120},{0,140}},
      color={255,204,51},
      thickness=0.5));
  connect(secRel.bus, bus) annotation (Line(
      points={{0,94},{0,140}},
      color={255,204,51},
      thickness=0.5));
  connect(secRel.port_bPre, port_bPre) annotation (Line(points={{8,66},{8,60},{
          80,60},{80,140}}, color={0,127,255}));
  annotation (Documentation(info="<html>
<p>
This model represents a configuration with an air economizer
and no relief air branch.
</p>
</html>"));
end EconomizerNoRelief;

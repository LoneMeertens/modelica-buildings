within Buildings.Templates.ZoneEquipment;
model VAVBoxCoolingOnly "VAV terminal unit cooling only"
  extends Buildings.Templates.ZoneEquipment.Interfaces.PartialAirTerminal(
    redeclare Buildings.Templates.ZoneEquipment.Data.VAVBox dat(
      typCoiHea=Buildings.Templates.Components.Types.Coil.None,
      typValCoiHea=Buildings.Templates.Components.Types.Valve.None,
      typDamVAV=damVAV.typ,
      have_CO2Sen=ctl.have_CO2Sen,
      typCtl=ctl.typ),
    final typ=Buildings.Templates.ZoneEquipment.Types.Configuration.VAVBox,
    final have_souChiWat=false,
    final have_souHeaWat=false,
    final mAirPri_flow_nominal=mAir_flow_nominal,
    final mChiWat_flow_nominal=0,
    final mHeaWat_flow_nominal=0,
    final QChiWat_flow_nominal=0,
    final QHeaWat_flow_nominal=0);

  inner replaceable Buildings.Templates.Components.Dampers.PressureIndependent damVAV
    constrainedby
    Buildings.Templates.Components.Dampers.Interfaces.PartialDamper(
      redeclare final package Medium = MediumAir,
      final dat=dat.damVAV)
    "VAV damper"
    annotation (Dialog(group="VAV damper"),
      choices(
      choice(redeclare replaceable Buildings.Templates.Components.Dampers.Modulating damVAV
        "Modulating damper"),
      choice(redeclare replaceable Buildings.Templates.Components.Dampers.PressureIndependent damVAV
        "Pressure independent damper")),
      Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-120,-200})));

  inner replaceable Buildings.Templates.ZoneEquipment.Components.Controls.OpenLoop ctl
    constrainedby
    Buildings.Templates.ZoneEquipment.Components.Controls.Interfaces.PartialVAVBoxController(
      final dat=dat.ctl)
    "Terminal unit controller"
    annotation (
    choices(
      choice(redeclare replaceable Buildings.Templates.ZoneEquipment.Components.Controls.OpenLoop ctl
        "Open loop control")),
    Dialog(group="Controller"),
    Placement(transformation(extent={{-10,-10},{10,10}})));

  Buildings.Templates.Components.Sensors.VolumeFlowRate VAirDis_flow(
    redeclare final package Medium = MediumAir,
    final have_sen=ctl.typ==Buildings.Templates.ZoneEquipment.Types.Controller.G36VAVBoxCoolingOnly,
    final m_flow_nominal=mAir_flow_nominal,
    final typ=Buildings.Templates.Components.Types.SensorVolumeFlowRate.FlowCross)
    "Airflow sensor"
    annotation (Placement(transformation(extent={{-200,-210},{-180,-190}})));

equation
  /* Control point connection - start */
  connect(damVAV.bus, bus.damVAV);
  connect(VAirDis_flow.y, bus.VAirDis_flow);
  /* Control point connection - end */
  connect(bus,ctl. bus) annotation (Line(
      points={{-300,0},{-10,0}},
      color={255,204,51},
      thickness=0.5));

  connect(port_Sup, VAirDis_flow.port_a)
    annotation (Line(points={{-300,-200},{-200,-200}}, color={0,127,255}));
  connect(VAirDis_flow.port_b, damVAV.port_a)
    annotation (Line(points={{-180,-200},{-130,-200}}, color={0,127,255}));
  connect(damVAV.port_b, port_Dis)
    annotation (Line(points={{-110,-200},{300,-200}}, color={0,127,255}));
  annotation (Diagram(graphics={
        Line(points={{300,-190},{-300,-190}},
                                            color={0,0,0}),
        Line(points={{300,-210},{-300,-210}},
                                            color={0,0,0})}),
  defaultComponentName="BoxCoo",
    Documentation(info="<html>
<h4>Description</h4>
<p>
This template represents a cooling-only VAV terminal unit
(or shut off box).
</p>
<p>
The possible equipment configurations are enumerated in the table below.
The user may refer to 
<a href=\"#ASHRAE2018\">ASHRAE (2018)</a>
for further details.
The first option displayed in bold characters corresponds to the default configuration.<br/>
</p>
<table summary=\"summary\" border=\"1\">
<tr><th>Component</th><th>Supported configuration</th><th>Note</th></tr>
<tr><td>VAV damper</td>
<td>
<b>Pressure independent damper</b><br/>
Modulating damper
</td>
<td></td>
</tr>
<tr><td>Controller</td>
<td>
<b>Open loop controller</b><br/>
ASHRAE Guideline 36 controller
</td>
<td></td>
</table>
<h4>References</h4>
<ul>
<li id=\"ASHRAE2018\">
ASHRAE, 2018. Guideline 36-2018, High-Performance Sequences of Operation 
for HVAC Systems. Atlanta, GA.
</li>
</ul>
</html>"));
end VAVBoxCoolingOnly;
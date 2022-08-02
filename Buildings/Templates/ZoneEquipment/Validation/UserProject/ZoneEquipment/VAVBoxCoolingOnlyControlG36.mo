within Buildings.Templates.ZoneEquipment.Validation.UserProject.ZoneEquipment;
model VAVBoxCoolingOnlyControlG36
  "Configuration of VAV terminal unit cooling only"
  extends Buildings.Templates.ZoneEquipment.VAVBoxCoolingOnly(
    redeclare replaceable
      Buildings.Templates.ZoneEquipment.Components.Controls.G36VAVBoxCoolingOnly ctl(
       stdVen=Buildings.Controls.OBC.ASHRAE.G36.Types.VentilationStandard.ASHRAE62_1_2016));

  annotation (
    defaultComponentName="ter",
    Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
This is a configuration model with the same default options as
<a href=\"modelica://Buildings.Templates.ZoneEquipment.VAVBoxReheat\">
Buildings.Templates.ZoneEquipment.VAVBoxReheat</a>
except for the following options.<br/>
</p>
<table summary=\"summary\" border=\"1\">
<tr><th>Component</th><th>Configuration</th></tr>
<tr><td>Controller</td><td>Guideline 36 controller</td></tr>
</table>
</html>"));
end VAVBoxCoolingOnlyControlG36;

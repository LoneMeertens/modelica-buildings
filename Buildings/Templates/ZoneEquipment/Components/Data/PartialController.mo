within Buildings.Templates.ZoneEquipment.Components.Data;
record PartialController "Record for controller interface class"
  extends Modelica.Icons.Record;

  parameter Buildings.Templates.ZoneEquipment.Types.Controller typ
    "Type of controller"
    annotation (Evaluate=true, Dialog(group="Configuration", enable=false));
end PartialController;
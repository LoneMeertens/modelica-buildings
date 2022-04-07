within Buildings.Templates.ChilledWaterPlant.Components.SecondaryPumps.Interfaces;
record Data "Data for secondary pumps"
  extends Modelica.Icons.Record;

  // Structure parameters

  parameter
    Buildings.Templates.ChilledWaterPlant.Components.Types.SecondaryPump typ
    "Type of secondary pumping"
    annotation (Evaluate=true, Dialog(group="Configuration", enable=false));
  parameter Integer nPum(final min=1) "Number of pumps"
    annotation (Evaluate=true, Dialog(group="Configuration", enable=false));
  final parameter Boolean is_none=
    typ ==Buildings.Templates.ChilledWaterPlant.Components.Types.SecondaryPump.None
    "= true if there is no secondary pumping";

  // Equipment parameters

  parameter Buildings.Templates.Components.Pumps.Interfaces.Data pum[nPum](
    each m_flow_nominal = m_flow_nominal / nPum)
    "Pump data"
    annotation(Dialog(group = "Pumps"));
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal
    "Pump group nominal flow rate"
    annotation(Dialog(group = "Nominal condition"));

end Data;
within Buildings.Templates.ChilledWaterPlant.Interfaces;
record Data "Data for chilled water plants"
  extends Modelica.Icons.Record;

  // Structure parameters

  parameter Buildings.Templates.ChilledWaterPlant.Components.Types.Configuration
    typ "Type of system"
    annotation (Evaluate=true, Dialog(group="Configuration", enable=false));
  final parameter Boolean isAirCoo=
    typ == Buildings.Templates.ChilledWaterPlant.Components.Types.Configuration.AirCooled
    "= true, chillers in group are air cooled, 
     = false, chillers in group are water cooled";

  // Component parameters

  // Controller

  parameter Buildings.Templates.ChilledWaterPlant.Components.Controls.Interfaces.Data con
    "Controller data"
    annotation (Dialog(group="Controller"));

  // Evaporator side equipment

  parameter Buildings.Templates.ChilledWaterPlant.Components.ChillerGroup.Interfaces.Data chiGro(
    m2_flow_nominal = mCHWPri_flow_nominal,
    m1_flow_nominal = mCon_flow_nominal)
    "Chiller group"
    annotation (Dialog(group="Equipment"));
  parameter Buildings.Templates.ChilledWaterPlant.Components.PrimaryPumpGroup.Interfaces.Data pumPri(
    m_flow_nominal = mCHWPri_flow_nominal)
    "Primary pump group"
    annotation (Dialog(group="Equipment"));
  parameter Buildings.Templates.ChilledWaterPlant.Components.ReturnSection.Interfaces.Data retSec(
    m1_flow_nominal = mCHWPri_flow_nominal,
    m2_flow_nominal = mCon_flow_nominal)
    "Waterside Economizer"
    annotation (Dialog(group="Equipment"));
  parameter Buildings.Templates.ChilledWaterPlant.Components.SecondaryPumpGroup.Interfaces.Data pumSec(
    m_flow_nominal = mCHWSec_flow_nominal)
    "Secondary pump group"
    annotation (Dialog(group="Equipment"));

  //Condenser side equipment

  parameter Buildings.Templates.ChilledWaterPlant.Components.CondenserWaterPumpGroup.Interfaces.Data pumCon(
    m_flow_nominal = mCon_flow_nominal)
    "Condenser pump group"
    annotation (Dialog(group="Equipment", enable=not isAirCoo));
  parameter Buildings.Templates.ChilledWaterPlant.Components.CoolingTowerGroup.Interfaces.Data cooTowGro(
    m_flow_nominal = mCon_flow_nominal)
    "Cooling tower group"
    annotation (Dialog(group="Equipment", enable=not isAirCoo));

  // Nominal conditions

  parameter Modelica.Units.SI.MassFlowRate mCHWPri_flow_nominal
    "Design primary chilled water mass flow rate"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.Units.SI.MassFlowRate mCHWSec_flow_nominal=
    mCHWPri_flow_nominal
    "Design secondary chilled water mass flow rate"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.Units.SI.PressureDifference dpDem_nominal
    "Differential pressure setpoint on the demand side"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal
    "Design condenser water mass flow rate"
    annotation (Dialog(group="Nominal conditions", enable=not isAirCoo));


end Data;

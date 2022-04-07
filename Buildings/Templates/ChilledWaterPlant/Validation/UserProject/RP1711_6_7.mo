within Buildings.Templates.ChilledWaterPlant.Validation.UserProject;
model RP1711_6_7
  "Parallel Chillers, Primary-secondary Chilled Water, Constant Condenser Water, Headered Pumps"
  extends Buildings.Templates.ChilledWaterPlant.WaterCooled(
    final nCooTow=2,
    redeclare
      Buildings.Templates.ChilledWaterPlant.Components.CoolingTowerSection.Parallel
      cooTowSec,
    redeclare
      Buildings.Templates.ChilledWaterPlant.Components.ChillerSection.Parallel
      chiSec(final nChi=2, redeclare
        Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_York_YT_1055kW_5_96COP_Vanes
        per),
    pumPri(final nPum=2, final have_floSen=true),
    redeclare
      Buildings.Templates.ChilledWaterPlant.Components.SecondaryPumps.Centralized
      pumSec(final nPum=2),
    pumCon(final nPum=2));
  annotation (
    defaultComponentName="chw");
end RP1711_6_7;
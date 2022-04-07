within Buildings.Templates.ChilledWaterPlant.Validation;
model RP1711_6_2
  "Parallel Chillers, Variable Primary Chilled Water, Constant Condenser Water, Dedicated Pumps"
  extends
    Buildings.Templates.ChilledWaterPlant.Validation.BaseChilledWaterPlant(
    redeclare Buildings.Templates.ChilledWaterPlant.Validation.UserProject.RP1711_6_2 chw);
  annotation (experiment(Tolerance=1e-6, StopTime=1));
end RP1711_6_2;
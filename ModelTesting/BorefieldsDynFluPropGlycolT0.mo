within ModelTesting;
model BorefieldsDynFluPropGlycolT0
  "Glycol borefield, fluid properties evaluated at 0°C"
  extends BorefieldsDynFluPropWater_All(
    redeclare package Medium =
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=273.15, X_a=0.25),
    redeclare package MediumTdep =
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=273.15, X_a=0.25)
  );
end BorefieldsDynFluPropGlycolT0;

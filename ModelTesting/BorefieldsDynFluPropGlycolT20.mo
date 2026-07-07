within ModelTesting;
model BorefieldsDynFluPropGlycolT20
  "Glycol borefield, fluid properties evaluated at 20°C"
  extends BorefieldsDynFluPropWater_All(
    redeclare package Medium =
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=293.15, X_a=0.25),
    redeclare package MediumTdep =
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=293.15, X_a=0.25)
  );
end BorefieldsDynFluPropGlycolT20;

within ModelTesting;
model BorefieldsDynFluPropGlycolTvar
  "Glycol borefield with variable property evaluation temperature"

  parameter Modelica.Units.SI.Temperature T_prop = 293.15
    "Temperature at which fluid properties are evaluated";
  
  parameter Modelica.Units.SI.Temperature X_a = 0.25
    "Glycol fraction";

  extends BorefieldsDynFluPropWater_All(
    redeclare package Medium =
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=T_prop, X_a=X_a),
    redeclare package MediumTdep =
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=T_prop, X_a=X_a)
  );

end BorefieldsDynFluPropGlycolTvar;

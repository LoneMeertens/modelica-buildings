within ModelTesting;
model BorefieldsDynFluPropGlycol
  extends BorefieldsDynFluPropWater_All(
    redeclare package Medium = 
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=293.15, X_a=0.25),
    redeclare package MediumTdep = 
      Buildings.Media.Antifreeze.PropyleneGlycolWater(
        property_T=293.15, X_a=0.25)
  );
    annotation(Icon(coordinateSystem(preserveAspectRatio = false,extent = {{-100.0,-100.0},{100.0,100.0}}),graphics = {Rectangle(lineColor={0,0,0},fillColor={230,230,230},fillPattern=FillPattern.Solid,extent={{-100.0,-100.0},{100.0,100.0}}),Text(lineColor={0,0,255},extent={{-150,150},{150,110}},textString="%name")}));
end BorefieldsDynFluPropGlycol;

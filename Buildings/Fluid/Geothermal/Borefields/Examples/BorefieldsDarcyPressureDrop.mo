within Buildings.Fluid.Geothermal.Borefields.Examples;
model BorefieldsDarcyPressureDrop
  extends Buildings.Fluid.Geothermal.Borefields.Examples.Borefields(
    borFieUTubDat(
      conDat=Buildings.Fluid.Geothermal.Borefields.Data.Configuration.Example(
        borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube,
        use_DarcyPressureDrop=true)),
    borFie2UTubParDat(
      conDat=Buildings.Fluid.Geothermal.Borefields.Data.Configuration.Example(
        borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
        use_DarcyPressureDrop=true)),
    borFie2UTubSerDat(
      conDat=Buildings.Fluid.Geothermal.Borefields.Data.Configuration.Example(
        borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeSeries,
        use_DarcyPressureDrop=true)));

  annotation (
    Documentation(info="<html>
<p>
This validation model extends
<a href=\"modelica://Buildings.Fluid.Geothermal.Borefields.Examples.Borefields\">
Buildings.Fluid.Geothermal.Borefields.Examples.Borefields</a>
and enables the Darcy-Weisbach pressure-drop calculation for all borefield
configurations.
</p>
</html>"));
end BorefieldsDarcyPressureDrop;

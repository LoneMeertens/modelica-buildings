within Buildings.Fluid.Geothermal.ZonedBorefields.BaseClasses.HeatTransfer;
impure function temporalSuperpositionExternal
  input KappaExternalObject obj;
  input Integer nTim;
  input Integer nSeg;
  input Real QAgg_flow[nSeg, nTim];
  input Integer curCel;
  output Real deltaTb[nSeg];

  external "C" kappaTemporalSuperposition(
    obj,
    nTim,
    nSeg,
    QAgg_flow,
    curCel,
    deltaTb)
    annotation(
      Include="#include \"kappaExternal.c\"",
      IncludeDirectory="modelica://Buildings/Resources/C-Sources");
end temporalSuperpositionExternal;

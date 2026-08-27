within Buildings.Fluid.Geothermal.ZonedBorefields.BaseClasses.HeatTransfer;
impure function kappaGetDiag1
  input KappaExternalObject obj;
  input Integer nSeg;
  output Real diag[nSeg];

  external "C" kappaGetDiag1(obj, nSeg, diag)
    annotation(
      Include="#include \"kappaExternal.c\"",
      IncludeDirectory="modelica://Buildings/Resources/C-Sources");
end kappaGetDiag1;

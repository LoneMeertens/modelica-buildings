within Buildings.Fluid.Geothermal.ZonedBorefields.BaseClasses.HeatTransfer;
class KappaExternalObject
  extends ExternalObject;

  function constructor
    input String fileName;
    input String matrixName;
    input Integer nSeg;
    input Integer nTim;
    output KappaExternalObject obj;

    external "C" obj = kappaConstructor(fileName, matrixName, nSeg, nTim)
      annotation(
        Include="#include \"kappaExternal.c\"",
        IncludeDirectory="modelica://Buildings/Resources/C-Sources");
  end constructor;

  function destructor
    input KappaExternalObject obj;

    external "C" kappaDestructor(obj)
      annotation(
        Include="#include \"kappaExternal.c\"",
        IncludeDirectory="modelica://Buildings/Resources/C-Sources");
  end destructor;

end KappaExternalObject;

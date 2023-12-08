within Buildings.Fluid.CHPs.OrganicRankine.Data.WorkingFluids;
record Toluene "Data record for toluene"
  extends Generic(
    T = {263.15,298.55,333.95,369.35,404.75,440.15,475.55,510.95,546.35,581.75},
    p = {4.65864538e+02,3.87850648e+03,1.91362008e+04,6.60727857e+04,
 1.77524088e+05,3.98214951e+05,7.82603177e+05,1.39451161e+06,
 2.31200882e+06,3.64728491e+06},
    dTSup = 50,
    sSatLiq = {-670.30058442,-462.34577856,-265.1734743 , -75.48608998, 108.73531773,
  288.91801129, 466.37022759, 642.81477669, 821.68499165,1017.47520872},
    sSatVap = { 978.30668321, 919.72231032, 907.69097928, 926.22965602, 964.68206703,
 1015.53036411,1072.87087895,1130.92109843,1181.09576699,1195.35219203},
    sSupVap = {1167.05704983,1109.64433437,1098.84436277,1118.64504391,1158.50830869,
 1211.2259082 ,1271.60163513,1335.56739206,1399.57754811,1460.28162689},
    hSatLiq = {-215928.29965858,-157558.83018377, -95210.96381295, -28467.95930608,
   42965.24683865, 119373.48036518, 201168.19155306, 289147.81263614,
  385288.93728589, 498520.55792195},
    hSatVap = {217902.70281866,255057.59775247,296467.12046034,341515.75148201,
 389409.69362011,439191.9074596 ,489589.57630811,538545.73773166,
 581653.01438984,602000.49296323},
    hSupVap = {272296.09476717,316509.17875328,365077.95522047,417382.96628455,
 472684.81167829,530185.35464011,589011.0156014 ,648135.47144068,
 706284.68769947,761949.49312292});
  annotation (
  defaultComponentPrefixes = "parameter",
  defaultComponentName = "pro",
  Documentation(info="<html>
<p>
Record containing properties of toluene.
Its name in CoolProp is \"Toluene\".
A figure in the documentation of
<a href=\"Modelica://Buildings.Fluid.CHPs.OrganicRankine.BottomingCycle\">
Buildings.Fluid.CHPs.OrganicRankine.BottomingCycle</a>
shows which lines these arrays represent.
</p>
</html>"));
end Toluene;
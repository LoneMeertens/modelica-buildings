within Buildings.Templates.AirHandlersFans.Validation;
model VAVMZNoRelief "Validation model for multiple-zone VAV"
  extends VAVMZNoEconomizer(
    datAll(redeclare model VAV =
      UserProject.AirHandlersFans.VAVMZNoRelief),
    redeclare UserProject.AirHandlersFans.VAVMZNoRelief
      VAV_1);

  annotation (
  experiment(Tolerance=1e-6, StopTime=1), Documentation(info="<html>
<p>
This is a validation model for the configuration represented by
<a href=\"modelica://Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZNoRelief\">
Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZNoRelief</a>
</p>
</html>"));
end VAVMZNoRelief;

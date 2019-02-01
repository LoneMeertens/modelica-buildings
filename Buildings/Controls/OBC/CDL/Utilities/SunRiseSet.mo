within Buildings.Controls.OBC.CDL.Utilities;
block SunRiseSet "Next sunrise and sunset time"
  parameter Modelica.SIunits.Angle lat(displayUnit="deg") "Latitude";
  parameter Modelica.SIunits.Angle lon(displayUnit="deg") "Longitude";
  parameter Modelica.SIunits.Time timZon(displayUnit="h") "Time zone";
  parameter Modelica.SIunits.Time startTime(displayUnit="h") "Simulation start time";

  Modelica.SIunits.Time timCor "Time correction factor";
  Modelica.SIunits.Time eqnTim "Equation of time";
  Modelica.SIunits.Time timDif "Time difference between local and civil time";
  Modelica.SIunits.Time solTim "Solar time";
  Modelica.SIunits.Angle decAng "Declination angle";
  Modelica.SIunits.Angle houAng "Hour angle";
  Modelica.SIunits.Angle altAng "Altitude angle";

  Interfaces.RealOutput nextSunRise(
    final quantity="Time",
    final unit="s",
    displayUnit="h") "Time of next sunrise"
    annotation (Placement(transformation(extent={{100,50},{120,70}}),
                    iconTransformation(extent={{100,50},{120,70}})));
  Interfaces.RealOutput nextSunSet(
    final quantity="Time",
    final unit="s",
    displayUnit="h") "Time of next sunset"
    annotation (Placement(transformation(extent={{100,-10},{120,10}}),
                    iconTransformation(extent={{100,-10},{120,10}})));
  Interfaces.BooleanOutput sunUp "Output true if the sun is up"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}}),
                    iconTransformation(extent={{100,-70},{120,-50}})));

protected
  constant Real k1 = sin(23.45*2*Modelica.Constants.pi/360) "Intermediate constant";
  constant Real k2 = 2*Modelica.Constants.pi/365.25 "Intermediate constant";
  Real Bt "Intermediate variable to calculate equation of time";

  function nextHouAng "Calculate the hour angle when the sun rises or sets next time"
    input Modelica.SIunits.Time t "Current simulation time";
    input Modelica.SIunits.Angle lat;
    output Modelica.SIunits.Angle houAng "Solar hour angle";
    output Modelica.SIunits.Time timCor "Time correction factor";
    output Modelica.SIunits.Time tNext "Timesnap when sun rises or sets next time";
  protected
    Integer iDay;
    Boolean compute "Flag, set to false when the sun rise or sets ";
    Real Bt "Intermediate variable to calculate equation of time";
    Modelica.SIunits.Time eqnTim "Equation of time";
    Modelica.SIunits.Time timDif "Time difference between local and civil time";
    Modelica.SIunits.Angle decAng "Declination angle";
    Real cosHou "Cosine of hour angle";
  algorithm
    iDay := 1;
    compute := true;
    while compute loop
      tNext := t+iDay*86400;
      Bt := Modelica.Constants.pi*((tNext + 86400)/86400 - 81)/182;
      decAng := Modelica.Math.asin(-k1*Modelica.Math.cos((tNext/86400 + 10)*k2));
      cosHou := -Modelica.Math.tan(lat)*Modelica.Math.tan(decAng);
      compute := abs(cosHou) > 1;
      iDay := iDay + 1;
    end while;
    houAng := Modelica.Math.acos(cosHou);
  end nextHouAng;

  function sunRise "Output the next sunrise time"
    input Modelica.SIunits.Time t "Current simulation time";
    input Modelica.SIunits.Time startTime;
    input Modelica.SIunits.Angle lat;
    output Modelica.SIunits.Time nextSunRise;
  protected
    Modelica.SIunits.Angle houAng "Solar hour angle";
    Modelica.SIunits.Time tNext "Timesnap when sun rises next time";
    Modelica.SIunits.Time timCor "Time correction factor";
    Modelica.SIunits.Time sunRise "Sunrise of the same day as input time";
  algorithm
    (houAng,timCor,tNext) := nextHouAng(t,lat);
    sunRise :=(12 - houAng*24/(2*Modelica.Constants.pi) - timCor/3600)*3600 +
               floor(tNext/24/3600)*24*3600;
    if startTime > sunRise then
      nextSunRise := sunRise + 86400;
    else
      nextSunRise := sunRise;
    end if;
  end sunRise;

  function sunSet "Output the next sunset time"
    input Modelica.SIunits.Time t "Current simulation time";
    input Modelica.SIunits.Time startTime;
    input Modelica.SIunits.Angle lat;
    output Modelica.SIunits.Time nextSunSet;
  protected
    Modelica.SIunits.Angle houAng "Solar hour angle";
    Modelica.SIunits.Time tNext "Timesnap when sun sets next time";
    Modelica.SIunits.Time timCor "Time correction factor";
    Modelica.SIunits.Time sunSet "Sunset of the same day as input time";
  algorithm
    (houAng,timCor,tNext) := nextHouAng(t,lat);
    sunSet :=(12 + houAng*24/(2*Modelica.Constants.pi) - timCor/3600)*3600 +
              floor(tNext/24/3600)*24*3600;
    if startTime > sunSet then
      nextSunSet := sunSet + 86400;
    else
      nextSunSet := sunSet;
    end if;
  end sunSet;

initial equation
  nextSunRise = sunRise(time-86400,startTime,lat);
  nextSunSet = sunSet(time-86400,startTime,lat);

equation
  Bt = Modelica.Constants.pi*((time + 86400)/86400 - 81)/182;
  eqnTim = 60*(9.87*Modelica.Math.sin(2*Bt) - 7.53*Modelica.Math.cos(Bt) - 1.5*
    Modelica.Math.sin(Bt));
  timDif = lon*43200/Modelica.Constants.pi - timZon;
  timCor = timDif + eqnTim;
  solTim = time + timCor;
  decAng = Modelica.Math.asin(-k1*Modelica.Math.cos((time/86400 + 10)*k2));
  houAng = (solTim/3600 - 12)*2*Modelica.Constants.pi/24;
  altAng = Modelica.Math.asin(Modelica.Math.cos(lat)*Modelica.Math.cos(decAng)*
    Modelica.Math.cos(houAng) + Modelica.Math.sin(lat)*Modelica.Math.sin(
    decAng));

  //When time passes the current sunrise/sunset, output the next sunrise/sunset
  when time >= pre(nextSunRise) then
    nextSunRise = sunRise(time,startTime,lat);
  end when;

  when time >= pre(nextSunSet) then
    nextSunSet = sunSet(time,startTime,lat);
  end when;

  if altAng >=0 then
    sunUp = true;
  else
    sunUp = false;
  end if;

  annotation (defaultComponentName="sunRiseSet",
  Documentation(info="<html>
<p>This block outputs the next sunrise and sunset time. The hours are output like step functions.
The sunrise time keeps constant until the model time reaches the current sunrise;
when the model time passes the current sunrise, the sunrise hour gets updated with the next sunrise.
Sunset output works in the same way as sunrise. </p>
<p>The time zone parameter is based on UTC time; for instance, Eastern Standard Time is -5h.
Note that daylight savings time is not considered in this component. </p>
<h4>Validation </h4>
<p>A validation can be found at
<a href=\"modelica://Buildings.Controls.OBC.CDL.Utilities.Validation.SunRiseSet\">
Buildings.Controls.OBC.CDL.Utilities.Validation.SunRiseSet</a>. </p>
</html>",
revisions="<html>
<ul>
<li>
November 27, 2018, by Kun Zhang:<br/>
First implementation.
This is for
issue <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/829\">829</a>.
</li>
</ul>
</html>"),
Icon(graphics={  Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
          Text(
            extent={{-100,160},{100,106}},
            lineColor={0,0,255},
            textString="%name"),
          Ellipse(
            extent={{70,-100},{-70,20}},
            lineColor={238,46,47},
            startAngle=0,
            endAngle=180),
          Line(
            points={{-94,-40},{92,-40},{92,-40}},
            color={28,108,200},
            thickness=0.5),
          Line(points={{0,60},{0,32}}, color={238,46,47}),
          Line(points={{60,40},{40,20}}, color={238,46,47}),
          Line(points={{94,-6},{70,-6}}, color={238,46,47}),
          Line(
            points={{10,10},{-10,-10}},
            color={238,46,47},
            origin={-50,30},
            rotation=90),
          Line(points={{-70,-6},{-94,-6}}, color={238,46,47})}));
end SunRiseSet;

within Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses;
model InternalHEXOneUTubeTdep
  "Internal heat exchanger of a borehole for a single U-tube configuration"
  extends
    Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.PartialInternalHEX;
  extends Buildings.Fluid.Interfaces.FourPortHeatMassExchanger(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    T1_start=TFlu_start,
    T2_start=TFlu_start,
    final tau1=VTubSeg*rho1_nominal/m1_flow_nominal,
    final tau2=VTubSeg*rho2_nominal/m2_flow_nominal,
    redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol1(
      final energyDynamics=energyDynamics,
      final massDynamics=energyDynamics,
      final prescribedHeatFlowRate=false,
      final m_flow_small=m1_flow_small,
      final V=VTubSeg,
      final mSenFac=mSenFac),
    redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol2(
      final energyDynamics=energyDynamics,
      final massDynamics=energyDynamics,
      final prescribedHeatFlowRate=false,
      final m_flow_small=m2_flow_small,
      final V=VTubSeg,
      final mSenFac=mSenFac));

protected
  parameter Real Rgg_val(fixed=false) "Thermal resistance between the two grout zones";
  parameter Modelica.Units.SI.Time tauFlow = 120
  "Time constant for filtered flow used in thermal correlations";
  Modelica.Units.SI.MassFlowRate m1_flow_dum(start=m1_flow_nominal, fixed=true)
  "Filtered mass flow for thermal calculations, side 1";
  Modelica.Units.SI.MassFlowRate m2_flow_dum(start=m2_flow_nominal, fixed=true)
  "Filtered mass flow for thermal calculations, side 2";
  parameter Real Rb_multipole_val(fixed=false, unit="(m.K)/W")
    "Borehole thermal resistance from multipole method";

public
  parameter Boolean useGlycol = false 
  "Set true if medium is PropyleneGlycolWater";
  parameter Real X_a = 0.25 
  "Glycol mass fraction (used only if useGlycol=true)";

  // ── Media property outputs from convection resistance function ──
  Real cp1(unit="J/(kg.K)") "Specific heat capacity inlet pipe";
  Real k1(unit="W/(m.K)")   "Thermal conductivity inlet pipe";
  Real mu1(unit="Pa.s")     "Dynamic viscosity inlet pipe";
  Real rho1(unit="kg/m3")   "Density inlet pipe";
  Real Pr1                   "Prandtl number inlet pipe";

  Real cp2(unit="J/(kg.K)") "Specific heat capacity outlet pipe";
  Real k2(unit="W/(m.K)")   "Thermal conductivity outlet pipe";
  Real mu2(unit="Pa.s")     "Dynamic viscosity outlet pipe";
  Real rho2(unit="kg/m3")   "Density outlet pipe";
  Real Pr2                   "Prandtl number outlet pipe";

  Real RVol1_val(unit="K/W") "Convective resistance (fluid 1) computed at runtime";
  output Real Nu1(unit="") "Nusselt (fluid 1)";
  output Modelica.Units.SI.CoefficientOfHeatTransfer h1 "Convective heat transfer coeff (fluid 1)";
  output Real Re1(unit="") "Reynolds number (fluid 1)";
  output Real NuTurb1(unit="") "Nusselt at Re=2400 (fluid 1)";

  Real RVol2_val(unit="K/W") "Convective resistance (fluid 2) computed at runtime";
  output Real Nu2(unit="") "Nusselt (fluid 2)";
  output Modelica.Units.SI.CoefficientOfHeatTransfer h2 "Convective heat transfer coeff (fluid 2)";
  output Real Re2(unit="") "Reynolds number (fluid 2)";
  output Real NuTurb2(unit="") "Nusselt at Re=2400 (fluid 2)";

  output Real Rb(unit="(m.K)/W") = Rb_multipole_val
    "Borehole thermal resistance [K/W]";

  Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.InternalResistancesOneUTube
    intResUTub(
      hSeg=hSeg,
      energyDynamics=energyDynamics,
      Rgb_val=Rgb_val,
      Rgg_val=Rgg_val,
      RCondGro_val=RCondGro_val,
      borFieDat=borFieDat,
      T_start=TGro_start)
    "Internal resistances for a single U-tube configuration"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Thermal.HeatTransfer.Components.ConvectiveResistor RConv2
    "Pipe convective resistance"
    annotation (Placement(transformation(extent={{-12,12},{12,-12}},
        rotation=270,
        origin={0,-28})));
  Modelica.Thermal.HeatTransfer.Components.ConvectiveResistor RConv1
    "Pipe convective resistance"
    annotation (Placement(transformation(extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,28})));
  Modelica.Blocks.Sources.RealExpression RVol1(y=RVol1_val)
    "Convective and thermal resistance at fluid 1"
    annotation (Placement(transformation(extent={{-96,-2},{-76,18}})));
  Modelica.Blocks.Sources.RealExpression RVol2(y=RVol2_val)
    "Convective and thermal resistance at fluid 1"
    annotation (Placement(transformation(extent={{-96,-18},{-76,2}})));

initial equation
  (x, Rgb_val, Rgg_val, RCondGro_val, Rb_multipole_val) =
    Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.internalResistancesOneUTube(
      hSeg=hSeg,
      rBor=borFieDat.conDat.rBor,
      rTub=borFieDat.conDat.rTub,
      eTub=borFieDat.conDat.eTub,
      sha=borFieDat.conDat.xC,
      kFil=borFieDat.filDat.kFil,
      kSoi=borFieDat.soiDat.kSoi,
      kTub=borFieDat.conDat.kTub,
      use_Rb=borFieDat.conDat.use_Rb,
      Rb=borFieDat.conDat.Rb,
      kMed=kMed,
      muMed=muMed,
      cpMed=cpMed,
      m_flow_nominal=m1_flow_nominal,
      instanceName=getInstanceName());

equation
  // Dummy flow dynamics to reduce coupling
  tauFlow*der(m1_flow_dum) = m1_flow - m1_flow_dum;
  tauFlow*der(m2_flow_dum) = m2_flow - m2_flow_dum;

  // Medium properties at current fluid temperature — pipe 1
  cp1  = Medium.specificHeatCapacityCp(Medium.setState_pTX(Medium.p_default, vol1.T, Medium.X_default));
  k1   = Medium.thermalConductivity(   Medium.setState_pTX(Medium.p_default, vol1.T, Medium.X_default));
  mu1  = Medium.dynamicViscosity(      Medium.setState_pTX(Medium.p_default, vol1.T, Medium.X_default));
  rho1 = Medium.density(               Medium.setState_pTX(Medium.p_default, vol1.T, Medium.X_default));

  // Medium properties at current fluid temperature — pipe 2
  cp2  = Medium.specificHeatCapacityCp(Medium.setState_pTX(Medium.p_default, vol2.T, Medium.X_default));
  k2   = Medium.thermalConductivity(   Medium.setState_pTX(Medium.p_default, vol2.T, Medium.X_default));
  mu2  = Medium.dynamicViscosity(      Medium.setState_pTX(Medium.p_default, vol2.T, Medium.X_default));
  rho2 = Medium.density(               Medium.setState_pTX(Medium.p_default, vol2.T, Medium.X_default));


  // Pipe 1 — evaluate medium at vol1.T, pass properties explicitly
  (RVol1_val, Nu1, h1, Re1, NuTurb1, Pr1) =
    Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions
    .convectionResistanceCircularPipeTdep(
        hSeg           = hSeg,
        rTub           = borFieDat.conDat.rTub,
        eTub           = borFieDat.conDat.eTub,
        T              = vol1.T,
        p              = Medium.p_default,
        m_flow         = m1_flow_dum, 
        m_flow_nominal = m1_flow_nominal,
        useGlycol      = useGlycol, 
        X_a            = X_a);

  (RVol2_val, Nu2, h2, Re2, NuTurb2, Pr2) =
    Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions
    .convectionResistanceCircularPipeTdep(
        hSeg           = hSeg,
        rTub           = borFieDat.conDat.rTub,
        eTub           = borFieDat.conDat.eTub,
        T              = vol1.T,
        p              = Medium.p_default,
        m_flow         = m1_flow_dum, 
        m_flow_nominal = m1_flow_nominal,
        useGlycol      = useGlycol, 
        X_a            = X_a);

    assert(borFieDat.conDat.borCon == Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.SingleUTube,
  "This model should be used for single U-type borefield, not double U-type.
  Check that the conDat record has been correctly parametrized");
  connect(vol1.heatPort, RConv1.fluid) annotation (Line(points={{-10,60},{-20,
          60},{-20,40},{6.66134e-016,40}}, color={191,0,0}));
  connect(RConv1.solid, intResUTub.port_1)
    annotation (Line(points={{0,16},{0,16},{0,10}}, color={191,0,0}));
  connect(RConv2.fluid, vol2.heatPort) annotation (Line(points={{0,-40},{20,-40},
          {20,-60},{12,-60}}, color={191,0,0}));
  connect(RConv2.solid, intResUTub.port_2) annotation (Line(points={{0,-16},{0,
          -12},{16,-12},{16,0},{10,0}}, color={191,0,0}));
  connect(intResUTub.port_wall, port_wall) annotation (Line(points={{0,0},{0,0},
          {0,6},{-28,6},{-28,86},{0,86},{0,100}},             color={191,0,0}));
  connect(RVol1.y, RConv1.Rc) annotation (Line(points={{-75,8},{-20,8},{-20,28},
          {-12,28}}, color={0,0,127}));
  connect(RVol2.y, RConv2.Rc) annotation (Line(points={{-75,-8},{-20,-8},{-20,-28},
          {-12,-28}}, color={0,0,127}));
    annotation (Dialog(tab="Dynamics"),
    Icon(coordinateSystem(preserveAspectRatio=false, initialScale=0.1),
                    graphics={Rectangle(
          extent={{88,54},{-88,64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid), Rectangle(
          extent={{88,-66},{-88,-56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid)}),
    Documentation(info="<html>
<p>
Model for the heat transfer between the fluid and within the borehole filling
for a single borehole segment.
This model computes the dynamic response of the fluid in the tubes,
the heat transfer between the fluid and the borehole filling,
and the heat storage within the fluid and the borehole filling.
</p>
<p>
This model computes the different thermal resistances present
in a single-U-tube borehole using the method of Bauer et al. (2011)
and computing explicitely the fluid-to-ground thermal resistance
<i>R<sub>b</sub></i> and the
grout-to-grout resistance
<i>R<sub>a</sub></i> as defined by Claesson and Hellstrom (2011)
using the multipole method.
</p>
<h4>References</h4>
<p>J. Claesson and G. Hellstrom.
<i>Multipole method to calculate borehole thermal resistances in a borehole heat exchanger.
</i>
HVAC&amp;R Research,
17(6): 895-911, 2011.</p>
<p>
D. Bauer, W. Heidemann, H. M&uuml;ller-Steinhagen, and H.-J. G. Diersch.
<i>
Thermal resistance and capacity models for borehole heat exchangers
</i>.
International Journal Of Energy Research, 35:312-320, 2011.
</p>
</html>", revisions="<html>
<ul>
<li>
May 17, 2024, by Michael Wetter:<br/>
Updated model due to removal of parameter <code>dynFil</code>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1885\">IBPSA, #1885</a>.
</li>
<li>
November 22, 2023, by Michael Wetter:<br/>
Corrected use of <code>getInstanceName()</code> which was called inside a function which
is not allowed.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1814\">IBPSA, #1814</a>.
</li>
<li>
March 7, 2022, by Michael Wetter:<br/>
Removed <code>massDynamics</code>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1542\">#1542</a>.
</li>
<li>
February 28, 2022, by Massimo Cimmino:<br/>
Removed <code>printDebug</code> parameter from call to
<a href=\"modelica://Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.internalResistancesOneUTube\">
Buildings.Fluid.Geothermal.Borefields.BaseClasses.Boreholes.BaseClasses.Functions.internalResistancesOneUTube</a>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1582\">IBPSA, #1582</a>.
</li>
<li>
July 10, 2018, by Alex Laferri&egrave;re:<br/>
Updated documentation following major changes to the Buildings.Fluid.HeatExchangers.Ground package.
Additionally, implemented a partial InternalHex model.
</li>
<li>
June 18, 2014, by Michael Wetter:<br/>
Added initialization for temperatures and derivatives of <code>capFil1</code>
and <code>capFil2</code> to avoid a warning during translation.
</li>
<li>
February 14, 2014, by Michael Wetter:<br/>
Removed unused parameters <code>B0</code> and <code>B1</code>.
</li>
<li>
January 24, 2014, by Michael Wetter:<br/>
Revised implementation, added comments, replaced
<code>HeatTransfer.Windows.BaseClasses.ThermalConductor</code>
with resistance models from the Modelica Standard Library.
</li>
<li>
January 23, 2014, by Damien Picard:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, initialScale=0.1)));
end InternalHEXOneUTubeTdep;

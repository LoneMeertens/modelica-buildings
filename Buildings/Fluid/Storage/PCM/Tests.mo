within Buildings.Fluid.Storage.PCM;
package Tests "Examples that test PCM HX models"
  extends Modelica.Icons.ExamplesPackage;

model test_formula

    replaceable parameter Buildings.Fluid.Storage.PCM.Data.HeatExchanger.Q3 Design "Design of HX";
  replaceable parameter Buildings.Fluid.Storage.PCM.Data.PhaseChangeMaterial.PCM58 Material "Phase Change Material";
  parameter Modelica.Units.SI.Temperature TStart_pcm "Starting temperature of pcm" annotation(Dialog(tab="General", group="Initialization"));
replaceable package Medium=Buildings.Media.Water "Water medium";
  replaceable parameter
    Buildings.HeatTransfer.Data.SolidsPCM.Generic PCM(x=sfin, d=Material.d, c=Material.c, k=Material.k, LHea=Material.LHea, TSol=Material.TSol, TLiq=Material.TLiq) "Storage material record";
  parameter Modelica.Units.SI.Energy TesNominal = PCM.LHea*PCM.d*PCM.x*A_pcm "Nominal Capacity (factor * 1kWh)" annotation(Dialog(group="Sizing"));
  parameter Modelica.Units.SI.DimensionlessRatio TesScale = Design.TesDesign/TesNominal "Scale factor for PCM HX size" annotation(Dialog(group="Sizing"));
  parameter Modelica.Units.SI.Length H = TesScale*Design.coeff_H "Height of finned tube heat exchanger"
                                                                                                       annotation(Dialog(group="Heat Exchanger"));

  parameter Integer Ntubes = Design.Ntubebanks*Design.Ntubes_bank "Number of tubes in heat exchanger"
                                                                                                     annotation(Dialog(group="Tubes"));
  parameter Integer NPro = integer(Ntubes*Design.NPro_coeff) "Number of process water tubes in heat exchanger"
                                                                                                              annotation(Dialog(group="Tubes"));
  parameter Integer NDom = integer(Ntubes*Design.NDom_coeff) "Number of domestic water tubes in heat exchanger"
                                                                                                               annotation(Dialog(group="Tubes"));
  parameter Modelica.Units.SI.Area A_tubeDom = Design.di*Modelica.Constants.pi*NDom*Design.D "Area of tubes in domestic circuit"
                                                                                                                                annotation(Dialog(group="Tubes"));
  parameter Modelica.Units.SI.Area A_tubePro = Design.di*Modelica.Constants.pi*NPro*Design.D "Area of tubes in process circuit"
                                                                                                                               annotation(Dialog(group="Tubes"));

  parameter Integer Nfins = integer(Design.Nfins_meter*Design.D) "Number of fins in heat exchanger"
                                                                                                   annotation(Dialog(group="Fins"));
  parameter Modelica.Units.SI.Length tfins = Design.t_fin*Nfins "Total thickness of all fins"
                                                                                             annotation(Dialog(group="Fins"));
  parameter Modelica.Units.SI.Length sfin = 1/Design.Nfins_meter - Design.t_fin "Spacing between fins"
                                                                                                      annotation(Dialog(group="Fins"));
  parameter Modelica.Units.SI.Length xfin = ((H*Design.W)/(Design.di*Modelica.Constants.pi*Ntubes)) "Fin heat transfer area per unit length"
                                                                                                                                            annotation(Dialog(group="Fins"));
  parameter Modelica.Units.SI.Area A_fin = Design.do*Modelica.Constants.pi*Ntubes*tfins "Area of fins"
                                                                                                      annotation(Dialog(group="Fins"));

  parameter Modelica.Units.SI.Area A_pcm=(Nfins*2*Design.W*H - Modelica.Constants.pi*(Design.do/2)^2*Ntubes) + Design.do*Modelica.Constants.pi*Ntubes*(Design.D-tfins) "Area of pcm"
                                                                                                                                                                                    annotation(Dialog(group="PCM"));

parameter Real cp=4184 "Constant specific heat capacity at constant pressure";
parameter Real eta=1.e-3 "Constant dynamic viscosity";
parameter Real lambda=0.598 "Constant thermal conductivity";
parameter Real Pr = eta * cp / lambda;
parameter Real m_flow = 0.1;

  //////////////////////////////////////////////////////////////////////////////

  replaceable parameter Modelica.Fluid.Dissipation.HeatTransfer.General.kc_approxForcedConvection_IN_con turb(target=Modelica.Fluid.Dissipation.Utilities.Types.kc_general.Rough, A_cross = Modelica.Constants.pi*Design.di^2/4, perimeter = Modelica.Constants.pi*Design.di, exp_Pr =0.4);
  replaceable parameter Modelica.Fluid.Dissipation.HeatTransfer.StraightPipe.kc_laminar_IN_con lam(d_hyd = Modelica.Constants.pi*Design.di^2/4, L = NPro*Design.D);
  Modelica.Fluid.Dissipation.HeatTransfer.General.kc_approxForcedConvection_IN_var var(cp=Medium.cp_const, lambda=Medium.lambda_const, eta=Medium.eta_const, rho=Medium.d_const, eta_wall=0.001, m_flow=m_flow);

  Real f_ini=((0.023*((4*abs(
        m_flow))/(Modelica.Constants.pi*Design.di*eta))^(4/5)*Pr^0.4)*
        lambda/(Design.di))*(A_tubePro);
  Real f_formula = Modelica.Fluid.Dissipation.HeatTransfer.General.kc_approxForcedConvection_KC(turb, var) * A_tubePro;
  Real f_complete = Buildings.Fluid.Storage.PCM.BaseClasses.kc_overall_forced_KC(turb, lam, var) * A_tubePro;




  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end test_formula;

  model t_ini
    MixingVolumes.BaseClasses.MixingVolumeHeatPort vol(T_start=325.15)
      annotation (Placement(transformation(extent={{-128,34},{-108,54}})));
    MixingVolumes.MixingVolume vol1(T_start=325.15)
      annotation (Placement(transformation(extent={{-86,24},{-66,44}})));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end t_ini;
end Tests;

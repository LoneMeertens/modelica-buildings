within Buildings.Templates.HeatingPlants.HotWater.Validation.UserProject.Data;
class AllSystems
  "Design and operating parameters for testing purposes"
  extends Buildings.Templates.Data.AllSystems;

  // The following instance name matches the system tag.
  outer Buildings.Templates.HeatingPlants.HotWater.BoilerPlant BOI;

  parameter Buildings.Templates.HeatingPlants.HotWater.Data.BoilerPlant _BOI(
    final have_boiCon=BOI.have_boiCon,
    final have_boiNon=BOI.have_boiNon,
    final nBoiCon=BOI.nBoiCon,
    final nBoiNon=BOI.nBoiNon,
    final typPumHeaWatSec=BOI.typPumHeaWatSec,
    final nPumHeaWatPriCon=BOI.nPumHeaWatPriCon,
    final nPumHeaWatPriNon=BOI.nPumHeaWatPriNon,
    final nPumHeaWatSec=BOI.nPumHeaWatSec,
    final have_valHeaWatMinByp=BOI.have_valHeaWatMinByp,
    final have_senDpHeaWatLoc=BOI.ctl.have_senDpHeaWatLoc,
    final nSenDpHeaWatRem=BOI.ctl.nSenDpHeaWatRem,
    final have_senVHeaWatSec=BOI.ctl.have_senVHeaWatSec,
    final typArrPumHeaWatPriCon=BOI.typArrPumHeaWatPriCon,
    final typArrPumHeaWatPriNon=BOI.typArrPumHeaWatPriNon,
    final have_varPumHeaWatPri=BOI.have_varPumHeaWatPri,
    final typCtl=BOI.typCtl,
    final rho_default=BOI.rho_default,
    boiCon(
      dpHeaWatBoi_nominal=fill(Buildings.Templates.Data.Defaults.dpHeaWatBoi, BOI.nBoiCon),
      mHeaWatBoi_flow_nominal=_BOI.ctl.capBoiCon_nominal /
        Buildings.Utilities.Psychrometrics.Constants.cpWatLiq ./
        (_BOI.ctl.THeaWatConSup_nominal - Buildings.Templates.Data.Defaults.THeaWatRet)),
    boiNon(
      dpHeaWatBoi_nominal=fill(Buildings.Templates.Data.Defaults.dpHeaWatBoi, BOI.nBoiNon),
      mHeaWatBoi_flow_nominal=_BOI.ctl.capBoiNon_nominal /
        Buildings.Utilities.Psychrometrics.Constants.cpWatLiq ./
        (_BOI.ctl.THeaWatSup_nominal - Buildings.Templates.Data.Defaults.THeaWatRet)),
    ctl(
      THeaWatSup_nominal=Buildings.Templates.Data.Defaults.THeaWatSup,
      THeaWatConSup_nominal=Buildings.Templates.Data.Defaults.THeaWatConSup,
      TOutLoc=Buildings.Templates.Data.Defaults.THeaWatSup,
      VHeaWatBoiCon_flow_nominal=_BOI.boiCon.mHeaWatBoi_flow_nominal /
        _BOI.rho_default,
      VHeaWatBoiCon_flow_min=0.1 * _BOI.ctl.VHeaWatBoiCon_flow_nominal,
      VHeaWatBoiNon_flow_nominal=_BOI.boiNon.mHeaWatBoi_flow_nominal /
        _BOI.rho_default,
      VHeaWatBoiNon_flow_min=0.1 * _BOI.ctl.VHeaWatBoiNon_flow_nominal,
      capBoiCon_nominal=fill(1E6, BOI.nBoiCon),
      capBoiNon_nominal=fill(1E6, BOI.nBoiNon),
      VHeaWatPriCon_flow_nominal=sum(_BOI.ctl.VHeaWatBoiCon_flow_nominal),
      VHeaWatPriNon_flow_nominal=sum(_BOI.ctl.VHeaWatBoiNon_flow_nominal),
      dpHeaWatLocSet_nominal=Buildings.Templates.Data.Defaults.dpHeaWatLocSet_max,
      yPumHeaWatPri_min=0.1,
      yPumHeaWatSec_min=0.1),
    pumHeaWatPriCon(
      dp_nominal=fill(max(_BOI.boiCon.dpHeaWatBoi_nominal) * 1.5, BOI.nPumHeaWatPriCon) +
       fill((if _BOI.typPumHeaWatSec==Buildings.Templates.HeatingPlants.HotWater.Types.PumpsSecondary.None then
       _BOI.ctl.dpHeaWatLocSet_nominal else 0), BOI.nPumHeaWatPriCon)),
    pumHeaWatPriNon(
      dp_nominal=fill(max(_BOI.boiNon.dpHeaWatBoi_nominal) * 1.5, BOI.nPumHeaWatPriNon) +
       fill((if _BOI.typPumHeaWatSec==Buildings.Templates.HeatingPlants.HotWater.Types.PumpsSecondary.None then
       _BOI.ctl.dpHeaWatLocSet_nominal else 0), BOI.nPumHeaWatPriNon)),
    pumHeaWatSec(
      dp_nominal=fill(_BOI.ctl.dpHeaWatLocSet_nominal, BOI.nPumHeaWatSec),
      m_flow_nominal=1.1 / max(1, BOI.nPumHeaWatSec) *
        fill(max(sum(_BOI.pumHeaWatPriCon.m_flow_nominal), sum(_BOI.pumHeaWatPriNon.m_flow_nominal)),
        BOI.nPumHeaWatSec)))
    "HW plant parameters";
  annotation (Documentation(info="<html>
<p>
This class provides system parameters for the validation
of air-cooled chiller plant models.
</p>
</html>"));
end AllSystems;

/**
 * Based off the work from Infinity Impossible, Copyright 2007
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_UTAttachment_LinkGun_Content extends UTMT_UTAttachment_LinkGun;

defaultproperties
{
   TeamLinkBeamSystems(0)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Red'
   TeamLinkBeamSystems(1)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Blue'
   TeamLinkBeamSystems(2)=ParticleSystem'DOM_MTContent.Materials.P_WP_Linkgun_Altbeam_Green'
   TeamLinkBeamSystems(3)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Gold'
   MultiTeamBeamEndpointTemplates(0)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Red'
   MultiTeamBeamEndpointTemplates(1)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Blue'
   MultiTeamBeamEndpointTemplates(2)=ParticleSystem'DOM_MTContent.Materials.P_WP_Linkgun_Beam_Impact_Green'
   MultiTeamBeamEndpointTemplates(3)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Gold'
   MultiTeamMuzzleFlashTemplates(0)=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Red'
   MultiTeamMuzzleFlashTemplates(1)=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
   MultiTeamMuzzleFlashTemplates(2)=ParticleSystem'DOM_MTContent.Materials.P_FX_LinkGun_3P_Beam_MF_Green'
   MultiTeamMuzzleFlashTemplates(3)=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Gold'
}

/**
 * Based off the work from Infinity Impossible, Copyright 2007
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_UTWeap_LinkGun_Content extends UTMT_UTWeap_LinkGun;

defaultproperties
{
   MultiTeamMuzzleFlashTemplates(0)=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Red'
   MultiTeamMuzzleFlashTemplates(1)=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Blue'
   MultiTeamMuzzleFlashTemplates(2)=ParticleSystem'DOM_MTContent.Materials.P_FX_LinkGun_MF_Beam_Green'
   MultiTeamMuzzleFlashTemplates(3)=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Gold'
   AttachmentClass=class'UTDom.DOM_MT_UTAttachment_LinkGun_Content'
}

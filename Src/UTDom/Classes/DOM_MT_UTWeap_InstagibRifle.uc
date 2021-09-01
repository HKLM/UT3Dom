/**
 * Based off the work from Infinity Impossible, Copyright 2007
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_UTWeap_InstagibRifle extends UTWeap_InstagibRifle;

defaultproperties
{
   TeamSkins(0)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Red'
   TeamSkins(1)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Blue'
   TeamSkins(2)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Green'
   TeamSkins(3)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Gold'
   TeamMuzzleFlashes(2)=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_MF_Green'
   TeamMuzzleFlashes(3)=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_MF_Gold'
   AttachmentClass=class'UTDom.DOM_MT_UTAttachment_InstagibRifle'
}

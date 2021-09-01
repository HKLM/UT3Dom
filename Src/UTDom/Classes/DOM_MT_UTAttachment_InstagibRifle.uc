/**
 * Based off the work from Infinity Impossible, Copyright 2007
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_UTAttachment_InstagibRifle extends UTAttachment_InstagibRifle;

defaultproperties
{
   TeamImpactEffects(2)=(Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_InstagibImpactCue',DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",ParticleTemplate=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_Impact_Green')
   TeamImpactEffects(3)=(Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_InstagibImpactCue',DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",ParticleTemplate=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_Impact_Gold')
   TeamSkins(0)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Red'
   TeamSkins(1)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Blue'
   TeamSkins(2)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Green'
   TeamSkins(3)=MaterialInstanceConstant'DOM_MTContent.Materials.UTMT_M_WP_ShockRifle_Instagib_Gold'
   TeamMuzzleFlashes(2)=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_3P_MF_Green'
   TeamMuzzleFlashes(3)=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_3P_MF_Gold'
   TeamBeams(2)=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_Beam_Green'
   TeamBeams(3)=ParticleSystem'DOM_MTContent.Materials.P_Shockrifle_Instagib_Beam_Gold'
}

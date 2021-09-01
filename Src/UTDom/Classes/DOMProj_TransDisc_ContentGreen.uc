/**
 * Translocator with 4 team support
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMProj_TransDisc_ContentGreen extends UTProj_TransDisc;

DefaultProperties
{
   ProjFlightTemplate=ParticleSystem'DOM_Content.Particles.P_WP_Translocator_Trail_Green'
   BounceTemplate=ParticleSystem'DOM_Content.Particles.P_WP_Translocator_BounceEffect_Green'

   Begin Object name=ProjectileMesh
      StaticMesh=StaticMesh'WP_Translocator.Mesh.S_Translocator_Disk'
      Materials(0)=MaterialInterface'DOM_Content.Materials.M_WP_Translocator_1PGreen_unlit'
      scale=2
   End Object

   Begin Object Class=ParticleSystemComponent Name=ConstantEffect
      Template=ParticleSystem'DOM_Content.Particles.P_WP_Translocator_Beacon_Green'
      bAutoActivate=false
      SecondsBeforeInactive=1.0f
   End Object
   LandEffects=ConstantEffect
   Components.Add(ConstantEffect)

   Begin Object Class=UTParticleSystemComponent Name=BrokenPCS
      Template=ParticleSystem'DOM_Content.Particles.P_WP_Translocator_Broken_Green'
      HiddenGame=true
      SecondsBeforeInactive=1.0f
   End Object
   DisruptedEffect=BrokenPCS
   Components.Add(BrokenPCS)

   BounceSound=SoundCue'A_Weapon_Translocator.Translocator.A_Weapon_Translocator_Bounce_Cue'
   DisruptedSound=SoundCue'A_Weapon_Translocator.Translocator.A_Weapon_Translocator_Disrupted_Cue'

   Begin Object Class=AudioComponent Name=DisruptionSound
      SoundCue=SoundCue'A_Weapon_Translocator.Translocator.A_Weapon_Translocator_DisruptedLoop_Cue'
   End Object
   Components.Add(DisruptionSound);
   DisruptedLoop=DisruptionSound;

   ProjectileLightClass=class'UTDom.DOM_UTTranslocatorLightGreen'
}

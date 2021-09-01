/**
 * Translocator with 4 team support
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMWeap_Translocator_Content extends UTWeap_Translocator_Content
   HideDropDown;

var LinearColor MultiSkinColors[4];

simulated function SetSkin(Material NewMaterial)
{
   local int TeamIndex;

   TeamIndex = Instigator.GetTeamNum();
   if ( TeamIndex == 255 )
      TeamIndex = 0;

   if ( NewMaterial == None )    // Clear the materials
   {
      Mesh.SetMaterial(1,TeamSkins[TeamIndex]);
      GeneralSkin.SetVectorParameterValue('Team_Color',MultiSkinColors[TeamIndex]);
   }
   else
   {
      super(UTWeapon).SetSkin(NewMaterial);
   }
}

DefaultProperties
{
   TeamSkins(2)=MaterialInterface'DOM_Content.Materials.M_WP_Translocator_1PGreen'
   TeamSkins(3)=MaterialInterface'DOM_Content.Materials.M_WP_Translocator_1PGold'
   WeaponProjectiles(0)=class'UTGameContent.UTProj_TransDisc_ContentRed'
   WeaponProjectiles(1)=class'UTGameContent.UTProj_TransDisc_ContentBlue'
   WeaponProjectiles(2)=class'UTDom.DOMProj_TransDisc_ContentGreen'
   WeaponProjectiles(3)=class'UTDom.DOMProj_TransDisc_ContentGold'
   AttachmentClass=class'UTDom.DOMAttachment_Translocator'
   MultiSkinColors(0)=(R=3.4,G=0.5,B=0.1)
   MultiSkinColors(1)=(R=0.2,G=0.5,B=3.4)
   MultiSkinColors(2)=(R=0.0,G=3.4,B=0.0)
   MultiSkinColors(3)=(R=2.4,G=2.4,B=0.0)
}

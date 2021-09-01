/**
 * Translocator with 4 team support
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMAttachment_Translocator extends UTAttachment_Translocator;

var MaterialInterface MultiTeamSkins[4];

simulated function SetSkin(Material NewMaterial)
{
   local int TeamIndex;

   if ( NewMaterial == None )    // Clear the materials
   {
      TeamIndex = Instigator.GetTeamNum();
      if ( TeamIndex == 255 )
         TeamIndex = 0;
      Mesh.SetMaterial(0,MultiTeamSkins[TeamIndex]);
   }
   else
   {
      Super(UTWeaponAttachment).SetSkin(NewMaterial);
   }
}

DefaultProperties
{
   WeaponClass=class'UTDom.DOMWeap_Translocator_Content'
   MultiTeamSkins[0]=MaterialInterface'WP_Translocator.Materials.M_WP_Translocator_1P'
   MultiTeamSkins[1]=MaterialInterface'WP_Translocator.Materials.M_WP_Translocator_1PBlue'
   MultiTeamSkins[2]=MaterialInterface'DOM_Content.Materials.M_WP_Translocator_1PGreen'
   MultiTeamSkins[3]=MaterialInterface'DOM_Content.Materials.M_WP_Translocator_1PGold'
}
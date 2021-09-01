/**
 * Based off the work from Infinity Impossible, Copyright 2007
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_UTMutator_WeaponReplacer extends UTMutator_WeaponReplacement;

defaultproperties
{
   WeaponsToReplace(0)=(OldClassName="UTWeap_Enforcer",NewClassPath="UTMultiTeam.UTMT_UTWeap_Enforcer")
   WeaponsToReplace(1)=(OldClassName="UTWeap_SniperRifle",NewClassPath="UTDom.DOM_MT_UTWeap_SniperRifle_Content")
   WeaponsToReplace(2)=(OldClassName="UTWeap_InstagibRifle",NewClassPath="UTDom.DOM_MT_UTWeap_InstagibRifle")
   WeaponsToReplace(3)=(OldClassName="UTWeap_Redeemer_Content",NewClassPath="UTMultiTeam.UTMT_UTWeap_Redeemer")
   WeaponsToReplace(4)=(OldClassName="UTWeap_LinkGun",NewClassPath="UTDom.DOM_MT_UTWeap_LinkGun_Content")
   WeaponsToReplace(5)=(OldClassName="UTMT_UTWeap_SniperRifle_Content",NewClassPath="UTDom.DOM_MT_UTWeap_SniperRifle_Content")
   WeaponsToReplace(6)=(OldClassName="UTMT_UTWeap_InstagibRifle",NewClassPath="UTDom.DOM_MT_UTWeap_InstagibRifle")
   WeaponsToReplace(7)=(OldClassName="UTMT_UTWeap_LinkGun_Conten",NewClassPath="UTDom.DOM_MT_UTWeap_LinkGun_Content")
   WeaponsToReplace(8)=(OldClassName="UnlaggedInstagibRifle",NewClassPath="UTDom.DOM_MT_UTWeap_InstagibRifle")
   bExportMenuData=False
   GroupNames(0)="BASEWEAPONMOD"
}

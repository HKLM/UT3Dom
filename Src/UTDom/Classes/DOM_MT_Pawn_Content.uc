/**
 * @deprecated
 * @warning THIS CLASS IS NO LONGER USED!
 * @remarks THIS IS ONLY KEPT AROUND IN HOPES THIS VERSION OF UT3DOM WILL BE CONFORMED CORRECTLY
 * 
 * Based off the work from Infinity Impossible, Copyright 2007
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_Pawn_Content extends UTMT_Pawn
   deprecated;

defaultproperties
{
   SkinReplacementMaterials(0)=(MaterialName="M_CH_IronG_Arms_FirstPersonArm",ReplacementMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.M_CH_IronG_Arms_FirstPersonArms_V01')
   SkinReplacementMaterials(1)=(MaterialName="M_CH_IronG_Arms_FirstPersonArm_VBlue",ReplacementMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.M_CH_IronG_Arms_FirstPersonArms_VBlue')
   SkinReplacementMaterials(2)=(MaterialName="M_CH_IronG_Arms_FirstPersonArm_VRed",ReplacementMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.M_CH_IronG_Arms_FirstPersonArms_VRed')
   ShieldBeltMultiTeamMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.ShieldBeltV1a_INST'
   MultiTransInEffects(0)=Class'UTGame.UTEmit_TransLocateOutRed'
   MultiTransInEffects(1)=Class'UTGame.UTEmit_TransLocateOut'
   MultiTransInEffects(2)=Class'UTDom.DOM_MT_UTEmit_TransLocateOutGreen'
   MultiTransInEffects(3)=Class'UTDom.DOM_MT_UTEmit_TransLocateOutGold'
   MultiTransOutEffects(0)=Class'UTGame.UTEmit_TransLocateOutRed'
   MultiTransOutEffects(1)=Class'UTGame.UTEmit_TransLocateOut'
   MultiTransOutEffects(2)=Class'UTDom.DOM_MT_UTEmit_TransLocateOutGreen'
   MultiTransOutEffects(3)=class'UTDom.DOM_MT_UTEmit_TransLocateOutGold'
}

/**
 * Based off the work from Infinity Impossible, Copyright 2007
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOM_MT_CharacterTeamMaterialTransformer extends UTMT_CharacterTeamMaterialTransformer;

defaultproperties
{
   ReplacementMaterials(0)=(MaterialName="M_CH_ALL_BASE_02",ReplacementMaterial=Material'DOM_MTContent.Materials.CharMatV1a')
   //TODO
   ReplacementMaterials(1)=(MaterialName="M_CH_ALL_BASE_02_Fallback",ReplacementMaterial=Material'DOM_MTContent.Materials.CharMatV1a')
   ReplacementMaterials(2)=(MaterialName="M_CH_NECRIS_GLOBAL",ReplacementMaterial=Material'DOM_MTContent.Materials.NewNecrisMat_BlueV1a')
   ReplacementMaterials(3)=(MaterialName="M_CH_NECRIS_GLOBAL_Fallback",ReplacementMaterial=Material'DOM_MTContent.Materials.NewNecrisMat_BlueV1a_Fallback')
}

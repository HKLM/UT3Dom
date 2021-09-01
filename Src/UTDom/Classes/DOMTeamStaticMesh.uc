/**
 * More advanced UTTeamStaticMesh. The exact UTGameObjective actor that will be monitoring, can be manualy set.
 * No longer limited to only the 0 index to change the material on.
 *
 * Setup the TeamMaterials array using the following format:
 *  TeamMaterials[0]=Red Team
 *  TeamMaterials[1]=Blue Team
 *  TeamMaterials[2]=Green Team
 *  TeamMaterials[3]=Gold Team
 *  TeamMaterials[4]=Neutral
 *
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMTeamStaticMesh extends UTTeamStaticMesh;

/** The UTGameObjective this actor will be associated with. If this value is 'none', Default to the nearest UTGameObjective. */
var() UTGameObjective TheObjective;
/** The index of the skin to apply the TeamMaterials on. Default is 0 */
var() int TeamMeshSkinIndex;

simulated event PreBeginPlay()
{
   local UTGameObjective O, Best;
   local float Distance, BestDistance;

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      if (TheObjective != none)
         Best = TheObjective;
      else
      {
         BestDistance = 1000000.f;
         foreach WorldInfo.AllNavigationPoints(class'UTGameObjective', O)
         {
            Distance = VSize(Location - O.Location);
            if (Distance < BestDistance)
            {
               BestDistance = Distance;
               Best = O;
            }
         }
      }

      if (Best != None)
      {
         Best.AddTeamStaticMesh(self);
      }
      else
      {
         SetTeamNum(255);
      }
   }
}

simulated function SetTeamNum(byte NewTeam)
{
   local int i;

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      i = 0;
      if ( TeamMeshSkinIndex <= StaticMeshComponent.GetNumElements() )
      {
         i = TeamMeshSkinIndex;
      }
      else
      {
         `Warn(string(self)$" - TeamMeshSkinIndex is Not a valid ElementIndex!  "$TeamMeshSkinIndex$"/"$StaticMeshComponent.GetNumElements());
      }

      if (NewTeam < TeamMaterials.length)
      {
         StaticMeshComponent.SetMaterial(i, TeamMaterials[NewTeam]);
      }
      else
      {
         StaticMeshComponent.SetMaterial(i, NeutralMaterial);
      }
   }
}

DefaultProperties
{
   TeamMeshSkinIndex=0
   // pre-size array to five elements for convenience
   TeamMaterials[0]=None
   TeamMaterials[1]=None
   TeamMaterials[2]=None
   TeamMaterials[3]=None
   TeamMaterials[4]=None
}

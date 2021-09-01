/**
 * Control Point for Domination games
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class ControlPoint extends DominationObjective
   notplaceable
   hidedropdown;

/** Array of the staticmeshes that are display for the current controlling team. */
var const StaticMesh ControlPointMeshes[5]; 
/** Array of skins used for the DomBase mesh to match it's current state */
var const Material DomSkin[6]; 
/** Array of Higher detail skins to apply to the corresponding ControlPointMeshes of the same index */
var MaterialInstanceConstant MISkin[5]; 

simulated function PostBeginPlay()
{
   Super.PostBeginPlay();

   UpdateTeamEffects(4);
   // Set the initial light to be a little brighter
   DomLight.SetLightProperties(self.default.DomLight.Brightness+1.0);
   if (PointName ~= "")
      PointName = GetHumanReadableName();
}

function UpdateStatus()
{
   local TeamInfo NewTeam;
   local int OldIndex;

   if ( ControllingPawn == None )
      NewTeam = none;
   else
      NewTeam = ControllingPawn.PlayerReplicationInfo.Team;

   if ( NewTeam == ControllingTeam )
      return;

   // for AI, update DefenderTeamIndex
   OldIndex = DefenderTeamIndex;
   if (NewTeam == None)
   {
      DefenderTeamIndex = 255; // ie. "no team" since 0 is a valid team
      if (HomeBase != none)
         HomeBase.DefenderTeamIndex = 255;
   }
   else
   {
      DefenderTeamIndex = NewTeam.TeamIndex;
      if (HomeBase != none)
         HomeBase.DefenderTeamIndex = NewTeam.TeamIndex;
   }

   if (bScoreReady && (OldIndex != DefenderTeamIndex))
      UTGame(WorldInfo.Game).FindNewObjectives(HomeBase);

   // otherwise we have a new controlling team, or the point is being re-enabled
   ControllingTeam = NewTeam;
   super.UpdateStatus();

   // Change the displayed mesh to match the controlling team
   if (ControllingTeam == None)
   {
      bScoreReady = False;
      UpdateTeamEffects(4);
   }
   else
   {
      UpdateTeamEffects(ControllingTeam.TeamIndex);
      ScoreTime = 2;
      SetTimer(1.0, True);
   }
}

/** 
 * Changes the displayed mesh and light color to match the controlling team.
 * 
 * @param TeamIndex  The new controlling team to update to
 */
simulated function UpdateTeamEffects(byte TeamIndex)
{
   local byte i;

   super.UpdateTeamEffects(TeamIndex);

   i = static.ValidateTeamIndex(TeamIndex);
   DomMesh.SetStaticMesh(ControlPointMeshes[i]);
   // Apply the higher detail skins
   if (MISkin[i] != None)
      DomMesh.SetMaterial(0, MISkin[i]);

   // Fix up the mesh sizes, esp for the Green and Gold team meshes
   if (i == 2)
      DomMesh.SetScale(1.22);
   else if (i == 3)
      DomMesh.SetScale(1.36);
   else
      DomMesh.SetScale(1.08);

   DomLight.SetLightProperties(, LightColors[i]);
   ForceNetRelevant();
}

/** 
 * Don't call super here since we don't want it incrementing score! 
 */
function Timer()
{
   ScoreTime--;
   if (ScoreTime > 0)
   {
      bScoreReady = False;
   }
   else
   {
      ScoreTime = 0;
      bScoreReady = True;
      SetTimer(0.00000, False);
   }
}

function Reset()
{
   super.Reset();
   UpdateTeamEffects(4);
}

DefaultProperties
{
   ControlPointMeshes[0]=StaticMesh'DOM_Content.Meshes.DomRed'
   ControlPointMeshes[1]=StaticMesh'DOM_Content.Meshes.DomBlue'
   ControlPointMeshes[2]=StaticMesh'DOM_Content.Meshes.DomGreen'
   ControlPointMeshes[3]=StaticMesh'DOM_Content.Meshes.DomGold'
   ControlPointMeshes[4]=StaticMesh'DOM_Content.Meshes.DomN'
   MISkin[0]=MaterialInstanceConstant'DOM_Content.Materials.ControlPoint0_INST'
   MISkin[1]=MaterialInstanceConstant'DOM_Content.Materials.ControlPoint1_INST'
   MISkin[2]=MaterialInstanceConstant'DOM_Content.Materials.ControlPoint2_INST'
   MISkin[3]=MaterialInstanceConstant'DOM_Content.Materials.ControlPoint3_INST'
   MISkin[4]=MaterialInstanceConstant'DOM_Content.Materials.ControlPoint4_INST'
   Begin Object class=StaticMeshComponent name=StaticMeshComponent0
      StaticMesh=StaticMesh'DOM_Content.Meshes.DomN'
      CastShadow=False
      bCastDynamicShadow=False
      bAcceptsLights=False
      bAcceptsDynamicLights=False
      LightEnvironment=DomPointLightEnvironment
      CollideActors=False
      CullDistance=7000
      bUseAsOccluder=False
      BlockRigidBody=False
      Translation=(X=0.0,Y=0.0,Z=-24.0)
      Scale=1.08
   End Object
   DomMesh=StaticMeshComponent0
   Components.Add(StaticMeshComponent0)
   ControlSound=SoundCue'DOM_Content.Sounds.ControlSoundCue'
   MessageClass=class'UTDom.DOMMessage'
   bNoDelete=False
   Physics=PHYS_Rotating
   RotationRate=(Yaw=6000)
   DesiredRotation=(Yaw=30000)
}

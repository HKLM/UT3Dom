/**
 * Base class for the actor that LD can place into a map.
 * This factory, at runtime, will spawn the ControlPoint needed by the game.
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DominationFactory extends UTGameObjective
   abstract
   hidecategories(Collision);

/** The displayed name of this point. ObjectiveName is localized and can also be used. */
var() string PointName;
/** Reference to the ControlPoint or xDomPointA/B that is spawned during the begining of play */
var ControlPoint myControlPoint;
/** ControlPoint class that will be spawned by this factory.
 * if LD require a way to control what point will be A or B in DoubleDom games, then use this.
 * NOTE: Set ONLY ONE ControlPointFactory actor to xDomPointA and there must also be another ControlPointFactory actor set to xDomPointB (ONLY ONE ACTOR).
 * All other ControlPointFactory actors must be set to none.
 */
var(Advanced) class<ControlPoint> ControlPointClass;
/** Allows LD to specify the ControlPointClass to be used when testing the map in the Play-In-Editor gamemode. None=ControlPoint*/
var(Debug) class<ControlPoint> PIEControlPointClass;
/** mesh that is only used with the UnrealEditor/Play in Editor, and should not be displayed during gameplay. */
var StaticMeshComponent EditorDomMesh;
var PointLightComponent DomLight;
var DynamicLightEnvironmentComponent LightEnvironment;
/** whether to render this points name above this point on HUD beacon (using PostRenderFor()) */
var() bool bDrawBeaconName;

replication
{
   if (bNetInitial && (Role == ROLE_Authority))
      PointName;
   if (Role==ROLE_Authority)
      myControlPoint;
}

simulated function PreBeginPlay()
{
   Super.PreBeginPlay();

   // Hide the EditorDomMesh for game play.
   if (EditorDomMesh != None)
      EditorDomMesh.SetHidden(True);

   if (ROLE == ROLE_Authority)
      SpawnControlPoint();
}

/** 
 * spawns the needed type of DominationObjective
 */
function SpawnControlPoint()
{
   local int i;

   // if this is a Play-In-Editor game, force it to use class defined by the PIEControlPointClass setting
   if (WorldInfo != None && WorldInfo.IsPlayInEditor())
   {
      if (PIEControlPointClass == None)
         PIEControlPointClass = class'UTDom.ControlPoint';

      LogInternal("WorldInfo.IsPlayInEditor() is True!  Setting ControlPointClass to "$string(PIEControlPointClass),);
      ControlPointClass = PIEControlPointClass;
   }

   if ( !bHidden )
   {
      if (ControlPointClass != None && myControlPoint == None)
      {
         myControlPoint = Spawn(ControlPointClass, self);
         if (myControlPoint != None)
         {
            bIsActive = True;
            // Copy any properties that a LD may have set
            myControlPoint.PointName = GetHumanReadableName();
            myControlPoint.HomeBase = self;
            myControlPoint.DefensePriority = DefensePriority;
            myControlPoint.bIsActive = bIsActive;
            myControlPoint.DefenderTeamIndex = DefenderTeamIndex;
            myControlPoint.MyBaseVolume = MyBaseVolume;
            myControlPoint.BaseRadius = BaseRadius;
            myControlPoint.AttackAnnouncement = AttackAnnouncement;
            myControlPoint.DefendAnnouncement = DefendAnnouncement;
            myControlPoint.bBlocked = bBlocked;
            myControlPoint.bOneWayPath = bOneWayPath;
            myControlPoint.bVehicleDestination = bVehicleDestination;
            myControlPoint.bMakeSourceOnly = bMakeSourceOnly;
            myControlPoint.bBlockedForVehicles = bBlockedForVehicles;
            myControlPoint.bPreferredVehiclePath = bPreferredVehiclePath;
            myControlPoint.ExtraCost = ExtraCost;
            myControlPoint.bDrawBeaconName = bDrawBeaconName;
            for (i=0; i < LocationSpeech.Length; i++)
            {
               myControlPoint.LocationSpeech.AddItem(LocationSpeech[i]);
            }

            for (i=0; i < VehicleParkingSpots.Length; i++)
            {
               myControlPoint.VehicleParkingSpots.AddItem(VehicleParkingSpots[i]);
            }
            DomLight.SetLightProperties(0.0);
            DomLight.SetEnabled(False);
            bForceNetUpdate = True;
         }
      }
   }
   else if (myControlPoint != None)
   {
      // we shouldn't have a DominationObjective in this case, so destroy it
      myControlPoint.Destroy();
   }
}

simulated function string GetHumanReadableName()
{
   if (PointName != "")
      return PointName;
   else
      return ObjectiveName;
}

simulated function bool PoweredBy(byte Team)
{
   if (myControlPoint != None && myControlPoint.ControllingTeam != None)
   {
      if ( (myControlPoint.ControllingTeam.TeamIndex != 255 && Team == myControlPoint.ControllingTeam.TeamIndex) ||
         (myControlPoint.ControllingTeam.TeamIndex != 4 && Team == myControlPoint.ControllingTeam.TeamIndex) )
         return True;
   }

   return False;
}

static function byte IsValidDOMTeamID(byte TeamID)
{
   // 255 is Neutral but we need a value between 0-5
   if (TeamID > 5)
      return 4;

   return TeamID;
}

/**
 * this gets called by GetTeamNum()
 */
simulated event byte ScriptGetTeamNum()
{
   local byte b;

   b = 254;
   if (myControlPoint != None)
   {
      if (myControlPoint.bIsDisabled)
         b = 5;
      else if (myControlPoint.ControllingTeam != None && myControlPoint.DefenderTeamIndex != 255)
         b = myControlPoint.ControllingTeam.TeamIndex;
      else
         b = 4;
   }

   if (b == 254)
   {
      if ( IsDisabled() )
         b = 5;
      else if ( IsNeutral() || DefenderTeamIndex == 255 )
         b = 4;
      else
         b = DefenderTeamIndex;
   }
   return IsValidDOMTeamID(b);
}

simulated function int GetControllingTeamNum()
{
   if (myControlPoint != None)
   {
      if (myControlPoint.bIsDisabled)
         return 5;

      if (myControlPoint.ControllingTeam != None && myControlPoint.DefenderTeamIndex != 255)
         return myControlPoint.ControllingTeam.TeamIndex;
   }
   return 4;
}

simulated function bool IsNeutral()
{
   if (myControlPoint != none && myControlPoint.bIsActive && myControlPoint.ControllingTeam != none)
   {
      if (myControlPoint.ControllingTeam.TeamIndex == 4 || myControlPoint.ControllingTeam.TeamIndex == 255)
         return True;
   }
   else if (DefenderTeamIndex == 4 || DefenderTeamIndex == 255)
   {
      return True;
   }

   return False;
}

simulated function bool IsDisabled()
{
   if (myControlPoint == None)
      return True;
   if (myControlPoint != None)
      return (myControlPoint.bIsDisabled);
   else if (DefenderTeamIndex == 5)
      return True;

   return False;
}

/** 
 * triggers all DOMSeqEvent_ControlPointEvent attached to this objective with the given Controlling Team event type
 * 
 * @param TeamIndex        The TeamID of the EventInstigator
 * @param EventInstigator  The Controller that triggered this to go off
 */
function TriggerKismetEvent(byte TeamIndex, Controller EventInstigator)
{
   local DOMSeqEvent_ControlPointEvent DomEvent;
   local int i;
   local name EventType;

   switch (TeamIndex)
   {
      case 0:
         EventType = 'Red';
         break;
      case 1:
         EventType = 'Blue';
         break;
      case 2:
         EventType = 'Green';
         break;
      case 3:
         EventType = 'Gold';
         break;
      case 5:
         EventType = 'Disabled';
         break;
      default:
         EventType = 'Neutral';
         break;
   }

   for (i = 0; i < GeneratedEvents.length; i++)
   {
      DomEvent = DOMSeqEvent_ControlPointEvent(GeneratedEvents[i]);
      if (DomEvent != None)
         DomEvent.Trigger(EventType, EventInstigator);
   }
}

/**
 * triggers all DOMSeqEvent_ControlPointEvent attached to this objective with the given flag event type 
 */
function TriggerFlagEvent(name EventType, Controller EventInstigator)
{
   local DOMSeqEvent_ControlPointEvent DOMEvent;
   local int i;

   for (i = 0; i < GeneratedEvents.length; i++)
   {
      DOMEvent = DOMSeqEvent_ControlPointEvent(GeneratedEvents[i]);
      if (DOMEvent != None)
         DOMEvent.Trigger(EventType, EventInstigator);
   }
}

/**
 * adds the given team static mesh to our list and initializes its team
 * 11/13/2008 - Changed to now use the AddItem() for adding to the TeamStaticMeshes array.
 *              Safer then using TeamStaticMeshes[TeamStaticMeshes.length]
 */
simulated function AddTeamStaticMesh(UTTeamStaticMesh SMesh)
{
   local int d;

   TeamStaticMeshes.AddItem(SMesh);
   d = DefenderTeamIndex;
   SMesh.SetTeamNum(d);
}

/**
 * updates TeamStaticMeshes array for a change in our team
 * 11/13/2008 - Removed the IsValidDOMTeamID checks and returned to the original logic in UTGameObjective.UpdateTeamStaticMeshes()
 */
simulated function UpdateTeamStaticMeshes()
{
   local int i, d;

   d = DefenderTeamIndex;
   for (i = 0; i < TeamStaticMeshes.length; i++)
   {
      TeamStaticMeshes[i].SetTeamNum(d);
   }
}

/**
 * TellBotHowToDisable()
 * tell bot what to do to disable me.
 * 
 * @return  true if valid/useable instructions were given
 */
function bool TellBotHowToDisable(UTBot B)
{
   local UTVehicle VehicleEnemy;
/* The following variables are Not used. Kept for backwards conform compatibility */
   local DOMSquadAI DOM_SquadAI;
   local UTBot OtherB;
   local bool bCloserTeammate;
   local float Dist;
   local DominationFactory DF; 
   local Pawn Pw;
   local UTGameObjective SqOb;

   if (DefenderTeamIndex == B.Squad.Team.TeamIndex)
      return False;

   if (!PoweredBy(B.Squad.Team.TeamIndex))
       return B.Squad.FindPathToObjective(B, self);

   //take out defensive turrets first
   VehicleEnemy = UTVehicle(B.Enemy);
   if ( VehicleEnemy != None && (VehicleEnemy.bStationary || VehicleEnemy.bIsOnTrack) &&
      (VehicleEnemy.AIPurpose == AIP_Defensive || VehicleEnemy.AIPurpose == AIP_Any) && B.LineOfSightTo(B.Enemy) )
   {
      return False;
   }

   if ( StandGuard(B) )
      return TooClose(B);

   // The following code is never used.
   // This is only here so there are no compiler warnings
   if (DefenderTeamIndex == 142)
   {
      DOM_SquadAI = None;
      OtherB = None;
      bCloserTeammate = False;
      Dist = 0.0f;
      DF = None;
      Pw = None;
      SqOb = None;
      if (DOM_SquadAI != None && OtherB != None && bCloserTeammate && DF != None && Pw != None && SqOb != None && Dist != 0.0)
         return False;
   }
}

/** 
 *  if bot is in important vehicle, and other bots can do the dirty work,
 *  return false if within get out distance
 *  @note based from UTOnslaughtObjective
 */
function bool StandGuard(UTBot B)
{
   local UTBot SquadMate;
   local float Dist;
   local int i;
   local UTVehicle BotVehicle;
   local UTVehicle_Deployable DeployableVehicle;

   if (DefenderTeamIndex != B.PlayerReplicationInfo.GetTeamNum() && DefenderTeamIndex < 2)
   {
      return False;
   }

   BotVehicle = UTVehicle(B.Pawn);
   if (BotVehicle != None && BotVehicle.ImportantVehicle())
   {
      Dist = VSize(BotVehicle.Location - Location);
      if (ReachedParkingSpot(BotVehicle) || (Dist < BotVehicle.ObjectiveGetOutDist && B.LineOfSightTo(self)))
      {
         if (BotVehicle.bKeyVehicle && BotVehicle.CanAttack(self))
         {
            DeployableVehicle = B.GetDeployableVehicle();
            if (DeployableVehicle != None && DeployableVehicle.DeployedState == EDS_Undeployed)
            {
               DeployableVehicle.SetTimer(0.01, False, 'ServerToggleDeploy');
            }
            return True;
         }
         if ( DefenderTeamIndex == B.PlayerReplicationInfo.Team.TeamIndex ||
            (B.Enemy != None && WorldInfo.TimeSeconds - B.LastSeenTime < 2) )
         {
            return True;
         }

         // check if there's a passenger
         if (BotVehicle.Seats.length > 1)
         {
            for (i = 1; i < BotVehicle.Seats.length; i++)
            {
               if (BotVehicle.Seats[i].SeatPawn != None)
               {
                  SquadMate = UTBot(BotVehicle.Seats[i].SeatPawn.Controller);
                  if (SquadMate != None)
                  {
                     BotVehicle.Seats[i].SeatPawn.DriverLeave(False);
                     return True;
                  }
               }
            }
         }

         // check if there's another bot around to do it
         for (SquadMate = B.Squad.SquadMembers; SquadMate != None; SquadMate = SquadMate.NextSquadMember)
         {
            if ( SquadMate.Pawn != None && (UTVehicle(SquadMate.Pawn) == None || !UTVehicle(SquadMate.Pawn).ImportantVehicle())
               && VSize(SquadMate.Pawn.Location - Location) < Dist + 2000.0 && SquadMate.RouteGoal == self )
            {
               return True;
            }
         }
      }
   }

   return False;
}

/**
 * @note based off UTOnslaughtObjective 
 */
function bool TooClose(UTBot B)
{
   local UTBot SquadMate;
   local int R;

   if ( (VSize(Location - B.Pawn.Location) < 2*B.Pawn.GetCollisionRadius()) && (PathList.Length > 1) )
   {
      //standing right on top of it, move away a little
      B.GoalString = "Move away from "$self;
      R = Rand(PathList.Length-1);
      B.MoveTarget = PathList[R].End.Nav;
      for ( SquadMate=B.Squad.SquadMembers; SquadMate!=None; SquadMate=SquadMate.NextSquadMember )
      {
         if ( (SquadMate.Pawn != None) && (VSize(SquadMate.Pawn.Location - B.MoveTarget.Location) < B.Pawn.GetCollisionRadius()) )
         {
            B.MoveTarget = PathList[R+1].End.Nav;
            break;
         }
      }
      B.SetAttractionState();
      return True;
   }
   return False;
}

function DisableThisPoint()
{
   ControlPointClass = None;
   bIsActive = False;
   bIsDisabled = True;
   DomLight.SetLightProperties(0.0);
   SetHidden(True);
   SetCollision(false,false);
   DefenderTeamIndex = 255;
   bForceNetUpdate = TRUE;
   if (myControlPoint != none && myControlPoint.bIsActive)
      myControlPoint.DisableThisPoint();

   GotoState('Disabled');
}

State Disabled
{
   ignores Touch;
}

function Reset()
{
   super.Reset();
   bIsActive = True;
   bIsDisabled = False;
   DefenderTeamIndex = 255;
}

DefaultProperties
{
   Components.Remove(Sprite)
   GoodSprite=None
   Begin Object Name=Sprite2
      Scale=0.85
   End Object
   Begin Object Name=CollisionCylinder
      CollisionRadius=+60.0
      CollisionHeight=+80.0
      CollideActors=True
      BlockRigidBody=False
   End Object
   CollisionType=COLLIDE_TouchAll
   CollisionComponent=CollisionCylinder
   Components.Add(CollisionCylinder)
   Begin Object Class=DynamicLightEnvironmentComponent Name=DomPointLightEnvironment
      LightDesaturation=20.0
   End Object
   LightEnvironment=DomPointLightEnvironment
   Components.Add(DomPointLightEnvironment)
   Begin Object Class=StaticMeshComponent Name=EditorStaticMeshComponent0
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
      HiddenEditor=False
      AlwaysLoadOnClient=False
      AlwaysLoadOnServer=False
   End Object
   EditorDomMesh=EditorStaticMeshComponent0
   Components.Add(EditorStaticMeshComponent0)
   Begin Object Class=PointLightComponent Name=DomLightComponent
      Radius=400
      Brightness=5.0
      LightColor=(B=180,G=180,R=180)
      LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE)
      CastShadows=True
      UseDirectLightMap=False
      CastDynamicShadows=True
      bForceDynamicLight=True
   End Object
   DomLight=DomLightComponent
   Components.Add(DomLightComponent)
   bStatic=True
   bStasis=False
   bNoDelete=True
   bCollideActors=True
   bCollideWorld=True
   bWorldGeometry=False
   bPushedByEncroachers=False
   bCollideWhenPlacing=True
   bIgnoreEncroachers=True
   bPathColliding=True
   bDestinationOnly=True
   bNotBased=True
   bHasSensor=True
   bCanWalkOnToReach=True
   NetUpdateFrequency=1
   bBlockActors=False
   bEdShouldSnap=True
   bAlwaysRelevant=True
   bGameRelevant=True
   bDrawBeaconName=True
   RemoteRole=ROLE_SimulatedProxy
   DrawScale=0.44
   CameraViewDistance=320.0
   DefenderTeamIndex=255
   StartTeam=255
   DefensePriority=2
   PIEControlPointClass=class'UTDom.ControlPoint'
   SupportedEvents.Add(class'UTDom.DOMSeqEvent_ControlPointEvent')
}
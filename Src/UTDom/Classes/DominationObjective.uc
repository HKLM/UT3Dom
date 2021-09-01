/**
 * Base class for all Domination style, Control Point Objectives.
 *
 * Base type of Objectives for Domination games.
 * The subclasses of DominationObjective can be spawned by the ControlPointFactory actor during
 * the begining of play. Use the 'notplaceable' flag on the subclasses that can be spawned and
 * you want to have the class listed in the ControlPointFactory.ControlPointClass property list.
 *
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DominationObjective extends UTGameObjective
   abstract
   notplaceable;

/** The displayed name of this point. ObjectiveName can also be used. */
var() string PointName;
/** The Light color DomLight will use to match the ControllingTeam */
var() color LightColors[5];
var StaticMeshComponent DomMesh;
var PointLightComponent DomLight;
var DynamicLightEnvironmentComponent LightEnvironment;
/** sound played when this control point changes hands - ControlPoint */
var SoundCue ControlSound;
/** Alarm sound for when this point is taken - xDomPoint */
var AudioComponent AlarmSound;
/** Pointer back to the DominationFactory actor that spawn us */
var DominationFactory HomeBase;
/** team currently controlling this point */
var repnotify TeamInfo ControllingTeam;
/** the current player who last captured this point */
var UTPlayerReplicationInfo HolderPRI;
/** controller who last touched this control point */
var Pawn ControllingPawn;
/** will be 'true' if and when the domination point can be captured */
var bool bScoreReady;     
var bool bVehiclesCanCapturePoint;
/** @deprecated No Longer Used  */
var deprecated int PlayerID;
/** The time after one team touches a control point, til the next team can capture it */
var int ScoreTime;
/** Offset position from the DomBase for the DomRing and DomLetter */
var vector EffectOffset; 
var deprecated transient byte CurrentEventID;
/** the ammount of time that has passed since this point was captured (Used for BotAI) */
var transient float ControlledTime;
/** The rotating letter displayed in game for this point */
var xDomDynamicSMActor DomLetter, DOMRing; 
/** whether to render this points name above this point on HUD beacon (using PostRenderFor()) */
var() bool bDrawBeaconName;

replication
{
   if ((Role==ROLE_Authority) && bNetDirty)
      ControllingTeam, bScoreReady, HolderPRI;
   if ((Role==ROLE_Authority) && (bNetInitial || bNetDirty))
      HomeBase, PointName;
}

simulated event ReplicatedEvent(name VarName)
{
   if (VarName == 'ControllingTeam')
   {
      if (ControllingTeam != None)
      {
         UpdateTeamEffects(ControllingTeam.TeamIndex);
      }
      else
      {
         UpdateTeamEffects(4);
      }
   }
   else if (VarName == 'bUnderAttack')
   {
      SetAlarm(bUnderAttack);
   }
   else
   {
      Super.ReplicatedEvent(VarName);
   }
}

simulated function PostBeginPlay()
{
   local UTDomGame Game;
   local UTPlayerController PC;

   super.PostBeginPlay();
   ControlledTime = WorldInfo.TimeSeconds;
   if (ROLE == ROLE_Authority)
   {
      if ( HomeBase == None && Owner != None && Owner.IsA('DominationFactory') )
         HomeBase = DominationFactory(Owner);

      // get the value for bVehiclesCanCapturePoint
      if (WorldInfo.Game != None)
      {
         Game = UTDomGame(WorldInfo.Game);
         if (Game != None)
            bVehiclesCanCapturePoint = Game.CanVehiclesCanCapturePoints();
      }
   }

   ForEach LocalPlayerControllers(class'UTPlayerController', PC)
      PC.PotentiallyHiddenActors[PC.PotentiallyHiddenActors.Length] = self;
}

/**
 * returns a valid 4 team TeamIndex or neutral
 * 
 * @param   TeamIndex   The number to valiadate
 * @return  a valid TeamIndex
 * @note
 * 0=Red Team
 * 1=Blue Team
 * 2=Green Team
 * 3=Gold Team
 * 4=Neutral (no team)
 */
static function byte ValidateTeamIndex(byte TeamIndex)
{
   if (TeamIndex > 3)
      return 4;
   else
      return TeamIndex;
}

simulated function string GetHumanReadableName()
{
   if (PointName != "")
      return PointName;

   return ObjectiveName;
}

simulated function UpdateTeamEffects(byte TeamIndex)
{
   local DominationFactory HB;
   local byte i;

   i = ValidateTeamIndex(TeamIndex);
   HB = GetHomeBase();
   if (HB != None)
   {
      HB.TriggerKismetEvent(i,ControllingPawn != None ? ControllingPawn.Controller : None);
      HB.SetTeam(i);
   }
}

/**
 * returns the game objective we should trigger Kismet ControlPoint events on
 * 
 * @return  HomeBase value
 */
function DominationFactory GetHomeBase()
{
   return HomeBase;
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
   local Pawn p;

   if ( Pawn(Other) == None || !Pawn(Other).IsPlayerPawn() || (UTPawn(Other) != None && UTPawn(Other).IsInState('FeigningDeath')) )
      return;

   // Dont allow Titan's to capture the Control Points
   if ( UTHeroPawn(Other) != None && UTHeroPawn(Other).IsHero() )
      return;

   if ( !bVehiclesCanCapturePoint )
   {
      p = Pawn(Other);
      if (Vehicle(p.base) != None || (UTVehicle(p) != None && !UTVehicle(p).bCanCarryFlag) )
         return;
   }

   if (ControllingPawn == None || Pawn(Other) != ControllingPawn)
   {
      ControllingPawn = Pawn(Other);
      UpdateStatus();
   }
}

event UnTouch(Actor Other)
{
   local UTPawn P;

   if ( Other == ControllingPawn )
   {
      ForEach TouchingActors(class'UTPawn', P)
      {
         if (P != None && P.IsPlayerPawn() && !P.IsHero() && !P.IsInState('FeigningDeath') )
         {
            ControllingPawn = P;
            UpdateStatus();
            break;
         }
      }
   }
}

/**
 * Updates effects and send out messages when the status of this point has changed.
 * 
 * @note ControllingPawn should be set before calling this and child classes need to set ControllingTeam before calling super.UpdateStatus()
 */
function UpdateStatus()
{
   local int i;

   ControlledTime = WorldInfo.TimeSeconds;
   if (ControlSound != none)
      PlaySound(ControlSound);

   if (ControllingTeam != none)
   {
      i = static.ValidateTeamIndex(ControllingTeam.TeamIndex);
      SetTeam(i);
      // Display HUD notification that this point has been captured by a team
      if (MessageClass != none)
         BroadcastLocalizedMessage(MessageClass,i,,,Self);
   }

   if (ControllingPawn != none)
   {
      HolderPRI = UTPlayerReplicationInfo(ControllingPawn.PlayerReplicationInfo);
      // Play Music event
      if (ControllingPawn.Controller != none && UTPlayerController(ControllingPawn.Controller) != none)
         UTPlayerController(ControllingPawn.Controller).ClientMusicEvent(7);

      // Bots broadcast team message
      if (ControllingPawn.Controller != none && AIController(ControllingPawn.Controller) != None)
         ControllingPawn.Controller.SendMessage(None, 'INPOSITION', 20);
   }
}

/** 
 * Lower the offset 
 */
simulated function vector GetHUDOffset(PlayerController PC, Canvas Canvas)
{
   local float Z;

   Z = 50;
   if ( PC.ViewTarget != None )
   {
      Z += 0.1 * VSize(PC.ViewTarget.Location - Location);
   }
   return Z*vect(0,0,1);
}

/**
 * PostRenderFor()
 * Hook to allow objectives to render HUD overlays for themselves.
 * Called only if objective was rendered this tick.
 * Assumes that appropriate font has already been set
 */
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
   local float TextXL, XL, YL, BeaconPulseScale, TextDistScale;
   local vector ScreenLoc;
   local LinearColor TeamColor;
   local Color TextColor;
   local UTWeapon Weap;
   local string NodeName;
   local byte TheTeamID;

   if ( !bDrawBeaconName || !IsActive() )
      return;

   screenLoc = Canvas.Project(Location + GetHUDOffset(PC,Canvas));

   // make sure not clipped out
   if (screenLoc.X < 0 ||
      screenLoc.X >= Canvas.ClipX ||
      screenLoc.Y < 0 ||
      screenLoc.Y >= Canvas.ClipY)
   {
      return;
   }

   // make sure not behind weapon
   if ( UTPawn(PC.Pawn) != None )
   {
      Weap = UTWeapon(UTPawn(PC.Pawn).Weapon);
      if ( (Weap != None) && Weap.CoversScreenSpace(screenLoc, Canvas) )
      {
         return;
      }
   }
   else if ( (UTVehicle_Hoverboard(PC.Pawn) != None) && UTVehicle_Hoverboard(PC.Pawn).CoversScreenSpace(screenLoc, Canvas) )
   {
      return;
   }

   // make sure really visible when looking at the correct direction
   if ( !PC.IsAimingAt(self,0.7) )
   {
      return;
   }

   if ( !IsKeyBeaconObjective(UTPlayerController(PC))  )
   {
      // periodically make sure really visible using traces
      if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
      {
         LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
         bPostRenderTraceSucceeded = FastTrace(Location, CameraPosition)
                              || FastTrace(Location+CylinderComponent.CollisionHeight*vect(0,0,1), CameraPosition);
      }
      
      if ( !bPostRenderTraceSucceeded )
      {
         return;
      }
      BeaconPulseScale = 1.0;
   }
   else
   {
      // pulse "key" objective
      BeaconPulseScale = UTPlayerController(PC).BeaconPulseScale;
   }

   TheTeamID = class'DominationFactory'.static.IsValidDOMTeamID(GetTeamNum());
   class'DOMHUD'.Static.GetTeamColor(TheTeamID, TeamColor, TextColor);
   TeamColor.A = 1.0;

   // fade if close to crosshair
   if (screenLoc.X > 0.4*Canvas.ClipX &&
      screenLoc.X < 0.6*Canvas.ClipX &&
      screenLoc.Y > 0.4*Canvas.ClipY &&
      screenLoc.Y < 0.6*Canvas.ClipY)
   {
      TeamColor.A = FMax(FMin(1.0, FMax(0.0,Abs(screenLoc.X - 0.5*Canvas.ClipX) - 0.05*Canvas.ClipX)/(0.05*Canvas.ClipX)), FMin(1.0, FMax(0.0, Abs(screenLoc.Y - 0.5*Canvas.ClipY)-0.05*Canvas.ClipX)/(0.05*Canvas.ClipY)));
      if ( TeamColor.A == 0.0 )
      {
         return;
      }
   }

   // fade if far away or not visible
   TeamColor.A = FMin(TeamColor.A, LocalPlayer(PC.Player).GetActorVisibility(self)
                           ? FClamp(1800/VSize(Location - CameraPosition),0.35, 1.0)
                           : 0.0);

   NodeName = GetHumanReadableName();

   Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(0);
   Canvas.StrLen(NodeName, TextXL, YL);
   TextDistScale = FMin(1.5, 0.1 * Canvas.ClipX/TextXL);
   TextXL *= TextDistScale;
   XL = 0.1 * Canvas.ClipX * BeaconPulseScale;
   YL *= TextDistScale*BeaconPulseScale;

   class'UTHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-0.6*(YL)- 0.5*(YL),1.4*XL,1.2*(YL) + YL, TeamColor, Canvas);
   Canvas.DrawColor = TextColor;
   Canvas.DrawColor.A = 255.0 * TeamColor.A;
   // draw node name
   Canvas.DrawColor.A = FMin(255.0, 128.0 * (1.0 + TeamColor.A));
   Canvas.SetPos(ScreenLoc.X-0.5*BeaconPulseScale*TextXL, ScreenLoc.Y - 0.5*YL - 0.6);
   Canvas.DrawTextClipped(NodeName, true, TextDistScale*BeaconPulseScale, TextDistScale*BeaconPulseScale);
   Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(0);
}

/**
  * Controls if the beacon should be pulsating or not
  * 
  * @return    true if is objective on which player should focus
  */
simulated function bool IsKeyBeaconObjective(UTPlayerController PC)
{
   if ( ControllingTeam == None )
      return True;

   if ( ControllingTeam != none && PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.GetTeamNum() == ControllingTeam.TeamIndex )
      return False;
   else
      return True;
}

function Reset()
{
   super.Reset();

   ControllingPawn = None;
   ControllingTeam = None;
   HolderPRI = None;
   ControlledTime = WorldInfo.TimeSeconds;
   DefenderTeamIndex = 255;
   if (HomeBase != None)
      HomeBase.Reset();
}

function ResetPoint(bool IsEnabled)
{
   Reset();
}

function bool BetterObjectiveThan(UTGameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
   if (DefenderTeamIndex != DesiredTeamNum)
      return False;

   if ( (Best == None) || (Best.DefensePriority < DefensePriority) || (DefenderTeamIndex == DesiredTeamNum) )
      return True;

   return False;
}

function bool NearObjective(Pawn P)
{
   return (VSize(Location - P.Location) < BaseRadius && P.LineOfSightTo(self));
}

simulated function bool PoweredBy(byte Team)
{
   if (ControllingTeam != none)
   {
      if ( (ControllingTeam.TeamIndex != 255 && Team == ControllingTeam.TeamIndex) ||
         (ControllingTeam.TeamIndex != 4 && Team == ControllingTeam.TeamIndex) )
         return True;
   }

   return False;
}

simulated event bool IsActive()
{
   return !bHidden;
}

simulated function SetAlarm(bool bNowOn)
{
   bUnderAttack = bNowOn;
}

function DisableThisPoint()
{
   bIsActive = False;
   DomLight.SetLightProperties(0.0);
   SetHidden(True);
   SetCollision(False,False);
   bScoreReady = False;
   ControllingPawn = None;
   ControllingTeam = None;
   HolderPRI = None;
   DefenderTeamIndex = 255;
   bForceNetUpdate = True;

   GotoState('Disabled');
}

State Disabled
{
   ignores Touch;

   event BeginState(Name PreviousStateName)
   {
      super.BeginState(PreviousStateName);
      bScriptInitialized = True;
      bIsDisabled = True;
      if (HomeBase != None)
         HomeBase.DefenderTeamIndex = 255;
   }
}

DefaultProperties
{
   Begin Object Name=CollisionCylinder
      CollisionRadius=+60.0
      CollisionHeight=+90.0
      CollideActors=True
      BlockRigidBody=False
   End Object
   CollisionType=COLLIDE_TouchAll
   CollisionComponent=CollisionCylinder
   Components.Add(CollisionCylinder)
   Begin Object Class=DynamicLightEnvironmentComponent Name=DomPointLightEnvironment
      LightDesaturation=40.0
   End Object
   LightEnvironment=DomPointLightEnvironment
   Components.Add(DomPointLightEnvironment)
   Begin Object Class=PointLightComponent Name=DomLightComponent
      Radius=400
      Brightness=2.0
      LightColor=(B=190,G=190,R=190)
      LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE)
      CastShadows=True
      UseDirectLightMap=False
      CastDynamicShadows=True
      bForceDynamicLight=True
   End Object
   DomLight=DomLightComponent
   Components.Add(DomLightComponent)
   LightColors(0)=(B=16,G=16,R=220,A=0)
   LightColors(1)=(B=220,G=32,R=32,A=0)
   LightColors(2)=(B=16,G=200,R=16,A=0)
   LightColors(3)=(B=16,G=200,R=200,A=0)
   LightColors(4)=(B=190,G=190,R=190,A=0)
   bScoreReady=True
   bStatic=False
   bStasis=False
   bNoDelete=True
   bCollideActors=True
   bCollideWorld=True
   bWorldGeometry=False
   bIgnoreEncroachers=True
   bPushedByEncroachers=False
   bCollideWhenPlacing=True
   bPathColliding=True
   bDestinationOnly=True
   bNotBased=True
   bHasSensor=True
   bCanWalkOnToReach=True
   bBlockActors=False
   bEdShouldSnap=True
   bAlwaysRelevant=True
   bGameRelevant=True
   bPostRenderIfNotVisible=True
   bDrawBeaconName=True
   RemoteRole=ROLE_SimulatedProxy
   NetUpdateFrequency=1
   DrawScale=0.44
   CameraViewDistance=320.0
   MaxBeaconDistance=4000.0
   DefenderTeamIndex=255
   DefensePriority=2
   StartTeam=255
}

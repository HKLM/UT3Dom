/**
 * operational AI control for Domination
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMSquadAI extends UTSquadAI;

var bool bDefendingSquad;
/** pointer to Team.AI so we don't have to cast all the time */
var DOMTeamAI DOM_TeamAI;
var float LastFindObjectiveTime; // last time tried to find attack objective (with squadobjective == None)

function Initialize(UTTeamInfo T, UTGameObjective O, Controller C)
{
   Super.Initialize(T, O, C);

   DOM_TeamAI = DOMTeamAI(T.AI);
   `Warn("TeamAI is not a subclass of DOMTeamAI",DOM_TeamAI == None);
}

/** 
 * returns whether the bot shouldn't get any closer to the given objective with the vehicle it's using
 */
function bool CloseEnoughToObjective(UTBot B, Actor O)
{
   return B.IsOverlapping(O);
}

function bool AllowTaunt(UTBot B)
{
   return ( Rand(2) == 1 );
}

/**
 * Checks if DominationObjective's can be captured by driving over them? 
 */
function bool MustCompleteOnFoot(Actor O, optional Pawn P)
{
   if (UTDomGame(WorldInfo.Game) != None)
      return !UTDomGame(WorldInfo.Game).CanVehiclesCanCapturePoints();
   else if (O.IsA('DominationFactory') && DominationFactory(O) != None)
      return !DominationFactory(O).myControlPoint.bVehiclesCanCapturePoint;
   else
      return true;
}

function name GetOrders()
{
   local name NewOrders;

   if ( PlayerController(SquadLeader) != None )
      NewOrders = 'Human';
   else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
      NewOrders = 'Freelance';
   else if ( bDefendingSquad || bFreelanceDefend || (SquadObjective != None && SquadObjective.DefenseSquad == self) )
      NewOrders = 'Defend';
   else
      NewOrders = 'Attack';
   if ( NewOrders != CurrentOrders )
   {
      CurrentOrders = NewOrders;
      bForceNetUpdate = TRUE;
   }
   return CurrentOrders;
}

simulated function DisplayDebug(HUD HUD, out float YL, out float YPos)
{
   local string EnemyList;
   local int i;
   local Canvas Canvas;

   Canvas = HUD.Canvas;
   Canvas.SetDrawColor(255,255,255);
   Canvas.DrawText("     ORDERS "$GetOrders()$" on "$GetItemName(string(self)), true);
   YPos += YL;
   Canvas.SetPos(4,YPos);
   if ( SquadObjective == None )
      Canvas.DrawText("     OBJECTIVE: No objective!!!", True);
   else
      Canvas.DrawText("     OBJECTIVE: "$SquadObjective.GetHumanReadableName(), True);
   YPos += YL;
   Canvas.SetPos(4,YPos);
   Canvas.DrawText("     Leader "$SquadLeader.GetHumanReadableName(), false);
   YPos += YL;
   Canvas.SetPos(4,YPos);
   EnemyList = "     Enemies: ";
   for ( i=0; i<ArrayCount(Enemies); i++ )
      if ( Enemies[i] != None )
         EnemyList = EnemyList@Enemies[i].GetHumanReadableName();
   Canvas.DrawText(EnemyList, false);
   YPos += YL;
   Canvas.SetPos(4,YPos);
}

/**
 * FindPathToObjective()
 * Returns path a bot should use moving toward a base
 */
function bool FindPathToObjective(UTBot B, Actor O)
{
   local bool bResult;

   if ( (DominationFactory(O) != None)
      && DominationFactory(O).IsNeutral()
      && (VSize(B.Pawn.Location - O.Location) < 2000) )
   {
      B.bForceNoDetours = True;
   }
   bResult = super.FindPathToObjective(B, O);
   B.bForceNoDetours = False;
   return bResult;
}

function bool CheckSquadObjectives(UTBot B)
{
   local bool bResult;
   local UTGameObjective tmpCP;
   local Actor DesiredPosition;
   local bool bInPosition, bCheckSuperPickups, bMovingToSuperPickup;
   local float SuperDist;
   local Vehicle V;

   if ( ((SquadObjective == None) || SquadObjective.bIsDisabled) && (WorldInfo.TimeSeconds - LastFindObjectiveTime > 4.0) )
   {
      LastFindObjectiveTime = WorldInfo.TimeSeconds;
      Team.AI.FindNewObjectiveFor(self, True);
   }

   if ( (UTPawn(B.Pawn) != None) && B.Squad.SquadObjective != none && B.Squad.SquadObjective.DefenderTeamIndex != B.PlayerReplicationInfo.Team.TeamIndex
     && (VSize(B.Squad.SquadObjective.Location - B.Pawn.Location) < 2000.0) && !DOM_TeamAI.ObjectiveCoveredByAnotherSquad(B.Squad.SquadObjective,self))
   {
      if (FindPathToObjective(B, B.Squad.SquadObjective))
      {
         B.GoalString = "Go capture Point: "$B.Squad.SquadObjective;
         B.RouteGoal = B.Squad.SquadObjective;
         return true;
      }
   }
   if (WorldInfo.TimeSeconds - B.Pawn.CreationTime < 5.0 && B.NeedWeapon() && B.FindInventoryGoal(0.0004))
   {
      B.GoalString = "Need weapon or ammo";
      B.NoVehicleGoal = B.RouteGoal;
      B.SetAttractionState();
      return true;
   }
   if (CheckVehicle(B))
      return true;
   if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
   {
      B.GoalString = "Need weapon or ammo";
      B.NoVehicleGoal = B.RouteGoal;
      B.SetAttractionState();
      return true;
   }
   tmpCP = DOM_TeamAI.FindControlPointNotOwned(B.Squad);
   if (tmpCP == none && self == Team.AI.FreelanceSquad && B.Squad.SquadObjective != none)
   {
      if ( B.Squad.SquadObjective.DefenderTeamIndex == Team.TeamIndex )
         Team.AI.ReAssessStrategy();
   }

   // consider stopping to attack enemy near objective
   if (B.Squad.SquadObjective != none && (B.Enemy != None && B.Enemy.PlayerReplicationInfo != None) && (B.Squad.SquadObjective.DefenderTeamIndex == B.PlayerReplicationInfo.Team.TeamIndex)
     && (VSize(B.Squad.SquadObjective.Location - B.Enemy.PlayerReplicationInfo.Location) < 2000.0))
   {
      if (GetOrders() == 'Defend')
      {
         B.GoalString = "Defend: Fight Enemy";
         B.FightEnemy(true, 0.0);
         return true;
      }
      else if (B.LineOfSightTo(B.Enemy))
      {
         B.GoalString = "Fight Enemy";
         B.FightEnemy(false, 0.0);
         return true;
      }
   }
   if (WorldInfo.TimeSeconds - B.Pawn.CreationTime < 5.0 && B.NeedWeapon() && B.FindInventoryGoal(0.0004))
   {
      B.GoalString = "Need weapon or ammo";
      B.NoVehicleGoal = B.RouteGoal;
      B.SetAttractionState();
      return true;
   }
   if ( (PlayerController(SquadLeader) != None) && (SquadLeader.Pawn != None) && (CurrentOrders == 'Follow'))
   {
      if ( UTHoldSpot(B.DefensePoint) == None )
      {
         // attack objective if close by
         if ( OverrideFollowPlayer(B) )
            return true;

         // follow human leader
         return TellBotToFollow(B,SquadLeader);
      }
      // hold position as ordered (position specified by DefensePoint)
   }

   if ( ShouldDestroyTranslocator(B) )
      return true;

   if ((B.Pawn.bStationary || (UTVehicle(B.Pawn) != None && UTVehicle(B.Pawn).bIsOnTrack)) && Vehicle(B.Pawn) != None)
   {
      if ( UTHoldSpot(B.DefensePoint) != None )
      {
         if ( UTHoldSpot(B.DefensePoint).HoldVehicle != B.Pawn && UTHoldSpot(B.DefensePoint).HoldVehicle != B.Pawn.GetVehicleBase() )
         {
            B.LeaveVehicle(true);
            return true;
         }
      }
      else if (UTVehicle(B.Pawn) != None && UTVehicle(B.Pawn).bKeyVehicle)
      {
         if ( B.DefensePoint != None )
            B.FreePoint();
         return false;
      }
   }
   V = Vehicle(B.Pawn);
   // see if should get superweapon/ pickup
   if (B.Skill > 0.5)
   {
      if (B.Pawn.bCanPickupInventory)
         bCheckSuperPickups = true;
      else if (V != None && V.Driver != None && V.Driver.bCanPickupInventory && (UTVehicle(V) == None || !UTVehicle(V).bKeyVehicle))
      {
         bCheckSuperPickups = true;
         B.bCheckDriverPickups = true;
      }

      if (bCheckSuperPickups)
      {
         if (UTHoldSpot(B.DefensePoint) != None || PriorityObjective(B) > 0)
            SuperDist = 800.0;
         else if ((GetOrders() == 'Freelance' || bFreelanceAttack || bFreelanceDefend) && !B.HasTimedPowerup())
            SuperDist = class'NavigationPoint'.const.INFINITE_PATH_COST;
         else if (CurrentOrders == 'Attack')
            SuperDist = (SquadObjective == None && B == SquadLeader && B.Skill >= 4.0) ? 6000.0 : 3000.0;
         else if (CurrentOrders == 'Defend' && B.Enemy != None)
            SuperDist = 1200.0;
         else
            SuperDist = 3200.0;

         bMovingToSuperPickup = ( (PickupFactory(B.RouteGoal) != None)
                     && PickupFactory(B.RouteGoal).bIsSuperItem
                     && (B.RouteDist < 1.1*SuperDist)
                     &&  PickupFactory(B.RouteGoal).ReadyToPickup(2)
                     && (B.RatePickup(B.RouteGoal, PickupFactory(B.RouteGoal).InventoryType) > 0) );
         if ( (bMovingToSuperPickup && B.FindBestPathToward(B.RouteGoal, false, true))
            ||  (B.Pawn.ValidAnchor() && CheckSuperItem(B, SuperDist)) )
         {
            B.bCheckDriverPickups = false;
            B.GoalString = "Get super item" @ B.RouteGoal;

            if ( V != None && !V.bCanPickupInventory && (B.Pawn.Anchor == None || !B.Pawn.Anchor.bFlyingPreferred) &&
               (B.MoveTarget == B.RouteGoal || (B.RouteCache.length > 1 && B.RouteCache[1] == B.RouteGoal)) )
            {
               // get out of vehicle here so driver can get it
               if (PickupFactory(B.RouteGoal) == None && UTVehicle(V) != None)
               {
                  UTVehicle(V).VehicleLostTime = WorldInfo.TimeSeconds + 5.0;
               }
               B.NoVehicleGoal = B.RouteGoal;
               B.LeaveVehicle(true);
            }
            else
            {
               B.SetAttractionState();
            }
            return true;
         }
         B.bCheckDriverPickups = false;
      }
   }

   if ( B.DefensePoint != None )
   {
      DesiredPosition = B.DefensePoint.GetMoveTarget();
      bInPosition = (B.Pawn == DesiredPosition) || B.Pawn.ReachedDestination(DesiredPosition);
      if ( bInPosition && (Vehicle(DesiredPosition) != None) )
      {
         if (V != None && B.Pawn != DesiredPosition && B.Pawn.GetVehicleBase() != DesiredPosition)
         {
            B.LeaveVehicle(true);
            return true;
         }

         if (V == None)
         {
            B.EnterVehicle(Vehicle(DesiredPosition));
            return true;
         }
      }
      if (B.ShouldDefendPosition())
      {
         return true;
      }
   }
   else if ( SquadObjective == None )
      return TellBotToFollow(B,SquadLeader);
   else if ( GetOrders() == 'Freelance' && (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
      return false;
   else
   {
      if ( SquadObjective.DefenderTeamIndex != Team.TeamIndex )
      {
         if ( SquadObjective.bIsDisabled )
         {
            B.GoalString = "Objective already disabled";
            return false;
         }
         B.GoalString = "Disable Objective "$SquadObjective;
         return SquadObjective.TellBotHowToDisable(B);
      }

      if (B.DefensivePosition != None && AcceptableDefensivePosition(B.DefensivePosition, B))
         DesiredPosition = B.DefensivePosition;
      else if (SquadObjective.bBlocked)
         DesiredPosition = FindDefensivePositionFor(B);
      else
      {
         DesiredPosition = SquadObjective;
      }
      bInPosition = ( VSize(DesiredPosition.Location - B.Pawn.Location) < NEAROBJECTIVEDIST &&
            (B.LineOfSightTo(SquadObjective) || (SquadObjective.bHasAlternateTargetLocation && B.LineOfSightTo(SquadObjective,, true))) );
      bResult = bInPosition;
      if (bResult)
         `Log("Bot is bInPosition");
   }

   if ( B.Enemy != None )
   {
      if ( B.LostContact(5) )
         B.LoseEnemy();

      if ( B.Enemy != None )
      {
         if ( B.LineOfSightTo(B.Enemy) || (WorldInfo.TimeSeconds - B.LastSeenTime < 3 && (SquadObjective == None || !SquadObjective.TeamLink(Team.TeamIndex))) 
            && (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
         {
            B.FightEnemy(false, 0);
            return true;
         }
      }
   }

   if ( bInPosition )
   {
      B.GoalString = "Near defense position" @ DesiredPosition;
      if ( !B.bInitLifeMessage )
      {
         B.bInitLifeMessage = true;
         B.SendMessage(None, 'INPOSITION', 25);
      }

      if ( B.DefensePoint != None )
         B.MoveToDefensePoint();
      else
      {
         if (B.Enemy != None && (B.LineOfSightTo(B.Enemy) || WorldInfo.TimeSeconds - B.LastSeenTime < 3))
         {
            B.FightEnemy(false, 0);
            return true;
         }

         B.WanderOrCamp();
      }
      return true;
   }

   if (ShouldUndeployVehicle(B))
      return true;

   if (B.Pawn.bStationary || (UTVehicle(B.Pawn) != None && UTVehicle(B.Pawn).bIsOnTrack))
      return false;

   B.GoalString = "Follow path to "$DesiredPosition;
   B.FindBestPathToward(DesiredPosition, false, true);
   if ( B.StartMoveToward(DesiredPosition) )
      return true;

   if ( (B.DefensePoint != None) && (DesiredPosition == B.DefensePoint) )
   {
      B.FreePoint();
      if ( (SquadObjective != None) && (VSize(B.Pawn.Location - SquadObjective.Location) > 1200) )
      {
         B.FindBestPathToward(SquadObjective,false,true);
         if ( B.StartMoveToward(SquadObjective) )
            return true;
      }
   }

   if (CurrentOrders == 'Freelance' && (B.Enemy == None) && (B.Squad.SquadObjective != none && DominationFactory(B.Squad.SquadObjective) != None))
   {
      if ( DominationFactory(B.Squad.SquadObjective).PoweredBy(Team.TeamIndex) )
      {
         B.GoalString = "Captured Control Point: "$B.Squad.SquadObjective;
         return (B.Squad.SquadObjective.TellBotHowToDisable(B));
      }
      else
      {
         B.GoalString = "Going to: "$B.Squad.SquadObjective;
         return FindPathToObjective(B, SquadObjective);
      }
   }

   return false;
}

function bool TellBotToFollow(UTBot B, Controller C)
{
   local Pawn Leader;

   if ( (C == None) || C.bDeleteMe )
   {
      PickNewLeader();
      C = SquadLeader;
   }

   if ( B == C )
      return false;

   B.GoalString = "Follow Leader";
   Leader = C.Pawn;
   if ( Leader == None )
      return false;

   if ( CloseToLeader(B.Pawn) )
   {
      if ( !B.bInitLifeMessage )
      {
         B.bInitLifeMessage = true;
         B.SendMessage(SquadLeader.PlayerReplicationInfo, 'GOTYOURBACK', 10);
      }
      if ( B.Enemy == None )
      {
         if ( B.FindInventoryGoal(0.0004) )
         {
            B.SetAttractionState();
            return true;
         }
         B.WanderOrCamp();
         return true;
      }
      else if ( (UTWeapon(B.Pawn.Weapon) != None) && UTWeapon(B.Pawn.Weapon).FocusOnLeader(false) )
      {
         B.FightEnemy(false,0);
         return true;
      }
      return false;
   }
   else if ( B.SetRouteToGoal(Leader) )
      return true;
   else
   {
      B.GoalString = "Can't reach leader";
      return false;
   }
}

function SetDefenseScriptFor(UTBot B)
{
   if (SquadObjective == none)
      return;
   else
      super.SetDefenseScriptFor(B);
}

DefaultProperties
{
   bShouldUseGatherPoints=False
   bAddTransientCosts=True
   MaxSquadSize=2
}

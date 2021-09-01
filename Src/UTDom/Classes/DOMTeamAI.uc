/**
 * strategic team AI control for Domination
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMTeamAI extends UTMT_TeamAI;

/** cached refference to the DominationFactory's. Need to be the DominationFactory because
the DominationObjective actors are not part of the Path network. */
var array<DominationFactory> DOMPoints;
var DominationObjective DomObjective;
var bool bFoundDomObjectives;
var float MaxTimeHeldByEnemy, MaxDistanceFromCP;

function SetObjectiveLists()
{
   local DominationFactory F;
   local int i;

   DOMPoints.Length = 0;
   foreach WorldInfo.AllNavigationPoints(class'DominationFactory', F)
   {
      if ( !F.IsDisabled() )
         DOMPoints.AddItem(F);
   }

   if (DOMPoints.Length > 0)
   {
      i = rand(DOMPoints.Length);
      Objectives = DOMPoints[i];
      DomObjective = DOMPoints[i].myControlPoint;
   }
   else
   {
      super.SetObjectiveLists();
   }
}

function ReAssessStrategy()
{
   local UTGameObjective O;
   local int PlusDiff, MinusDiff;
   local float HighestEnemyTeamScore;

   if (FreelanceSquad == None)
      return;

   HighestEnemyTeamScore = MaxEnemyTeamScore();
   // decide whether to play defensively or aggressively
   if (WorldInfo.GRI.RemainingTime < 0.25 * WorldInfo.Game.TimeLimit)
   {
      PlusDiff = 10;
      if (WorldInfo.GRI.RemainingTime < 0.1 * WorldInfo.Game.TimeLimit)
         MinusDiff = 0;
      else
         MinusDiff = 10;
   }

   FreelanceSquad.bFreelanceAttack = False;
   FreelanceSquad.bFreelanceDefend = False;
   if ( Team.Score > HighestEnemyTeamScore + PlusDiff )
   {
      FreelanceSquad.bFreelanceDefend = True;
      O = GetLeastDefendedObjective(FreelanceSquad.SquadLeader);
   }
   else if ( Team.Score < HighestEnemyTeamScore - MinusDiff )
   {
      FreelanceSquad.bFreelanceAttack = True;
      O = GetPriorityAttackObjectiveFor(FreelanceSquad, FreelanceSquad.SquadLeader);
   }
   else
      O = GetPriorityFreelanceObjectiveFor(FreelanceSquad);

   if ( (O != None) && (O != FreelanceSquad.SquadObjective) )
      FreelanceSquad.SetObjective(O,True);
}

/** 
 * prioritize the farthest ControlPoint because those tend to be the ones that no one goes to
 */
function UTGameObjective GetLeastDefendedObjective(Controller InController)
{
   local bool bCheckDistance;
   local float BestDistSq, NewDistSq;
   local UTGameObjective Best;
   local DominationFactory F;
   local int i;

   bCheckDistance = (InController != None) && (InController.Pawn != None);
   for (i=0; i<DomPoints.Length; i++)
   {
      F = DomPoints[i];
      if (F != none && F.myControlPoint != none)
      {
         if (F.myControlPoint.DefenderTeamIndex != Team.TeamIndex)
         {
            if ((Best == None) || (Best.DefensePriority < F.myControlPoint.DefensePriority))
            {
               Best = F;
               if (bCheckDistance)
                  BestDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
            }
            else if (Best.DefensePriority == F.DefensePriority )
            {
               if (bCheckDistance)
               {
                  NewDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
                  if (NewDistSq > BestDistSq)
                  {
                     Best = F;
                     BestDistSq = NewDistSq;
                  }
               }
            }
         }
      }
   }
   if (Best == None)
      Best = GetPriorityAttackObjectiveFor(None, InController); //nothing needs defending, so head to neutral node

   return Best;
}

/** 
 * checks if the DominationObjective's are held by the Enemy for too long
 */
function UTGameObjective IsHeldByEnemyTooLong()
{
   local int i;
   local float T, BestTime;
   local UTGameObjective Best;
   local DominationFactory F;

   if (DomPoints.Length == 0)
      return none;

   for (i=0; i<DomPoints.Length; i++)
   {
      F = DomPoints[i];
      if (F != none && F.myControlPoint != none)
      {
         if (F.myControlPoint.DefenderTeamIndex != Team.TeamIndex && (Best == none || F.myControlPoint.ControlledTime > BestTime))
         {
            BestTime = F.myControlPoint.ControlledTime;
            Best = F;
         }
      }
   }
   if (Best != none)
   {
      T = WorldInfo.TimeSeconds - BestTime;
      if (T >= MaxTimeHeldByEnemy)
         return Best;
   }

   return none;
}

function UTGameObjective GetPriorityAttackObjectiveFor(UTSquadAI InAttackSquad, Controller InController)
{
   local UTGameObjective Best;
   local bool bCheckDistance;
   local float BestDistSq, NewDistSq;
   local int i;

   bCheckDistance = (InController != None) && (InController.Pawn != None);
   if (bCheckDistance)
   {
      for (i=0; i<DomPoints.Length; i++)
      {
         if (DomPoints[i].myControlPoint.DefenderTeamIndex != Team.TeamIndex)
         {
            NewDistSq = VSizeSq(DomPoints[i].Location - InController.Pawn.Location);
            if (NewDistSq < MaxDistanceFromCP && !DomPoints[i].PoweredBy(Team.TeamIndex) && InController.Pawn.LineOfSightTo(DomPoints[i]))
               return DomPoints[i];

            if ( Best == none || NewDistSq < BestDistSq )
            {
               Best = DomPoints[i];
               BestDistSq = NewDistSq;
            }
         }
      }
   }
   else
   {
      Best  = IsHeldByEnemyTooLong();
      if (Best == none)
      {
         for (i=0; i<DomPoints.Length; i++)
         {
            if (DomPoints[i].DefenderTeamIndex != Team.TeamIndex)
            {
               Best = DomPoints[i];
               if (Rand(2) == 1)
                  break;
            }
         }
      }
   }

   if (Best != none)
   {
      PickedObjective = Best;
      return PickedObjective;
   }
   else
      return none;
}

function UTGameObjective GetPriorityFreelanceObjectiveFor(UTSquadAI InFreelanceSquad)
{
   if (InFreelanceSquad != None)
      InFreelanceSquad.bFreelanceAttack = True;

   return GetPriorityAttackObjectiveFor(InFreelanceSquad, (InFreelanceSquad != None) ? InFreelanceSquad.SquadLeader : None);
}

function bool PutOnDefense(UTBot B)
{
   local UTGameObjective O;

   O = GetLeastDefendedObjective(B);
   if ( O != None )
   {
      //we need this because in Onslaught/Domination, unlike other gametypes, two defending squads (possibly from different teams!)
      //could be headed to the same objective
      if ( O.DefenseSquad == None || O.DefenseSquad.Team != Team )
      {
         O.DefenseSquad = AddSquadWithLeader(B, O);
         DOMSquadAI(O.DefenseSquad).bDefendingSquad = True;
      }
      else
         O.DefenseSquad.AddBot(B);
      return True;
   }
   return False;
}

/** 
 * returns true if the given objective is a SquadObjective for some other squad on this team than the passed in squad
 * 
 * @param O             the objective to test for
 * @param IgnoreSquad   squad to ignore (because we're calling this while evaluating changing its objective)
 * @return              whether the objective is sufficiently covered by another squad
 */
function bool ObjectiveCoveredByAnotherSquad(UTGameObjective O, UTSquadAI IgnoreSquad)
{
   local UTSquadAI S;

   for (S = Squads; S != None; S = S.NextSquad)
   {
      if (S.SquadObjective == O && S != IgnoreSquad && S.Size >= 1 )
         return True;
   }

   return False;
}

function UTGameObjective FindControlPointNotOwned(UTSquadAI InSquad)
{
   local int i;
   local UTGameObjective UTgo;

   for (i=0; i<DomPoints.Length; i++)
   {
      if (DomPoints[i].DefenderTeamIndex == 255 || DomPoints[i].DefenderTeamIndex != InSquad.Team.TeamIndex)
      {
         UTgo = DomPoints[i];
         break;
      }
   }
   if (UTgo != none)
      return UTgo;

   return None;
}

DefaultProperties
{
   SquadType=Class'UTDom.DOMSquadAI'
   MaxTimeHeldByEnemy=20.0
   MaxDistanceFromCP=2000.0
   OrderList(0)=ATTACK
   OrderList(1)=FREELANCE
   OrderList(2)=ATTACK
   OrderList(3)=ATTACK
   OrderList(4)=FREELANCE
   OrderList(5)=DEFEND
   OrderList(6)=ATTACK
   OrderList(7)=FREELANCE
}

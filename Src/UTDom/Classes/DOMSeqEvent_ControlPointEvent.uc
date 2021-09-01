/**
 * Control Point Kismet Event
 * Triggered when there is a new ControllingTeam
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2008-2010 All Rights Reserved.
 */
class DOMSeqEvent_ControlPointEvent extends SequenceEvent;

/** The current Controlling Team Index Red=0 Blue=1 Green=2 Gold=3 */
var int TeamNum;
/** The current Controlling Teams score */
var int TeamScore;

/** attempts to activate the event with the appropriate output for the given event type and instigator */
function Trigger(name EventType, Controller EventInstigator)
{
   local array<int> ActivateIndices;
   local int i;
   local UTGameReplicationInfo GRI;
   local SeqVar_Int IntVar, IntVarScore;
   local DominationFactory DF;

   for (i = 0; i < OutputLinks.length; i++)
   {
      if (EventType == name(OutputLinks[i].LinkDesc))
      {
         ActivateIndices[ActivateIndices.length] = i;
      }
   }
   
   if (Originator == none || DominationFactory(Originator) == none)
   {
      `Warn("No DominationFactory connected to" @ self);
      return;
   }

   DF = DominationFactory(Originator);
   if (DF != None)
   {
      if (ActivateIndices.length == 0)
      {
         ScriptLog("Not activating" @ self @ "for event" @ EventType @ "because there are no matching outputs");
      }
      else if (CheckActivate(Originator, EventInstigator, false, ActivateIndices))
      {
         TeamNum = DF.GetTeamNum();
         if (TeamNum > 3)
            TeamNum = 4;

         if (TeamNum < 4)
         {
            GRI = UTGameReplicationInfo(GetWorldInfo().GRI);
            if (GRI != none && GRI.Teams[TeamNum] != none)
            {
               TeamScore = GRI.Teams[TeamNum].Score;
            }
         }

         foreach LinkedVariables(class'SeqVar_Int', IntVar, "Team Number")
         {
            IntVar.IntValue = TeamNum;
         }
         foreach LinkedVariables(class'SeqVar_Int', IntVarScore, "Score")
         {
            IntVarScore.IntValue = TeamScore;
         }
      }
   }
`if(`isdefined(DEBUG))
   if (EventInstigator != none)
      `log("******************* TeamScore="@TeamScore@" / TeamNum="@TeamNum@" / EventInstigator="@EventInstigator.GetHumanReadableName()@" / ControlPoint="@DF.GetHumanReadableName(),,self.Name);
   else if (DF.myControlPoint.HolderPRI != none)
      `log("******************* TeamScore="@TeamScore@" / TeamNum="@TeamNum@" / EventInstigator="@DF.myControlPoint.HolderPRI.GetCallSign()@" / ControlPoint="@DF.GetHumanReadableName(),,self.Name);
   else
      `log("******************* TeamScore="@TeamScore@" / TeamNum="@TeamNum@" / EventInstigator=None / ControlPoint="@DF.GetHumanReadableName(),,self.Name);
`endif
}

defaultproperties
{
   ObjName="Control Point Event"
   ObjCategory="Objective"
   bPlayerOnly=false
   MaxTriggerCount=0
   ObjClassVersion=7
   OutputLinks[0]=(LinkDesc="Red")
   OutputLinks[1]=(LinkDesc="Blue")
   OutputLinks[2]=(LinkDesc="Green")
   OutputLinks[3]=(LinkDesc="Gold")
   OutputLinks[4]=(LinkDesc="Neutral")
   OutputLinks[5]=(LinkDesc="Disabled")
   VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Team Number",PropertyName=TeamNum,MaxVars=1,bWriteable=true)
   VariableLinks(2)=(ExpectedType=class'SeqVar_Int',LinkDesc="Score",PropertyName=TeamScore,MaxVars=1,bWriteable=true)
}

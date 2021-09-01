/**
 * Kismet event that returns the GoalScore and TimeLimit for the match.
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2009-2010 All Rights Reserved.
 */
class DOMSeqEvent_GetMatchSettings extends SequenceEvent;

/** The TimeLimit for the match */
var int TimeLimit;
/** The ammount of points needed to win the match */
var int GoalScore;

event Activated()
{
   local WorldInfo WI;
   local UTGameReplicationInfo GRI;

   WI = GetWorldInfo();
   if ( WI != none )
   {
      GRI = UTGameReplicationInfo(WI.GRI);
      if ( GRI != none )
      {
         TimeLimit = GRI.TimeLimit;
         GoalScore = GRI.GoalScore;
      }
   }
}

defaultproperties
{
   ObjName="Get Match Settings"
   ObjCategory="UTDom Events"
   MaxTriggerCount=1
   bPlayerOnly=false
   VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Goal Score",bWriteable=true,PropertyName=GoalScore)
   VariableLinks(2)=(ExpectedType=class'SeqVar_Int',LinkDesc="Time Limit",bWriteable=true,PropertyName=TimeLimit)
}

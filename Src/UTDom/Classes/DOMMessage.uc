/**
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
Class DOMMessage extends UTLocalMessage;

var(Message) localized String ControlPointStr;
var(Message) localized String ControlledByTeam[4];

static function color GetColor(
                               optional int Switch,
                               optional PlayerReplicationInfo RelatedPRI_1,
                               optional PlayerReplicationInfo RelatedPRI_2,
                               optional Object OptionalObject
                               )
{
   return class'UTTeamInfo'.Default.BaseTeamColor[Switch];
}

// <summary>
// We use the switch to pass in the TeamIndex
// </summary>
// <param name="Switch" type="int">TeamIndex</param>
// <param name="RelatedPRI_1"></param>
// <param name="RelatedPRI_2"></param>
// <param name="OptionalObject"></param>
// <returns>localized string message to display what team is the current controller of what control point.</returns>
static function string GetString(
                                 optional int Switch,
                                 optional bool bPRI1HUD,
                                 optional PlayerReplicationInfo RelatedPRI_1,
                                 optional PlayerReplicationInfo RelatedPRI_2,
                                 optional Object OptionalObject
                                 )
{
   local string txt;

   txt = Default.ControlPointStr@"["$ControlPoint(OptionalObject).GetHumanReadableName()$"]"@Default.ControlledByTeam[Switch];
   return txt;
}

defaultproperties
{
   Lifetime=2
   MessageArea=0
   bIsUnique=True
   bIsConsoleMessage=False
   DrawColor=(B=255,G=255,R=255,A=255)
   FontSize=1
}

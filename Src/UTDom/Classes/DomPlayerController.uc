/**
 * Used to save the players preffered team for use with the TeamPicker (UIDomPlayerConfigScene)
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2010 All Rights Reserved.
 */
class DomPlayerController extends UTMT_PlayerController
   config(Dom);
`include(UTDom.uci)

var config byte SavedTeamID;
var config bool bHasSavedTeam;

/**
 * returns the players bHasSavedTeam value
 */
reliable client function bool HasSavedTeam()
{
   return bHasSavedTeam;
}

/**
 * validates the input for a value between 0-3
 * otherwise default to 0
 * 
 * @param   MyTeamID    The value to validate
 * @param   MaxTeams    The number of teams in the current game
 */
static function byte IsValidDOMTeamID(byte MyTeamID, byte MaxTeams)
{
   if (MyTeamID > MaxTeams)
      return 0;

   return MyTeamID;
}

/**
 * Returns a valid SavedTeamID value
 * 
 * @param   MaxTeamID    The highest TeamID in the current game.Expecting a number between 1 and 3.
 */
reliable client function byte GetSavedTeamID(byte MaxTeamID)
{
   local byte T, M;
   
   M = Clamp(MaxTeamID-1, 1, 3);
   T = Clamp(SavedTeamID, 0, M);
   return T;
}

/**
 * Saves a valid SavedTeamID value
 * 
 * @param   NewSavedTeamID    The highest TeamID in the current game.Expecting a number between 1 and 3.
 */
reliable client function SetSavedTeamID(byte NewSavedTeamID)
{
   SavedTeamID = Clamp(NewSavedTeamID, 0, 3);
   SaveConfig();
}

defaultproperties
{
   SavedTeamID=0
`if(`isdefined(PLATFORM_PS3))
   bHasSavedTeam=False
`else
   bHasSavedTeam=True
`endif
}

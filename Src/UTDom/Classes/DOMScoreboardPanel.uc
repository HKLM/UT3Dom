/**
 * New Scoreboard needed to correct changes made by the official UT3 patch 2.0 made
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMScoreboardPanel extends UTMT_TDMScoreboardPanel;

event PostInitialize()
{
   local UTPlayerController PC;
   local EFeaturePrivilegeLevel Level;

   super(UTDrawPanel).PostInitialize();
   SizeFonts();

   UTHudSceneOwner = UTUIScene_Hud( GetScene() );
   NotifyResolutionChanged = OnNotifyResolutionChanged;

   if (bInteractive)
   {
      OnRawInputKey=None;
      OnProcessInputKey=ProcessInputKey;
   }

   // Set the localized header strings.
   SetHeaderStrings();

   PC = UTHudSceneOwner.GetUTPlayerOwner();
   if (PC != none )
   {
      Level = PC.OnlineSub.PlayerInterface.CanCommunicate( LocalPlayer(PC.Player).ControllerId );
      bCensor = Level != FPL_Enabled;
   }

   HighlightPad = 3.0f;
   PlayerNamePad = 1.0f;
   PRIListSize = 0;
}

/** 
 * Sets the header strings using localized values 
 */
function SetHeaderStrings()
{
   HeaderTitle_Name = Localize( "Scoreboards", "Name", "UTGameUI" );
   HeaderTitle_Score = Localize( "Scoreboards", "Score", "UTGameUI" );
}

defaultproperties
{
   HUDClass=class'UTDom.DOMHUD'
}
/**
 * UI scene used to configure/change the players team.
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2010 All Rights Reserved.
 */
class UIDomPlayerConfigScene extends UTUIFrontEnd_CustomScreen;

var transient UTSimpleList Team;
var transient UIImage BackgroundImg[4];
var int OldListIndex;

event PostInitialize()
{
   local WorldInfo WI;
   local UTGameReplicationInfo GRI;
   local DomPlayerController UTPC;
   local int i, v, x, y;
   local array<int> PlayerCount;
   local string strItem;

   super.PostInitialize();

   WI = GetWorldInfo();
   if (WI == none)
   {
      return;
   }

   i = WI.GRI.Teams.Length;

   UTPC = DomPlayerController(GetUTPlayerOwner());
   if (UTPC != None)
   {
      // if has a saved TeamID, use it
      if ( UTPC.bHasSavedTeam )
      {
         OldListIndex = UTPC.GetSavedTeamID(i);
      }
      else
      {
         OldListIndex = Clamp(UTPC.GetTeamNum(), 0, i);
      }
   }

   if (WI.NetMode != NM_StandALone)
   {
      GRI = UTGameReplicationInfo(WI.GRI);
      if (GRI == none)
      {
         return;
      }
      PlayerCount.Length = i;
      for (x=0; x<GRI.PRIArray.Length; x++)
      {
         // only count active human players
         if (!GRI.PRIArray[x].bOnlySpectator && !GRI.PRIArray[x].bBot)
            PlayerCount[GRI.PRIArray[x].GetTeamNum()]++;
      }
   }

   BackgroundImg[0] = UIImage(FindChild('BG_Dom', True));
   if (BackgroundImg[0] != None)
   {
      BackgroundImg[1] = UIImage(FindChild('BG_Dom1', True));
      BackgroundImg[2] = UIImage(FindChild('BG_Dom2', True));
      BackgroundImg[3] = UIImage(FindChild('BG_Dom3', True));
      for (v=0; v<4; v++)
      {
         if (BackgroundImg[v] != none)
            BackgroundImg[v].SetVisibility(False);
      }
   }

   Team = UTSimpleList(FindChild('slstTeams', True));
   Team.NotifyActiveStateChanged = OnNotifyActiveStateChanged;   
   Team.OnItemChosen = OnTeamItemChosen;
   if ( Team != None )
   {
      for (y=0; y<i; y++)
      {
         if (WI.NetMode == NM_StandALone)
            strItem = Localize("UIConfig", "Team"$string(y), "UTDom");
         else
            strItem = Localize("UIConfig", "Team"$string(y), "UTDom")@"["$string(PlayerCount[y])$"]";

         Team.AddItem(strItem,y);
         if (y == OldListIndex && BackgroundImg[y] != none)
            BackgroundImg[y].SetVisibility(True);      
      }

      Team.SelectItem(OldListIndex);
   }
}

/** 
 * Sets the title for this scene.
 */
function SetTitle()
{
   local string FinalStr;
   local UILabel TitleLabel;

   TitleLabel = GetTitleLabel();
   if ( TitleLabel != None )
   {
      if(TabControl == None)
      {
         FinalStr = Caps(Localize("Titles", string(SceneTag), "UTDom"));
         TitleLabel.SetDataStoreBinding(FinalStr);
      }
      else
      {
         TitleLabel.SetDataStoreBinding("");
      }
   }
}

/**
 * Sets up the scene's button bar.
 */
function SetupButtonBar()
{
   ButtonBar.Clear();
   ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Cancel>", OnButtonBar_Back);
   ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Accept>", OnButtonBar_Accept);
}

/**
 * Dynamicly change the background image to match the selected team
 */
function OnTeamItemChosen(UTSimpleList SourceList, int SelectedIndex, int PlayerIndex)
{
   local int i;

   for (i=0; i<4; i++)
   {
      if (BackgroundImg[i] != None)
         BackgroundImg[i].SetVisibility(False);
   }

   if (BackgroundImg[SelectedIndex] != None)
      BackgroundImg[SelectedIndex].SetVisibility(True);
}

/**
 * commit the team change
 */
function OnAccept()
{
   local DomPlayerController UTPC;

   UTPC = DomPlayerController(GetUTPlayerOwner());
   if (UTPC != None)
   {
      if (UTPC.SavedTeamID != Team.Selection)
         UTPC.SetSavedTeamID(Team.Selection);
      
      if (GetPRIOwner().GetTeamNum() != Team.Selection)
         UTPC.DoChangeTeam(Team.Selection);
   }

   CloseScene(self);
}

/**
 * do Not save changes, use SavedTeamID if saved then close the scene
 */
function OnBack()
{
   CloseScene(self);
}

// ButtonBar callbacks

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
   OnBack();
   return True;
}

function bool OnButtonBar_Accept(UIScreenObject InButton, int PlayerIndex)
{
   OnAccept();
   return true;
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param   EventParms  information about the input event.
 *
 * @return  TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
   local bool bResult;

   bResult = False;
   if (EventParms.EventType == IE_Released)
   {
      if (EventParms.InputKeyName == 'XboxTypeS_B' || EventParms.InputKeyName == 'Escape')
      {
         OnBack();
         bResult = True;
      }
   }

   return bResult;
}

defaultproperties
{
   DescriptionMap.Add((WidgetTag="slstTeams",DataStoreMarkup="<Strings:UTDom.UIConfig.ChangeTeamsDesc>"));
}

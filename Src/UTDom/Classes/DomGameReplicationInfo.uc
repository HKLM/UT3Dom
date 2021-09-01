/**
 * Needed to correctly setup the midgamemenu for the corresponding # of teams 
 * (allways use the 2 team midgamemenu if this is the PS3 build)
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2009-2010 All Rights Reserved.
 */
class DomGameReplicationInfo extends UTMT_GameReplicationInfo;

/** Replicated value of UTDomGame.bShowPickTeamAtLogin */
var bool bPickTeamAtLogin;
var UIScene TeamPickerTemplate;
var name MidGameMenuTag[4];

replication
{
   if (bNetInitial || bNetDirty)
      bPickTeamAtLogin;
}

/**
 * Use the 'DomMidGameMenu' instead
 */
simulated function PostBeginPlay()
{
   local UTPowerupPickupFactory Powerup;
   local Sequence GameSequence;
   local array<SequenceObject> AllFactoryActions;
   local SeqAct_ActorFactory FactoryAction;
   local UTActorFactoryPickup Factory;
   local int i, T;
   local UTGameUISceneClient SC;

   if ( WorldInfo.IsConsoleBuild() )
      Super.PostBeginPlay();
   else
   {
      Super(GameReplicationInfo).PostBeginPlay();
      if (WorldInfo.NetMode != NM_DedicatedServer)
      {
         SetTimer(1.0, false, 'StartProcessingCharacterData');
      }

      // using DynamicActors here so the overlays don't break if the LD didn't build paths
      foreach DynamicActors(class'UTPowerupPickupFactory', Powerup)
      {
         Powerup.AddWeaponOverlay(self);
      }

      // also check if any Kismet actor factories spawn powerups
      GameSequence = WorldInfo.GetGameSequence();
      if (GameSequence != None)
      {
         GameSequence.FindSeqObjectsByClass(class'SeqAct_ActorFactory', true, AllFactoryActions);
         for (i = 0; i < AllFactoryActions.length; i++)
         {
            FactoryAction = SeqAct_ActorFactory(AllFactoryActions[i]);
            Factory = UTActorFactoryPickup(FactoryAction.Factory);
            if (Factory != None && ClassIsChildOf(Factory.InventoryClass, class'UTInventory'))
            {
               class<UTInventory>(Factory.InventoryClass).static.AddWeaponOverlay(self);
            }
         }
      }

      // Look for a mid game menu and if it's there fix it up
      SC = UTGameUISceneClient(class'UIRoot'.static.GetSceneClient());
      if (SC != none )
      {
         T = Teams.Length;

         if ( MidGameMenuTag[T] != '' )
            CurrentMidGameMenu = UTUIScene_MidGameMenu(SC.FindSceneByTag(MidGameMenuTag[T]));
         else
            CurrentMidGameMenu = UTUIScene_MidGameMenu(SC.FindSceneByTag(MidGameMenuTag[1]));

         if ( CurrentMidGameMenu != none )
            CurrentMidGameMenu.Reset();
      }
   }
}

/**
 * Open the mid-game menu unless if the TabTag='LoginPickTeam', then open the UIDomPlayerConfigScene instead.
 * 
 * @note using the TabTag='LoginPickTeam' should only be done once at the players login
 */
simulated function UTUIScene_MidGameMenu ShowMidGameMenu(UTPlayerController InstigatorPC, optional name TabTag,optional bool bEnableInput)
{
   local UIScene Scene;
   local UTUIScene Template;
   local class<UTDomGame> UTDomGameClass;

   if ( WorldInfo.IsConsoleBuild() )
   {
      return super.ShowMidGameMenu(InstigatorPC,TabTag,bEnableInput);
   }
   else
   {
      if (TabTag == '')
      {
         if (LastUsedMidgameTab != '')
         {
            TabTag = LastUsedMidGameTab;
         }
      }

      if ( CurrentMidGameMenu != none )
      {
         if ( TabTag != '' && TabTag != 'ChatTab' )
         {
   //       CurrentMidGameMenu.ActivateTab(TabTag);
         }
         return CurrentMidGameMenu;
      }

      if ( ScoreboardScene != none )   // Force the scoreboards to close
      {
         ShowScores(false, none, none );
      }

      UTDomGameClass = class<UTDomGame>(GameClass);
      if (UTDomGameClass == none)
      {
         LogInternal("UTDomGameClass is none!!",'DomGameReplicationInfo');
         return None;
      }

      if ( UTDomGameClass.Default.MidGameMenuTemplates[Teams.Length-2] != none )
         Template = UTDomGameClass.Default.MidGameMenuTemplates[Teams.Length-2];
      else
         Template = UTDomGameClass.Default.MidGameMenuTemplate;

      if ( Template != none )
      {
         Scene = OpenUIScene(InstigatorPC,Template);
         if ( Scene != none )
         {
            CurrentMidGameMenu = UTUIScene_MidGameMenu(Scene);
            ToggleViewingMap(true);

            if (bMatchIsOver)
            {
               CurrentMidGameMenu.TabControl.RemoveTabByTag('SettingsTab');
            }

            if ( TabTag != '' )
            {
               CurrentMidGameMenu.ActivateTab(TabTag);
            }
         }
         else
         {
            `log("ERROR - Could not open the mid-game menu:"@Template);
         }
      }

      if ( CurrentMidGameMenu != none && bEnableInput)
      {
         CurrentMidGameMenu.SetSceneInputMode(INPUTMODE_Free);
      }

      if (TabTag == 'LoginPickTeam')
      {
         ClientOpenUIScene(InstigatorPC, TeamPickerTemplate);
         if ( DomPRI(InstigatorPC.PlayerReplicationInfo) != none)
            DomPRI(InstigatorPC.PlayerReplicationInfo).bTeamPickerMenuDone = true;
      }

      return CurrentMidGameMenu;
   }
}

/** 
 * wrapper for opening UI scenes on the clienbt
 * 
 * @param InstigatorPC - player to open it for
 * @param Template - the scene to open
 */
reliable client function UIScene ClientOpenUIScene(UTPlayerController InstigatorPC, UIScene Template)
{
   local UIInteraction UIController;
   local LocalPlayer LP;
   local UIScene s;

   LP = LocalPlayer(InstigatorPC.Player);
   UIController = LP.ViewportClient.UIController;
   if ( UIController != none )
   {
      UIController.OpenScene(Template,LP,s);
   }

   return S;
}

defaultproperties
{
   TeamPickerTemplate=UTUIScene'UI_UT3Dom.DomTeamConfig'
   MidGameMenuTag(0)=DomMidGameMenu2
   MidGameMenuTag(1)=DomMidGameMenu2
   MidGameMenuTag(2)=DomMidGameMenu3
   MidGameMenuTag(3)=DomMidGameMenu
}
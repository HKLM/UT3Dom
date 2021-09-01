/**
 * UI scene used to configure Double Domination.
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2009-2010 All Rights Reserved.
 */
class UIDoubleDomConfigScene extends UTUIFrontEnd_CustomScreen;

var transient UTUISlider NumOfTeams;
var transient UICheckbox VehiclesCanCapturePoints;
var transient UTSimpleList Inventory;
var transient UTUISlider TimeToScore;
var transient UTUISlider TimeDisabled;
var transient UICheckbox UseAltMultiTeamTimeToScore;
var transient UICheckbox ShowTeamPicker;
var class<xDoubleDom> DomGameClass;
/** temp stores the current values before the scene is closed, and only upon clicking the
   accept button, will the values be saved */
var bool bUnlimitedTranslocator, bUseHoverboard, bUseTranslocator;
/** marker to determin if the selectedItem of the list has changed */
var int OldListIndex;

event PostInitialize()
{
   super.PostInitialize();

   VehiclesCanCapturePoints = UICheckbox(FindChild('chkVehiclesCanCapturePoints', True));
   VehiclesCanCapturePoints.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   VehiclesCanCapturePoints.SetValue(DomGameClass.Default.bVehiclesCanCapturePoints);

   ShowTeamPicker = UICheckbox(FindChild('chkShowTeamPicker', True));
   ShowTeamPicker.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   ShowTeamPicker.SetValue(DomGameClass.Default.bShowPickTeamAtLogin);

   NumOfTeams = UTUISlider(FindChild('sliNumTeams', True));
   NumOfTeams.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   NumOfTeams.SliderValue.MinValue = 2.f;
   NumOfTeams.SliderValue.MaxValue = 4.f;
   NumOfTeams.SliderValue.NudgeValue = 1.f;
   NumOfTeams.SliderValue.bIntRange = True;
   NumOfTeams.SliderValue.CurrentValue = DomGameClass.Default.NumOfTeams;
   NumOfTeams.UpdateCaption();

   Inventory = UTSimpleList(FindChild('slstPlayerInv', True));
   Inventory.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   Inventory.OnItemChosen = SaveInventory;
   // Determine what item to be the Default selectedItem
   if ( Inventory != None )
   {
      bUnlimitedTranslocator = DomGameClass.Default.bUnlimitedTranslocator;
      bUseHoverboard = DomGameClass.Default.bUseHoverboard;
      bUseTranslocator = DomGameClass.Default.bUseTranslocator;

      /**
       * bUseHoverboard allways overrides the trans
       * bUnlimitedTranslocator can only work if bUseTranslocator is also true
       * !bUseTranslocator && !bUseHoverboard will allways disable the unlimited/normal trans and hoverboards
       */
      if ( bUseHoverboard )
      {
         OldListIndex = 3;
         Inventory.SelectItem(3);
      }
      else if ( !bUseTranslocator && !bUseHoverboard )
      {
         OldListIndex = 0;
         Inventory.SelectItem(0);
      }
      else if ( bUseTranslocator && bUnlimitedTranslocator && !bUseHoverboard )
      {
         OldListIndex = 1;
         Inventory.SelectItem(1);
      }
      else if ( bUseTranslocator && !bUnlimitedTranslocator && !bUseHoverboard )
      {
         OldListIndex = 2;
         Inventory.SelectItem(2);
      }
      else
      {
         Inventory.SelectItem(1);
      }
   }

   UseAltMultiTeamTimeToScore = UICheckbox(FindChild('chkUseAltMultiTeamTimeToScore', True));
   UseAltMultiTeamTimeToScore.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   UseAltMultiTeamTimeToScore.SetValue(DomGameClass.Default.bUseAltMultiTeamTimeToScore);

   TimeToScore = UTUISlider(FindChild('sliTimeToScore', True));
   TimeToScore.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   TimeToScore.SliderValue.MinValue = 1.f;
   TimeToScore.SliderValue.MaxValue = DomGameClass.Default.MaxTimeToScore;
   TimeToScore.SliderValue.NudgeValue = 1.f;
   TimeToScore.SliderValue.bIntRange = True;
   TimeToScore.SliderValue.CurrentValue = DomGameClass.Default.TimeToScore;
   TimeToScore.UpdateCaption();

   TimeDisabled = UTUISlider(FindChild('sliTimeDisabled', True));
   TimeDisabled.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
   TimeDisabled.SliderValue.MinValue = 1.f;
   TimeDisabled.SliderValue.MaxValue = DomGameClass.Default.MaxTimeDisabled;
   TimeDisabled.SliderValue.NudgeValue = 1.f;
   TimeDisabled.SliderValue.bIntRange = True;
   TimeDisabled.SliderValue.CurrentValue = DomGameClass.Default.TimeDisabled;
   TimeDisabled.UpdateCaption();
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
 * Converts the selected UTSimpleList item to something that can be used
 */
function SaveInventory(UTSimpleList SourceList, int SelectedIndex, int PlayerIndex)
{
   if (OldListIndex != SelectedIndex)
   {
      switch(SelectedIndex)
      {
      case 0:
         bUnlimitedTranslocator = False;
         bUseTranslocator = False;
         bUseHoverboard = False;
         break;
      case 1:
         bUnlimitedTranslocator = True;
         bUseTranslocator = True;
         bUseHoverboard = False;
         break;
      case 2:
         bUnlimitedTranslocator = False;
         bUseTranslocator = True;
         bUseHoverboard = False;
         break;
      case 3:
         bUnlimitedTranslocator = False;
         bUseTranslocator = False;
         bUseHoverboard = True;
         break;
      Default:
         break;
      }

      OldListIndex = SelectedIndex;
   }
}

/**
 * Saves changes
 */
function OnAccept()
{
   if (DomGameClass != none)
   {
      DomGameClass.Default.NumOfTeams = NumOfTeams.GetValue();
      DomGameClass.Default.bVehiclesCanCapturePoints = VehiclesCanCapturePoints.IsChecked();
      DomGameClass.Default.bUnlimitedTranslocator = bUnlimitedTranslocator;
      DomGameClass.Default.bUseTranslocator = bUseTranslocator;
      DomGameClass.Default.bUseHoverboard = bUseHoverboard;
      DomGameClass.Default.TimeToScore = TimeToScore.GetValue();
      DomGameClass.Default.TimeDisabled = TimeDisabled.GetValue();
      DomGameClass.Default.bUseAltMultiTeamTimeToScore = UseAltMultiTeamTimeToScore.IsChecked();
      DomGameClass.Default.bShowPickTeamAtLogin = ShowTeamPicker.IsChecked();

      DomGameClass.static.StaticSaveConfig();
   }

   CloseScene(self);
}

/** 
 * do Not save changes, just close the scene
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
   DomGameClass=class'DoubleDom'
   DescriptionMap.Add((WidgetTag="chkVehiclesCanCapturePoints",DataStoreMarkup="<Strings:UTDom.UIConfig.VehiclesCanCaptureDesc>"));
   DescriptionMap.Add((WidgetTag="sliNumTeams",DataStoreMarkup="<Strings:UTDom.UIConfig.NumTeamsDesc>"));
   DescriptionMap.Add((WidgetTag="slstPlayerInv",DataStoreMarkup="<Strings:UTDom.UIConfig.InventoryDesc>"));
   DescriptionMap.Add((WidgetTag="chkUseAltMultiTeamTimeToScore",DataStoreMarkup="<Strings:UTDom.UIConfig.AltMultiTeamTimeToScoreDesc>"));
   DescriptionMap.Add((WidgetTag="sliTimeToScore",DataStoreMarkup="<Strings:UTDom.UIConfig.TimeToScoreDesc>"));
   DescriptionMap.Add((WidgetTag="sliTimeDisabled",DataStoreMarkup="<Strings:UTDom.UIConfig.TimeDisabledDesc>"));
   DescriptionMap.Add((WidgetTag="chkShowTeamPicker",DataStoreMarkup="<Strings:UTDom.UIConfig.TeamPickerDesc>"));
}

/**
 * Based off the class UTMultiTeam.UTMT_PlayerReplicationInfo
 * Some parts was changed to make DOM compatible with the Titan mutator
 * 
 * Copyright 2007, Infinity Impossible
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2009-2010 All Rights Reserved.
 */
class DomPRI extends UTHeroPRI;

// 0=Red, 1=Blue, 2=Green, 3=Gold
var MaterialInstanceConstant  TeamHeadMIC[4];
var MaterialInstanceConstant  TeamBodyMIC[4];
var transient bool bTeamPickerMenuDone;

/**
 * validates the input for a value between 0-3
 * otherwise default to 0
 */
static function byte IsValidDOMTeamID(byte MyTeamID)
{
   if (MyTeamID > 3)
      return 0;

   return MyTeamID;
}

simulated function SetOtherTeamSkin(SkeletalMesh NewSkelMesh)
{
   local int i;

   if ( WorldInfo.IsConsoleBuild() )
   {
      super.SetOtherTeamSkin(NewSkelMesh);
   }
   else
   {
      if (Team != None && NewSkelMesh != None)
      {
         i = IsValidDOMTeamID( GetTeamNum() );
         TeamHeadMIC[i] = MaterialInstanceConstant(NewSkelMesh.Materials[0]);
         TeamBodyMIC[i] = MaterialInstanceConstant(NewSkelMesh.Materials[1]);
         `Log("SetOtherTeamSkin [DomPRI.PlayerName="@PlayerName@"] [TeamHeadMIC["@i@"]="@string(TeamHeadMIC[i])@"]");
         `Log("SetOtherTeamSkin [DomPRI.PlayerName="@PlayerName@"] [TeamBodyMIC["@i@"]="@string(TeamBodyMIC[i])@"]<<<<");
      }
   }
}

/**
 * For Gold and Green teams, we want them to appear with Lotus' shader, so give them a "blue" skin.
 */
simulated function string GetCustomCharTeamString()
{
   if (Team != None)
   {
      switch(Team.TeamIndex)
      {
      case 0:
         return "VRed";
      case 1:     // Blue
      default: // Any other team
         return "VBlue";
      }
   }

   return "V01";
}

/**
 * For Gold and Green teams, we want them to appear with Lotus' shader, so give them a "blue" skin.
 */
simulated function string GetCustomCharOtherTeamString()
{
   if (Team != None)
   {
      switch(Team.TeamIndex)
      {
      case 0:
         return "VBlue";
      case 1:     // Blue
      default: // Any other team
         return "VRed";
      }
   }

   return "V01";
}

/**
 * Changed logic to act on more than 2 teams. Prevents DemoDude from appearing.
 */
simulated function bool UpdateCustomTeamSkin()
{
   local Pawn P;

   if (Team != None && IsLocalPlayerPRI())
   {
      if (Team.TeamIndex < 5 && TeamHeadMIC[Team.TeamIndex] != None)
      {
         SetCharMeshMaterial(0, TeamHeadMIC[Team.TeamIndex]);
         SetCharMeshMaterial(1, TeamBodyMIC[Team.TeamIndex]);
      }
      else
         return FALSE;

      foreach WorldInfo.AllPawns(class'Pawn', P)
      {
         if (P.PlayerReplicationInfo == self || (P.DrivenVehicle != None && P.DrivenVehicle.PlayerReplicationInfo == self))
            P.NotifyTeamChanged();
      }

      CharacterMeshTeamNum = Team.TeamIndex;
      return TRUE;
   }

   return FALSE;
}

/** 
 * Accessor that sets the custom character mesh to use for this PRI, and updates instance of player in map if there is one. 
 */
simulated function SetCharacterMesh(SkeletalMesh NewSkelMesh, optional bool bIsReplacement)
{
   local Pawn P;
   local UTGameReplicationInfo GRI;
   local class<UTFamilyInfo> FamilyInfoClass;
   local byte T, i;

   if (CharacterMesh != NewSkelMesh)
   {
      CharacterMesh = NewSkelMesh;
      bIsFemale = FALSE;
      VoiceClass = default.VoiceClass;

      for (i=0; i < 4; i++)
      {
         TeamHeadMIC[i] = None;
         TeamBodyMIC[i] = None;
      }

      if (CharacterMesh == None)
      {
         if ( !bUsingReplacementCharacter )
         {
            GRI = UTGameReplicationInfo(WorldInfo.GRI);
            if (GRI != None)
               GRI.TotalPlayersSetToProcess--;
         }
      }
      else
      {
         T  = IsValidDOMTeamID( GetTeamNum() );
         TeamHeadMIC[T] = MaterialInstanceConstant(CharacterMesh.Materials[0]);
         TeamBodyMIC[T] = MaterialInstanceConstant(CharacterMesh.Materials[1]);

         // set sex and voice
         if ( CharacterData.FamilyID != "" && CharacterData.FamilyID != "NONE" )
         {
            // We have decent family, look in info class
            FamilyInfoClass = class'UTCustomChar_Data'.static.FindFamilyInfo(CharacterData.FamilyID);
            if (FamilyInfoClass != None)
            {
               bIsFemale = FamilyInfoClass.default.bIsFemale;
               VoiceClass = FamilyInfoClass.static.GetVoiceClass(CharacterData);
            }
         }
      }

      bUsingReplacementCharacter = bIsReplacement;

      // a little hacky, relies on presumption that enum vals 0-3 are male, 4-8 are female
      if (bIsFemale)
         TTSSpeaker = ETTSSpeaker(Rand(4));
      else
         TTSSpeaker = ETTSSpeaker(Rand(5) + 4);

      foreach WorldInfo.AllPawns(class'Pawn', P)
      {
         if (P.PlayerReplicationInfo == self || (P.DrivenVehicle != None && P.DrivenVehicle.PlayerReplicationInfo == self))
            P.NotifyTeamChanged();
      }
   }

   CharacterMeshTeamNum = IsValidDOMTeamID( GetTeamNum() );
}

/**
 * if UTDomGame.bShowPickTeamAtLogin is enabled, Opens the MidGameMenu with the Change Team Tab open by default
 */
simulated function bool AttemptMidGameMenu()
{
   local UTPlayerController PlayerOwner;
   local DomGameReplicationInfo GRI;

   if ( WorldInfo.IsConsoleBuild() )
   {
      return super.AttemptMidGameMenu();
   }
   else
   {
      PlayerOwner = UTPlayerController(Owner);
      if ( PlayerOwner != none )
      {
         GRI = DomGameReplicationInfo(WorldInfo.GRI);
         if (GRI != none)
         {
            if ( GRI.bPickTeamAtLogin && !bTeamPickerMenuDone)
            {
               GRI.ShowMidGameMenu(PlayerOwner,'LoginPickTeam',True);
            }
            else
            {
               GRI.ShowMidGameMenu(PlayerOwner,'ScoreTab',True);
            }

            if ( GRI.CurrentMidGameMenu != none )
               GRI.CurrentMidGameMenu.bInitial = True;

            ClearTimer('AttemptMidGameMenu');
            return True;
         }
      }

      return False;
   }
}
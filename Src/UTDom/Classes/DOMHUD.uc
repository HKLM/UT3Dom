/**
 * Domination HUD.
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DOMHUD extends UTMT_TeamHUD
   config(Dom);
`include(UTDom.uci)

struct EPointInfo
{
   var() vector2D Icon; // The cached location of where to draw this points icon at
   var() ControlPoint thePoint; // Cached refference to the ControlPoints
};
var() array<EPointInfo> Points;
var vector2D DomPosition;
var float TextY, TextX;
var bool bPowerUpAdjusted, bControlPointInitialized;
var const linearcolor TeamLinearColor[6];
var const Texture2D DomTeamIconTexture[5]; // The Control Point HUD icon textures
var config bool bShowDirectionalControlPoints;

simulated function PostBeginPlay()
{
   local Pawn P;
   local UTGameObjective O;
   local UTDeployableNodeLocker DNL;
   local UTOnslaughtNodeTeleporter NT;
   local int i;;

   Super(GameHUD).PostBeginPlay();
   SetTimer(1.0, true);

   UTPlayerOwner = UTPlayerController(PlayerOwner);

   // add actors to the PostRenderedActors array
   ForEach DynamicActors(class'Pawn', P)
   {
      if ( (UTPawn(P) != None) || (UTVehicle(P) != None) )
         AddPostRenderedActor(P);
   }

   foreach WorldInfo.AllNavigationPoints(class'UTGameObjective',O)
   {
      AddPostRenderedActor(O);
   }

   foreach WorldInfo.AllNavigationPoints(class'UTOnslaughtNodeTeleporter',NT)
   {
      AddPostRenderedActor(NT);
   }

   ForEach AllActors(class'UTDeployableNodeLocker',DNL)
   {
      AddPostRenderedActor(DNL);
   }

   if ( UTConsolePlayerController(PlayerOwner) != None )
   {
      bShowOnlyAvailableWeapons = true;
      bNoWeaponNumbers = true;
   }

   // Cache data that will be used a lot
   UTPlayerOwner = UTPlayerController(Owner);

   // Setup Damage indicators,etc.
   // Create the 3 Damage Constants
   DamageData.Length = MaxNoOfIndicators;

   for (i = 0; i < MaxNoOfIndicators; i++)
   {
      DamageData[i].FadeTime = 0.0f;
      DamageData[i].FadeValue = 0.0f;
      DamageData[i].MatConstant = new(self) class'MaterialInstanceConstant';
      if (DamageData[i].MatConstant != none && BaseMaterial != none)
      {
         DamageData[i].MatConstant.SetParent(BaseMaterial);
      }
   }

   // create hit effect material instance
   HitEffect = MaterialEffect(LocalPlayer(UTPlayerOwner.Player).PlayerPostProcess.FindPostProcessEffect('HitEffect'));
   if (HitEffect != None)
   {
      if (MaterialInstanceConstant(HitEffect.Material) != None && HitEffect.Material.GetPackageName() == 'Transient')
      {
         // the runtime material already exists; grab it
         HitEffectMaterialInstance = MaterialInstanceConstant(HitEffect.Material);
      }
      else
      {
         HitEffectMaterialInstance = new(HitEffect) class'MaterialInstanceConstant';
         HitEffectMaterialInstance.SetParent(HitEffect.Material);
         HitEffect.Material = HitEffectMaterialInstance;
      }
      HitEffect.bShowInGame = false;
   }

   // find the controller icons font
   ConsoleIconFont=Font(DynamicLoadObject(ConsoleIconFontClassName, class'font', true));
}

simulated event Timer()
{
   local int i;
   local bool bDoNext;

   Super.Timer();

   if ( PawnOwner == None )
      return;

   if ( !bControlPointInitialized )
   {
      bControlPointInitialized = true;
      FindControlPoints();
      for ( i=0; i<Points.Length; i++ )
      {
         if ( bDoNext )
            DomPosition.Y -= 0.08;
         else
         {
            bDoNext = True;
         }

         Points[i].Icon.Y = DomPosition.Y;
         Points[i].Icon.X = DomPosition.X;
      }
   }
}

simulated function FindControlPoints()
{
   local ControlPointFactory C;
   local EPointInfo NewPoint;

   bShowDirectional = bShowDirectionalControlPoints;
   foreach WorldInfo.AllNavigationPoints(class'ControlPointFactory',C)
   {
      if ( C.myControlPoint != none )
      {
         NewPoint.thePoint = C.myControlPoint;
         Points.AddItem(NewPoint);
      }
   }
}

/**
 * Display current messages
 *
 * Override to move the displayed text over to the right due to the engine not actualy using
 * the param ConsoleMessagePosX specified in this classes defaultproperties
 */
function DisplayConsoleMessages()
{
   local int Idx, XPos, YPos;
   local float XL, YL;

   if ( ConsoleMessages.Length == 0 )
      return;

   for (Idx = 0; Idx < ConsoleMessages.Length; Idx++)
   {
      if ( ConsoleMessages[Idx].Text == "" || ConsoleMessages[Idx].MessageLife < WorldInfo.TimeSeconds )
      {
         ConsoleMessages.Remove(Idx--,1);
      }
   }

   XPos = (0.05 * HudCanvasScale * Canvas.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeX);
   YPos = (ConsoleMessagePosY * HudCanvasScale * Canvas.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeY);
   Canvas.Font = class'Engine'.Static.GetSmallFont();
   Canvas.DrawColor = ConsoleColor;
   Canvas.TextSize ("A", XL, YL);
   YPos -= YL * ConsoleMessages.Length; // DP_LowerLeft
   YPos -= YL; // Room for typing prompt

   for (Idx = 0; Idx < ConsoleMessages.Length; Idx++)
   {
      if (ConsoleMessages[Idx].Text == "")
      {
         continue;
      }
      Canvas.StrLen( ConsoleMessages[Idx].Text, XL, YL );
      Canvas.SetPos( XPos, YPos );
      Canvas.DrawColor = ConsoleMessages[Idx].TextColor;
      Canvas.DrawText( ConsoleMessages[Idx].Text, false );
      YPos += YL;
   }
}

function DisplayScoring()
{
   Super.DisplayScoring();
   if ( !bIsSplitScreen || bIsFirstPlayer )
   {
      DisplayDomPoints();
   }
}

/** 
 * default method for Displaying the Dom Point Icons: Along the lower left side of the canvas,
 * and draws the icons each adding higher up then the last one.
 */
function DisplayDomPoints()
{
   local int i, n;
   local vector2D POS;
   local string work;

   if ( !bShowDirectionalControlPoints || Points.Length == 0)
      return;

   Canvas.DrawColor = WhiteColor;
   for ( i=0; i<Points.Length; i++ )
   {
      if (Points[i].thePoint != none && Points[i].thePoint.ControllingTeam != none)
         n = Points[i].thePoint.static.ValidateTeamIndex(Points[i].thePoint.ControllingTeam.TeamIndex);
      else
         n = 4;

      POS.X = Canvas.ClipX*(Points[i].Icon.X+0.02*ResolutionScale);
      POS.Y = Canvas.ClipY*(Points[i].Icon.Y+0.05*ResolutionScale);
      Canvas.SetPos(POS.X,POS.Y);
      DrawTileCentered(DomTeamIconTexture[n], 40*ResolutionScale, 40*ResolutionScale, 2, 2, 255, 255, TeamLinearColor[n]);
      DisplayControlPointIcons(i,POS, 1.0);

      if (Points[i].thePoint != none)
      {
         work = Points[i].thePoint.GetHumanReadableName();
         Canvas.Font = GetFontSizeIndex(0);
         Canvas.SetDrawColor(200,200,200,255);
         POS.Y += TextY * ResolutionScale;
         POS.X = TextX * ResolutionScale;
         Canvas.SetPos(POS.X,POS.Y);
         Canvas.DrawTextClipped(work);
      }
   }
}

/**
 * Overriding this so the two DirectionIndicator's in the center dont get displayed 
 */
function DisplayTeamLogos(byte TeamIndex, vector2d POS, optional float DestScale=1.0);

function DisplayControlPointIcons(byte ControlPointIndex, vector2d POS, optional float DestScale=1.0)
{
   if ( bShowDirectional )
   {
      DisplayDirectionIndicator(ControlPointIndex, POS, GetDirectionalDest(ControlPointIndex), DestScale );
   }
}

function Actor GetDirectionalDest(byte TeamIndex)
{
   if (Points[TeamIndex].thePoint != none)
   {
      return Points[TeamIndex].thePoint;
   }

   return none;
}

/** 
 * to support 4 teams 
 */
simulated function int GetTeamScore(byte TeamIndex)
{
   local byte i;

   if (TeamIndex > 3)
   {
      i = 4;
   }
   else
   {
      i = TeamIndex;
   }

   if( (i != 4) && (UTGRI != None) && (UTGRI.Teams[i] != None) )
   {
      return INT(UTGRI.Teams[i].Score);
   }

   return 0;
}

/** 
 * Adjust the Dom Icons if player has a timed PowerUp 
 */
function DisplayPowerups()
{
   local int i;

   super.DisplayPowerups();

   if ( bDisplayingPowerups && !bPowerUpAdjusted )
   {
      for ( i=0; i<Points.Length; i++ )
      {
         Points[i].Icon.Y -= 0.1;
      }

      bPowerUpAdjusted = True;
   }
   else if ( !bDisplayingPowerups && bPowerUpAdjusted )
   {
      for ( i=0; i<Points.Length; i++ )
      {
         Points[i].Icon.Y += 0.1;
      }

      bPowerUpAdjusted = False;
   }
}

static simulated function GetTeamColor(int TeamIndex, optional out LinearColor ImageColor, optional out color TextColor)
{
   if ( TeamIndex < 4 )
   {
      ImageColor = Default.TeamLinearColor[TeamIndex];
      TextColor = Default.LightGoldColor;
   }
   else
   {
      ImageColor = Default.TeamLinearColor[4];
      TextColor = Makecolor(192,192,192,192);
   }
}

DefaultProperties
{
`if(`isdefined(PLATFORM_PS3))
   ScoreboardSceneTemplates(0)=UTUIScene_TeamScoreboard'UI_Scenes_Scoreboards.sbTeamDM'
`else
   ScoreboardSceneTemplates(0)=UTUIScene_TeamScoreboard'UI_UT3Dom.sbTeamDM'
`endif
   ScoreboardSceneTemplates(1)=UTUIScene_TeamScoreboard'UI_UT3Dom.sbDOM3'
   ScoreboardSceneTemplates(2)=UTUIScene_TeamScoreboard'UI_UT3Dom.sbDOM4'
   DomTeamIconTexture(0)=Texture2D'DOM_Content.HUD.RedTeamSymbol'
   DomTeamIconTexture(1)=Texture2D'DOM_Content.HUD.BlueTeamSymbol'
   DomTeamIconTexture(2)=Texture2D'DOM_Content.HUD.GreenTeamSymbol'
   DomTeamIconTexture(3)=Texture2D'DOM_Content.HUD.GoldTeamSymbol'
   DomTeamIconTexture(4)=Texture2D'DOM_Content.HUD.NeutralSymbol'
   TeamLinearColor(0)=(R=3.0,G=0.0,B=0.05,A=0.8)
   TeamLinearColor(1)=(R=0.0,G=0.0,B=1.0,A=0.8)
   TeamLinearColor(2)=(R=0.0,G=1.0,B=0.0,A=0.8)
   TeamLinearColor(3)=(R=0.9,G=0.98,B=0.0,A=0.8)
   TeamLinearColor(4)=(R=0.5,G=0.5,B=0.5,A=0.8)
   bShowScoring=True
   bShowDirectional=True
   bShowDirectionalControlPoints=True
   bShowFragCount=False
   DomPosition=(X=0.016,Y=0.74)
   ConsoleMessagePosX=0.05
   TextY=16
   TextX=14
}

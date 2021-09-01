/**
 * @author Copyright 2007, Infinity Impossible
 * 
 * Skin code based upon Lotus's CustomUT skin shaders, code and shaders
 * used with permission.
 * 
 * @author Other parts Writen by Brian 'Snake' Alexander. Copyright(c) 2009-2010 All Rights Reserved.
 * 
 * Based from UTMultiTeam.UTMT_Pawn and UTMultiTeamContent.UTMT_Pawn_Content
 * This was needed to made DOM compatible with the Titan mutator.
 */
class DOMPawn extends UTHeroPawn;

/** The color to be used for the Hero's aura */
var array<vector> HeroAuraTeamColors;

struct ReplacementMaterial
{
   var string MaterialName;
   var MaterialInterface ReplacementMaterial;
};

/**
 * Replace these skins, if they are used on a model, with the correct
 * materials. This is used for replacing the Iron Guard first person
 * arm materials with instances of the root character material used by
 * all other character models.
 */
var array<ReplacementMaterial> SkinReplacementMaterials;

/**
 * If this is set, then the red and blue teams will not be transformed as per
 * the TeamInfo transform data (see UTMT_TeamInfo), but their original skins
 * will be used instead.
 */
var bool bUseOriginalRedAndBlueSkins;
var MaterialInterface ShieldBeltMultiTeamMaterial;
var array< class<Actor> >  MultiTransInEffects;
var array< class<Actor> >  MultiTransOutEffects;
var array<LinearColor>  MultiTranslocateColor;
var class<UTCustomChar_Data> CustomCharClass;
var class<DamageType> ChangeTeamDamageClass;

/**
 * @return True if we are allowed to perform reskinning using shaders, i.e.
 *       we are not using the original red and blue skins.
 */
simulated function bool ReSkinningAllowed()
{
   local bool bOnRedOrBlue;

   bOnRedOrBlue = (GetTeamNum() == 0 || GetTeamNum() == 1);

   return !(bOnRedOrBlue && bUseOriginalRedAndBlueSkins);
}

simulated function NotifyTeamChanged()
{
   super.NotifyTeamChanged();

   if(WorldInfo.NetMode != NM_DedicatedServer
      && ReSkinningAllowed() )
   {
      DoSkinning();
   }
}

simulated function MaterialInterface GetReplacementSkinMaterial(MaterialInterface Mat)
{
   local int i;

   for(i = 0; i < SkinReplacementMaterials.Length; ++i)
      if(SkinReplacementMaterials[i].MaterialName ~= string(Mat))
         Mat = SkinReplacementMaterials[i].ReplacementMaterial;

   return Mat;
}

/**
 * Here we replace the base materials of players for those with color changing parameters.
 */
simulated function DoSkinning()
{
   local MaterialInstanceConstant OldMIC;
   local MaterialInterface OldMat;
   local int i;
   local int j;
   local UTMT_TeamInfo MultiTeamInfo;

   if(GetTeam() != None)
   {
      MultiTeamInfo = UTMT_TeamInfo(WorldInfo.GRI.Teams[GetTeamNum()]);
      if(MultiTeamInfo != None)
       {
         for(i = 0; i < BodyMaterialInstances.Length; ++i)
         {
            OldMIC = BodyMaterialInstances[i];
            MultiTeamInfo.TransformCharacterMaterial(OldMIC);
         }

         for(i = 0; i < ArrayCount(ArmsMesh); ++i)
         {
            for(j = 0; j < ArmsMesh[i].Materials.Length; ++j)
            {
               OldMat = ArmsMesh[i].GetMaterial(j);
               OldMat = GetReplacementSkinMaterial(OldMat);

               OldMIC = new class'MaterialInstanceConstant';
               OldMIC.SetParent(OldMat);
               ArmsMesh[i].SetMaterial(j, OldMIC);

               MultiTeamInfo.TransformCharacterMaterial(OldMIC);
            }
         }
      }
      else
      {
         WarnInternal("Could not perform color transform on Pawn because teaminfo was not a subclass of UTMT_TeamInfo");
      }
   }
}

/**
 * Same as the function in UTPawn, but uses the MultiTransInEffects array.
 * Edit: 1-4-2008  Brian Alexander
 * Changes: removed if (MultiTransInEffects.Length >= TeamNum) and replaced with  if ( MultiTransInEffects[TeamNum] != none)
 */
function SpawnTransEffect(int TeamNum)
{
   if (MultiTransInEffects[TeamNum] != none)
   {
      Spawn(MultiTransInEffects[TeamNum],self,,Location + GetCollisionHeight() * vect(0,0,0.75));
   }
}

/**
 * Same as the function in UTPawn, but uses the MultiTransOutEffects array.
 * Edit: 1-4-2008  Brian Alexander
 * Changes: removed ASSSERT and replaced with  if ( MultiTransoutEffects[TeamNum] == None )
 */
function DoTranslocateOut(Vector PrevLocation, int TeamNum)
{
   local UTEmit_TransLocateOut TLEffect;

   if ( MultiTransoutEffects[TeamNum] == None )
   {
      super.DoTranslocateOut(PrevLocation,TeamNum);
      return;
   }

   TLEffect = UTEmit_TranslocateOut( Spawn(MultiTransoutEffects[TeamNum], self,, PrevLocation, rotator(Location - PrevLocation)) );
   if (TLEffect != none && TLEffect.CollisionComponent != none)
      TLEffect.CollisionComponent.SetActorCollision(true, false);
}

/**
 * Same as the function in UTPawn, but uses the MultiTranslocateColor array.
 */
function PlayTeleportEffect(bool bOut, bool bSound)
{
   local int TeamNum, TransCamIndx;
   local UTPlayerController PC;

   if ( (PlayerReplicationInfo != None) && (PlayerReplicationInfo.Team != None) )
   {
      TeamNum = PlayerReplicationInfo.Team.TeamIndex;
   }
   if ( !bSpawnIn && (WorldInfo.TimeSeconds - SpawnTime < UTGame(WorldInfo.Game).SpawnProtectionTime) )
   {
      bSpawnIn = true;
      SetBodyMatColor( SpawnProtectionColor, UTGame(WorldInfo.Game).SpawnProtectionTime );
      SpawnTransEffect(TeamNum);
      if (bSound)
      {
         PlaySound(SpawnSound);
      }
   }
   else
   {
      SetBodyMatColor( MultiTranslocateColor[TeamNum], 1.0 );
      SpawnTransEffect(TeamNum);
      if (bSound)
      {
         PlaySound(TeleportSound);
      }
   }

   if (bOut)
   {
      PC = UTPlayerController(Controller);
      if (PC != None)
      {
         if ( !WorldInfo.Game.bTeamGame || PlayerReplicationInfo == None || PlayerReplicationInfo.Team == None
            || PlayerReplicationInfo.GetTeamNum() > 1 )
         {
            TransCamIndx = 2;
         }
         else
         {
            TransCamIndx = TeamNum;
         }
         PC.ClientPlayCameraAnim(TransCameraAnim[TransCamIndx], 1.0f);
      }
   }

   super(GamePawn).PlayTeleportEffect( bOut, bSound );
}

/**
 * Same as in UTPawn, except that it looks at the current gametype's HUDType
 * class for GetColor() to colorise the beacons.
 */
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
   local float TextXL, XL, YL, Dist;
   local vector ScreenLoc;
   local LinearColor TeamColor;
   local Color TextColor;
   local string ScreenName;
   local UTWeapon Weap;
   local UTPlayerReplicationInfo PRI;
   local UTMT_TeamHUD HUD;

   HUD = UTMT_TeamHUD(PC.MyHUD);
   if(HUD == None)
      WarnInternal("Gametype is not using a subclass of UTMT_HUD");

   screenLoc = Canvas.Project(Location + GetCollisionHeight()*vect(0,0,1));
   // make sure not clipped out
   if (screenLoc.X < 0 ||
      screenLoc.X >= Canvas.ClipX ||
      screenLoc.Y < 0 ||
      screenLoc.Y >= Canvas.ClipY)
   {
      return;
   }

   PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
   if ( !WorldInfo.GRI.OnSameTeam(self, PC) )
   {
      // maybe change to action music if close enough
      if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
      {
         if ( !UTPlayerController(PC).AlreadyInActionMusic() && (VSize(CameraPosition - Location) < VSize(PC.ViewTarget.Location - Location)) && !IsInvisible() )
         {
            // check whether close enough to crosshair
            if ( (Abs(screenLoc.X - 0.5*Canvas.ClipX) < 0.1 * Canvas.ClipX)
               && (Abs(screenLoc.Y - 0.5*Canvas.ClipY) < 0.1 * Canvas.ClipY) )
            {
               // periodically make sure really visible using traces
               if ( FastTrace(Location, CameraPosition,, true)
                           || FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition,, true) )
               {
                  UTPlayerController(PC).ClientMusicEvent(0);;
               }
            }
         }
         LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
      }
      return;
   }

   // make sure not behind weapon
   if ( UTPawn(PC.Pawn) != None )
   {
      Weap = UTWeapon(UTPawn(PC.Pawn).Weapon);
      if ( (Weap != None) && Weap.CoversScreenSpace(screenLoc, Canvas) )
      {
         return;
      }
   }
   else if ( (UTVehicle_Hoverboard(PC.Pawn) != None) && UTVehicle_Hoverboard(PC.Pawn).CoversScreenSpace(screenLoc, Canvas) )
   {
      return;
   }

   // periodically make sure really visible using traces
   if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
   {
      LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
      bPostRenderTraceSucceeded = FastTrace(Location, CameraPosition)
                           || FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition);
   }
   if ( !bPostRenderTraceSucceeded )
   {
      return;
   }

   HUD.GetMultiTeamColor( GetTeam(), TeamColor, TextColor);

   Dist = VSize(CameraPosition - Location);
   if ( Dist < TeamBeaconPlayerInfoMaxDist )
   {
      ScreenName = PlayerReplicationInfo.GetPlayerAlias();
      Canvas.StrLen(ScreenName, TextXL, YL);
      XL = Max( TextXL, 24 * Canvas.ClipX/1024 * (1 + 2*Square((TeamBeaconPlayerInfoMaxDist-Dist)/TeamBeaconPlayerInfoMaxDist)));
   }
   else
   {
      XL = Canvas.ClipX * 16 * TeamBeaconPlayerInfoMaxDist/(Dist * 1024);
      YL = 0;
   }

   HUD.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-1.8*YL,1.4*XL,1.9*YL, TeamColor, Canvas);

   if ( (PRI != None) && (Dist < TeamBeaconPlayerInfoMaxDist) )
   {
      Canvas.DrawColor = TextColor;
      Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.2*YL);
      Canvas.DrawTextClipped(ScreenName, true);
   }

   if ( (HUD != None) && !HUD.bCrosshairOnFriendly
      && (Abs(screenLoc.X - 0.5*Canvas.ClipX) < 0.1 * Canvas.ClipX)
      && (screenLoc.Y <= 0.5*Canvas.ClipY) )
   {
      // check if top to bottom crosses center of screen
      screenLoc = Canvas.Project(Location - GetCollisionHeight()*vect(0,0,1));
      if ( screenLoc.Y >= 0.5*Canvas.ClipY )
      {
         HUD.bCrosshairOnFriendly = true;
      }
   }
}

simulated function SetOverlayMaterial(MaterialInterface NewOverlay)
{
   if( (NewOverlay!= None)
      && string(NewOverlay) ~= string(ShieldBeltMultiTeamMaterial))
   {
      SetTeamShieldMaterialInstanceColor(NewOverlay);
   }

   super.SetOverlayMaterial(NewOverlay);
}

simulated function MaterialInterface GetShieldMaterialInstance(bool bTeamGame)
{
   if(bTeamGame && ReSkinningAllowed())
      return ShieldBeltMultiTeamMaterial;
   else
      return super.GetShieldMaterialInstance(bTeamGame);
}

simulated function SetTeamShieldMaterialInstanceColor(MaterialInterface ShieldMaterial)
{
   local UTMT_TeamInfo MultiTeamInfo;
   local LinearColor ShieldColor;
   local MaterialInstanceConstant ShieldMIC;

   if(ReSkinningAllowed())
   {
      MultiTeamInfo = UTMT_TeamInfo(GetTeam());
      if(MultiTeamInfo != None)
      {
         ShieldColor = MultiTeamInfo.GetShieldBeltColor();
         ShieldMIC = MaterialInstanceConstant(ShieldMaterial);
         if(ShieldMIC != None)
            ShieldMIC.SetVectorParameterValue('BeltColor', ShieldColor);
      }
   }
}

function PlayerChangedTeam()
{
   Died( none, ChangeTeamDamageClass, Location );
}

/**
 * returns a valid 4 team TeamIndex
 * 
 * @param   TeamIndex   The number to valiadate
 * @return  a valid TeamIndex or default to 0 (red)
 * @note
 * 0=Red Team
 * 1=Blue Team
 * 2=Green Team
 * 3=Gold Team
 */
static function byte ValidateTeamIndex(byte TeamIndex)
{
   if (TeamIndex > 3)
      return 0;
   else
      return TeamIndex;
}

/**
 * Change the HeroAuraEffect color to support 4 team play
 */
simulated function AttachHeroAuraEffect()
{
   local int i;

   i = ValidateTeamIndex( GetTeamNum() );

   if ( (Controller != None) && Controller.IsLocalPlayerController() )
   {
      AttachComponent(HeroOwnerAuraEffect);
      // Change the HeroAuraEffect color
      HeroOwnerAuraEffect.SetVectorParameter('HeroColor', HeroAuraTeamColors[i]);
      HeroOwnerAuraEffect.ActivateSystem();
   }
   else
   {
      AttachComponent(HeroAuraEffect);
      // Change the HeroAuraEffect color
      HeroAuraEffect.SetVectorParameter('HeroColor', HeroAuraTeamColors[i]);
      HeroAuraEffect.ActivateSystem();
   }
}

defaultproperties
{
   bUseOriginalRedAndBlueSkins=True
   MultiTranslocateColor(0)=(R=20.0,G=0.0,B=0.0,A=1.0)
   MultiTranslocateColor(1)=(R=0.0,G=0.0,B=20.0,A=1.0)
   MultiTranslocateColor(2)=(R=0.0,G=20.0,B=0.0,A=1.0)
   MultiTranslocateColor(3)=(R=20.0,G=20.0,B=0.0,A=1.0)
   CustomCharClass=Class'UTGame.UTCustomChar_Data'
   ChangeTeamDamageClass=class'UTMultiTeam.UTMT_DmgType_ChangedTeam'
   SkinReplacementMaterials(0)=(MaterialName="M_CH_IronG_Arms_FirstPersonArm",ReplacementMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.M_CH_IronG_Arms_FirstPersonArms_V01')
   SkinReplacementMaterials(1)=(MaterialName="M_CH_IronG_Arms_FirstPersonArm_VBlue",ReplacementMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.M_CH_IronG_Arms_FirstPersonArms_VBlue')
   SkinReplacementMaterials(2)=(MaterialName="M_CH_IronG_Arms_FirstPersonArm_VRed",ReplacementMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.M_CH_IronG_Arms_FirstPersonArms_VRed')
   ShieldBeltMultiTeamMaterial=MaterialInstanceConstant'DOM_MTContent.Materials.ShieldBeltV1a_INST'
   MultiTransInEffects(0)=Class'UTGame.UTEmit_TransLocateOutRed'
   MultiTransInEffects(1)=Class'UTGame.UTEmit_TransLocateOut'
   MultiTransInEffects(2)=Class'UTDom.DOM_MT_UTEmit_TransLocateOutGreen'
   MultiTransInEffects(3)=Class'UTDom.DOM_MT_UTEmit_TransLocateOutGold'
   MultiTransOutEffects(0)=Class'UTGame.UTEmit_TransLocateOutRed'
   MultiTransOutEffects(1)=Class'UTGame.UTEmit_TransLocateOut'
   MultiTransOutEffects(2)=Class'UTDom.DOM_MT_UTEmit_TransLocateOutGreen'
   MultiTransOutEffects(3)=class'UTDom.DOM_MT_UTEmit_TransLocateOutGold'
   HeroAuraTeamColors(0)=(X=1.0,Y=0.2,Z=0.2)
   HeroAuraTeamColors(1)=(X=0.2,Y=0.2,Z=1.0)
   HeroAuraTeamColors(2)=(X=0.2,Y=1.0,Z=0.2)
   HeroAuraTeamColors(3)=(X=1.0,Y=0.9,Z=0.2)
}

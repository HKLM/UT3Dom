/**
 * Kismet condition that one of two outputs will be triggered depending if
 * the current game is a Domination or a Double Domination game.
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2010 All Rights Reserved.
 */
class DOMSeqCond_GameType extends SequenceCondition;

event Activated()
{
   if ( GetWorldInfo() != none && GetWorldInfo().Game != none )
   {
      `Log("GameType is: "@string(GetWorldInfo().Game),,'DOMSeqCond_GameType');
      if ( Domination(GetWorldInfo().Game) != none )
      {
         OutputLinks[0].bHasImpulse = true;
      }
      else if ( DoubleDom(GetWorldInfo().Game) != none )
      {
         OutputLinks[1].bHasImpulse = true;
      }
   }
}

defaultproperties
{
   ObjName="Domination or DoubleDom"
   ObjCategory="GameType"
   OutputLinks(0)=(LinkDesc="Domination")
   OutputLinks(1)=(LinkDesc="Double Domination")
}

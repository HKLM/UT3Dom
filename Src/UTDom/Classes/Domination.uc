/**
 * Domination (A.K.A. Classic Domination) Gametype.
 * Based of the original UT:GoTY version of Domination.
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class Domination extends UTDomGame;

DefaultProperties
{
   bExportMenuData=True
   bUnlimitedTranslocator=True
   MessageClass=class'UTDom.DOMMessage'
   Acronym="DOM"
   MapList[0]=(MapName="DOM-Cinder",bEnabled=False,ControlPoints=("Lava"))
}

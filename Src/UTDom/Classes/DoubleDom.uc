/**
 * Double Domination Gametype.
 * Based of the UT2004 xGame.xDoubleDom gametype
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class DoubleDom extends xDoubleDom;

DefaultProperties
{
   bExportMenuData=True
   bUseTranslocator=False
   MessageClass=class'UTDom.xDomMessage'
   TranslocatorClass=class'UTDom.DOMWeap_Translocator_Content'
   UnlimitedTranslocatorClass=class'UTDom.DOMWeap_UnlimitedTranslocator_Content'
   Acronym="DOM2"
   MapList[0]=(MapName="DOM-Condemned",bEnabled=False,ControlPoints=("Roof Top","Garage"))
   NumTeams=2
   NumOfTeams=2
}

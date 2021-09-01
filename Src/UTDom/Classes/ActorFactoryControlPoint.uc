/**
 * Adds Editor support of rightclicking to place a ControlPointFactory actor in your map
 * 
 * Writen by Brian 'Snake' Alexander. Copyright(c) 2007-2010 All Rights Reserved.
 */
class ActorFactoryControlPoint extends ActorFactory;

DefaultProperties
{
   MenuName="Add Control Point"
   NewActorClass=class'ControlPointFactory'
}
/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.openvideoplayer.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoplayer.events.PlayingChangeEvent;
	import org.openvideoplayer.traits.IPlayable;
	import org.openvideoplayer.traits.TemporalTrait;
	
	/**
	 * ITemporal which keeps its position in sync with the playing state of an
	 * IPlayable, via a Timer.  Useful for testing.
	 **/
	public class TimerTemporalTrait extends TemporalTrait
	{
		public function TimerTemporalTrait(duration:Number, playable:IPlayable)
		{
			super();
			
			this.duration = duration;
			this.position = 0;
			this.playable = playable;
			
			playheadTimer = new Timer(250);
			playheadTimer.addEventListener(TimerEvent.TIMER, onPlayheadTimer);
			
			playable.addEventListener(PlayingChangeEvent.PLAYING_CHANGE, onPlayingChange);
		}
		
		override protected function processDurationReached():void
		{
			super.processDurationReached();
			
			playheadTimer.stop();
		}
		
		private function onPlayingChange(event:PlayingChangeEvent):void
		{
			if (event.playing)
			{
				playheadTimer.start();
			}
			else
			{
				playheadTimer.stop();
			}
		}
		
		private function onPlayheadTimer(event:TimerEvent):void
		{
			position += 0.25;
		}
		
		private var playable:IPlayable;
		private var playheadTimer:Timer;
	}
}
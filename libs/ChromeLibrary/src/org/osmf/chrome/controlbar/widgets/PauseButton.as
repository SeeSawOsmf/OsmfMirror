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

package org.osmf.chrome.controlbar.widgets
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class PauseButton extends PlayableButton
	{
		[Embed("../assets/images/pause_up.png")]
		public var pauseUpType:Class;
		[Embed("../assets/images/pause_down.png")]
		public var pauseDownType:Class;
		[Embed("../assets/images/pause_disabled.png")]
		public var pauseDisabledType:Class;
		
		public function PauseButton(up:Class = null, down:Class = null, disabled:Class = null)
		{
			super
				( up || pauseUpType
				, down || pauseDownType
				, disabled || pauseDisabledType
				);
		}
		
		// Overrides
		//
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var playable:PlayTrait = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playable.pause();
		}
		
		override protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible = playable && playable.playState != PlayState.PAUSED && playable.canPause;
		}
	}
}
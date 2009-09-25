/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.openvideoplayer.mast.adapter
{
	import flash.utils.Dictionary;
	
	/**
	 * The purpose of this class is to map the OSMF
	 * properties and events to the MAST properties
	 * and events.
	 */
	public class MASTAdapter
	{
		// Properties
		
		/**
		 * The duration of the current content.
		 */
		public static const DURATION:String = "duration";
		
		/**
		 * The playhead postion of the current content.
		 */		
		public static const POSITION:String = "position";
		
		/**
		 * True if the content is currently rendering in fullscreen mode.
		 */		
		public static const FULLSCREEN:String = "fullScreen";
		
		/**
		 * True if the content is currently playing.
		 */
		public static const IS_PLAYING:String = "isPlaying";
		
		/**
		 * True if the content is currently paused.
		 */	
		public static const IS_PAUSED:String = "isPaused";
		
		/**
		 * The native width of the current content.
		 */
		public static const CONTENT_WIDTH:String = "contentWidth";
		
		/**
		 * The native height of the current content.
		 */
		public static const CONTENT_HEIGHT:String = "contentHeight";
		
		// events
		
		/**
		 * Defined as anytime the play command is issued, even after a pause
		 */		
		public static const ON_PLAY:String = "OnPlay";

		/**
		* The stop command is given
		*/
		public static const ON_STOP:String = "OnStop";

		/**
		* The pause command is given
		*/
		public static const ON_PAUSE:String = "OnPause";

		/**
		* The player was muted
		*/
		public static const ON_MUTE:String = "OnMute";

		/**
		* Volume was changed
		*/
		public static const ON_VOLUME_CHANGE:String = "OnVolumeChange";

		/**
		* The player has stopped naturally, with no new content
		*/
		public static const ON_END:String = "OnEnd";

		/**
		* The player was manually seeked
		*/
		public static const ON_SEEK:String = "OnSeek";

		/**
		* A new item is being started
		*/
		public static const ON_ITEM_START:String = "OnItemStart";
		
		/**
		 * An item has ended
		 */
		public static const ON_ITEM_END:String = "OnItemEnd";
		
		public function MASTAdapter()
		{
			_map = new Dictionary();
			
			// Properties
			_map[DURATION] 		= "ITemporal.duration";
			_map[POSITION] 		= "ITemporal.position";
			_map[IS_PLAYING]	= "IPlayable.playing";
			_map[IS_PAUSED]		= "IPausable.paused";
			_map[CONTENT_WIDTH]	= "ISpatial.width";
			_map[CONTENT_HEIGHT]= "ISpatial.height";

			// Events					
			_map[ON_PLAY]			= "org.openvideoplayer.events.PlayingChangeEvent.PLAYING_CHANGE";
			_map[ON_STOP]			= "org.openvideoplayer.events.PlayingChangeEvent.PLAYING_CHANGE";
			_map[ON_PAUSE]			= "org.openvideoplayer.events.PausedChangeEvent.PAUSED_CHANGE";
			_map[ON_MUTE]			= "org.openvideoplayer.events.MutedChangeEvent.MUTED_CHANGE";
			_map[ON_VOLUME_CHANGE]	= "org.openvideoplayer.events.VolumeChangeEvent.VOLUME_CHANGE";
			_map[ON_SEEK]			= "org.openvideoplayer.events.SeekingChangeEvent.SEEKING_CHANGE";
			_map[ON_ITEM_START]		= "org.openvideoplayer.events.PlayingChangeEvent.PLAYING_CHANGE";
			_map[ON_ITEM_END]		= "org.openvideoplayer.events.TraitEvent.DURATION_REACHED";
		}
		
		public function lookup(conditionName:String):String
		{
			return _map[conditionName];
		}
		
		private var _map:Dictionary;
	}
}

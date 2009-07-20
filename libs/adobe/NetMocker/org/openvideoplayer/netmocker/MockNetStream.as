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
package org.openvideoplayer.netmocker
{
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.openvideoplayer.net.NetStreamCodes;
	
	public class MockNetStream extends NetStream
	{
		/**
		 * Constructor.
		 **/
		public function MockNetStream(connection:NetConnection)
		{
			super(connection);
			
			// Intercept all NetStatusEvents dispatched from the base class.
			eventInterceptor = new NetStatusEventInterceptor(this);
			
			playheadTimer = new Timer(TIMER_DELAY);
			playheadTimer.addEventListener(TimerEvent.TIMER, onPlayheadTimer);
		}
				
		/**
		 * The expected duration of the stream, in seconds.  Necessary so that
		 * this mock stream class knows when to dispatch the events related
		 * to a stream completing.  The default is zero.
		 **/
		public function set expectedDuration(value:Number):void
		{
			this._expectedDuration = value;
		}
		
		public function get expectedDuration():Number
		{
			return _expectedDuration;
		}

		/**
		 * The expected width of the stream, in pixels.  Necessary so that
		 * this mock stream class knows the dimensions to include in the
		 * onMetaData callback.  The default is zero.
		 **/
		public function set expectedWidth(value:Number):void
		{
			this._expectedWidth = value;
		}
		
		public function get expectedWidth():Number
		{
			return _expectedWidth;
		}

		/**
		 * The expected height of the stream, in pixels.  Necessary so that
		 * this mock stream class knows the dimensions to include in the
		 * onMetaData callback.  The default is zero.
		 **/
		public function set expectedHeight(value:Number):void
		{
			this._expectedHeight = value;
		}
		
		public function get expectedHeight():Number
		{
			return _expectedHeight;
		}
		
		// Overrides
		//
		
		override public function get time():Number
		{
			// Return value is in seconds.
			return playing
						? (elapsedTime + (flash.utils.getTimer() - absoluteTimeAtLastPlay))/1000
						: elapsedTime;
		}
		
		override public function close():void
		{
			playing = false;
			elapsedTime = 0;

			playheadTimer.stop();
		}
		
		override public function play(...arguments):void
		{
			if (expectedDuration > 0)
			{
				var info:Object = {};
				if (expectedDuration > 0)
				{
					info["duration"] = expectedDuration;
				}
				if (expectedWidth > 0)
				{
					info["width"] = expectedWidth;
				}
				if (expectedHeight > 0)
				{
					info["height"] = expectedHeight;
				}
				
				try
				{
					client.onMetaData(info);
				}
				catch (e:ReferenceError)
				{
					// Swallow, there's no such property on the client
					// and that's OK.
				}
			}
			//The flash player sets the buferTime to a .1 minimum for VOD (http://)
			if(arguments[0].toString().substr(0,4) == "http")
			{
				bufferTime = bufferTime < .1 ? .1 : bufferTime; 
			}
			
			
			absoluteTimeAtLastPlay = flash.utils.getTimer();
			playing = true;
			
			playheadTimer.start();

			var infos:Array =
					[ {"code":NetStreamCodes.NETSTREAM_PLAY_RESET, 	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_PLAY_START, 	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FULL,	"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}

		override public function pause():void
		{
			elapsedTime += ((flash.utils.getTimer() - absoluteTimeAtLastPlay) /1000);
			playing = false;
			
			playheadTimer.stop();

			var infos:Array =
					[ {"code":NetStreamCodes.NETSTREAM_PAUSE_NOTIFY,	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FLUSH,	"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}

		override public function resume():void
		{
			absoluteTimeAtLastPlay = flash.utils.getTimer();
			playing = true;

			playheadTimer.start();

			var infos:Array =
					[ {"code":NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY, 	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_PLAY_START, 		"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FULL,		"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}
		
		override public function seek(offset:Number):void
		{
			// Offset is in seconds.
			if (offset >= 0 && offset < expectedDuration)
			{
				elapsedTime = offset;
				if (playing)
				{
					absoluteTimeAtLastPlay = flash.utils.getTimer();
				}
				
				var infos:Array =
						[ {"code":NetStreamCodes.NETSTREAM_SEEK_NOTIFY, 	"level":LEVEL_STATUS}
						, {"code":NetStreamCodes.NETSTREAM_PLAY_START, 		"level":LEVEL_STATUS}
						, {"code":NetStreamCodes.NETSTREAM_BUFFER_FULL,		"level":LEVEL_STATUS}
						];
				eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
			}
			else
			{
				// TODO
			}
		}
		
		// Internals
		//
		
		private function onPlayheadTimer(event:TimerEvent):void
		{
			if (time >= expectedDuration)
			{
				elapsedTime = expectedDuration;
				playing = false;
				
				playheadTimer.stop();
				
				var infos:Array =
						[ {"code":NetStreamCodes.NETSTREAM_PLAY_STOP, 		"level":LEVEL_STATUS}
						, {"code":NetStreamCodes.NETSTREAM_BUFFER_FLUSH,	"level":LEVEL_STATUS}
						, {"code":NetStreamCodes.NETSTREAM_BUFFER_EMPTY,	"level":LEVEL_STATUS}
						];
				eventInterceptor.dispatchNetStatusEvents(infos);
			}
		}
		
		private var eventInterceptor:NetStatusEventInterceptor;
		private var _expectedDuration:Number = 0;
		private var _expectedWidth:Number = 0;
		private var _expectedHeight:Number = 0;
		
		private var playheadTimer:Timer;
		
		private var playing:Boolean = false;
		private var elapsedTime:Number = 0; // seconds

		private var absoluteTimeAtLastPlay:Number = 0; // milliseconds
		
		private static const TIMER_DELAY:int = 100;
		
		private static const EVENT_DELAY:int = 100;
		
		private static const LEVEL_STATUS:String = "status";
		private static const LEVEL_ERROR:String = "error";
	}
}
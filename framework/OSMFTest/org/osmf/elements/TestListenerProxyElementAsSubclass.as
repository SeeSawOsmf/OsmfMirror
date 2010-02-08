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
package org.osmf.elements
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import org.osmf.events.*;
	import org.osmf.net.dynamicstreaming.SwitchingDetail;
	import org.osmf.net.dynamicstreaming.SwitchingDetailCodes;
	import org.osmf.traits.*;
	import org.osmf.utils.DynamicBufferTrait;
	import org.osmf.utils.DynamicListenerProxyElement;
	import org.osmf.utils.DynamicLoadTrait;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.DynamicDynamicStreamTrait;
	import org.osmf.utils.DynamicTimeTrait;
	import org.osmf.utils.DynamicDisplayObjectTrait;
	import org.osmf.utils.SimpleLoader;
	
	public class TestListenerProxyElementAsSubclass extends TestListenerProxyElement
	{
		// Overrides
		//
		
		override public function setUp():void
		{
			super.setUp();
			
			events = new Array();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			events = null;
		}
		
		override protected function createProxyElement():ProxyElement
		{
			return new DynamicListenerProxyElement([]);
		}
		
		public function testProcessTraitChanges():void
		{
			var proxyElement:DynamicListenerProxyElement = new DynamicListenerProxyElement(events, true);
			var proxiedElement:DynamicMediaElement = new DynamicMediaElement([], new SimpleLoader());
			proxyElement.proxiedElement = proxiedElement;
			
			assertTrue(events.length == 0);
						
			proxiedElement.doAddTrait(MediaTraitType.PLAY, new PlayTrait());
			
			assertTrue(events.length == 1);
			assertTrue(events[0]["traitTypeAdded"] == MediaTraitType.PLAY);
			
			proxiedElement.doRemoveTrait(MediaTraitType.PLAY);
			
			assertTrue(events.length == 2);
			assertTrue(events[1]["traitTypeRemoved"] == MediaTraitType.PLAY);
			
			proxiedElement.doAddTrait(MediaTraitType.LOAD, new LoadTrait(null, null));
			assertTrue(events.length == 3);
			assertTrue(events[2]["traitTypeAdded"] == MediaTraitType.LOAD);
			
			proxiedElement.doRemoveTrait(MediaTraitType.LOAD);
			
			assertTrue(events.length == 4);
			assertTrue(events[3]["traitTypeRemoved"] == MediaTraitType.LOAD);
			
			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			proxiedElement.doAddTrait(MediaTraitType.PLAY, new PlayTrait());
			proxiedElement.doRemoveTrait(MediaTraitType.PLAY);
			
			assertTrue(events.length == 4);
		}
		
		public function testProcessAudioTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.AUDIO);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			var audible:AudioTrait = proxyElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;
			
			audible.volume = 0.57;
			assertTrue(events.length == 1);
			assertTrue(events[0]["newVolume"] == 0.57);

			audible.muted = true;
			assertTrue(events.length == 2);
			assertTrue(events[1]["muted"] == true);

			audible.pan = -0.5;
			assertTrue(events.length == 3);
			assertTrue(events[2]["newPan"] == -0.5);

			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			audible.volume = 0.27;
			audible.muted = false;
			audible.pan = 0.7;
			
			assertTrue(events.length == 3);
		}

		public function testProcessBufferTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.BUFFER);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			var bufferTrait:DynamicBufferTrait = proxyElement.getTrait(MediaTraitType.BUFFER) as DynamicBufferTrait;
			
			// No event for bufferLength changes.
			bufferTrait.bufferLength = 5;
			assertTrue(events.length == 0);

			bufferTrait.bufferTime = 15;
			assertTrue(events.length == 1);
			assertTrue(events[0]["newBufferTime"] == 15.0);

			bufferTrait.buffering = true;
			assertTrue(events.length == 2);
			assertTrue(events[1]["buffering"] == true);

			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			bufferTrait.bufferLength = 1;
			bufferTrait.bufferTime = 1;
			bufferTrait.buffering = false;
			
			assertTrue(events.length == 2);
		}
		
		public function testProcessLoadTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.LOAD);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			var loadTrait:DynamicLoadTrait = proxyElement.getTrait(MediaTraitType.LOAD) as DynamicLoadTrait;
			
			loadTrait.load();
			assertTrue(events.length == 2);
			assertTrue(events[0]["loadState"] == LoadState.LOADING);
			assertTrue(events[1]["loadState"] == LoadState.READY);
			
			loadTrait.unload();
			assertTrue(events.length == 4);
			assertTrue(events[2]["loadState"] == LoadState.UNLOADING);
			assertTrue(events[3]["loadState"] == LoadState.UNINITIALIZED);
			
			loadTrait.bytesTotal = 88;
			assertTrue(events.length == 5);
			assertTrue(events[4]["bytesTotal"] == 88);

			// No events for bytesLoaded.
			loadTrait.bytesLoaded = 35;
			assertTrue(events.length == 5);

			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			loadTrait.load();
			loadTrait.bytesLoaded = 40;
			loadTrait.bytesTotal = 400;
			
			assertTrue(events.length == 5);
		}
		
		public function testProcessPlayTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.PLAY);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			var playTrait:PlayTrait = proxyElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			
			playTrait.play();
			assertTrue(events.length == 1);
			assertTrue(events[0]["playState"] == PlayState.PLAYING);
			
			playTrait.pause();
			assertTrue(events.length == 2);
			assertTrue(events[1]["playState"] == PlayState.PAUSED);

			playTrait.stop();
			assertTrue(events.length == 3);
			assertTrue(events[2]["playState"] == PlayState.STOPPED);

			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			playTrait.play();
			playTrait.pause();
			playTrait.stop();
			
			assertTrue(events.length == 3);
		}
		
		public function testProcessSeekTraitChanges():void
		{
			var proxyElement:DynamicListenerProxyElement = createProxyWithTrait(null) as DynamicListenerProxyElement;
			var seekTrait:SeekTrait = new SeekTrait(new TimeTrait(3));
			DynamicMediaElement(proxyElement.proxiedElement).doAddTrait(MediaTraitType.SEEK, seekTrait);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			seekTrait.seek(1);
			assertTrue(events.length == 1);
			assertTrue(events[0]["seeking"] == true);
			assertTrue(events[0]["time"] == 1);
			
			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			seekTrait.seek(0);
			
			assertTrue(events.length == 1);
		}
		
		public function testProcessTimeTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.TIME);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			var timeTrait:DynamicTimeTrait = proxyElement.getTrait(MediaTraitType.TIME) as DynamicTimeTrait;
			
			assertTrue(events.length == 0);
			
			timeTrait.duration = 3;
			assertTrue(events.length == 1);
			assertTrue(isNaN(events[0]["oldDuration"]));
			assertTrue(events[0]["newDuration"] == 3);
			
			timeTrait.currentTime = 3;
			assertTrue(events.length == 2);
			assertTrue(events[1]["complete"] == true);
			
			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			timeTrait.currentTime = 2;
			timeTrait.duration = 2;
			
			assertTrue(events.length == 2);
		}

		public function testProcessDynamicStreamTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.DYNAMIC_STREAM);
			
			assertTrue(events.length == 0);
			
			// Changing properties should result in events.
			//
			
			var dsTrait:DynamicDynamicStreamTrait = proxyElement.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicDynamicStreamTrait;
			dsTrait.bitrates = [100, 200, 300, 400];
			assertTrue(events.length == 1);
			assertTrue(events[0]["numDynamicStreamsChange"] == true);
			
			dsTrait.autoSwitch = false;
			assertTrue(events.length == 2);
			assertTrue(events[1]["newAutoSwitch"] == false);
			
			// For our mock trait, switches complete synchronously.
			dsTrait.switchTo(3);
			assertTrue(events.length == 4);
			assertTrue(events[2]["switching"] == true);
			assertTrue((events[2]["detail"] as SwitchingDetail).detailCode == SwitchingDetailCodes.SWITCHING_MANUAL);
			assertTrue(events[3]["switching"] == false);
			assertTrue((events[3]["detail"] as SwitchingDetail).detailCode == SwitchingDetailCodes.SWITCHING_MANUAL);
			
			dsTrait.autoSwitch = true;
			assertTrue(events.length == 5);
			assertTrue(events[4]["newAutoSwitch"] == true);
			
			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			dsTrait.bitrates = [300, 400, 500];
			dsTrait.autoSwitch = false;
			dsTrait.switchTo(1);
			
			assertTrue(events.length == 5);
		}
				
		public function testProcessDisplayObjectTraitChanges():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.DISPLAY_OBJECT);
			
			assertTrue(events.length == 1);
			assertTrue(events[0]["oldDisplayObject"] == null);
			assertTrue(events[0]["newDisplayObject"] != null);
			
			// Changing properties should result in events.
			//
			
			var displayObjectTrait:DynamicDisplayObjectTrait = proxyElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DynamicDisplayObjectTrait;
			
			var aView:DisplayObject = new Sprite();
						
			displayObjectTrait.displayObject = aView; 
			assertTrue(events.length == 2);
			assertTrue(events[1]["oldDisplayObject"] != null);
			assertTrue(events[1]["newDisplayObject"] == aView);
			
			displayObjectTrait.displayObject = null; 
			assertTrue(events.length == 3);
			assertTrue(events[2]["oldDisplayObject"] == aView);
			assertTrue(events[2]["newDisplayObject"] == null);
			
			displayObjectTrait.setSize(20, 10);
			assertTrue(events.length == 4);
			assertTrue(events[3]["oldWidth"] == 0);
			assertTrue(events[3]["newWidth"] == 20);
			assertTrue(events[3]["oldHeight"] == 0);
			assertTrue(events[3]["newHeight"] == 10);

			// We shouldn't get any events when we're no longer proxying the
			// wrapped element.
			//
			
			proxyElement.proxiedElement = null;
			
			displayObjectTrait.displayObject = aView;
			displayObjectTrait.setSize(0, 0);
			
			assertTrue(events.length == 4);
		}
		
		public function testProcessDisplayObjectTraitChangesOnAddDisplayObjectTrait():void
		{
			var proxyElement:ProxyElement = createProxyWithTrait(MediaTraitType.PLAY);
			
			var aView:DisplayObject = new Sprite();
			var displayObjectTrait:DisplayObjectTrait = new DisplayObjectTrait(aView);
			
			assertTrue(events.length == 0);
			
			// DISPLAY_OBJECT is the one trait where adding the trait to the
			// MediaElement can trigger a ListenerProxyElement event.
			DynamicMediaElement(proxyElement.proxiedElement).doAddTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
			
			assertTrue(events.length == 1);
			assertTrue(events[0]["oldDisplayObject"] == null);
			assertTrue(events[0]["newDisplayObject"] == aView);
		}
		
		private function createProxyWithTrait(traitType:String):ProxyElement
		{
			var proxyElement:DynamicListenerProxyElement = new DynamicListenerProxyElement(events);
			var proxiedElement:DynamicMediaElement = new DynamicMediaElement([traitType], new SimpleLoader(), null, true);
			proxyElement.proxiedElement = proxiedElement;
			return proxyElement;
		}
		
		private var events:Array;
	}
}
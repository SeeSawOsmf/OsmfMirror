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
package org.osmf.metadata
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.netmocker.MockNetLoader;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.NetFactory;
	import org.osmf.utils.TestConstants;	

	public class TestTimelineMetadata extends TestCase
	{
		override public function setUp():void
		{
			netFactory = new NetFactory();
			loader = netFactory.createNetLoader();
			createTemporalData();
			eventDispatcher = new EventDispatcher();
			
			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netFactory = null;
			loader = null;
			_testValues = null;
			eventDispatcher = null;
		}
		
		public function testConstructor():void		
		{
			// Test passing null arguments
			try
			{
				var timelineMetadata:TimelineMetadata = new TimelineMetadata(null);
				
				fail();
			}
			catch(error:ArgumentError)
			{
			}
			
			// Test passing valid arguments
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());
			assertTrue(metadata != null);
		}
		
		public function testAddValue():void
		{
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());
			metadata.addEventListener(MetadataEvent.VALUE_ADD, onAdd);
			var addCount:int = 0;
			
			for each(var value:TimelineMarker in _testValues)
			{
				metadata.addValue("" + value.time, value);
			}
			assertTrue(addCount == _testValues.length);
			
			// Values should be sorted by time when we get them back
			var numMarkers:int = metadata.keys.length
			var lastValue:Number = 0;
			
			for (var i:int = 0; i < numMarkers; i++)
			{
				var val:TimelineMarker = metadata.getMarkerAt(i);
				assertTrue(val.time > lastValue);
				lastValue = val.time;	
			}
			
			// Test invalid values
			try
			{
				metadata.addValue(null, null);
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}
			
			try
			{
				metadata.addValue("" + -100, new TimelineMarker(-100, -10));
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}
			
			function onAdd(event:MetadataEvent):void
			{
				addCount++;
				assertTrue(event.value != null);
			}
		}
		
		public function testAddMarker():void
		{
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());
			metadata.addEventListener(TimelineMetadataEvent.MARKER_ADD, onAdd);
			var addCount:int = 0;
			
			for each (var value:TimelineMarker in _testValues)
			{
				metadata.addMarker(value);
			}
			assertTrue(addCount == _testValues.length);
			
			// Values should be sorted by time when we get them back
			var numMarkers:int = metadata.numMarkers;
			var lastValue:Number = 0;
			
			for (var i:int = 0; i < numMarkers; i++)
			{
				var val:TimelineMarker = metadata.getMarkerAt(i);
				assertTrue(val.time > lastValue);
				lastValue = val.time;	
			}
			
			// Test invalid values
			try
			{
				metadata.addMarker(null);
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}
			
			try
			{
				metadata.addMarker(new TimelineMarker(-100, -10));
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}
			
			function onAdd(event:TimelineMetadataEvent):void
			{
				addCount++;
				assertTrue(event.marker != null);
			}
		}
		
		public function testRemoveValue():void
		{
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());
			metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onRemove);
			var removeCount:int = 0;
			
			assertTrue(metadata.removeValue("" + 3) == null);
			
			for each(var value:TimelineMarker in _testValues)
			{
				metadata.addValue("" + value.time, value);
			}
			assertTrue(removeCount == 0);
			
			var result:* = metadata.removeValue("" + 3);
			assertTrue(result != null);
			assertTrue(result is TimelineMarker);
			assertTrue(TimelineMarker(result).time == 3);
			assertTrue(TimelineMarker(result).duration == 1);
			assertTrue(removeCount == 1);
			
			assertTrue(metadata.removeValue("" + 3) == null);
			assertTrue(metadata.removeValue("" + 2.8) == null);
			assertTrue(removeCount == 1);
			
			// Test invalid values
			try
			{
				metadata.removeValue(null);
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}

			function onRemove(event:MetadataEvent):void
			{
				removeCount++;
				assertTrue(event.value != null);
			}
		}
		
		public function testRemoveMarker():void
		{
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());
			metadata.addEventListener(TimelineMetadataEvent.MARKER_REMOVE, onRemove);
			var removeCount:int = 0;
			
			assertTrue(metadata.removeMarker(new TimelineMarker(3)) == null);
			
			for each (var value:TimelineMarker in _testValues)
			{
				metadata.addMarker(value);
			}
			assertTrue(removeCount == 0);
			
			var result:TimelineMarker = metadata.removeMarker(new TimelineMarker(3));
			assertTrue(result != null);
			assertTrue(result.time == 3);
			assertTrue(result.duration == 1);
			assertTrue(removeCount == 1);
			
			assertTrue(metadata.removeMarker(new TimelineMarker(3)) == null);
			assertTrue(metadata.removeMarker(new TimelineMarker(2.8)) == null);
			assertTrue(removeCount == 1);
			
			// Test invalid values
			try
			{
				metadata.removeMarker(null);
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}
			
			function onRemove(event:TimelineMetadataEvent):void
			{
				removeCount++;
				assertTrue(event.marker != null);
			}
		}
		
		public function testGetValue():void
		{
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());

			metadata.addValue("" + 500, new TimelineMarker(500, 5));
			metadata.addValue("" + 300, new TimelineMarker(300));
			metadata.addValue("" + 400, new TimelineMarker(400, 2));
			
			assertTrue(TimelineMarker(metadata.getValue("" + 500)).time == 500);
			assertTrue(TimelineMarker(metadata.getValue("" + 500)).duration == 5);
			assertTrue(TimelineMarker(metadata.getValue("" + 300)).time == 300);
			assertTrue(isNaN(TimelineMarker(metadata.getValue("" + 300)).duration));
			assertTrue(TimelineMarker(metadata.getValue("" + 400)).time == 400);
			assertTrue(TimelineMarker(metadata.getValue("" + 400)).duration == 2);

			assertNull(metadata.getValue("" + 123));
			assertNull(metadata.getValue("foo"));
			
			try
			{
				metadata.getValue(null);
				
				fail();
			}
			catch(err:ArgumentError)
			{
			}
		}

		public function testGetMarkerAt():void
		{
			var metadata:TimelineMetadata = new TimelineMetadata(new VideoElement());
			
			metadata.addMarker(new TimelineMarker(500, 5));
			metadata.addMarker(new TimelineMarker(300));
			metadata.addMarker(new TimelineMarker(400, 2));

			assertTrue(metadata.numMarkers == 3);
			assertTrue(metadata.getMarkerAt(0).time == 300);
			assertTrue(isNaN(metadata.getMarkerAt(0).duration));
			assertTrue(metadata.getMarkerAt(1).time == 400);
			assertTrue(metadata.getMarkerAt(1).duration == 2);
			assertTrue(metadata.getMarkerAt(2).time == 500);
			assertTrue(metadata.getMarkerAt(2).duration == 5);
			
			assertNull(metadata.getMarkerAt(-5));
			assertNull(metadata.getMarkerAt(3));
		}
		
		public function testTimeReached():void
		{
			testEvents();
		}
		
		public function testTimeReachedWithPause():void
		{
			testEvents(true);
		}
		
		public function testRemovingATrait():void
		{
			testOnTraitRemove();
		}
				
		private function testEvents(testPause:Boolean=false):void
		{
			var videoElement:VideoElement = createMediaElement();
			videoElement.resource = resourceForMediaElement;
			
			var metadata:TimelineMetadata = new TimelineMetadata(videoElement);

			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TIMEOUT));

			for each(var value:TimelineMarker in _testValues)
			{
				metadata.addMarker(value);
			}
			
			var timeReachedCount:int = 0;

			metadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onTimeReached);
			
			var loadTrait:LoadTrait = videoElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			assertTrue(loadTrait != null);
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			loadTrait.load();
			
			function onLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					var playTrait:PlayTrait = videoElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
					assertTrue(playTrait != null);
					playTrait.play();
				}
			}
			
			function onTimeReached(event:TimelineMetadataEvent):void
			{
				timeReachedCount++;
				
				var newEvent:TimelineMetadataEvent = event.clone() as TimelineMetadataEvent;
				assertNotNull(newEvent);
				
				var timeTrait:TimeTrait = videoElement.getTrait(MediaTraitType.TIME) as TimeTrait;
				assertTrue(timeTrait != null);
				
				var playTrait:PlayTrait = videoElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
				assertTrue(playTrait != null);
				
				// The time should be within TOLERANCE seconds of the playhead position
				var timeValue:Number = event.marker.time;
				var playheadPosition:Number = timeTrait.currentTime;
				assertTrue((playheadPosition >= (timeValue - TOLERANCE)) && (playheadPosition <= (timeValue + TOLERANCE)));
				
				if (testPause && (timeReachedCount == (metadata.numMarkers/2)))
				{
					playTrait.pause();
					playTrait.play();
				}
								
				// This ensures we got all the "time reached" events
				if (timeReachedCount == metadata.numMarkers)
				{
					metadata.removeEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onTimeReached);
					playTrait.pause();
					
					var seekTrait:SeekTrait = videoElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
					seekTrait.seek(5);
	
					metadata.enabled = false;
					if (eventDispatcher != null)
					{
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
				}
			}
		}
		
		private function testOnTraitRemove():void
		{
			var mediaElement:DynamicMediaElement = createDynamicMediaElement();
																		 			
			var metadata:TimelineMetadata = new TimelineMetadata(mediaElement);

			for each (var value:TimelineMarker in _testValues)
			{
				metadata.addMarker(value);
			}
						
			var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			assertTrue(loadTrait != null);
			loadTrait.load();
			assertTrue(loadTrait.loadState == LoadState.READY);
			
			var playTrait:PlayTrait = mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			assertTrue(playTrait != null);
			playTrait.play();
			
			var timeTrait:TimeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			assertTrue(timeTrait != null);
			
			var seekTrait:SeekTrait = mediaElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
			assertTrue(seekTrait != null);
						
			// Remove the traits while playing
			mediaElement.doRemoveTrait(MediaTraitType.SEEK);
			mediaElement.doRemoveTrait(MediaTraitType.PLAY);
			mediaElement.doRemoveTrait(MediaTraitType.TIME);
		}

		private function createTemporalData():void
		{
			_testValues = new Vector.<TimelineMarker>();
			
			_testValues.push(new TimelineMarker(3.5, 1));
			_testValues.push(new TimelineMarker(1));
			_testValues.push(new TimelineMarker(3, 0));
			_testValues.push(new TimelineMarker(2));
			_testValues.push(new TimelineMarker(2.5, 1));
			
			// Add a few duplicates.
			_testValues.push(new TimelineMarker(1, 1));
			_testValues.push(new TimelineMarker(3, 1));
		}
		
		
		private function createMediaElement():VideoElement
		{
			if (loader is MockNetLoader)
			{
				// Give our mock loader an arbitrary duration and size to ensure
				// we get metadata.
				MockNetLoader(loader).netStreamExpectedDuration = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_DURATION;
				MockNetLoader(loader).netStreamExpectedWidth = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_WIDTH;
				MockNetLoader(loader).netStreamExpectedHeight = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_HEIGHT;
			}

			return new VideoElement(null, loader); 
		}
		
		private function createDynamicMediaElement():DynamicMediaElement
		{
			if (loader is MockNetLoader)
			{
				// Give our mock loader an arbitrary duration and size to ensure
				// we get metadata.
				MockNetLoader(loader).netStreamExpectedDuration = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_DURATION;
				MockNetLoader(loader).netStreamExpectedWidth = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_WIDTH;
				MockNetLoader(loader).netStreamExpectedHeight = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_HEIGHT;
			}

			var elem:DynamicMediaElement = new DynamicMediaElement([ MediaTraitType.PLAY,
											 MediaTraitType.SEEK, MediaTraitType.TIME ],
											 loader, resourceForMediaElement);
			elem.doAddTrait(MediaTraitType.LOAD, new NetStreamLoadTrait(loader, resourceForMediaElement));
			return elem;
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}
		
		private function get resourceForMediaElement():MediaResourceBase
		{
			// Use a valid URL so that the tests will pass if we use
			// a real NetLoader rather than a MockNetLoader.
			return new URLResource(TestConstants.REMOTE_PROGRESSIVE_VIDEO);
		}
		
		private static const TOLERANCE:Number = .25;
		private static const TIMEOUT:Number = 9000;
		
		private var _testValues:Vector.<TimelineMarker>;
		
		private var netFactory:NetFactory;
		private var loader:NetLoader;
		private var eventDispatcher:EventDispatcher;
	}
}

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
package org.osmf.content
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.TestMediaElement;
	import org.osmf.traits.IDownloadable;
	import org.osmf.traits.ILoadable;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;

	public class TestContentElementIntegration extends TestMediaElement
	{
		override protected function get loadable():Boolean
		{
			return true;
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return 	[ MediaTraitType.LOADABLE
					];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return 	[ MediaTraitType.LOADABLE
					, MediaTraitType.DOWNLOADABLE
					, MediaTraitType.SPATIAL
					, MediaTraitType.VIEWABLE
				   	];
		}
		
		/**
		 * Subclasses should override to specify the total number of bytes
		 * represented by resourceForMediaElement.
		 **/
		protected function get expectedBytesTotal():Number
		{
			return NaN;
		}
		
		// Add some IDownloadable testing:
		//
		
		public function testDownloadable():void
		{
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var count:int = 0;
			var bytesTotalFired:Boolean = false;
			
			var element:MediaElement = createMediaElement();
			element.resource = resourceForMediaElement;
			
			var loadable:ILoadable = element.getTrait(MediaTraitType.LOADABLE) as ILoadable;
			
			eventDispatcher.addEventListener(Event.COMPLETE, addAsync(mustReceiveEvent, 10000));
			
			loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			loadable.load();
			
			function onLoadStateChange(event:LoadEvent):void
			{
				var downloadable:IDownloadable;
				
				count++;
				if (count == 1)
				{
					assertEquals(LoadState.LOADING, event.loadState);
					downloadable = element.getTrait(MediaTraitType.DOWNLOADABLE) as IDownloadable;
					assertNotNull(downloadable);
					assertEquals(NaN, downloadable.bytesLoaded);
					assertEquals(NaN, downloadable.bytesTotal);
					
					downloadable.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
				}
				else if (count == 2)
				{
					assertEquals(LoadState.READY, event.loadState);
					downloadable = element.getTrait(MediaTraitType.DOWNLOADABLE) as IDownloadable;
					assertNotNull(downloadable);
					assertEquals(expectedBytesTotal, downloadable.bytesLoaded);
					assertEquals(expectedBytesTotal, downloadable.bytesTotal);
					
					assertTrue(bytesTotalFired);
					
					eventDispatcher.dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			
			function onBytesTotalChange(event:LoadEvent):void
			{
				var downloadable:IDownloadable = event.target as IDownloadable;
				assertNotNull(downloadable);
				assertEquals(event.bytes, expectedBytesTotal);
				
				bytesTotalFired = true;
			}
		}
	}
}
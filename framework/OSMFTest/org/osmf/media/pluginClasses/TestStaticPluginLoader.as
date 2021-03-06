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
package org.osmf.media.pluginClasses
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.TestLoaderBase;
	import org.osmf.utils.Version;
	
	public class TestStaticPluginLoader extends TestLoaderBase
	{
		override public function setUp():void
		{
			mediaFactory = new MediaFactory();
			eventDispatcher = new EventDispatcher();

			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			mediaFactory = null;
			eventDispatcher = null;
		}
				
		override protected function createInterfaceObject(... args):Object
		{
			return new StaticPluginLoader(mediaFactory, Version.version);
		}

		override protected function createLoadTrait(loader:LoaderBase, resource:MediaResourceBase):LoadTrait
		{
			return new PluginLoadTrait(loader, resource);
		}
		
		override protected function get successfulResource():MediaResourceBase
		{
			return new PluginInfoResource(new SimpleVideoPluginInfo);
		}

		override protected function get failedResource():MediaResourceBase
		{
			return new PluginInfoResource(new InvalidVersionPluginInfo);
		}

		override protected function get unhandledResource():MediaResourceBase
		{
			return new URLResource("http://example.com");
		}
		
		override protected function verifyMediaErrorOnLoadFailure(error:MediaError):void
		{
			assertTrue(error.errorID == MediaErrorCodes.IO_ERROR ||
					   error.errorID == MediaErrorCodes.SECURITY_ERROR ||
					   error.errorID == MediaErrorCodes.PLUGIN_VERSION_INVALID ||
					   error.errorID == MediaErrorCodes.PLUGIN_IMPLEMENTATION_INVALID);
		}

		public function testLoadOfPlugin():void
		{
			var loadTrait:LoadTrait = createLoadTrait(loader, new PluginInfoResource(new SimpleVideoPluginInfo));
			
			assertTrue(mediaFactory.numItems == 0);
			
			loader.load(loadTrait);

			// Ensure the MediaFactoryItem object has been registered with the media factory.
			assertTrue(mediaFactory.getItemById(SimpleVideoPluginInfo.MEDIA_FACTORY_ITEM_ID) != null);
			assertTrue(mediaFactory.numItems == 1);
		}

		public function testLoadOfPluginWithMultipleMediaFactoryItems():void
		{
			var loadTrait:LoadTrait = createLoadTrait(loader, new PluginInfoResource(new SimpleVideoImagePluginInfo));
			
			assertTrue(mediaFactory.numItems == 0);
			
			loader.load(loadTrait);

			// Ensure the MediaFactoryItem object has been registered with the media factory.
			assertTrue(mediaFactory.getItemById(SimpleVideoImagePluginInfo.IMAGE_MEDIA_FACTORY_ITEM_ID) != null);
			assertTrue(mediaFactory.getItemById(SimpleVideoImagePluginInfo.VIDEO_MEDIA_FACTORY_ITEM_ID) != null);
			assertTrue(mediaFactory.numItems == 2);
		}

		public function testUnloadOfPlugin():void
		{
			var loadTrait:LoadTrait = createLoadTrait(loader, new PluginInfoResource(new SimpleVideoPluginInfo()));
			
			assertTrue(mediaFactory.numItems == 0);
			
			loader.load(loadTrait);
			assertTrue(mediaFactory.numItems > 0);
			
			loader.unload(loadTrait);
			assertTrue(mediaFactory.numItems == 0);
		}
		
		public function testLoadOfInvalidVersionPlugin():void
		{
			doTestLoadOfInvalidPlugin(new PluginInfoResource(new InvalidVersionPluginInfo));
		}

		public function testLoadOfInvalidImplementationPlugin():void
		{
			doTestLoadOfInvalidPlugin(new PluginInfoResource(new InvalidImplementationPluginInfo));
		}
		
		private function doTestLoadOfInvalidPlugin(pluginResource:PluginInfoResource):void
		{
			var loadTrait:LoadTrait = createLoadTrait(loader, pluginResource);
			
			assertTrue(mediaFactory.numItems == 0);
			
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 1000));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			loader.load(loadTrait);
			
			function onLoadStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.LOAD_ERROR)
				{
					eventDispatcher.dispatchEvent(new Event("testComplete"));
				}
			}
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder.
		}

		private var mediaFactory:MediaFactory;
		private var eventDispatcher:EventDispatcher;
	}
}
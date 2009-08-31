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
package org.openvideoplayer.plugin
{
	import flash.display.DisplayObject;
	
	import org.openvideoplayer.content.ContentLoadedContext;
	import org.openvideoplayer.events.LoaderEvent;
	import org.openvideoplayer.events.MediaErrorEvent;
	import org.openvideoplayer.media.IMediaFactory;
	import org.openvideoplayer.media.IMediaResource;
	import org.openvideoplayer.swf.SWFLoader;
	import org.openvideoplayer.traits.ILoadable;
	import org.openvideoplayer.traits.LoadState;
	import org.openvideoplayer.traits.LoadableTrait;
	
	internal class DynamicPluginLoader extends PluginLoader
	{
		/**
		 * Constructor
		 */
		public function DynamicPluginLoader(mediaFactory:IMediaFactory)
		{
			super(mediaFactory);
		}

		/**
		 * @inheritDoc
		 */
	    override public function canHandleResource(resource:IMediaResource):Boolean
	    {
	    	return new SWFLoader().canHandleResource(resource);
	    }

		/**
		 * @inheritDoc
		 */
		override public function load(loadable:ILoadable):void
		{
			super.load(loadable);
			
			updateLoadable(loadable, LoadState.LOADING);
			
			// We'll use a SWFLoader to do the loading.  Make sure we load the
			// SWF into the same security domain so that the class types are
			// merged.
			var swfLoader:SWFLoader = new SWFLoader(true);
			swfLoader.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onSWFLoaderStateChange);
			
			// Create a temporary ILoadable for this purpose, so that our main
			// ILoadable doesn't reflect any of the state changes from the
			// loading of the SWF, and so that we can catch any errors.
			var swfLoadable:LoadableTrait = new LoadableTrait(swfLoader, loadable.resource);
			swfLoadable.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadableError);
			
			swfLoader.load(swfLoadable);
			
			function onSWFLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.LOADED)
				{
					// This is a terminal state, so remove all listeners.
					swfLoader.removeEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onSWFLoaderStateChange);
					swfLoadable.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadableError);
	
					var loadedContext:ContentLoadedContext = event.loadedContext as ContentLoadedContext;
					var root:DisplayObject = loadedContext.loader.content;
					var pluginInfo:IPluginInfo = root[PLUGININFO_PROPERTY_NAME] as IPluginInfo;
	
					loadFromPluginInfo(loadable, pluginInfo, loadedContext.loader);
				}
				else if (event.newState == LoadState.LOAD_FAILED)
				{
					// This is a terminal state, so remove the listener.  But
					// don't remove the error event listener, as that will be
					// removed when the error event for this failure is
					// dispatched.
					swfLoader.removeEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onSWFLoaderStateChange);
					
					updateLoadable(loadable, event.newState);
				}
			}
			
			function onLoadableError(event:MediaErrorEvent):void
			{
				// Only remove this listener, as there will be a corresponding
				// event for the load failure.
				swfLoadable.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadableError);
				
				loadable.dispatchEvent(event.clone());
			}
		}
		
		// Internals
		//

		/**
		 * @inheritDoc
		 */
		override public function unload(loadable:ILoadable):void
		{
			super.unload(loadable);
			
			updateLoadable(loadable, LoadState.UNLOADING, loadable.loadedContext);
			
			// First unload the IPluginInfo.
			//
			
			var pluginLoadedContext:PluginLoadedContext = loadable.loadedContext as PluginLoadedContext;
			var pluginInfo:IPluginInfo = pluginLoadedContext != null ? pluginLoadedContext.pluginInfo : null;
			
			unloadFromPluginInfo(pluginInfo);

			// Then unload the SWF.
			//
			
			var swfLoader:SWFLoader = new SWFLoader();
			swfLoader.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onSWFLoaderStateChange);
			
			// Create a temporary ILoadable for this purpose, so that our main
			// ILoadable doesn't reflect any of the state changes from the
			// unloading of the SWF.
			var swfLoadable:LoadableTrait = new LoadableTrait(swfLoader, loadable.resource);
			swfLoadable.loadState = LoadState.LOADED;
			swfLoadable.loadedContext = new ContentLoadedContext(pluginLoadedContext.loader);
			
			swfLoader.unload(swfLoadable);
			
			function onSWFLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.CONSTRUCTED)
				{
					swfLoader.removeEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onSWFLoaderStateChange);
					
					updateLoadable(loadable, LoadState.CONSTRUCTED);
				}
			}
		}
		
		private static const PLUGININFO_PROPERTY_NAME:String = "pluginInfo";
	}
}
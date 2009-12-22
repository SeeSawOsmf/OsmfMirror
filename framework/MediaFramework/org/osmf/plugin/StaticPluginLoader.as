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
package org.osmf.plugin
{
	import org.osmf.media.IMediaResource;
	import org.osmf.media.MediaFactory;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	
	internal class StaticPluginLoader extends PluginLoader
	{
		/**
		 * Constructor
		 */
		public function StaticPluginLoader(mediaFactory:MediaFactory)
		{
			super(mediaFactory);
		}

		/**
		 * Indicates if this loader can handle the given resource.
		 * 
		 * The resource that's passed in needs to be of type <code>ClassResource</code>
		 * for static plugins. If the class reference points to a <code>Class</code>
		 * that can be successfully instantiated and implements IPluginInfo, 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    override public function canHandleResource(resource:IMediaResource):Boolean
	    {
	    	return (resource is PluginInfoResource);
	    }
	    
		override public function load(loadTrait:LoadTrait):void
		{
			super.load(loadTrait);

			updateLoadTrait(loadTrait, LoadState.LOADING);

			var classResource:PluginInfoResource = loadTrait.resource as PluginInfoResource; 	
			var pluginInfo:IPluginInfo = classResource.pluginInfoRef;
			
			loadFromPluginInfo(loadTrait, pluginInfo);
		}
		
		override public function unload(loadTrait:LoadTrait):void
		{
			super.unload(loadTrait);
			
			var pluginLoadedContext:PluginLoadedContext = loadTrait.loadedContext as PluginLoadedContext;
			var pluginInfo:IPluginInfo = pluginLoadedContext != null ? pluginLoadedContext.pluginInfo : null;

			updateLoadTrait(loadTrait, LoadState.UNLOADING, loadTrait.loadedContext);
						
			unloadFromPluginInfo(pluginInfo);
			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
	}
}
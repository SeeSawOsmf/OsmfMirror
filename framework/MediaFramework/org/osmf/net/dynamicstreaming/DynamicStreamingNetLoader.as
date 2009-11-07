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

package org.osmf.net.dynamicstreaming
{
	import flash.errors.IllegalOperationError;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.LoadableStateChangeEvent;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.NetLoadedContext;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.ILoadable;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadableTrait;
	import org.osmf.utils.URL;
	import org.osmf.utils.MediaFrameworkStrings;
	
	/**
	 * DynamicStreamingNetLoader extends NetLoader to provide
	 * dynamic stream switching functionality. This class is
	 * "backwards compatible" meaning if it is not handed a 
	 * DynamicStreamingResource it will call the base class
	 * implementation for both <code>load</code> and <code>unload</code>
	 * methods.
	 */
	public class DynamicStreamingNetLoader extends NetLoader
	{
		/**
		 * Constructor.
		 * 
		 * @inheritDoc
		 */
		public function DynamicStreamingNetLoader(allowConnectionSharing:Boolean=true, factory:NetConnectionFactory=null)
		{
			super(allowConnectionSharing, factory);
		}
		
		/**
		 * Attempts to load the DynamicStreamingResource supplied as an ILoadable object.
		 * If the <code>loadable</code> argument is not a DynamicStreamingResource, the
		 * base class implementation will be called so that this class can handle regular,
		 * non-dynamic streaming resources.
		 */
		override public function load(loadable:ILoadable):void
		{
			var dsResource:DynamicStreamingResource = loadable.resource as DynamicStreamingResource;
			
			if (dsResource == null)
			{
				// Must be a "regular" stream, let the base class handle it
				super.load(loadable);
			}
			else
			{
				// Get the hostname from the DynamicStreamingResource and ask the base class to connect
				var hostName:URL = dsResource.host;
				var tempTrait:LoadableTrait = new LoadableTrait(null, new URLResource(hostName));
				
				tempTrait.addEventListener(LoadableStateChangeEvent.LOADABLE_STATE_CHANGE, onLoadableStateChange);
				super.load(tempTrait);
				
				function onLoadableStateChange(event:LoadableStateChangeEvent):void
				{
					if (event.newState == LoadState.LOADED)
					{
						tempTrait.removeEventListener(LoadableStateChangeEvent.LOADABLE_STATE_CHANGE, onLoadableStateChange);
									
						var netLoadedContext:NetLoadedContext = tempTrait.loadedContext as NetLoadedContext;
						DynamicNetStream(netLoadedContext.stream).resource = dsResource;
																										
						loadable.loadedContext = new DynamicStreamingNetLoadedContext(netLoadedContext.connection, netLoadedContext.stream,
																						netLoadedContext.shareable, netLoadedContext.netConnectionFactory,
																						netLoadedContext.resource, tempTrait);
					}
					loadable.loadState = event.newState;					
				}
			}
		}
		
		/**
		 * Attempts to unload the DynamicStreamingResource supplied as an ILoadable object.
		 * If the <code>loadable</code> argument is not a DynamicStreamingResource, the
		 * base class implementation will be called so that this class can handle regular,
		 * non-dynamic streaming resources.
		 */
		override public function unload(loadable:ILoadable):void
		{
			var dsResource:DynamicStreamingResource = loadable.resource as DynamicStreamingResource;
			
			if (dsResource == null)
			{
				super.unload(loadable);
			}
			else
			{
				var loadedContext:DynamicStreamingNetLoadedContext = loadable.loadedContext as DynamicStreamingNetLoadedContext;
				var hostLoadable:ILoadable = loadedContext.hostNameLoadable;
				
				var netLoadedContext:NetLoadedContext = hostLoadable.loadedContext as NetLoadedContext;
				if (netLoadedContext == null)
				{
					throw new IllegalOperationError(MediaFrameworkStrings.NULL_PARAM);
				}
				else
				{
					updateLoadable(loadable, LoadState.UNLOADING, hostLoadable.loadedContext);	
					netLoadedContext.stream.close();
					if (netLoadedContext.shareable)
					{
						netLoadedContext.netConnectionFactory.closeNetConnectionByResource(netLoadedContext.resource);
					}		
					else
					{
						netLoadedContext.connection.close();
					}			
						
					updateLoadable(loadable, LoadState.CONSTRUCTED);	
				}
			}			
		}
		
		/**
		 * Overridden to allow the creation of a DynamicNetStream object.
		 */
		override protected function createNetStream(connection:NetConnection,loadable:ILoadable):NetStream
		{			
			return new DynamicNetStream(connection);
		}
	}
}

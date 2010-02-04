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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/
package org.osmf.net
{
	import __AS3__.vec.Vector;
	
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.MediaType;
	import org.osmf.metadata.MetadataUtils;
	import org.osmf.metadata.MimeTypes;
	import org.osmf.net.dynamicstreaming.NetStreamSwitchManager;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;

	/**
	 * The NetLoader class extends LoaderBase to provide
	 * loading support to the AudioElement and VideoElement classes.
	 * <p>Supports both streaming and progressive media resources.
	 * If the resource URL is RTMP, connects to an RTMP server by invoking a NetConnectionFactory. 
	 * NetConnections may be shared between LoadTrait instances.
	 * If the resource URL is HTTP, performs a <code>connect(null)</code>
	 * for progressive downloads.</p>
	 * 
	 * @param allowConnectionSharing if true, the NetLoader will allow sharing. Note that this param implies
	 * that an already existing NetConnection may be used to satisfy this LoadTrait, as well as whether a
	 * new NetConnection established by this loader can be shared with future LoadTraits. 
	 * 
	 * @param factory the NetConnectionFactory instance to use for managing NetConnections. Since the NetConnectionFactory
	 * facilitates connection sharing, this is an easy way of enabling global sharing, by creating a single NetConnectionFactory
	 * instance within the player and then handing it to all NetLoader instances. 
	 * 
	 * @see NetLoadedContext
	 * @see NetConnectionFactory
	 * @see flash.net.NetConnection
	 * @see flash.net.NetStream
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class NetLoader extends LoaderBase
	{
		/**
		 * Constructor
		 * 
		 * @param allowConnectionSharing true if the NetLoader can invoke a NetConnectionFactory which
		 * re-uses (shares) an existing NetConnection. 
		 * 
		 * @param factory the NetConnectionFactory instance to use for managing NetConnections. Since the NetConnectionFactory
		 * facilitates connection sharing, this is an easy way of enabling global sharing, by creating a single NetConnectionFactory
		 * instance within the player and then handing it to all NetLoader instances. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetLoader(allowConnectionSharing:Boolean = true, factory:NetConnectionFactory = null)
		{
			super();
			_allowConnectionSharing = allowConnectionSharing;
			netConnectionFactory = factory;
			if (netConnectionFactory != null)
			{
				addListenersToFactory();
			}
			
		}
		
		/**
		 * Sets whether this NetLoader will invoke a NetConnectionFactory which allows
		 * NetConnection reuse. Changes to this property will apply to future calls to <code>load()</code>
		 * and will not be retro-actively applied to previously loaded, or loading operations that are underway.
		 * 
		 * @param value true if the NetConnectionFactory can share an existing NetConnection
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set allowConnectionSharing(value:Boolean):void
		{
			_allowConnectionSharing = value;
		}
		
		/**
		 * Validates the LoadTrait to verify that this class can in fact load it. Examines the protocol
		 * associated with the LoadTrait's resource. If the protocol is HTTP, calls the <code>startLoadingHTTP()</code>
		 * method. If the protocol is RTMP-based, calls the  <code>startLoadingRTMP()</code> method. If the URL protocol is invalid,
		 * dispatches a mediaErroEvent against the LoadTrait and updates the LoadTrait's state to LoadState.LOAD_ERROR.
	     *
	     * @param loadTrait LoadTrait requesting this load operation.
	     * @see org.osmf.traits.LoadTrait
	     * @see org.osmf.traits.LoadState
	     * @see org.osmf.events.MediaErrorEvent
		 * @inheritDoc
		**/
		override protected function executeLoad(loadTrait:LoadTrait):void
		{	
			updateLoadTrait(loadTrait, LoadState.LOADING);
			switch ((loadTrait.resource as URLResource).url.protocol)
			{
				case PROTOCOL_RTMP:
				case PROTOCOL_RTMPS:
				case PROTOCOL_RTMPT:
				case PROTOCOL_RTMPE:
				case PROTOCOL_RTMPTE:
					startLoadingRTMP(loadTrait);
					break;
				case PROTOCOL_HTTP:
				case PROTOCOL_HTTPS:
				case PROTOCOL_FILE:
				case PROTOCOL_EMPTY: 
					startLoadingHTTP(loadTrait);
					break;
				default:
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent
						( new MediaErrorEvent
							( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, new MediaError(MediaErrorCodes.INVALID_URL_PROTOCOL)
							)
						);
					break;
			}
		}
		
		/**
	     * Unloads the media after validating the unload operation against the LoadTrait. Examines the NetLoadedContext
	     * object associated with the LoadTrait. If the object is null, throws a OSMFStrings.NULL_PARAM error.
	     * Closes the NetStream defines within the NetLoadedContext object. 
	     * If the shareable property of the object is true, calls the NetConnectionFactory to close() the NetConnection
	     * otherwise closes the NetConnection directly. Dispatches the loaderStateChange event with every state change.
	     * 
	     * @throws IllegalOperationError if the parameter is <code>null</code>.
	     * @param loadTrait LoadTrait to be unloaded.
	     * @see org.osmf.loaders.LoaderBase#event:loaderStateChange	
		**/
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			var netLoadedContext:NetLoadedContext = loadTrait.loadedContext as NetLoadedContext;			
			
			updateLoadTrait(loadTrait, LoadState.UNLOADING, loadTrait.loadedContext); 			
			netLoadedContext.stream.close();
			if (netLoadedContext.shareable)
			{
				netLoadedContext.netConnectionFactory.closeNetConnectionByResource(netLoadedContext.resource);
			}		
			else
			{
				netLoadedContext.connection.close();
			}	
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED); 				
		}
		
		/**
		 * The NetLoader returns true for URLResources which support the media and mime-types
		 * (or file extensions) for streaming audio and streaming or progressive video, or
		 * implement one of the following schemes: http, https, file, rtmp, rtmpt, rtmps,
		 * rtmpe or rtmpte.
		 * 
		 * @param resource The URL of the source media.
		 * @return Returns <code>true</code> for URLResources which it can load
		 * @inheritDoc
		**/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MetadataUtils.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MimeTypes.SUPPORTED_VIDEO_MIME_TYPES);
			if (rt != MetadataUtils.METADATA_MATCH_UNKNOWN)
			{
				return rt == MetadataUtils.METADATA_MATCH_FOUND;
			}			

			/*
			 * The rules for URL checking is outlined as below:
			 * 
			 * If the URL is null or empty, we assume being unable to handle the resource
			 * If the URL has no protocol, we check for file extensions
			 * If the URL has protocol, we have to make a distinction between progressive and stream
			 * 		If the protocol is progressive (file, http, https), we check for file extension
			 *		If the protocol is stream (the rtmp family), we assume that we can handle the resource
			 *
			 * We assume being unable to handle the resource for conditions not mentioned above
			 */
			var res:URLResource = resource as URLResource;
			if (res == null || res.url == null || res.url.rawUrl == null || res.url.rawUrl.length <= 0)
			{
				return false;
			}
			if (res.url.protocol == "")
			{
				return res.url.path.search(/\.flv$|\.f4v$|\.mov$|\.mp4$|\.mp4v$|\.m4v$|\.3gp$|\.3gpp2$|\.3g2$/i) != -1;
			}
			if (NetStreamUtils.isRTMPStream(res.url))
			{
				return true;
			}
			if (res.url.protocol.search(/file$|http$|https$/i) != -1)
			{
				return (res.url.path == null ||
						res.url.path.length <= 0 ||
						res.url.path.indexOf(".") == -1 ||
						res.url.path.search(/\.flv$|\.f4v$|\.mov$|\.mp4$|\.mp4v$|\.m4v$|\.3gp$|\.3gpp2$|\.3g2$/i) != -1);
			}
			
			return false;
		}
		
		/**
		 *
		 * The factory function for creating a NetStream.  Allows third party plugins to create custom net streams.
		 * 
		 * @param connection the NetConnnection to associate with the new NetStream.
		 * @param loadTrait The LoadTrait instance requesting this NetStream. Developers of custom NetStreams can use this 
		 * LoadTrait reference to dispatch custom media errors against the LoadTrait.
		 * 
		 *  @return a new NetStream associated with the NetConnection.
		**/
		protected function createNetStream(connection:NetConnection, loadTrait:LoadTrait):NetStream
		{
			return new NetStream(connection);
		}

		/**
		 * The factory function for creating a NetStreamSwitchManager.  Allows third party plugins to
		 * create custom switch managers.
		 * 
		 * Returns null if multi bitrate switching is not enabled for the NetStream returned by
		 * createNetStream.
		 **/
		protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, loadTrait:LoadTrait):NetStreamSwitchManager
		{
			return null;
		}

		/**
		 *  Function for creating a NetConnectionFactory  
		 *
		 *  @return An NetConnectionFactory
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function createNetConnectionFactory():NetConnectionFactory
		{
			if (netConnectionFactory == null)
			{
				netConnectionFactory = new NetConnectionFactory();
				addListenersToFactory();
			}
			return netConnectionFactory;
		}

		/**
		 *  Establishes a new NetStream on the connected NetConnection and signals that loading is complete.
		 *
		 *  @private
		**/
		private function finishLoading(connection:NetConnection, loadTrait:LoadTrait, shareable:Boolean = false, factory:NetConnectionFactory = null):void
		{
			var stream:NetStream = createNetStream(connection, loadTrait);				
			stream.client = new NetClient();
			var switchManager:NetStreamSwitchManager = createNetStreamSwitchManager(connection, stream, loadTrait);
			updateLoadTrait(loadTrait, LoadState.READY, new NetLoadedContext(connection, stream, switchManager, shareable, factory, loadTrait.resource as URLResource));		
		}	
		
		/**
		 * Initiates the process of creating a connected NetConnection
		 * 
		 * @private
		 */
		private function startLoadingRTMP(loadTrait:LoadTrait):void
		{
			var factory:NetConnectionFactory  = createNetConnectionFactory();

			factory.create(loadTrait, _allowConnectionSharing);
		}
		
		/**
		 * Called once the NetConnectionFactory has successfully created a NetConnection
		 * 
		 * @private
		 */
		private function onCreated(event:NetConnectionFactoryEvent):void
		{
			finishLoading(event.netConnection, event.loadTrait, event.shareable, event.currentTarget as NetConnectionFactory);
		}
		
		/**
		 * Called once the NetConnectionFactory has failed to create a NetConnection
		 * TBD - error dispatched at lower level.
		 * 
		 * @private
		 */
		private function onCreationFailed(event:NetConnectionFactoryEvent):void
		{
			updateLoadTrait(event.loadTrait, LoadState.LOAD_ERROR);
		}
		
		/**
		 * Initiates a HTTP connection.
		 * 
		 * @private
		 * 
		 */
		private function startLoadingHTTP(loadTrait:LoadTrait):void
		{
			var connection:NetConnection = new NetConnection();
			connection.client = new NetClient();
			connection.connect(null);
			finishLoading(connection, loadTrait);
		}
		
		/**
		 * Adds listeners to the netConnectionFactory instance. It is possible that a non-null
		 * NetConnectionFactory is supplied in the constructor and then modified later via the 
		 * createNetConnectionFactory() method, which is why any prior listeners are removed before the 
		 * new ones are added.
		 * @private
		 * 
		 */
		private function addListenersToFactory():void
		{
			if (netConnectionFactory.hasEventListener(NetConnectionFactoryEvent.CREATED))
			{
				netConnectionFactory.removeEventListener(NetConnectionFactoryEvent.CREATED,onCreated);
			}
			if (netConnectionFactory.hasEventListener(NetConnectionFactoryEvent.CREATION_FAILED))
			{
				netConnectionFactory.removeEventListener(NetConnectionFactoryEvent.CREATION_FAILED,onCreationFailed);
			}
			netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATED,onCreated);
			netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_FAILED,onCreationFailed);
		}
		
		private var _allowConnectionSharing:Boolean;
		private var netConnectionFactory:NetConnectionFactory;
		
		private static const PROTOCOL_RTMP:String = "rtmp";
		private static const PROTOCOL_RTMPS:String = "rtmps";
		private static const PROTOCOL_RTMPT:String = "rtmpt";
		private static const PROTOCOL_RTMPE:String = "rtmpe";
		private static const PROTOCOL_RTMPTE:String = "rtmpte";
		private static const PROTOCOL_HTTP:String = "http";
		private static const PROTOCOL_HTTPS:String = "https";
		private static const PROTOCOL_FILE:String = "file";
		private static const PROTOCOL_EMPTY:String = "";
				
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.VIDEO]);
	}
}


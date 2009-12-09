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
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.events.NetNegotiatorEvent;
	import org.osmf.media.IURLResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.utils.FMSURL;

	/**
	 * Dispatched when the factory has successfully created and connected a NetConnection
	 *
	 * @eventType org.osmf.events.NetConnectionFactoryEvent.CREATED
	 * 
	 **/
	[Event(name="created", type="org.osmf.events.NetConnectionFactoryEvent")]
	
	/**
	 * Dispatched when the factory has failed to create and connect a NetConnection
	 *
	 * @eventType org.osmf.events.NetConnectionFactoryEvent.CREATION_FAILED
	 * 
	 **/
	[Event(name="creationfailed", type="org.osmf.events.NetConnectionFactoryEvent")]
	
	/**
	 * The NetConnectionFactory class is used to generate connected NetConnection instances
	 * and to manage sharing of these instances between multiple LoadTraits. This class is stateless. 
	 * Multiple parallel create() requests may be made. Concurrent requests to the same URL by disparate LoadTraits
	 * are handled efficiently with only a single NetNegotiation instance being used. A hash of the resource URL is used as a key
	 * to determine which NetConnections may be shared. 
	 * 
	 * @see NetNegotiator
	 * 
	 */
	public class NetConnectionFactory extends EventDispatcher
	{
		/**
		 * Constructor
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetConnectionFactory(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * Begins the process of creating a new NetConnection.  The method creates two dictionaries to help it 
		 * manage previously shared connections as well as pending connections. Only if a NetConenction is not shareable
		 * and not pending is a new connection sequence initiated via a new NetNegotiator instance.
		 * <p/>
		 * If this method receives a CONNECTION_FAILED event back from a NetNegotiator, it will dispatch the appropriate 
		 * MediaErrorEvent against the associated LoadTrait.
		 * 
		 * @param loadTrait the LoadTrait that requires the NetConnection
		 * @param allowNetConnectionSharing Boolean specifying whether the NetConnection may be shared or not
		 * 
		 * @see org.osmf.events.MediaErrorEvent;
		 * @see org.osmf.events.MediaError
		 * @see NetNegotiator
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function create(loadTrait:LoadTrait,allowNetConnectionSharing:Boolean):void
		{
			var urlResource:IURLResource = loadTrait.resource as IURLResource;
			var key:String = extractKey(urlResource);
			
			// The first time this method is called, we create our dictionaries.
			if (connectionDictionary == null)
			{
				connectionDictionary = new Dictionary();
				pendingDictionary = new Dictionary();
			}
			var sharedConnection:SharedConnection = connectionDictionary[key] as SharedConnection;
			var connectionsUnderway:Vector.<PendingConnection> = pendingDictionary[key] as Vector.<PendingConnection>;
			
			// Check to see if we already have this connection ready to be shared.
			if (sharedConnection != null && allowNetConnectionSharing)
			{
				sharedConnection.count++;
				dispatchEvent
					( new NetConnectionFactoryEvent
						( NetConnectionFactoryEvent.CREATED
						, false
						, false
						, sharedConnection.netConnection
						, loadTrait
						, true
						)
					);
			} 
			// Check to see if there is already a connection attempt pending on this resource.
			else if (connectionsUnderway != null)
			{
				// Add this LoadTrait to the vector of LoadTraits to be notified once the
				// connection has either succeeded or failed.
				connectionsUnderway.push(new PendingConnection(loadTrait, allowNetConnectionSharing));
			}
			// If no connection is shareable or pending, then initiate a new connection attempt.
			else
			{
				// Add this connection to the list of pending connections
				var pendingConnections:Vector.<PendingConnection> = new Vector.<PendingConnection>();
				pendingConnections.push(new PendingConnection(loadTrait, allowNetConnectionSharing));
				pendingDictionary[key] = pendingConnections;
				
				// Create a new NetNegotiator to perform the connection attempts
				var negotiator:NetNegotiator  = createNetNegotiator();
				negotiator.addEventListener(NetNegotiatorEvent.CONNECTED, onConnected);
				negotiator.addEventListener(NetNegotiatorEvent.CONNECTION_FAILED, onConnectionFailed);
				negotiator.connect(urlResource);
	
				// Catch the connected event coming back from the NetNegotiator
				function onConnected(event:NetNegotiatorEvent):void
				{
					negotiator.removeEventListener(NetNegotiatorEvent.CONNECTED, onConnected);
					negotiator.removeEventListener(NetNegotiatorEvent.CONNECTION_FAILED, onConnectionFailed);
					
					// Dispatch an event for each pending LoadTrait.
					var pendingConnections:Vector.<PendingConnection> = pendingDictionary[key];
					for (var i:Number=0; i < pendingConnections.length; i++)
					{
						var pendingConnection:PendingConnection = pendingConnections[i] as PendingConnection;
						if (pendingConnection.shareable)
						{
							var alreadyShared:SharedConnection = connectionDictionary[key] as SharedConnection;
							if (alreadyShared != null)
							{
								alreadyShared.count++;
							}
							else
							{
								var obj:SharedConnection = new SharedConnection();
								obj.count = 1;
								obj.netConnection = event.netConnection;
								connectionDictionary[key] = obj;
							}
						} 
						dispatchEvent
							( new NetConnectionFactoryEvent
								( NetConnectionFactoryEvent.CREATED
								, false
								, false
								, event.netConnection
								, pendingConnection.loadTrait
								, pendingConnection.shareable
								)
							);
					}
					delete pendingDictionary[key];
				}
				
				// Catch the failed event coming back from the NetNegotiator
				function onConnectionFailed(event:NetNegotiatorEvent):void
				{
					negotiator.removeEventListener(NetNegotiatorEvent.CONNECTED, onConnected);
					negotiator.removeEventListener(NetNegotiatorEvent.CONNECTION_FAILED, onConnectionFailed);
					
					// Dispatch an event for each pending LoadTrait.
					var pendingConnections:Vector.<PendingConnection> = pendingDictionary[key];
					for (var i:Number=0; i < pendingConnections.length; i++)
					{
						if (event.mediaError != null)
						{
							loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, event.mediaError));
						}
						dispatchEvent
							( new NetConnectionFactoryEvent
								( NetConnectionFactoryEvent.CREATION_FAILED
								, false
								, false
								, null
								, loadTrait
								)
							);
					}
					delete pendingDictionary[key];
				}
			}
		}
		
		/**
		 * Manages the closing of a shared NetConnection using the resource as the key. NetConnections
		 * are only physically closed after the last sharer has requested a close().
		 * 
		 * @param resource the IURLresource originally used to establish the NetConenction
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function closeNetConnectionByResource(resource:IURLResource):void
		{
			var key:String = extractKey(resource);
			var obj:SharedConnection = connectionDictionary[key] as SharedConnection;
			obj.count--;
			if (obj.count == 0)
			{
				obj.netConnection.close();
				delete connectionDictionary[key];
			}
		}
		
		/**
		 * Override this method to allow the use of a custom NetNegotiator
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function createNetNegotiator():NetNegotiator
		{
			return new NetNegotiator();
		}
		
		/**
		 * Generates a key to uniquely identify each connection. 
		 * 
		 * @param resource a IURLResource
		 * @return a String hash that uniquely identifies the NetConnection
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function extractKey(resource:IURLResource):String
		{
			var fmsURL:FMSURL = resource is FMSURL ? resource as FMSURL : new FMSURL(resource.url.rawUrl);
			return fmsURL.protocol + fmsURL.host + fmsURL.port + fmsURL.appName;
		}
		
		private var connectionDictionary:Dictionary;
		private var pendingDictionary:Dictionary;
	}
}

import flash.net.NetConnection;
import org.osmf.traits.LoadTrait;

/**
 * Utility class for structuring shared connection data.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion OSMF 1.0
 */
class SharedConnection
{
	public var count:Number;
	public var netConnection:NetConnection	
}

/**
 * Utility class for structuring pending connection data.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion OSMF 1.0
 */
class PendingConnection
{
	public function PendingConnection(loadTrait:LoadTrait,shareable:Boolean)
	{
		_loadTrait = loadTrait;
		_shareable = shareable;
	}
	
	public function get loadTrait():LoadTrait
	{
		return _loadTrait;
	}
	
	public function get shareable():Boolean
	{
		return _shareable;
	}
	
	private var _loadTrait:LoadTrait;
	private var _shareable:Boolean;	
}

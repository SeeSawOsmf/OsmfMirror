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
package org.osmf.net
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.TimeTrait;

	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class NetStreamLoadTrait extends LoadTrait
	{
		public function NetStreamLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
			
			isStreamingResource = NetStreamUtils.isStreamingResource(resource);
		}
		
		/**
		 * The connected NetConnection, used for streaming audio and video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */

	    public function get connection():NetConnection
	    {	   	
	   		return _connection;
	   	}
	   	
	   	public function set connection(value:NetConnection):void
	   	{
	   		_connection = value;
	   	}
	   
        /**
		 * The NetStream associated with the NetConnection, used
         * for streaming audio and video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get netStream():NetStream
	    {	   	
	   		return _netStream;
	   	}
	   	
	   	public function set netStream(value:NetStream):void
	   	{
	   		_netStream = value;
	   	}

        /**
		 * Manager class for switching between different MBR renditions using
		 * a NetStream.  Null if MBR switching is not enabled for the NetStream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get switchManager():NetStreamSwitchManager
	    {	   	
	   		return _switchManager;
	   	}
	   	
	   	public function set switchManager(value:NetStreamSwitchManager):void
	   	{
	   		_switchManager = value;
	   	}
	   	
	   	/**
	   	 * Defines the object's optional DVRTrait
	   	 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	   	 */	   	
	   	public function set dvrTrait(value:DVRTrait):void
	   	{
	   		_dvrTrait = value;
	   	}
	   	
	   	public function get dvrTrait():DVRTrait
	   	{
	   		return _dvrTrait; 
	   	}
	   	
	   	/**
	   	 * Defines the object's optional custom TimeTrait
	   	 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	   	 */	   	
	   	public function set timeTrait(value:TimeTrait):void
	   	{
	   		_timeTrait = value;
	   	}
	   	
	   	public function get timeTrait():TimeTrait
	   	{
	   		return _timeTrait; 
	   	}
	   	
	   	/**
		 * The NetConnectionFactoryBase associated with the NetConnection.
		 * If a NetConnectionFactory is used and the NetConnection is shared,
		 * then the NetConnection should be closed by calling
		 * closeNetConnectionByResource() on the NetConnectionFactory instance
		 * rather than on the NetConnection itself.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get netConnectionFactory():NetConnectionFactoryBase
	    {	   	
	   		return _netConnectionFactory;
	   	}
	   	
	   	public function set netConnectionFactory(value:NetConnectionFactoryBase):void
	   	{
	   		_netConnectionFactory = value;
	   	}
	   	
	   	/**
	   	 * @private
	   	 **/
		override protected function loadStateChangeStart(newState:String):void
		{
			if (newState == LoadState.READY)
			{
				if (	!isStreamingResource
					 && (  netStream.bytesTotal <= 0
					 	|| netStream.bytesTotal == uint.MAX_VALUE
					 	)
				   )
				{
					netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				}
			}
			else if (newState == LoadState.UNINITIALIZED)
			{
				netStream = null;
			}
		}
		
		/**
		 * @private
		 */
		override public function get bytesLoaded():Number
		{
			return isStreamingResource ? NaN : (netStream != null ? netStream.bytesLoaded : NaN);
		}
		
		/**
		 * @private
		 */
		override public function get bytesTotal():Number
		{
			return isStreamingResource ? NaN : (netStream != null ? netStream.bytesTotal : NaN);
		}
		
		// Internals
		//
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			if (netStream.bytesTotal > 0)
			{
				dispatchEvent
					( new LoadEvent
						( LoadEvent.BYTES_TOTAL_CHANGE
						, false
						, false
						, null
						, netStream.bytesTotal
						)
					);
					
				netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
		}

	   	private var _connection:NetConnection;
	   	private var _switchManager:NetStreamSwitchManager;
	   	private var _dvrTrait:DVRTrait;
	   	private var _timeTrait:TimeTrait;
	   	private var _netConnectionFactory:NetConnectionFactoryBase;

		private var isStreamingResource:Boolean;
		private var _netStream:NetStream;
	}
}
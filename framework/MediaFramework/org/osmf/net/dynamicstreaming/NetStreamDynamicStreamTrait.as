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
*  Contributor(s): Adobe Systems Incorporated.
* 
*****************************************************/

package org.osmf.net.dynamicstreaming
{
	import flash.events.NetStatusEvent;
	
	import org.osmf.events.SwitchEvent;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.traits.DynamicStreamTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetStreamDynamicStreamTrait class extends DynamicStreamTrait for NetStream-based
	 * dynamic streaming.
	 */   
	public class NetStreamDynamicStreamTrait extends DynamicStreamTrait
	{
		/**
		 * Constructor.
		 * 
		 * @param ns The DynamicNetStream object the class will work with.
		 * @param res The DynamicStreamingResource the class will use.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function NetStreamDynamicStreamTrait(ns:DynamicNetStream, res:DynamicStreamingResource)
		{
			super(!ns.useManualSwitchMode, ns.renderingIndex, res.streamItems.length);	
			
			_ns = ns;
			_resource = res;
									
			_ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_ns.addEventListener(SwitchEvent.SWITCHING_CHANGE, onNetStreamSwitchingChange);
		}
		
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		override public function getBitrateForIndex(index:int):Number
		{
			return _resource.streamItems[index].bitrate;
		}	
				
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		override protected function processSwitchTo(value:int):void
		{
			_ns.switchTo(value);
		}
			
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		override protected function processAutoSwitchChange(value:Boolean):void
		{
			_ns.useManualSwitchMode = !value;
		}
		
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */ 
		override protected function processMaxIndexChange(value:int):void
		{
			if(_ns != null)
			{
				_ns.maxIndex = value;
			}
		}
		
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */ 
		override protected function postProcessSwitchTo(detail:SwitchingDetail=null):void
		{
			// Do nothing, wait for onNetStreamSwitchingChange handler to dispatch SwitchComplete.
		}
				
		private function onNetStatus(event:NetStatusEvent):void
		{			
			if (!switchUnderway)
			{
				return;
			}
			
			switch (event.info.code) 
			{
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:					
					processSwitchState(SwitchEvent.SWITCHSTATE_FAILED);					
					break;
			}			
		}
		
		private function onNetStreamSwitchingChange(event:SwitchEvent):void
		{
			if (event.newState == SwitchEvent.SWITCHSTATE_COMPLETE)
			{
				setCurrentIndex(_ns.renderingIndex);
			}

			processSwitchState(event.newState, event.detail);
		}				
						
		private var _ns:DynamicNetStream;
		private var _resource:DynamicStreamingResource;		
	}
}

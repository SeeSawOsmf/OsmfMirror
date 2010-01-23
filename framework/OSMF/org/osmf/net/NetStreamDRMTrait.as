﻿/*****************************************************
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
	import flash.events.Event;
	
	CONFIG::FLASH_10_1
	{
		import org.osmf.drm.DRMServices;
		import flash.net.drm.DRMContentData;
	}

	import org.osmf.events.DRMEvent;
	import org.osmf.traits.DRMTrait;
	import org.osmf.events.MediaError;
	import org.osmf.drm.DRMState;

    [ExcludeClass]
    
    /**
	 * @private
	 * 
     * NetStream-specific DRM trait.
     */
	public class NetStreamDRMTrait extends DRMTrait
	{
	CONFIG::FLASH_10_1
	{
		/**
   		 * Constructor.
   		 *  
   		 *  @langversion 3.0
   		 *  @playerversion Flash 10
   		 *  @playerversion AIR 1.5
   		 *  @productversion OSMF 1.0
   		 */ 
		public function NetStreamDRMTrait()
		{
			super();			
			drmServices.addEventListener(DRMEvent.DRM_STATE_CHANGE, onStateChange);		
		}
		
		/**
		 * Data used by the flash player to implement DRM specific content protection.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set drmMetadata(value:Object):void
		{
			if (value != drmServices.drmMetadata)
			{
				drmServices.drmMetadata = value;
			}
		}
	
		public function get drmMetadata():Object
		{
			return drmServices.drmMetadata;
		}

		/**
		 * @private
		 */				
		override public function get authenticationMethod():String
		{
			return drmServices.authenticationMethod;
		}

		/**
		 * @private
		 */				
		override public function authenticate(username:String = null, password:String = null):void
		{							
			drmServices.authenticate(username, password);
		}

		/**
		 * @private
		 */		
		override public function authenticateWithToken(token:Object):void
		{							
			drmServices.authenticateWithToken(token);
		}
		
		/**
		 * @private
		 * Signals failures from the DRMsubsystem not captured though the 
		 * DRMServices class.
	
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function inlineDRMFailed(error:MediaError):void
		{
			drmServices.inlineDRMFailed(error);
		}
		
		// Internals
		//
						
		private function onStateChange(event:DRMEvent):void
		{
			drmStateChange(drmServices.drmState, event.token, event.error, event.startDate, event.endDate, event.period);
		}
															
		private var drmServices:DRMServices = new DRMServices();
    }
	}
}
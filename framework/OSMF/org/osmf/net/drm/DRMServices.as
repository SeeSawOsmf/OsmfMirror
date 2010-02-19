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
package org.osmf.net.drm
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.traits.DRMState;
	import org.osmf.utils.OSMFStrings;

	CONFIG::FLASH_10_1
	{
	import flash.events.DRMAuthenticationCompleteEvent;
	import flash.events.DRMAuthenticationErrorEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.net.drm.AuthenticationMethod;
	import flash.net.drm.DRMContentData;
	import flash.net.drm.DRMManager;
	import flash.net.drm.DRMVoucher;
	import flash.net.drm.LoadVoucherSetting;
	import flash.net.drm.VoucherAccessInfo;
	import flash.system.SystemUpdater;
	import flash.system.SystemUpdaterType;
	}
	
	[ExcludeClass]
		
	/**
	 * Dispatched when either anonymous or credential-based authentication is needed in order
	 * to playback the media.
	 *
	 * @eventType org.osmf.events.DRMEvent.DRM_STATE_CHANGE
 	 */ 
	[Event(name='drmStateChange', type='org.osmf.events.DRMEvent')]	

	/**
	 * @private
	 * 
	 * The DRMServices class is a utility class to adapt the Flash Player's DRM
	 * to the OSMF-style DRM API.  DRMServices handles triggering updates to
	 * the DRM subsystem, as well as triggering the appropriate events when
	 * authentication is needed, complete, or failed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	internal class DRMServices extends EventDispatcher
	{
	CONFIG::FLASH_10_1
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  
		 */ 
		public function DRMServices()
		{
			drmManager = DRMManager.getDRMManager();
		}
		
		/**
		 * The current state of the DRM for this media.  The states are explained
		 * in the DRMState enumeration in the org.osmf.drm package.
		 * @see DRMState
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get drmState():String
		{
			return _drmState;
		} 
			
		/**
		 * The metadata property is specific to the DRM for the Flash Player.  Once set, authentication
		 * and voucher retrieval is started.  This method may trigger an update to the DRM subsystem.  Metadata
		 * forms the basis for content data.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function set drmMetadata(value:Object):void
		{		
			lastToken = null;
			if (value is DRMContentData)
			{
				drmContentData = value as DRMContentData;
				retrieveVoucher();	
			}
			else
			{	
				try
				{
					drmContentData = new DRMContentData(value as ByteArray);
					retrieveVoucher();	
				}
				catch (argError:ArgumentError)  // DRM ContentData is invalid
				{		
					updateDRMState		
						( 	DRMState.AUTHENTICATE_FAILED,
							new MediaError(argError.errorID, "DRMContentData invalid")
						);
						
				}
				catch (error:Error)
				{
					var e:Error = error;
					function onComplete(event:Event):void
					{
						updater.removeEventListener(IOErrorEvent.IO_ERROR, onComplete);
						updater.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onComplete);
						updater.removeEventListener(Event.COMPLETE, onComplete);
						if (event.type == Event.COMPLETE)
						{
								drmMetadata = value;
								return;
						}	
					}				
					if (updater == null)
					{
						updater = new SystemUpdater();
						updater.addEventListener(IOErrorEvent.IO_ERROR, onComplete);
						updater.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onComplete);
						updater.addEventListener(Event.COMPLETE, onComplete);
						updater.update(SystemUpdaterType.DRM);				
					}
				}
			}
		}
			
		public function get drmMetadata():Object
		{		
			return drmContentData;
		}
			
		/**
		 * Authenticates the media.  Can be used for both anonymous and credential-based
		 * authentication.
		 * 
		 * @param username The username.  Should be null for anonymous authentication.
		 * @param password The password.  Should be null for anonymous authentication.
		 * 
		 * @throws IllegalOperationError If the metadata hasn't been set.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function authenticate(username:String = null, password:String = null):void
		{			
			if (drmContentData == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DRM_METADATA_NOT_SET));
			}
		
			drmManager.addEventListener(DRMAuthenticationErrorEvent.AUTHENTICATION_ERROR, authError);			
			drmManager.addEventListener(DRMAuthenticationCompleteEvent.AUTHENTICATION_COMPLETE, authComplete);		
			
			if (password == null && username == null)
			{
				retrieveVoucher();
			}	
			else
			{
				drmManager.authenticate(drmContentData.serverURL, drmContentData.domain, username, password);
			}
		}
		
		/**
		 * Authenticates the media using an object which serves as a token.  Can be used
		 * for both anonymous and credential-based authentication.
		 * 
		 * @param token The token to use for authentication.
		 * 
		 * @throws IllegalOperationError If the metadata hasn't been set.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function authenticateWithToken(token:Object):void
		{
			if (drmContentData == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DRM_METADATA_NOT_SET));
			}
						
			drmManager.setAuthenticationToken(drmContentData.serverURL, drmContentData.domain, token as ByteArray);
			retrieveVoucher();
		}
					
		/**
		 * Returns the start date for the playback window.  Returns null if authentication 
		 * hasn't taken place.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get startDate():Date
		{
			if (voucher != null)
			{
				return voucher.playbackTimeWindow ? voucher.playbackTimeWindow.startDate : voucher.voucherStartDate;	
			}
			else
			{
				return null;
			}			
		}
		
		/**
		 * Returns the end date for the playback window.  Returns null if authentication 
		 * hasn't taken place.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get endDate():Date
		{
			if (voucher != null)
			{
				return voucher.playbackTimeWindow ? voucher.playbackTimeWindow.endDate : voucher.voucherEndDate;	
			}
			else
			{
				return null;
			}			
		}
		
		/**
		 * Returns the length of the playback window, in seconds.  Returns NaN if
		 * authentication hasn't taken place.
		 * 
		 * Note that this property will generally be the difference between startDate
		 * and endDate, but is included as a property because there may be times where
		 * the duration is known up front, but the start or end dates are not (e.g. a
		 * one week rental).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get period():Number
		{
			if (voucher != null)
			{
				return voucher.playbackTimeWindow ? voucher.playbackTimeWindow.period : (voucher.voucherEndDate.time - voucher.voucherStartDate.time)/1000;	
			}
			else
			{
				return NaN;
			}		
		}
		
		/**
		 * Returns the URL of the server used to manage this content's DRM.  Returns "" if
		 * the server is unknown.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get serverURL():String
		{
			if (drmContentData != null)
			{
				return drmContentData.serverURL;	
			}
			else
			{
				return "";
			}		
		}
		
		/**
		 * @private
		 * 
		 * Signals failures from the DRMsubsystem not captured though the 
		 * DRMServices class.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function inlineDRMFailed(error:MediaError):void
		{
			updateDRMState(DRMState.AUTHENTICATE_FAILED, error);
		}
		
		// Internals
		//
		
		/**
		 * Downloads the voucher for the metadata specified.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		private function retrieveVoucher():void
		{				
			drmManager.addEventListener(DRMErrorEvent.DRM_ERROR, onDRMError);
			drmManager.addEventListener(DRMStatusEvent.DRM_STATUS, onVoucherLoaded);
						
			drmManager.loadVoucher(drmContentData, LoadVoucherSetting.ALLOW_SERVER);					
		}
		
		private function onVoucherLoaded(event:DRMStatusEvent):void
		{	
			if (event.contentData == drmContentData)
			{
				var now:Date = new Date();
				this.voucher = event.voucher;		
				if (	voucher
					 && voucher.voucherEndDate != null
					 && voucher.voucherEndDate.time >= now.time
					 && voucher.voucherStartDate != null
					 && voucher.voucherStartDate.time <= now.time
				    )
				{
					removeEventListeners();
								
					if (voucher.playbackTimeWindow == null)
					{					
						updateDRMState(DRMState.AUTHENTICATED, null, voucher.voucherStartDate, voucher.voucherEndDate, period, lastToken);
					} 
					else
					{
						updateDRMState(DRMState.AUTHENTICATED, null, voucher.playbackTimeWindow.startDate, voucher.playbackTimeWindow.endDate, voucher.playbackTimeWindow.period, lastToken);
					}								
				}
				else
				{
					forceRefreshVoucher();
				}	
			}	
		}
					
		private function forceRefreshVoucher():void
		{
			drmManager.loadVoucher(drmContentData, LoadVoucherSetting.FORCE_REFRESH);
		}
			
		private function onDRMError(event:DRMErrorEvent):void
		{
			if (event.contentData == drmContentData) //Ensure this event is for our data.
			{
				switch(event.errorID)
				{
					case MediaErrorCodes.DRM_CONTENT_NOT_YET_VALID:
						forceRefreshVoucher();
						break;
					case MediaErrorCodes.DRM_NEEDS_AUTHENTICATION:
						var voucherInfo:VoucherAccessInfo = event.contentData.getVoucherAccessInfo()[0];
						updateDRMState(DRMState.AUTHENTICATION_NEEDED, null, null, null, 0, null, voucherInfo.displayName );
						break;
					default:
						removeEventListeners();							
						updateDRMState(DRMState.AUTHENTICATE_FAILED,  new MediaError(event.errorID, event.text));	
						break;
				}
			}	
		}
					
		private function removeEventListeners():void
		{
			drmManager.removeEventListener(DRMErrorEvent.DRM_ERROR, onDRMError);
			drmManager.removeEventListener(DRMStatusEvent.DRM_STATUS, onVoucherLoaded);
		}
		
		private function authComplete(event:DRMAuthenticationCompleteEvent):void
		{
			drmManager.removeEventListener(DRMAuthenticationErrorEvent.AUTHENTICATION_ERROR, authError);
			drmManager.removeEventListener(DRMAuthenticationCompleteEvent.AUTHENTICATION_COMPLETE, authComplete);
			lastToken = event.token;
			retrieveVoucher();
		}			
				
		private function authError(event:DRMAuthenticationErrorEvent):void
		{
			drmManager.removeEventListener(DRMAuthenticationErrorEvent.AUTHENTICATION_ERROR, authError);
			drmManager.removeEventListener(DRMAuthenticationCompleteEvent.AUTHENTICATION_COMPLETE, authComplete);
			
			updateDRMState
				( DRMState.AUTHENTICATE_FAILED,
					new MediaError
						( event.errorID
						, MediaErrorCodes.getMessageForErrorID(event.errorID)
						)					
				);
		}
		
		private function updateDRMState(newState:String,  error:MediaError = null,  start:Date = null, end:Date = null, period:Number = 0 , token:Object=null, prompt:String = null ):void
		{
			_drmState = newState;
			dispatchEvent
				( new DRMEvent
					( DRMEvent.DRM_STATE_CHANGE,
					newState,
					false,
					false,
					start,
					end,
					period,
					prompt,
					token,
					error
					)
				);
		}
		
		private var _drmState:String = DRMState.INITIALIZING;
		private var lastToken:ByteArray
		private var drmContentData:DRMContentData;
		private var voucher:DRMVoucher;
		private var drmManager:DRMManager;
		private var updater:SystemUpdater;
	}
	}
}
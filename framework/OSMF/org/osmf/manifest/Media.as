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
package org.osmf.manifest
{
	import flash.utils.ByteArray;
	
	import org.osmf.utils.URL;
	
	/**
	 * Describes a specific piece of media.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	internal class Media
	{
		/**
		 * Information about the |AdditionalHeader used with the media. |AdditionalHeader
		 * contains DRM metadtaa
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var drmAdditionalHeader:DRMAdditionalHeader = new DRMAdditionalHeader();
		
		/**
		 * Represents all information needed to bootstrap playback of 
		 * HTTP streamed media. It contains either a byte array
		 * of, or a URL to, the bootstrap information in the format that corresponds 
		 * to the bootstrap profile. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
 		public var bootstrapInfo:ByteArray;
 		
 		/**
		 * The URL that points to the bootstrap info.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
 		public var bootstrapInfoURL:URL;
 		
 		/**
		 * The profile, or type of bootstrapping represented by this element. 
		 * For the Named Access profile, use "named". For the Range Access Profile, 
		 * use "range". For other bootstrapping profiles, use some other string (i.e. 
		 * the field is extensible). It is required.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
 		public var bootstrapProfile:String;
		
		/**
		 * The ID of this &lt;bootstrapInfo&gt; element. It is optional. If it is not specified, 
		 * then this bootstrapping block will apply to all &lt;media&gt; elements that don't have a 
		 * bootstrapInfoId property. If it is specified, then this bootstrapping block will apply 
		 * only to those &lt;media&gt; elements that use the same ID in their bootstrapInfoId property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public var bootstrapInfoId:String;
				
		/**
		 * Location of the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public var url:URL;
		
		/**
		 * The bitrate of the media in kilobits per second.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var bitrate:Number;
		
		/**
		 * Represents the Movie Box, or "moov" atom, for one representation of 
		 * the piece of media. It is an optional child element of &lt;media&gt;.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var moov:ByteArray;
		
		/**
		 * Width of the resource in pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var width:Number;
		
		/**
		 * Height of the resource in pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var height:Number;
				
		
	}
}
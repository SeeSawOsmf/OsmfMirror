/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.net.dvr
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.NetLoader;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.DVRTrait;

	/**
	 * Defines a NetLoader sublcass for loading streams from a DVRCast equiped
	 * FMS server.
	 */	
	public class DVRCastNetLoader extends NetLoader
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function DVRCastNetLoader()
		{
			super(new DVRCastNetConnectionFactory());
		}
		
		/**
		 * @private
		 */		
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var result:Boolean;
			
			var streamingURLResource:StreamingURLResource = resource as StreamingURLResource;
			if (streamingURLResource)
			{
				result = streamingURLResource.streamType == StreamType.DVR;
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			return new DVRCastNetStream(connection, resource);
		}
		
		/**
		 * @private
		 */
		override protected function createDVRTrait(connection:NetConnection, netStream:NetStream, resource:URLResource):DVRTrait
		{
			var result:DVRTrait;
	
			var streamingURLResource:StreamingURLResource = resource as StreamingURLResource;
			if (streamingURLResource != null && connection != null)
			{
				// See if a DVRCast facet is available on the resource's metadata:
				var dvrcastFacet:KeyValueFacet
					=	resource.metadata.getFacet(MetadataNamespaces.DVRCAST_METADATA)
					as	KeyValueFacet;
					
	  			if (dvrcastFacet != null)
	  			{
	  				result = new DVRCastDVRTrait(dvrcastFacet, connection, netStream);
	  			}
			}
			
			return result;
		}
	}
}
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
package org.osmf.media
{
	import flash.utils.Dictionary;
	
	/**
	 * An MediaResourceBase is a base class for media that serves as input
	 * to a MediaElement.
	 * 
	 * <p>Different MediaElement instances can "handle" (i.e. input) different
	 * resource types (e.g. a URL vs. an array of streams), or even different
	 * variations of the same resource type (e.g. a URL with the ".jpg"
	 * extension vs. a URL with a ".mp3" extension).</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaResourceBase
	{
		/**
		 * Constructor.
		 **/
		public function MediaResourceBase()
		{
			super();
		}
		
		/**
		 * The MediaType, if any, of this resource.
		 **/
		public function get mediaType():String
		{
			return _mediaType;
		}
		
		public function set mediaType(value:String):void
		{
			_mediaType = value;
		}

		/**
		 * The MIME type, if any, of this resource.
		 **/
		public function get mimeType():String
		{
			return _mimeType;
		}
		
		public function set mimeType(value:String):void
		{
			_mimeType = value;
		}

		/**
		 * Adds a metadata value to this resource.
		 * 
		 * @param namespaceURL A URL with which this metadata is associated,
		 * and with which it can be retrieved.  If there is metadata that
		 * is already associated with this URL, then it will be overwritten. 
		 * @param value The metadata value.  It is recommended that this be a
		 * strongly-typed class, rather than an untyped Object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function addMetadataValue(namespaceURL:String, value:Object):void
		{
			if (_metadata == null)
			{
				_metadata = new Dictionary();
			}

			_metadata[namespaceURL] = value;			
		}

		/**
		 * Retrieves a metadata value from this resource.
		 * 
		 * @param namespaceURL The URL with which the metadata is associated.
		 * 
		 * @return The retrieved metadata value, null if there is no metadata value
		 * associated with the specified namespace URL.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function getMetadataValue(namespaceURL:String):Object
		{
			if (_metadata != null)
			{
				return _metadata[namespaceURL];
			}
			
			return null;
		}

		/**
		 * Removes a metadata value from this resource.
		 * 
		 * @param namespaceURL The URL with which the metadata value is associated.
		 * 
		 * @return The removed metadata value, null if there is no metadata value
		 * associated with the specified namespace URL.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function removeMetadataValue(namespaceURL:String):Object
		{
			if (_metadata != null)
			{
				var value:Object = _metadata[namespaceURL];
				delete _metadata[namespaceURL];
				return value;
			}
			
			return null;
		}

		// Internals
		//
		
		private var _metadata:Dictionary;
		private var _mediaType:String;
		private var _mimeType:String;
	}
}
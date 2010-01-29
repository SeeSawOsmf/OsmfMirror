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
package org.osmf.image
{
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.MediaType;
	import org.osmf.metadata.MetadataUtils;
	import org.osmf.swf.LoaderUtils;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.*;

	/**
	 * The ImageLoader class creates a flash.display.Loader object, 
	 * which it uses to load and unload an image.
	 * <p>The image is loaded from the URL provided by the
	 * <code>resource</code> property of the LoadTrait that is passed
	 * to the ImageLoader's <code>load()</code> method.</p>
	 *
	 * @see ImageElement
	 * @see org.osmf.traits.LoadTrait
	 * @see flash.display.Loader
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class ImageLoader extends LoaderBase
	{
		/**
		 * Constructs a new ImageLoader.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function ImageLoader()
		{
			super();
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether this ImageLoader is capable of handling the specified resource.
		 * Returns <code>true</code> for URLResources with GIF, JPG, or PNG extensions.
		 * @param resource Resource proposed to be loaded.
		 */ 
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MetadataUtils.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MetadataUtils.METADATA_MATCH_UNKNOWN)
			{
				return rt == MetadataUtils.METADATA_MATCH_FOUND;
			}			
			
			var urlResource:URLResource = resource as URLResource;
			if (urlResource != null &&
				urlResource.url != null)
			{
				return (urlResource.url.path.search(/\.gif$|\.jpg$|\.png$/i) != -1);
			}	
			return false;
		}
		
		/**
		 * @private
		 * 
		 * Loads content using a flash.display.Loader object. 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param loadTrait LoadTrait to be loaded.
		 */ 
		override public function load(loadTrait:LoadTrait):void
		{
			super.load(loadTrait);
			
			LoaderUtils.loadLoadTrait(loadTrait, updateLoadTrait, false);
		}

		/**
		 * @private
		 * 
		 * Unloads content using a flash.display.Loader object.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param loadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#unload()
		 */ 
		override public function unload(loadTrait:LoadTrait):void
		{
			super.unload(loadTrait);

			LoaderUtils.unloadLoadTrait(loadTrait, updateLoadTrait);
		}
		
		// Internals
		//

		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["image/png", "image/gif", "image/jpeg"]);	
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.IMAGE]);
	}
}
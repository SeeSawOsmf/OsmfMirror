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
	import org.osmf.content.ContentElement;
	import org.osmf.media.URLResource;
	
	/**
	 * ImageElement is a media element specifically created for
	 * presenting still images.
	 * It can load and present any PNG, GIF, or JPG image.
	 * <p>The ImageElement uses an ImageLoader class to load and unload its media.
	 * Developers requiring custom loading logic for images
	 * can pass their own loaders to the ImageElement constructor. 
	 * These loaders should subclass ImageLoader.</p>
	 * <p>The basic steps for creating and using an ImageElement are:
	 * <ol>
	 * <li>Create a new IURLResource pointing to the URL of image to be loaded.</li>
	 * <li>Create a new ImageLoader.</li>
	 * <li>Create the new ImageElement, passing the ImageLoader and IURLResource
	 * as parameters.</li>
	 * <li>Get the ImageElement's LoadTrait using the 
	 * <code>MediaElement.getTrait(MediaTraitType.LOAD)</code> method.</li>
	 * <li>Load the image using the LoadTrait's <code>load()</code> method.</li>
	 * <li>Get the ImageElement's DisplayObjectTrait trait using the 
	 * <code>MediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT)</code> method.</li>
	 * <li>Add the DisplayObject that represents the ImageElement's DisplayObjectTrait trait
	 * to the display list. This DisplayObjects is in the <code>view</code>
	 * property of the DisplayObjectTrait.</li>
	 * <li>When done with the ImageElement, unload the image using the
	 * LoadTrait's <code>unload()</code> method.</li>
	 * </ol>
	 * </p>
	 * 
	 * @see ImageLoader
	 * @see org.osmf.media.IURLResource
	 * @see org.osmf.media.MediaElement
	 * @see org.osmf.traits
	 * @see flash.display.DisplayObjectContainer#addChild()
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class ImageElement extends ContentElement
	{
		/**
		 * Constructor.
		 * 
		 * @param loader Loader used to load the image.
		 * @param resource Url that points to the image that the ImageElement will use.
		 * 
		 * @throws ArgumentError If loader is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function ImageElement(loader:ImageLoader, resource:URLResource = null)
		{
			super(loader, resource);		
		}
	}
}
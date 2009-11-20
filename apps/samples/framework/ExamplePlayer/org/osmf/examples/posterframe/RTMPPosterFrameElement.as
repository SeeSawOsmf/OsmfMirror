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
package org.osmf.examples.posterframe
{
	import org.osmf.media.IMediaResource;
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.IPlayable;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.video.VideoElement;

	/**
	 * A PosterFrameElement is a playable Image Element.  Making it playable
	 * ensures it shows up as a poster frame.
	 **/
	public class RTMPPosterFrameElement extends VideoElement
	{
		public function RTMPPosterFrameElement(loader:NetLoader, resource:IMediaResource, posterFrameTime:Number)
		{
			// Add metadata to our resource so that it's treated as a zero-length
			// subclip.
			var kvFacet:KeyValueFacet = new KeyValueFacet(MetadataNamespaces.SUBCLIP_METADATA);
			kvFacet.addValue(MetadataNamespaces.SUBCLIP_START_ID, posterFrameTime);
			kvFacet.addValue(MetadataNamespaces.SUBCLIP_END_ID, posterFrameTime);
			resource.metadata.addFacet(kvFacet);
	
			super(loader, resource);
		}
		
		/**
		 * @private
		 **/
		override protected function processReadyState():void
		{
			super.processReadyState();

			// First, remove the temporal and playable traits.  Doing so
			// will ensure that our "play" call to display the poster
			// frame won't cause this MediaElement to complete (and therefore
			// trigger the playback of the next child, when in a SerialElement).
			removeTrait(MediaTraitType.TEMPORAL);
			var playable:IPlayable = removeTrait(MediaTraitType.PLAYABLE) as IPlayable;
			
			// Calling play() on our removed trait will cause the poster frame
			// to be displayed.  But because this playable trait is detached, no
			// events are dispatched to the client.  From a traits perspective,
			// this is functionally equivalent to an ImageElement, where there's
			// an IViewable but no IPlayable.
			playable.play();
			
			// Last, to ensure that the user can complete playback of this item,
			// we add a dummy IPlayable trait.
			addTrait(MediaTraitType.PLAYABLE, new PosterFramePlayableTrait(this));
		}
	}
}
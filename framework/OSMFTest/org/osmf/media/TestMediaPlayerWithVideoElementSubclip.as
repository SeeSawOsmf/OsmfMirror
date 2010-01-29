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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.media
{
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.ObjectIdentifier;
	import org.osmf.net.NetLoader;
	import org.osmf.netmocker.MockNetLoader;
	import org.osmf.netmocker.NetConnectionExpectation;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.NetFactory;
	import org.osmf.utils.TestConstants;
	import org.osmf.utils.URL;
	import org.osmf.video.VideoElement;
	
	public class TestMediaPlayerWithVideoElementSubclip extends TestMediaPlayer
	{
		// Overrides
		//
				
		override public function setUp():void
		{
			netFactory = new NetFactory();
			loader = netFactory.createNetLoader();

			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netFactory = null;
			loader = null;
		}

		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			if (loader is MockNetLoader)
			{
				// Give our mock loader an arbitrary duration and size to ensure
				// we get metadata.
				MockNetLoader(loader).netStreamExpectedDuration = 6;//TestConstants.REMOTE_STREAMING_VIDEO_EXPECTED_DURATION;
				MockNetLoader(loader).netStreamExpectedSubclipDuration = 3;
				MockNetLoader(loader).netStreamExpectedWidth = TestConstants.REMOTE_STREAMING_VIDEO_EXPECTED_WIDTH
				MockNetLoader(loader).netStreamExpectedHeight = TestConstants.REMOTE_STREAMING_VIDEO_EXPECTED_HEIGHT;
			
				if (resource == INVALID_RESOURCE)
				{
					MockNetLoader(loader).netConnectionExpectation = NetConnectionExpectation.INVALID_FMS_APPLICATION;
				}
			}

			return new VideoElement(resource, loader);
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return true;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			// Use a valid URL so that the tests will pass if we use
			// a real NetLoader rather than a MockNetLoader.
			var resource:URLResource = new URLResource(new URL(TestConstants.REMOTE_STREAMING_VIDEO));
			var kvFacet:KeyValueFacet = new KeyValueFacet(MetadataNamespaces.SUBCLIP_METADATA);
			kvFacet.addValue(MetadataNamespaces.SUBCLIP_START_ID, 2);
			kvFacet.addValue(MetadataNamespaces.SUBCLIP_END_ID, 5);
			resource.metadata.addFacet(kvFacet);
			return resource;
		}

		override protected function get invalidResourceForMediaElement():MediaResourceBase
		{
			// Use an invalid URL so that the tests will fail if we use
			// a real NetLoader rather than a MockNetLoader.
			return INVALID_RESOURCE;
		}
		
		override protected function get dynamicStreamResource():MediaResourceBase
		{
			return null;
		}

		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.LOAD];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [ MediaTraitType.AUDIO
				   , MediaTraitType.BUFFER
				   , MediaTraitType.LOAD
				   , MediaTraitType.PLAY
				   , MediaTraitType.SEEK
				   , MediaTraitType.TIME
				   , MediaTraitType.DISPLAY_OBJECT
				   ];
		}
		
		override protected function get expectedMediaWidthOnInitialization():Number
		{
			// Default width for a Video object.
			return 320;
		}

		override protected function get expectedMediaHeightOnInitialization():Number
		{
			// Default height for a Video object.
			return 240;
		}
		
		override protected function get expectedMediaWidthAfterLoad():Number
		{
			return TestConstants.REMOTE_STREAMING_VIDEO_EXPECTED_WIDTH;
		}

		override protected function get expectedMediaHeightAfterLoad():Number
		{
			return TestConstants.REMOTE_STREAMING_VIDEO_EXPECTED_HEIGHT;
		}
		
		override protected function get supportsSubclips():Boolean
		{
			return true;
		}
		
		override protected function get expectedSubclipDuration():Number
		{
			return 3;
		}
		
		// Internals
		//

		private static const INVALID_RESOURCE:URLResource = new URLResource(new URL(TestConstants.INVALID_STREAMING_VIDEO));
		
		private var netFactory:NetFactory;
		private var loader:NetLoader;
	}
}

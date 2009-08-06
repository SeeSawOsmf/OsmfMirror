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
package org.openvideoplayer.image
{
	import flash.utils.Dictionary;
	
	import flexunit.framework.TestCase;
	
	import org.openvideoplayer.media.URLResource;
	import org.openvideoplayer.metadata.KeyValueFacet;
	import org.openvideoplayer.metadata.MediaType;
	import org.openvideoplayer.utils.MediaFrameworkStrings;
	import org.openvideoplayer.utils.NullResource;
	import org.openvideoplayer.utils.URL;
	
	/**
	 * Note that because ImageLoader must make network calls and cannot be
	 * mocked (due to Flash API restrictions around LoaderInfo), we only
	 * test a subset of the functionality here.  The rest is tested in the
	 * integration test suite, under TestImageLoaderIntegration.
	 * 
	 * Tests which do not require network access should be added here.
	 * 
	 * Tests which do should be added to TestImageLoaderIntegration.
	 **/
	public class TestImageLoader extends TestCase
	{
		public function testCanHandleResource():void
		{
			var loader:ImageLoader = new ImageLoader();
			
			// Verify some valid resources.
			assertTrue(loader.canHandleResource(new URLResource(new URL("assets/image.gif"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("http://example.com/image.gif"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("http://example.com/image.jpg"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("http://example.com/image.png"))));
			
			// And some invalid ones.
			assertFalse(loader.canHandleResource(new URLResource(new URL("http://example.com/image.foo"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("http://example.com/image"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("foo"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL(""))));
			assertFalse(loader.canHandleResource(new URLResource(null)));
			assertFalse(loader.canHandleResource(new NullResource()));
			assertFalse(loader.canHandleResource(null));

			// Verify some valid resources based on metadata information
			var dictionary:Dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] = MediaType.IMAGE;
			var metadata:KeyValueFacet = new KeyValueFacet(null, dictionary);
			var resource:URLResource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));
			
			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/png";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/gif";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/jpeg";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.IMAGE;
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/png";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.IMAGE;
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/gif";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.IMAGE;
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/jpeg";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			// Add some invalid cases based on metadata information
			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.SWF;
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "Invalide MIME Type";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.IMAGE;
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "Invalide MIME Type";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.SWF;
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "image/gif";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			dictionary = new Dictionary();
			dictionary[MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE] =  MediaType.SWF;
			dictionary[MediaFrameworkStrings.METADATA_KEY_MIME_TYPE] = "Invalide MIME Type";
			metadata = new KeyValueFacet(null, dictionary);
			resource = new URLResource(new URL("http://example.com/image"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));
		}
		
		public function testLoad():void
		{
			// See TestImageLoaderIntegration for the actual tests.
		}

		public function testUnload():void
		{
			// See TestImageLoaderIntegration for the actual tests.
		}
	}
}
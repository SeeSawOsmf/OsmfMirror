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
package org.osmf.elements
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.utils.TestConstants;

	public class TestImageElementIntegration extends TestImageOrSWFElementIntegration
	{
		override protected function createMediaElement():MediaElement
		{
			return new ImageElement(null, new ImageLoader()); 
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new URLResource(TestConstants.REMOTE_IMAGE_FILE);
		}
		
		override protected function get expectedBytesTotal():Number
		{
			// Size of resourceForMediaElement.
			return 42803;
		}
	}
}
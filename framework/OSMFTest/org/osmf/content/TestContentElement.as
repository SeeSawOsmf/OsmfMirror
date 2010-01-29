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
package org.osmf.content
{
	import flexunit.framework.TestCase;

	/**
	 * Note that because ContentLoader must make network calls and cannot be
	 * mocked (due to Flash API restrictions around LoaderInfo), we only
	 * test a subset of the functionality here.  The rest is tested in the
	 * integration test suite, under TestContentElementIntegration.
	 * 
	 * Tests which do not require network access should be added here.
	 * 
	 * Tests which do should be added to TestContentElementIntegration.
	 **/
	public class TestContentElement extends TestCase
	{
		public function testConstructor():void
		{
			try
			{
				var contentElement:ContentElement = new ContentElement();
				assertNotNull(contentElement);
				
				fail();
			}
			catch (e:ArgumentError)
			{
			}
			
			// See TestContentElementIntegration for more actual tests.
		}
	}
}
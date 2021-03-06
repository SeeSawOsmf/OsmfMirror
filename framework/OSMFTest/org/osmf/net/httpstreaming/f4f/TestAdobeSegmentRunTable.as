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
package org.osmf.net.httpstreaming.f4f
{
	import flash.utils.ByteArray;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.net.httpstreaming.AdobeBootstrapBoxDescriptor;
	import org.osmf.net.httpstreaming.HTTPStreamingTestsHelper;
	
	public class TestAdobeSegmentRunTable extends TestCase
	{
		override public function setUp():void
		{
			abstDescriptor = HTTPStreamingTestsHelper.createBasicAdobeBootstrapBoxDescriptor(); 						
			var bytes:ByteArray = HTTPStreamingTestsHelper.createAdobeBootstrapBox(abstDescriptor);

			var parser:BoxParser = new BoxParser();
			parser.init(bytes);
			var boxes:Vector.<Box> = parser.getBoxes();
			assertTrue(boxes.length == 1);
			
			abst = boxes[0] as AdobeBootstrapBox;
			assertTrue(abst != null);
			
			assertTrue(abst.segmentRunTables.length == 1);
			asrt = abst.segmentRunTables[0] as AdobeSegmentRunTable;
		}
		
		public function testFindSegmentIdByFragmentId():void
		{
			assertTrue(asrt.findSegmentIdByFragmentId(0) == 0);
			for (var i:int = 1; i <= 10; i++)
			{			
				assertTrue(asrt.findSegmentIdByFragmentId(i) == 1);
			}
			for (i = 11; i <= 15; i++)
			{			
				assertTrue(asrt.findSegmentIdByFragmentId(i) == 2);
			}
			assertTrue(asrt.findSegmentIdByFragmentId(16) == 3);
		}
		
		public function testTotalFragments():void
		{
			assertTrue(asrt.totalFragments == 15);
			assertTrue(abst.totalFragments == asrt.totalFragments);
		}
		
		// Internals
		//
		
		private var asrt:AdobeSegmentRunTable;
		private var abst:AdobeBootstrapBox;
		private var abstDescriptor:AdobeBootstrapBoxDescriptor;
	}
}
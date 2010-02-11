/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.netmocker
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.net.NetClient;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.dynamicstreaming.DynamicStreamingNetLoader;
	import org.osmf.traits.LoadTrait;
	

	public class MockDynamicStreamingNetLoader extends DynamicStreamingNetLoader implements IMockNetLoader
	{
		public function MockDynamicStreamingNetLoader(netConnectionFactory:NetConnectionFactory= null, mockNetNegotiatorFunction:Function = null)
		{
			mockNetNegotiatorFunction = mockNetNegotiatorFunction || createMockNetNegotiator;
			_netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			
			if (netConnectionFactory == null)
			{
				netConnectionFactory = new DefaultNetConnectionFactory(createMockNetNegotiator);
			}
			
			super(netConnectionFactory);
		}
		
		/**
		 * @inheritDoc
		 */
		public function set netConnectionExpectation(value:NetConnectionExpectation):void
		{
			_netConnectionExpectation = value;			
		}
		
		public function get netConnectionExpectation():NetConnectionExpectation
		{
			return _netConnectionExpectation;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set netStreamExpectedDuration(value:Number):void
		{
			_netStreamExpectedDuration = value;			
		}
		
		public function get netStreamExpectedDuration():Number
		{
			return _netStreamExpectedDuration;
		}
		
		/**
		 * @inheritDoc
		 **/
		public function set netStreamExpectedSubclipDuration(value:Number):void
		{
			_netStreamExpectedSubclipDuration = value;
		}
		
		public function get netStreamExpectedSubclipDuration():Number
		{
			return _netStreamExpectedSubclipDuration;
		}

		public function set netStreamExpectedWidth(value:Number):void
		{
			_netStreamExpectedWidth = value;			
		}
		
		public function get netStreamExpectedWidth():Number
		{
			return _netStreamExpectedWidth;
		}
		
		public function set netStreamExpectedHeight(value:Number):void
		{
			_netStreamExpectedHeight = value;			
		}
		
		public function get netStreamExpectedHeight():Number
		{
			return _netStreamExpectedHeight;
		}
		
		public function set netStreamExpectedEvents(value:Array):void
		{
			_netStreamExpectedEvents = value;			
		}
		
		public function get netStreamExpectedEvents():Array
		{
			return _netStreamExpectedEvents;
		}
		
	    /**
	     * @inheritDoc
	     **/
	    override protected function createNetStream(connection:NetConnection, loadTrait:LoadTrait):NetStream
	    {
			var mockNetStream:MockNetStream = new MockNetStream(connection);			
			mockNetStream.client = new NetClient();			
			mockNetStream.expectedDuration = _netStreamExpectedDuration;
			mockNetStream.expectedSubclipDuration = _netStreamExpectedSubclipDuration;
			mockNetStream.expectedWidth = _netStreamExpectedWidth;
			mockNetStream.expectedHeight = _netStreamExpectedHeight;
			mockNetStream.expectedEvents = _netStreamExpectedEvents;
			return mockNetStream;
	    }
	    
	    private function createMockNetNegotiator():MockNetNegotiator
	    {
	    	var mockNetNegotiator:MockNetNegotiator = new MockNetNegotiator();
	    	mockNetNegotiator.netConnectionExpectation = _netConnectionExpectation;
	    	return mockNetNegotiator;
	    }

		private var _netConnectionExpectation:NetConnectionExpectation;
	    private var _netStreamExpectedDuration:Number = 0;
	    private var _netStreamExpectedSubclipDuration:Number = NaN;
	    private var _netStreamExpectedWidth:Number = 0;
	    private var _netStreamExpectedHeight:Number = 0;
	    private var _netStreamExpectedEvents:Array = [];

		private var negotiator:MockNetNegotiator;   		
	}
}

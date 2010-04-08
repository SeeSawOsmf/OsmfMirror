/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.net.httpstreaming.dvr
{
	import flash.net.NetConnection;
	
	import org.osmf.elements.f4mClasses.DVRInfo;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.net.httpstreaming.HTTPNetStream
	import org.osmf.traits.TimeTrait;

	[ExcludeClass]

	/**
	 * @private
	 */	
	public class HTTPStreamingDVRCastTimeTrait extends TimeTrait
	{
		public function HTTPStreamingDVRCastTimeTrait(connection:NetConnection, stream:HTTPNetStream, dvrInfo:DVRInfo)
		{
			super(NaN);

			_connection = connection;
			_stream = stream; 
			_dvrInfo = dvrInfo;
			_stream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
		}
		
		override public function get duration():Number
		{
			if (_dvrInfo == null)
			{
				return NaN;
			}
			
			return _dvrInfo.curLength;
		}
		
		override public function get currentTime():Number
		{
			return _stream.time;
		}
		
		//
		// Internal
		//
		
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dvrInfo = event.info as DVRInfo;
		}
		
		private var _connection:NetConnection;
		private var _stream:HTTPNetStream;
		private var _dvrInfo:DVRInfo;
	}
}
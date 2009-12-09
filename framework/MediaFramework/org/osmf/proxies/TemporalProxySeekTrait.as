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
package org.osmf.proxies
{
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	internal class TemporalProxySeekTrait extends SeekTrait
	{
		public function TemporalProxySeekTrait(temporal:TimeTrait)
		{
			super(temporal);
		}
		
		override protected function processSeekingChange(newSeeking:Boolean, time:Number):void
		{
			if (newSeeking)
			{
				lastSeekTime = time;
			}
		}
		
		override protected function postProcessSeekingChange():void
		{
			super.postProcessSeekingChange();

			// Auto-complete any in-progress seek operation.
			if (seeking == true)
			{
				processSeekCompletion(lastSeekTime);
			}
		}
		
		private var lastSeekTime:Number;
	}
}
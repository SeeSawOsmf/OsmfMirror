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
package org.openvideoplayer.events
{
	import flash.events.Event;

	/**
	 * The TraitEvent class is the base class for events dispatched by
	 * traits.
	 */	
	public class TraitEvent extends Event
	{
		/**
		 * Dispatched when the <code>position</code>
		 * of a trait that implements the ITemporal interface first matches
		 * its <code>duration</code>.
		 * <p>The TraitEvent.DURATION_REACHED constant defines the value
		 * of the type property of the event object for a durationReached
		 * event.</p>
		 * 
		 * 
		 * @eventType DURATION_REACHED
		 * 
		 */		
		public static const DURATION_REACHED:String = "durationReached";
		
		/**
		 * @inheritDoc 
		 */		
		public function TraitEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
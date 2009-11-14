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
package org.osmf.events
{
	import flash.events.Event;
	
	/**
	 * A TimeEvent is dispatched when properties of an ITemporal trait have changed.
	 */	     
	public class TimeEvent extends Event
	{       	
		/**
		 * The TimeEvent.CURRENT_TIME_CHANGE constant defines the value of the
		 * type property of the event object for a currentTimeChange event. 
		 */	
		public static const CURRENT_TIME_CHANGE:String = "currentTimeChange";
		
		/**
		 * The TimeEvent.DURATION_CHANGE constant defines the value
		 * of the type property of the event object for a durationChange
		 * event.
		 */		
		public static const DURATION_CHANGE:String = "durationChange";

		/**
		 * The TimeEvent.DURATION_REACHED constant defines the value
		 * of the type property of the event object for a durationReached
		 * event.
		 */		
		public static const DURATION_REACHED:String = "durationReached";

		/**
		 * Constructor
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param time The new time for the event.  The property to which this value applies depends
 		 * on the event type constant. 
		 */		
		public function TimeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, time:Number=NaN)
		{			
			super(type, bubbles, cancelable);
			
			_time = time;
		}
			
		/**
		 * New time value resulting from this change.  For currentTimeChange events, this
		 * corresponds to the currentTime property.  For durationChange events, this corresponds
		 * to the duration property.  For durationReached events, this is unused.
		 */		
		public function get time():Number
		{
			return _time;
		}
					
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TimeEvent(type, bubbles, cancelable, time);
		}
			
		// Internals
		//
				
		private var _time:Number;		    
	}
}
		

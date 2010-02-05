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

package org.osmf.layout
{
	import flash.events.Event;

	public class LayoutRendererChangeEvent extends Event
	{
		public static const LAYOUT_RENDERER_CHANGE:String = "layoutRendererChange";
		public static const PARENT_LAYOUT_RENDERER_CHANGE:String = "parentLayoutRendererChange";
		
		public function LayoutRendererChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, oldValue:LayoutRendererBase = null, newValue:LayoutRendererBase = null)
		{
			super(type, bubbles, cancelable);
			
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		public function get oldValue():LayoutRendererBase
		{
			return _oldValue;
		}
		
		public function get newValue():LayoutRendererBase
		{
			return _newValue;
		}
		
		// Overrides
		//
		
		override public function clone():Event
		{
			return new(type, bubbles, cancelable, _oldValue, _newValue);
		}
		
		// Internals
		//
		
		private var _oldValue:LayoutRendererBase;
		private var _newValue:LayoutRendererBase;
	}
}
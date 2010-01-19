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

package org.osmf.chrome.controlbar.widgets
{
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	
	import org.osmf.chrome.controlbar.ControlBarWidget;
	import org.osmf.chrome.fonts.Fonts;
	
	public class Label extends ControlBarWidget
	{
		public function Label(width:Number = 52)
		{
			textField = Fonts.getDefaultTextField();
			textField.height = 20;
			textField.width = width;
			textField.alpha = 0.4;
			textField.text = "";
			addChild(textField);
			
			super();
		}
		
		public function get text():String
		{
			return textField.text;
		}
		
		public function set text(value:String):void
		{
			textField.text = value;
		}
		
		// Internals
		//
		
		private var textField:TextField;
	}
}
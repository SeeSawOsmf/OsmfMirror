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
	import org.osmf.chrome.controlbar.ControlBarBase;
	import org.osmf.metadata.Facet;
	import org.osmf.metadata.FacetKey;
	
	public class PinDownButton extends PinUpButton
	{
		[Embed("../assets/images/pinDown_up.png")]
		public var pinDownUpType:Class;
		[Embed("../assets/images/pinDown_down.png")]
		public var pinDownDownType:Class;
		[Embed("../assets/images/pinDown_disabled.png")]
		public var pinDownDisabledType:Class;
		
		public function PinDownButton(up:Class = null, down:Class = null, disabled:Class = null)
		{
			super(up || pinDownUpType, down || pinDownDownType, disabled || pinDownDisabledType);
		}
		
		override protected function controlBarAutoHideChangeCallback(value:Facet):void
		{
			visible = value && value.getValue(new FacetKey(ControlBarBase.METADATA_AUTO_HIDE_URL)) == true;
		}
	}
}
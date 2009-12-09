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
package org.osmf.utils
{
	import org.osmf.media.IMediaResource;
	import org.osmf.metadata.Metadata;
	
	public class SimpleResource implements IMediaResource
	{
		public static const SUCCESSFUL:String = "successful";
		public static const FAILED:String = "failed";
		public static const UNHANDLED:String = "unhandled";
		
		public function SimpleResource(type:String)
		{
			_type = type;
		}
		
		public function get type():String
		{
			return _type;
		}

		public function get metadata():Metadata
		{
			if (_metadata == null)
			{
				_metadata = new Metadata();
			}
			return _metadata;
		}
		
		private var _metadata:Metadata;
		private var _type:String;
	}
}
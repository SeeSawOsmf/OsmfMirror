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
*  Contributor(s): Adobe Systems Inc.
*  
*****************************************************/
package org.openvideoplayer.vast.model
{
	/**
	 * This class represents a URL in a VAST document.
	 */
	public class VASTUrl
	{
		/**
		 * Constructor.
		 * 
		 * @param url The URL.
		 * @param id An optional id associated with the URL.
 * 		 */
		public function VASTUrl(url:String, id:String=null) 
		{
			_url = url;
			_id = id;
		}

		/**
		 * The URL.
		 */
		public function get url():String 
		{
			return _url;
		}

		/**
		 * An optional id associated with the URL.
		 */
		public function get id():String 
		{
			return _id;
		}
		
		private var _url:String;		
		private var _id:String;
	}
}
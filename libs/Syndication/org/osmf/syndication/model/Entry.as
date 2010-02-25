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
package org.osmf.syndication.model
{
	import org.osmf.syndication.model.extensions.FeedExtension;
	
	public class Entry
	{
		/**
		 * The title of the item.
		 **/
		public function get title():String
		{
			return _title;
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}
		
		/**
		 * Describes a media object that is attached
		 * to the item.
		 **/
		public function get enclosure():Enclosure
		{
			return _enclosure;
		}
		
		public function set enclosure(value:Enclosure):void
		{
			_enclosure = value;
		}

		/**
		 * The collection of FeedExtension objects.
		 **/
		public function get feedExtensions():Vector.<FeedExtension>
		{
			return _feedExtensions;
		}
		
		public function set feedExtensions(value:Vector.<FeedExtension>):void
		{
			_feedExtensions = value;	
		}

		private var _title:String;
		private var _enclosure:Enclosure;
		private var _feedExtensions:Vector.<FeedExtension>;
	}
}
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
	import org.osmf.media.IMediaReferrer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.ILoader;

	public class DynamicReferenceMediaElement extends DynamicMediaElement implements IMediaReferrer
	{
		public function DynamicReferenceMediaElement(referenceUrlToMatch:String, traitTypes:Array=null, loader:ILoader=null, resource:MediaResourceBase=null)
		{
			super(traitTypes, loader, resource);
			
			_references = new Array();
			this.referenceUrlToMatch = referenceUrlToMatch;
		}
		
		public function canReferenceMedia(target:MediaElement):Boolean
		{
			// It can reference any DynamicMediaElement whose URL contains
			// a predefined string.
			return 		target is DynamicMediaElement
					&&	target.resource is URLResource
					&&  referenceUrlToMatch != null
					&&  URLResource(target.resource).url.rawUrl == referenceUrlToMatch;
		}

		public function addReference(target:MediaElement):void
		{
			_references.push(target);
		}
		
		public function get references():Array
		{
			return _references;
		}
		
		private var referenceUrlToMatch:String;
		private var _references:Array;
	}
}
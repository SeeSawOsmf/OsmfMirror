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
package org.openvideoplayer.regions
{
	import org.openvideoplayer.media.MediaElement;
	
	/**
	 * IRegion defines the interface of objects within the OSMF that
	 * act as a gateway to one or more MediaElements.
	 */	
	public interface IRegion
	{
		/**
		 * Adds a MediaElement instance to the region.
		 * 
		 * @param element The MediaElementInstance to add to the region.
		 * @throws IllegalOperationError if the specified element is null,
		 * or already a child of the region.
		 */		
		function addChildElement(element:MediaElement):void;
		
		
		/**
		 * Removes a MediaElement instance from the region.
		 * 
		 * @param element The element to remove from the region.
		 * @return The removed MediaElement instance.
		 * @throws IllegalOperationError if the specified element isn't
		 * a child element, or is null.
		 */
		function removeChildElement(element:MediaElement):MediaElement;
		
		/**
		 * Verifies if an element is a child of the region.
		 *  
		 * @param element Element to verify.
		 * @return True if the element if a child of the region.
		 */		
		function containsElement(element:MediaElement):Boolean;
	}
}
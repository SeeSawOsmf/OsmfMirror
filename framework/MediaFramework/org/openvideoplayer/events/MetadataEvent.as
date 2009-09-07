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
	
	import org.openvideoplayer.metadata.IFacet;

	/**
	 * Metadata Events are dispatched by the IMetadata object when 
	 * IFacets are added or removed from the metadata collection.
	 */ 
	public class MetadataEvent extends Event
	{
		/**
		 * Dispatched when a value is added to a IFacet.
		 */ 
		public static const FACET_ADD:String = "facetAdd";
		
		/**
		 * Dispatched when a value is removed from a IFacet.
		 */ 
		public static const FACET_REMOVE:String = "facetRemove";
					
		/**
		 * Constructs a new metadata event.  
		 * @param facet the facet that is changing.
		 */ 				
		public function MetadataEvent(facet:IFacet, type:String, 
		                              bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_facet = facet;			
		}
		
		/**
		 *  @returns The metadata IFacet associated with this event. 
		 */ 
		public function get facet():IFacet
		{
			return _facet;
		}
		
		/**
		 * @private
		 */ 
		override public function clone():Event
		{
			return new MetadataEvent(_facet, type, bubbles, cancelable);
		}
		
		private var _facet:IFacet;		
	}
}
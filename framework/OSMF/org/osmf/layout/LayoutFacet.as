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
	import org.osmf.metadata.Facet;
	import org.osmf.metadata.FacetSynthesizer;
	import org.osmf.metadata.NullFacetSynthesizer;

	/**
	 * @private
	 *
	 * Base class for the default renderer's layout facets.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	internal class LayoutFacet extends Facet
	{
		/**
		 * @private
		 *
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function LayoutFacet(namespaceURL:String)
		{
			super(namespaceURL);
			
			_synthesizer = new NullFacetSynthesizer(namespaceURL);
		}
		
		/**
		 * @private
		 */	
		override public function get synthesizer():FacetSynthesizer
		{
			return _synthesizer;
		}
		
		// Internals
		//
		
		private var _synthesizer:NullFacetSynthesizer;
	}
}
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
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ILayoutContext defines the interface to the objects that an LayoutRenderer
	 * implementing instance requires in order to calculate and effect the spatial
	 * characteristics of its targets.
	 * 
	 * An ILayoutContext exposes a container property of type DisplayObjectContainer
	 * that LayoutRenderer implementing classes may use to stage and unstage their
	 * targets, as well as to manage the z-ordering of their targets.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public interface ILayoutContext extends ILayoutTarget
	{
		/**
		 * Defines the DisplayObjectContainer instance that an LayoutRenderer class
		 * may use to to stage and unstage their targets, as well as to manage the
		 * z-ordering of their targets.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		function get container():DisplayObjectContainer;
		
		/**
		 * Defines the index that the LayoutRenderer class should use on staging
		 * its first target onto the container. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		function get firstChildIndex():uint;
	
		/**
		 * Defines the layout renderer that manages this target's children (if any).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		function get layoutRenderer():LayoutRenderer;
		function set layoutRenderer(value:LayoutRenderer):void;
		
		/**
		 * Method invoked by an LayoutRenderer class to inform the context that it
		 * should recalculate its intrinsicWidth and intrinsicHeight fields:
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		function updateIntrinsicDimensions():void
		
		/**
		 * Defines the context's last calculated width.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		function get calculatedWidth():Number;
	 	function set calculatedWidth(value:Number):void;
	 	
	 	/**
	 	 * Defines the context's last calculated height.
	 	 *  
	 	 *  @langversion 3.0
	 	 *  @playerversion Flash 10
	 	 *  @playerversion AIR 1.5
	 	 *  @productversion OSMF 1.0
	 	 */
	 	function get calculatedHeight():Number;
	 	function set calculatedHeight(value:Number):void;
	 	
	 	/**
	 	 * Defines the context's last projected width.
	 	 *  
	 	 *  @langversion 3.0
	 	 *  @playerversion Flash 10
	 	 *  @playerversion AIR 1.5
	 	 *  @productversion OSMF 1.0
	 	 */
	 	function get projectedWidth():Number;
	 	function set projectedWidth(value:Number):void;
	 	
	 	/**
	 	 * Defines the context's last projected height.
	 	 *  
	 	 *  @langversion 3.0
	 	 *  @playerversion Flash 10
	 	 *  @playerversion AIR 1.5
	 	 *  @productversion OSMF 1.0
	 	 */
	 	function get projectedHeight():Number;
	 	function set projectedHeight(value:Number):void;
	}
}
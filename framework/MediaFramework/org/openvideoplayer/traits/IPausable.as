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
package org.openvideoplayer.traits
{
	import org.openvideoplayer.media.IMediaTrait;

	/**
	 * Dispatched when the IPausable's <code>paused</code> property has changed.
	 * 
	 * @eventType org.openvideoplayer.events.PausedChangeEvent.PAUSED_CHANGE
	 */
	[Event(name="pausedChange",type="org.openvideoplayer.events.PausedChangeEvent")]

	/**
	 * IPausable defines the trait interface for media that can be paused. 
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.Pausable)</code> method to query
	 * whether a media element has a trait that implements this interface. 
	 * If <code>hasTrait(MediaTraitType.Pausable)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.Pausable)</code> method
	 * to get an object that is guaranteed to implement the IPausable interface.</p>
	 * <p>Through its MediaElement, an IPausable trait can participate in media compositions.
	 * See the applicable class in the composition package for details about its behavior
	 * in this context.</p>
	 * 
	 * @see org.openvideoplayer.composition
	 * @see org.openvideoplayer.media.MediaElement
	 */	
	public interface IPausable extends IMediaTrait
	{
		/**
		 * Indicates whether the media is paused.
		 */		
		function get paused():Boolean;
		
		/**
		 * Pauses the media if it is not already paused. 
		 */		
		function pause():void;
	}
}
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
package org.osmf.media
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.MediaFrameworkStrings;
	
	/**
	 * Dispatched when the resolver's resolvedTrait property changed.
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Abstract base class for objects that keep a list of traits of similar type, capable
	 * of pointing out a so called "active" trait, that currently represents the group.
	 */	
	public class MediaTraitResolver extends EventDispatcher
	{
		/**
		 * Constructor
		 *  
		 * @param type The type of traits that this resolver will be resolving.
		 * 
		 * @throws ArgumentError If type is null.
		 */		
		public function MediaTraitResolver(type:MediaTraitType)
		{
			if (type == null)
			{
				throw new ArgumentError(MediaFrameworkStrings.NULL_PARAM);
			}
			
			_type = type;
		}
		
		/**
		 * Defines the media trait type that the resolver handles.
		 */		
		final public function get type():MediaTraitType
		{
			return _type;
		}
		
		/**
		 * Method for use by subclasses to set the resolved trait.
		 * @param value The trait instance to set as the resolved trait.
		 */		
		final protected function setResolvedTrait(value:IMediaTrait):void
		{
			if (value != _resolvedTrait)
			{
				if (_resolvedTrait)
				{ 
					_resolvedTrait = null;
					dispatchEvent(new Event(Event.CHANGE));
				}
				
				_resolvedTrait = value;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Defines the trait instance that currently represents the group of traits as
		 * a whole.
		 */
		final public function get resolvedTrait():IMediaTrait
		{
			return _resolvedTrait;	
		}
		
		/**
		 * Adds a trait instance to the resolver. Whether the specified instance gets
		 * added is at the discretion of the implementing resolver. If the method
		 * returns false, then the instance was not added.
		 * 
		 * @param instance The instance to add.
		 * @throws ArgumentError If the passed trait is null, or if the trait's type
		 * does not match the resolver's trait type.
		 */		
		final public function addTrait(instance:IMediaTrait):void
		{	
			if (instance == null)
			{
				throw new ArgumentError(MediaFrameworkStrings.NULL_PARAM);
			}
			if (instance is type.traitInterface == false)
			{
				throw new ArgumentError(MediaFrameworkStrings.TRAIT_TYPE_MISMATCH);
			}
			
			processAddTrait(instance);
		}
		 
		 /**
		 * Removes a trait instance from the resolver. Whether the specified instance gets
		 * removed is at the discretion of the implementing resolver. If the method
		 * returns false, then the instance was not removed.
		 * 
		 * @param instance The instance to remove.
		 * @return The instance that was removed. Null if no matching instance was found.
		 * @throws ArgumentError If the passed trait is null, or if the trait's type
		 * does not match the resolver's trait type.
		 */	
		final public function removeTrait(instance:IMediaTrait):IMediaTrait
		{
			if (instance == null)
			{
				throw new ArgumentError(MediaFrameworkStrings.NULL_PARAM);
			}
			if (instance is type.traitInterface == false)
			{
				throw new ArgumentError(MediaFrameworkStrings.TRAIT_TYPE_MISMATCH);
			}
			
			return processRemoveTrait(instance);
		}
		
		// Subclass stubs
		//
		
		protected function processAddTrait(instance:IMediaTrait):void
		{	
		}
		
		protected function processRemoveTrait(instance:IMediaTrait):IMediaTrait
		{
			return null;
		}
		
		private var _type:MediaTraitType;
		private var _resolvedTrait:IMediaTrait;
	}
}
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
*  Contributor(s): Adobe Systems Incorporated.
* 
*****************************************************/

package org.openvideoplayer.traits
{
	import flash.errors.IllegalOperationError;
	
	import org.openvideoplayer.events.SwitchingChangeEvent;
	import org.openvideoplayer.events.TraitEvent;
	import org.openvideoplayer.net.dynamicstreaming.SwitchingDetail;
	import org.openvideoplayer.net.dynamicstreaming.SwitchingDetailCodes;
	import org.openvideoplayer.utils.MediaFrameworkStrings;
	
	/**
	 * Dispatched when a stream switch is requested, completed, or failed.
	 * 
	 * @eventType org.openvideoplayer.events.SwitchingChangeEvent.SWITCHING_CHANGE
	 */
	[Event(name="switchingChange",type="org.openvideoplayer.events.SwitchingChangeEvent")]
	
	/**
	 * Dispatched when the number of indices or associated bitrates have changed.
	 * 
	 * @eventType org.openvideoplayer.events.TraitEvent.INDICES_CHANGE
	 */
	[Event(name="indicesChange",type="org.openvideoplayer.events.TraitEvent")]

		
		
	/**
	 * The SwitchableTrait class provides a base ISwitchable implementation.
	 * It can be used as the base class for a more specific Switchable trait
	 * subclass.
	 */	
	public class SwitchableTrait extends MediaTraitBase implements ISwitchable
	{
		/**
		 * Creates a new SwitchableTrait with the ability to switch to.  The
		 * maxIndex is initially set to numIndices - 1.
		 * @param autoSwitch the initial autoSwitch state for the trait.
		 * @param currentIndex the start index for the swichable trait.
		 * @param numIndices the maximum value allow to be set on maxIndex 
		 */ 
		public function SwitchableTrait(autoSwitch:Boolean=true, currentIndex:int=0, numIndices:int=1)
		{
			super();	
			_autoSwitch = autoSwitch;
			_currentIndex = currentIndex;		
			this.numIndices = numIndices;
		}
		
		/**
		 * The number of indices this trait can switch between.
		 **/
		public function get numIndices():int
		{
			return _numIndices;
		}
		
		public function set numIndices(value:int):void
		{
			if (value != _numIndices)
			{
				_numIndices = value;
				maxIndex = _numIndices - 1;
				
				dispatchEvent(new TraitEvent(TraitEvent.INDICES_CHANGE));
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get autoSwitch():Boolean
		{			
			return _autoSwitch;
		}
		
		/**
		 * @inheritDoc
		 * This property defaults to true.
		 */
		public function set autoSwitch(value:Boolean):void
		{
			if (autoSwitch != value)
			{
				if (canProcessAutoSwitchChange(value))
				{
					_autoSwitch = value;
					processAutoSwitchChange(value);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get currentIndex():int
		{
			return _currentIndex;
		}
		
		/**
		 * @inheritDoc
		 */ 
		public function getBitrateForIndex(index:int):Number
		{
			if (index > (numIndices-1) || index < 0)
			{
				throw new RangeError(MediaFrameworkStrings.STREAMSWITCH_INVALID_INDEX);
			}
			return -1;
		}
			
		/**
		 * @inheritDoc
		 */	
		public function get maxIndex():int
		{
			return _maxIndex;
		}
		
		public function set maxIndex(value:int):void
		{
			if (maxIndex != value)
			{
				if (canProcessMaxIndexChange(value))
				{
					processMaxIndexChange(value);
					_maxIndex = value;
				}
			}		
		}
		
		/**
		 * @inheritDoc
		 */
		public function get switchUnderway():Boolean
		{			
			return (switchState == SwitchingChangeEvent.SWITCHSTATE_REQUESTED);
		}
		
		/**
		 * @inheritDoc
		 */ 		
		public function switchTo(index:int):void
		{
			if (autoSwitch)
			{
				throw new IllegalOperationError(MediaFrameworkStrings.STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE);
			}
			else if (index != currentIndex)
			{
				if (canProcessSwitchTo(index))
				{
					var detail:SwitchingDetail = new SwitchingDetail(SwitchingDetailCodes.SWITCHING_MANUAL);
					
					processSwitchState(SwitchingChangeEvent.SWITCHSTATE_REQUESTED, detail);
					_currentIndex = index;
					processSwitchTo(index);
					postProcessSwitchTo(detail);
				}
			}			
		}
		
		/**
		 * Returns if this trait can change autoSwitch mode.
		 */ 
		protected function canProcessAutoSwitchChange(value:Boolean):Boolean
		{
			return true; 
		}
		
		/**
		 * Does the actual processing of changes to the autoSwitch property
		 */ 
		protected function processAutoSwitchChange(value:Boolean):void
		{			
			// autoswitching is processed here
		}
				
		/**
		 * Returns if this trait can switch to the specified stream index.
		 */ 
		protected function canProcessSwitchTo(index:int):Boolean
		{
			validateIndex(index);
			return true; 
		}
		
		/**
		 * 
		 */ 
		protected function validateIndex(index:int):void
		{
			if (index < 0 || index > maxIndex)
			{
				throw new RangeError(MediaFrameworkStrings.STREAMSWITCH_INVALID_INDEX);
			}
		}
		
		/**
		 * Does the actual switching of indices.
		 */ 
		protected function processSwitchTo(value:int):void
		{			
			// switchTo is processed here
		}
		
		/**
		 * Fires the SwitchState complete event
		 */ 
		protected function postProcessSwitchTo(detail:SwitchingDetail = null):void
		{
			processSwitchState(SwitchingChangeEvent.SWITCHSTATE_COMPLETE, detail);
		}
		
		/**
		 * Does the acutal switching of indices.
		 */ 
		protected function processSwitchState(newState:int, detail:SwitchingDetail = null):void
		{			
			var oldState:int = switchState;
			switchState = newState;
			dispatchEvent(new SwitchingChangeEvent(newState, oldState, detail));
		}
		
		/**
		 * Returns if this trait can change the max index to specified value
		 */ 
		protected function canProcessMaxIndexChange(value:int):Boolean
		{
			if (value < 0 || value >= numIndices)
			{				
				throw new RangeError(MediaFrameworkStrings.STREAMSWITCH_INVALID_INDEX);
			}
			
			return true;
		}
		
		/**
		 * Does the setting of the max index.
		 */ 
		protected function processMaxIndexChange(value:int):void
		{			
			// MaxIndex is proccessed here
		}
					
		/**
		 * Backing variable for autoSwitch
		 */ 	
		private var _autoSwitch:Boolean;
		
		/**
		 * Backing variable for currentIndex
		 */ 
		private var _currentIndex:int = 0;
	
		/**
		 * Backing variable for maxIndex
		 */ 
		private var _maxIndex:int = 0;
		
		/**
		 * tracks the number of possible indices
		 */ 
		private var _numIndices:int;
		
		/**
		 * Tracks the current switching state of this trait.  
		 * See SwitchingChangeEvent for all possible states.
		 */ 
		private var switchState:int = SwitchingChangeEvent.SWITCHSTATE_UNDEFINED;
	}
}

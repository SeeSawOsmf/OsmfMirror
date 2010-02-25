/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.elements.compositeClasses
{
	import org.osmf.events.DVREvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	internal class CompositeDVRTrait extends DVRTrait implements IReusable
	{
		/**
	 	 * @private
	 	 */
		public function CompositeDVRTrait(traitAggregator:TraitAggregator, owner:MediaElement, mode:String) 
		{
			this.traitAggregator = traitAggregator;
			this.mode = mode;
			
			traitAggregationHelper
				= new TraitAggregationHelper
					( traitType
					, traitAggregator
					, processAggregatedChild
					, processUnaggregatedChild
					);
					
			super();
		}
	
		// IReusable
		//
		
		/**
		 * @private
		 */
		public function attach():void
		{
			traitAggregationHelper.attach();
		}
		
		/**
		 * @private
		 */
		public function detach():void
		{
			traitAggregationHelper.detach();
		}
		
		// Overrides
		//
		
		override public function get livePosition():Number
		{
			var result:Number;
			
			if (mode == CompositionMode.SERIAL)
			{
				if (traitAggregator.listenedChild != null)
				{
					var dvrTrait:DVRTrait = DVRTrait(traitAggregator.listenedChild.getTrait(MediaTraitType.DVR));
					result = dvrTrait.livePosition;
					
					var timeTrait:TimeTrait = TimeTrait(traitAggregator.listenedChild.getTrait(MediaTraitType.TIME));
					
					var precedingDuration:Number = 0;
					var precedingDurationSet:Boolean;
					
					// Add the sum of all preceding temporal object's duration:
					traitAggregator.forEachChildTrait
						( function(peerTimeTrait:TimeTrait):void
						  	{
						  		if (precedingDurationSet == false)
						  		{
									if (peerTimeTrait == timeTrait)
									{
										// We're done:
										precedingDurationSet = true;
									}
									else
									{
										precedingDuration += peerTimeTrait.duration;
									}
						  		}
						  	}
						, MediaTraitType.TIME
						);
						
					result += precedingDuration;
				}
			}
			else // PARALLEL
			{
				traitAggregator.forEachChildTrait
					( function(dvrTrait:DVRTrait):void
						{
							var childPosition:Number = dvrTrait.livePosition;
							
							result
								= isNaN(result)
									? childPosition
									: Math.min(childPosition, result);	
						}
					, MediaTraitType.DVR
					);
			}
			
			return result;
		}
		
		
		// Internals
		//
		
		private function processAggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{
			child.addEventListener(DVREvent.IS_RECORDING_CHANGE, onChildIsRecordingChange);
		}
		
		private function processUnaggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{
			child.removeEventListener(DVREvent.IS_RECORDING_CHANGE, onChildIsRecordingChange);
		}
		
		private function onChildIsRecordingChange(event:DVREvent):void
		{
			var dvrTrait:DVRTrait = DVRTrait(event.target);
			
			if (mode == CompositionMode.SERIAL)
			{
				// isRecording must be true if the active child's isRecording
				// property is true:
				if	(	traitAggregator.listenedChild
					&&	(	traitAggregator.listenedChild.getTrait(MediaTraitType.DVR)
						== 	dvrTrait
						)
					)
				{
					// The active child's trait changed value: update ours
					// accordingly:
					setIsRecording(dvrTrait.isRecording);
				}
			}
			else // PARALLEL
			{
				// isRecording must be true if at least one of the children
				// is recording:				
				var newIsRecording:Boolean;
				traitAggregator.forEachChildTrait
					( function(dvrTrait:DVRTrait):void
						{
							newIsRecording ||= dvrTrait.isRecording;	
						}
					, MediaTraitType.DVR
					);
					
				if (isRecording != newIsRecording)
				{
					setIsRecording(newIsRecording);
				}
			}
		}
		
		private var mode:String;
		private var traitAggregator:TraitAggregator;
		
		private var traitAggregationHelper:TraitAggregationHelper;
	}
}
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
package org.osmf.net.httpstreaming.f4f
{
	import __AS3__.vec.Vector;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Fragment run table. Each entry in the table is the first fragment of a sequence of 
	 * fragments that have the same duration.
	 */
	internal class AdobeFragmentRunTable extends FullBox
	{
		/**
		 * Constructor
		 * 
		 * @param bi The box info that contains the size and type of the box
		 * @param parser The box parser to be used to assist constructing the box
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function AdobeFragmentRunTable()
		{
			super();
			
			_fragmentDurationPairs = new Vector.<FragmentDurationPair>();
		}
		
		/**
		 * The time scale for this run table.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get timeScale():uint
		{
			return _timeScale;
		}
		
		public function set timeScale(value:uint):void
		{
			_timeScale = value;
		}

		/**
		 * The quality segment URL modifiers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get qualitySegmentURLModifiers():Vector.<String>
		{
			return _qualitySegmentURLModifiers;
		}

		public function set qualitySegmentURLModifiers(value:Vector.<String>):void
		{
			_qualitySegmentURLModifiers = value;
		}

		/**
		 * A list of <first fragment, duration> pairs.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fragmentDurationPairs():Vector.<FragmentDurationPair>
		{
			return _fragmentDurationPairs;
		}
		
		/**
		 * Append a fragment duration pair to the list. The accrued duration for the newly appended
		 * fragment duration needed to be calculated. This is basically the total duration till the
		 * time spot that the newly appended fragment duration pair represents.
		 * 
		 * @param fdp The <first fragment, duration> pair to be appended to the list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addFragmentDurationPair(fdp:FragmentDurationPair):void
		{
			_fragmentDurationPairs.push(fdp);
		}
		
		/**
		 * The total duration of the movie in terms of the time scale used. It is basically
		 * the duration accrued until the last fragment duration pair plus the duration for the
		 * last fragment duration pair.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get totalDuration():uint
		{
			var lastFdp:FragmentDurationPair 
				= _fragmentDurationPairs.length <= 0 ? null : _fragmentDurationPairs[_fragmentDurationPairs.length - 1];
				
			return (lastFdp != null) ? lastFdp.durationAccrued + lastFdp.duration : 0;
		}
		
		/**
		 * Given a time spot in terms of the time scale used by the fragment table, returns the corresponding
		 * Id of the fragment that contains the time spot.
		 * 
		 * @return the Id of the fragment that contains the time spot.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function findFragmentIdByTime(time:Number):Number
		{
			if (_fragmentDurationPairs.length <= 0)
			{
				return 0;
			}
			
			var fdp:FragmentDurationPair = null;
			
			for (var i:uint = 1; i < _fragmentDurationPairs.length; i++)
			{
				fdp = _fragmentDurationPairs[i];
				if (fdp.durationAccrued >= time)
				{
					return validateFragment(calculateFragmentId(_fragmentDurationPairs[i - 1], time));
				}
			}
			
			return validateFragment(calculateFragmentId(_fragmentDurationPairs[_fragmentDurationPairs.length - 1], time));
		}
		
		public function validateFragment(fragId:uint):Number
		{
			var size:uint = _fragmentDurationPairs.length - 1;
			for (var i:uint = 0; i < size; i++)
			{
				var curFdp:FragmentDurationPair = _fragmentDurationPairs[i];
				var nextFdp:FragmentDurationPair = _fragmentDurationPairs[i+1];
				
				if (curFdp.firstFragment <= fragId && fragId < nextFdp.firstFragment)
				{
					if (curFdp.duration > 0)
					{
						return fragId;
					}
					
					curFdp = findValidFragmentDurationPair(i + 1);
					if (curFdp == null)
					{
						return NaN;
					}
					
					return curFdp != null? curFdp.firstFragment : NaN;
				}
			}
			
			if (fragId >= _fragmentDurationPairs[size].firstFragment)
			{
				return _fragmentDurationPairs[size].duration > 0 ? fragId : NaN;
			}
			
			return NaN;
		}
		
		// Internal
		//
		
		private function findValidFragmentDurationPair(index:uint):FragmentDurationPair
		{
			for (var i:uint = index; index < _fragmentDurationPairs.length; i++)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				if (fdp.duration > 0)
				{
					return fdp;
				}
			}
			
			return null;
		}
		
		private function calculateFragmentId(fdp:FragmentDurationPair, time:Number):uint
		{
			return fdp.firstFragment + ((uint)(time - fdp.durationAccrued)) / fdp.duration;
		}

		private var _timeScale:uint;
		private var _qualitySegmentURLModifiers:Vector.<String>;
		private var _fragmentDurationPairs:Vector.<FragmentDurationPair>;
	}
}

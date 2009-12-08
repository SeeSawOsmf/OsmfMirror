﻿/*****************************************************
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
package org.osmf.audio
{
	import flash.media.Sound;
	
	import org.osmf.traits.ILoadedContext;
	
	/**
	 * The SoundLoadedContext contains information about the output of the
	 * SoundLoader's load operation.
	 */
	internal class SoundLoadedContext implements ILoadedContext
	{
		/**
		 *  Constructor.
		 * 	@param sound A new Sound object that has been
		 * 	successfully loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function SoundLoadedContext(sound:Sound)
		{
			_sound = sound;
		}

		/**
		 * The Sound to be used by a AudioElement.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get sound():Sound
		{
			return _sound;
		}
		
		private var _sound:Sound;
	}
}
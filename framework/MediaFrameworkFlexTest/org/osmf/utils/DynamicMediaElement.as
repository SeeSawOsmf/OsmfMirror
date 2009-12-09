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
package org.osmf.utils
{
	import org.osmf.events.SeekEvent;
	import org.osmf.media.IMediaResource;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.ILoader;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.traits.ViewTrait;
	
	public class DynamicMediaElement extends MediaElement
	{
		public function DynamicMediaElement(traitTypes:Array=null, loader:ILoader=null, resource:IMediaResource=null, useDynamicTraits:Boolean=false)
		{
			this.resource = resource;
			
			var doCreateSeekTrait:Boolean = false;
			
			if (traitTypes != null)
			{
				for each (var traitType:String in traitTypes)
				{
					var trait:MediaTraitBase = null;
					
					switch (traitType)
					{
						case MediaTraitType.AUDIO:
							trait = new AudioTrait();
							break;
						case MediaTraitType.BUFFER:
							if (useDynamicTraits)
							{
								trait = new DynamicBufferTrait();
							}
							else
							{
								trait = new BufferTrait();
							}
							break;
						case MediaTraitType.LOAD:
							if (useDynamicTraits)
							{
								trait = new DynamicLoadTrait(loader, resource);
							}
							else
							{
								trait = new LoadTrait(loader, resource);
							}
							break;
						case MediaTraitType.PLAY:
							trait = new PlayTrait();
							break;
						case MediaTraitType.SEEK:
							doCreateSeekTrait = true;
							continue;
						case MediaTraitType.DYNAMIC_STREAM:
							trait = new DynamicStreamTrait(true, 0, 5);
							break;
						case MediaTraitType.TIME:
							if (useDynamicTraits)
							{
								trait = new DynamicTimeTrait();
							}
							else
							{
								trait = new TimeTrait();
							}
							timeTrait = trait as TimeTrait;
							break;
						case MediaTraitType.VIEW:
							if (useDynamicTraits)
							{
								trait = new DynamicViewTrait(null);
							}
							else
							{
								trait = new ViewTrait(null);
							}
							break;
						default:
							break;
					}
					
					if (trait != null)
					{
						doAddTrait(traitType, trait);
					}
				}
			}
			
			if (doCreateSeekTrait)
			{
				var seekTrait:SeekTrait = new SeekTrait(timeTrait);
				doAddTrait(MediaTraitType.SEEK, seekTrait);
			}
		}
		
		public function doAddTrait(traitType:String, instance:MediaTraitBase):void
		{
			this.addTrait(traitType, instance);
		}

		public function doRemoveTrait(traitType:String):MediaTraitBase
		{
			return this.removeTrait(traitType);
		}
		
		private var timeTrait:TimeTrait;
	}
}
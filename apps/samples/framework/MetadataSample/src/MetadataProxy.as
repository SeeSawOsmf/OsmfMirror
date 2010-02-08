package
{
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.ObjectIdentifier;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.URL;

	public class MetadataProxy extends ProxyElement
	{
		public static const VIDEO_METADATA:URL = new URL("http://example.com/metadata");
		
		public function MetadataProxy(video:VideoElement)
		{
			super(video);
			videoElement = video;	
			(videoElement.getTrait(MediaTraitType.LOAD) as LoadTrait).addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoaded);				
		}
		
		private function onLoaded(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{
				videoElement.client.addHandler(NetStreamCodes.ON_META_DATA, onMetadata);
			}
		}
				
		private function onMetadata(info:Object):void
		{
			var kv:KeyValueFacet = new KeyValueFacet(VIDEO_METADATA);
			
			for (var key:Object in info)
			{
				kv.addValue(new ObjectIdentifier(key), info[key]);
			} 						
			metadata.addFacet(kv);	 	
		}
		
		private var videoElement:VideoElement;	
	}
}
package org.osmf.test.captioning
{
	import flexunit.framework.TestCase;
	
	import org.osmf.captioning.CaptioningPluginInfo;
	import org.osmf.media.MediaInfo;
	import org.osmf.plugin.PluginInfo;

	public class TestCaptioningPluginInfo extends TestCase
	{
		public function testGetMediaInfoAt():void
		{
			var pluginInfo:PluginInfo = new CaptioningPluginInfo();
			
			assertNotNull(pluginInfo);
			
			var mediaInfo:MediaInfo = pluginInfo.getMediaInfoAt(0);
			
			assertNotNull(mediaInfo);
		}
		
		public function testGetMediaInfoAtWithBadIndex():void
		{
			var pluginInfo:PluginInfo = new CaptioningPluginInfo();
			
			assertNotNull(pluginInfo);

			try
			{			
				var mediaInfo:MediaInfo = pluginInfo.getMediaInfoAt(10);
				fail();
			}
			catch(error:RangeError)
			{
			}
		}
		
		public function testIsFrameworkVersionSupported():void
		{
			var pluginInfo:PluginInfo = new CaptioningPluginInfo();
			assertNotNull(pluginInfo);
			
			assertEquals(true, pluginInfo.isFrameworkVersionSupported("1.0.0"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.0.1"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.5.1"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.7.0"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.4.9"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported(null));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported(""));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("abc"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("foo.bar"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("foobar."));
		}
		
		public function testNumMediaInfos():void
		{
			var pluginInfo:PluginInfo = new CaptioningPluginInfo();
			assertNotNull(pluginInfo);

			assertTrue(pluginInfo.numMediaInfos > 0);			
		}
	}
}

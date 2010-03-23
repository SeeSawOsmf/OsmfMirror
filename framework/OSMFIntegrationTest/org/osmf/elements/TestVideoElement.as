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
package org.osmf.elements
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.flexui.patterns.AssertNotNullPattern;
	import flexunit.framework.TestCase;
	
	import mx.utils.Base64Decoder;
	
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.*;
	import org.osmf.metadata.*;
	import org.osmf.traits.*;

	public class TestVideoElement extends TestCase
	{
		private static const ANONYMOUS_METADATA:String = "MIIipwYJKoZIhvcNAQcCoIIimDCCIpQCAQExCzAJBgUrDgMCGgUAMIIXOQYJKoZIhvcNAQcBoIIXKgSCFyYwghciAgECMIIQkjCCEI4CAQECAQEEJEYxNjY0MEYzLTIxRjAtMzYzNi1BRjAyLUY0ODA5MzM0OTNBNQSCD7hQRDk0Yld3Z2RtVnljMmx2YmowaU1TNHdJaUJsYm1OdlpHbHVaejBpVlZSR0xUZ2lJSE4wWVc1a1lXeHZibVU5SW5sbGN5SS9QZ284VUc5c2FXTjVJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbUZrYjJKbExtTnZiUzl6WTJobGJXRXZNUzR3TDNCa2Ntd2lQanh1Y3pFNlEyOXVjM1J5WVdsdWRDQkRiMjV6ZEhKaGFXNTBUbUZ0WlQwaVEyRmphR1ZFZFhKaGRHbHZiaUlnZUcxc2JuTTlJbWgwZEhBNkx5OTNkM2N1WVdSdlltVXVZMjl0TDJac1lYTm9ZV05qWlhOekwzWXhJaUI0Yld4dWN6cHVjekU5SW1oMGRIQTZMeTkzZDNjdVlXUnZZbVV1WTI5dEwzTmphR1Z0WVM4eExqQXZjR1J5YkNJK1BHNXpNVHBRY205d1pYSjBlU0JRY205d1pYSjBlVTVoYldVOUltTnlhWFJwWTJGc0lqNDhibk14T2xCeWIzQmxjblI1Vm1Gc2RXVStkSEoxWlR3dmJuTXhPbEJ5YjNCbGNuUjVWbUZzZFdVK1BDOXVjekU2VUhKdmNHVnlkSGsrUEc1ek1UcFFjbTl3WlhKMGVTQlFjbTl3WlhKMGVVNWhiV1U5SW5ObFkyOXVaSE1pUGp4dWN6RTZVSEp2Y0dWeWRIbFdZV3gxWlQ0ek1EQThMMjV6TVRwUWNtOXdaWEowZVZaaGJIVmxQand2Ym5NeE9sQnliM0JsY25SNVBqd3Zibk14T2tOdmJuTjBjbUZwYm5RK1BHNXpNanBEYjI1emRISmhhVzUwSUVOdmJuTjBjbUZwYm5ST1lXMWxQU0pEYjI1MFpXNTBSSFZ5WVhScGIyNGlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbUZrYjJKbExtTnZiUzltYkdGemFHRmpZMlZ6Y3k5Mk1TSWdlRzFzYm5NNmJuTXlQU0pvZEhSd09pOHZkM2QzTG1Ga2IySmxMbU52YlM5elkyaGxiV0V2TVM0d0wzQmtjbXdpUGp4dWN6STZVSEp2Y0dWeWRIa2dVSEp2Y0dWeWRIbE9ZVzFsUFNKamNtbDBhV05oYkNJK1BHNXpNanBRY205d1pYSjBlVlpoYkhWbFBuUnlkV1U4TDI1ek1qcFFjbTl3WlhKMGVWWmhiSFZsUGp3dmJuTXlPbEJ5YjNCbGNuUjVQanh1Y3pJNlVISnZjR1Z5ZEhrZ1VISnZjR1Z5ZEhsT1lXMWxQU0p6WldOdmJtUnpJajQ4Ym5NeU9sQnliM0JsY25SNVZtRnNkV1UrT0RZME1EQXdNREE4TDI1ek1qcFFjbTl3WlhKMGVWWmhiSFZsUGp3dmJuTXlPbEJ5YjNCbGNuUjVQand2Ym5NeU9rTnZibk4wY21GcGJuUStQRzV6TXpwRGIyNXpkSEpoYVc1MElFTnZibk4wY21GcGJuUk9ZVzFsUFNKVGRHRnlkRVZ1WkNJZ2VHMXNibk05SW1oMGRIQTZMeTkzZDNjdVlXUnZZbVV1WTI5dEwyWnNZWE5vWVdOalpYTnpMM1l4SWlCNGJXeHVjenB1Y3pNOUltaDBkSEE2THk5M2QzY3VZV1J2WW1VdVkyOXRMM05qYUdWdFlTOHhMakF2Y0dSeWJDSStQRzV6TXpwUWNtOXdaWEowZVNCUWNtOXdaWEowZVU1aGJXVTlJbU55YVhScFkyRnNJajQ4Ym5Nek9sQnliM0JsY25SNVZtRnNkV1UrZEhKMVpUd3Zibk16T2xCeWIzQmxjblI1Vm1Gc2RXVStQQzl1Y3pNNlVISnZjR1Z5ZEhrK1BHNXpNenBRY205d1pYSjBlU0JRY205d1pYSjBlVTVoYldVOUltNXZkRUpsWm05eVpTSStQRzV6TXpwUWNtOXdaWEowZVZaaGJIVmxQakl3TURrdE1ERXRNekZVTVRJNk16UTZOVFl0TURnd01Ed3Zibk16T2xCeWIzQmxjblI1Vm1Gc2RXVStQQzl1Y3pNNlVISnZjR1Z5ZEhrK1BDOXVjek02UTI5dWMzUnlZV2x1ZEQ0OGJuTTBPa052Ym5OMGNtRnBiblFnUTI5dWMzUnlZV2x1ZEU1aGJXVTlJa0pwYm1SVWIwMWhZMmhwYm1VaUlIaHRiRzV6UFNKb2RIUndPaTh2ZDNkM0xtRmtiMkpsTG1OdmJTOW1iR0Z6YUdGalkyVnpjeTkyTVNJZ2VHMXNibk02Ym5NMFBTSm9kSFJ3T2k4dmQzZDNMbUZrYjJKbExtTnZiUzl6WTJobGJXRXZNUzR3TDNCa2Ntd2lQanh1Y3pRNlVISnZjR1Z5ZEhrZ1VISnZjR1Z5ZEhsT1lXMWxQU0pqY21sMGFXTmhiQ0krUEc1ek5EcFFjbTl3WlhKMGVWWmhiSFZsUG5SeWRXVThMMjV6TkRwUWNtOXdaWEowZVZaaGJIVmxQand2Ym5NME9sQnliM0JsY25SNVBqd3Zibk0wT2tOdmJuTjBjbUZwYm5RK1BGQnZiR2xqZVVWdWRISjVQanhRY21sdVkybHdZV3dnVUhKcGJtTnBjR0ZzVG1GdFpWUjVjR1U5SWxOWlUxUkZUU0krUEZCeWFXNWphWEJoYkVSdmJXRnBiajVHYkdGemFFRmpZMlZ6Y3p3dlVISnBibU5wY0dGc1JHOXRZV2x1UGp4UWNtbHVZMmx3WVd4T1lXMWxQbVpzWVhOb1lXTmpaWE56UEM5UWNtbHVZMmx3WVd4T1lXMWxQand2VUhKcGJtTnBjR0ZzUGp4dWN6VTZVR1Z5YldsemMybHZiaUJCWTJObGMzTTlJa0ZNVEU5WElpQlFaWEp0YVhOemFXOXVUbUZ0WlQwaVkyOXRMbUZrYjJKbExtWnNZWE5vWVdOalpYTnpMbkpwWjJoMGN5NXdiR0Y1SWlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1aFpHOWlaUzVqYjIwdlpteGhjMmhoWTJObGMzTXZkakVpSUhodGJHNXpPbTV6TlQwaWFIUjBjRG92TDNkM2R5NWhaRzlpWlM1amIyMHZjMk5vWlcxaEx6RXVNQzl3WkhKc0lqNDhibk0xT2tOdmJuTjBjbUZwYm5RZ1EyOXVjM1J5WVdsdWRFNWhiV1U5SWs5MWRIQjFkRkJ5YjNSbFkzUnBiMjRpUGp4dWN6VTZVSEp2Y0dWeWRIa2dVSEp2Y0dWeWRIbE9ZVzFsUFNKamNtbDBhV05oYkNJK1BHNXpOVHBRY205d1pYSjBlVlpoYkhWbFBuUnlkV1U4TDI1ek5UcFFjbTl3WlhKMGVWWmhiSFZsUGp3dmJuTTFPbEJ5YjNCbGNuUjVQanh1Y3pVNlVISnZjR1Z5ZEhrZ1VISnZjR1Z5ZEhsT1lXMWxQU0poYm1Gc2IyY2lQanh1Y3pVNlVISnZjR1Z5ZEhsV1lXeDFaVDR3UEM5dWN6VTZVSEp2Y0dWeWRIbFdZV3gxWlQ0OEwyNXpOVHBRY205d1pYSjBlVDQ4Ym5NMU9sQnliM0JsY25SNUlGQnliM0JsY25SNVRtRnRaVDBpWkdsbmFYUmhiQ0krUEc1ek5UcFFjbTl3WlhKMGVWWmhiSFZsUGpBOEwyNXpOVHBRY205d1pYSjBlVlpoYkhWbFBqd3Zibk0xT2xCeWIzQmxjblI1UGp3dmJuTTFPa052Ym5OMGNtRnBiblErUEM5dWN6VTZVR1Z5YldsemMybHZiajQ4Ym5NMk9sQmxjbTFwYzNOcGIyNGdRV05qWlhOelBTSkJURXhQVnlJZ1VHVnliV2x6YzJsdmJrNWhiV1U5SW1OdmJTNWhaRzlpWlM1bWJHRnphR0ZqWTJWemN5NXlhV2RvZEhNdVlYQndiR2xqWVhScGIyNUVaV1pwYm1Wa0lpQjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NWhaRzlpWlM1amIyMHZabXhoYzJoaFkyTmxjM012ZGpFaUlIaHRiRzV6T201ek5qMGlhSFIwY0RvdkwzZDNkeTVoWkc5aVpTNWpiMjB2YzJOb1pXMWhMekV1TUM5d1pISnNJajQ4Ym5NMk9rTnZibk4wY21GcGJuUWdRMjl1YzNSeVlXbHVkRTVoYldVOUlrRndjR3hwWTJGMGFXOXVVSEp2Y0hNaVBqeHVjelk2VUhKdmNHVnlkSGtnVUhKdmNHVnlkSGxPWVcxbFBTSmpjbWwwYVdOaGJDSStQRzV6TmpwUWNtOXdaWEowZVZaaGJIVmxQblJ5ZFdVOEwyNXpOanBRY205d1pYSjBlVlpoYkhWbFBqd3Zibk0yT2xCeWIzQmxjblI1UGp4dWN6WTZVSEp2Y0dWeWRIa2dVSEp2Y0dWeWRIbE9ZVzFsUFNKd2JHRjVZbUZqYTAxdlpHVWlQanh1Y3pZNlVISnZjR1Z5ZEhsV1lXeDFaVDVaVjNoelBDOXVjelk2VUhKdmNHVnlkSGxXWVd4MVpUNDhMMjV6TmpwUWNtOXdaWEowZVQ0OGJuTTJPbEJ5YjNCbGNuUjVJRkJ5YjNCbGNuUjVUbUZ0WlQwaVUyOTFibVFnYjJZZ2IyNWxJR2hoYm1RZ1kyeGhjSEJwYm1jaVBqeHVjelk2VUhKdmNHVnlkSGxXWVd4MVpUNHdQQzl1Y3pZNlVISnZjR1Z5ZEhsV1lXeDFaVDQ4TDI1ek5qcFFjbTl3WlhKMGVUNDhibk0yT2xCeWIzQmxjblI1SUZCeWIzQmxjblI1VG1GdFpUMGlVMnhwY0hCbGNua2lQanh1Y3pZNlVISnZjR1Z5ZEhsV1lXeDFaVDVWTW5oMlkwZFZQVHd2Ym5NMk9sQnliM0JsY25SNVZtRnNkV1UrUEM5dWN6WTZVSEp2Y0dWeWRIaytQRzV6TmpwUWNtOXdaWEowZVNCUWNtOXdaWEowZVU1aGJXVTlJa2RwWVc1MElqNDhibk0yT2xCeWIzQmxjblI1Vm1Gc2RXVStWVWRHZFZwSFJUMDhMMjV6TmpwUWNtOXdaWEowZVZaaGJIVmxQand2Ym5NMk9sQnliM0JsY25SNVBqeHVjelk2VUhKdmNHVnlkSGtnVUhKdmNHVnlkSGxPWVcxbFBTSk9hVzVxWVNJK1BHNXpOanBRY205d1pYSjBlVlpoYkhWbFBsSXlSbkJhUjFaMVBDOXVjelk2VUhKdmNHVnlkSGxXWVd4MVpUNDhMMjV6TmpwUWNtOXdaWEowZVQ0OEwyNXpOanBEYjI1emRISmhhVzUwUGp3dmJuTTJPbEJsY20xcGMzTnBiMjQrUEM5UWIyeHBZM2xGYm5SeWVUNDhMMUJ2YkdsamVUNEtDZz09oAoMCDIuMC4wMjkwoQsMCUFub255bW91c6MyMTAwLgwqY29tLmFkb2JlLmZsYXNoYWNjZXNzLmF0dHJpYnV0ZXMuYW5vbnltb3VzMQClVzFVMAkMBUVtcHR5MQAwDgwETWVhdDEGBARQb3JrMA8MBEZpc2gxBwQFUGVyY2gwEAwFRnJ1aXQxBwQFUGVhY2gwFQwJVmVnZXRhYmxlMQgEBlBvdGF0bzGCBOwwggToMSEMH2h0dHA6Ly9kaWxsLmNvcnAuYWRvYmUuY29tOjgwOTAwggTBMIIDqaADAgECAhAkyUrsJ+1JFcnsWVsbFBC3MA0GCSqGSIb3DQEBCwUAMFsxCzAJBgNVBAYTAlVTMSMwIQYDVQQKExpBZG9iZSBTeXN0ZW1zIEluY29ycG9yYXRlZDEnMCUGA1UEAxMeRmxhc2ggQWNjZXNzIEJvb3RzdHJhcCBURVNUIENBMB4X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";
		private static const ANONYMOUS_ENCRYPTED:String = "http://moonpie.corp.adobe.com/HTTP/FLV/_DILL_2.0/Anonymous/Magic_Music.flv";
		
		private static const IDENT_METADATA:String = "MIIcbAYJKoZIhvcNAQcCoIIcXTCCHFkCAQExCzAJBgUrDgMCGgUAMIIQ4AYJKoZIhvcNAQcBoIIQ0QSCEM0wghDJAgECMIIKPDCCCjgCAQECAQEEJDM3RjJDRDg3LTY4QkItM0VGRC1BODA4LTM5Nzk1Mzg0RDBBRQSCCWhQRDk0Yld3Z2RtVnljMmx2YmowaU1TNHdJaUJsYm1OdlpHbHVaejBpVlZSR0xUZ2lJSE4wWVc1a1lXeHZibVU5SW5sbGN5SS9QZ284VUc5c2FXTjVJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbUZrYjJKbExtTnZiUzl6WTJobGJXRXZNUzR3TDNCa2Ntd2lQanh1Y3pFNlEyOXVjM1J5WVdsdWRDQkRiMjV6ZEhKaGFXNTBUbUZ0WlQwaVRtOURZV05vWlNJZ2VHMXNibk05SW1oMGRIQTZMeTkzZDNjdVlXUnZZbVV1WTI5dEwyWnNZWE5vWVdOalpYTnpMM1l4SWlCNGJXeHVjenB1Y3pFOUltaDBkSEE2THk5M2QzY3VZV1J2WW1VdVkyOXRMM05qYUdWdFlTOHhMakF2Y0dSeWJDSStQRzV6TVRwUWNtOXdaWEowZVNCUWNtOXdaWEowZVU1aGJXVTlJbU55YVhScFkyRnNJajQ4Ym5NeE9sQnliM0JsY25SNVZtRnNkV1UrZEhKMVpUd3Zibk14T2xCeWIzQmxjblI1Vm1Gc2RXVStQQzl1Y3pFNlVISnZjR1Z5ZEhrK1BDOXVjekU2UTI5dWMzUnlZV2x1ZEQ0OGJuTXlPa052Ym5OMGNtRnBiblFnUTI5dWMzUnlZV2x1ZEU1aGJXVTlJbE4wWVhKMFJXNWtJaUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTVoWkc5aVpTNWpiMjB2Wm14aGMyaGhZMk5sYzNNdmRqRWlJSGh0Ykc1ek9tNXpNajBpYUhSMGNEb3ZMM2QzZHk1aFpHOWlaUzVqYjIwdmMyTm9aVzFoTHpFdU1DOXdaSEpzSWo0OGJuTXlPbEJ5YjNCbGNuUjVJRkJ5YjNCbGNuUjVUbUZ0WlQwaVkzSnBkR2xqWVd3aVBqeHVjekk2VUhKdmNHVnlkSGxXWVd4MVpUNTBjblZsUEM5dWN6STZVSEp2Y0dWeWRIbFdZV3gxWlQ0OEwyNXpNanBRY205d1pYSjBlVDQ4Ym5NeU9sQnliM0JsY25SNUlGQnliM0JsY25SNVRtRnRaVDBpYm05MFFtVm1iM0psSWo0OGJuTXlPbEJ5YjNCbGNuUjVWbUZzZFdVK01qQXdPUzB3TVMwek1WUXhNam96TkRvMU5pMHdPREF3UEM5dWN6STZVSEp2Y0dWeWRIbFdZV3gxWlQ0OEwyNXpNanBRY205d1pYSjBlVDQ4Ym5NeU9sQnliM0JsY25SNUlGQnliM0JsY25SNVRtRnRaVDBpYm05MFFXWjBaWElpUGp4dWN6STZVSEp2Y0dWeWRIbFdZV3gxWlQ0eU1ERXdMVEV5TFRNeFZESXpPalU1T2pVNUxUQTRNREE4TDI1ek1qcFFjbTl3WlhKMGVWWmhiSFZsUGp3dmJuTXlPbEJ5YjNCbGNuUjVQand2Ym5NeU9rTnZibk4wY21GcGJuUStQRzV6TXpwRGIyNXpkSEpoYVc1MElFTnZibk4wY21GcGJuUk9ZVzFsUFNKQ2FXNWtWRzlOWVdOb2FXNWxJaUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTVoWkc5aVpTNWpiMjB2Wm14aGMyaGhZMk5sYzNNdmRqRWlJSGh0Ykc1ek9tNXpNejBpYUhSMGNEb3ZMM2QzZHk1aFpHOWlaUzVqYjIwdmMyTm9aVzFoTHpFdU1DOXdaSEpzSWo0OGJuTXpPbEJ5YjNCbGNuUjVJRkJ5YjNCbGNuUjVUbUZ0WlQwaVkzSnBkR2xqWVd3aVBqeHVjek02VUhKdmNHVnlkSGxXWVd4MVpUNTBjblZsUEM5dWN6TTZVSEp2Y0dWeWRIbFdZV3gxWlQ0OEwyNXpNenBRY205d1pYSjBlVDQ4TDI1ek16cERiMjV6ZEhKaGFXNTBQanhRYjJ4cFkzbEZiblJ5ZVQ0OFVISnBibU5wY0dGc0lGQnlhVzVqYVhCaGJFNWhiV1ZVZVhCbFBTSlRXVk5VUlUwaVBqeFFjbWx1WTJsd1lXeEViMjFoYVc0K1JteGhjMmhCWTJObGMzTThMMUJ5YVc1amFYQmhiRVJ2YldGcGJqNDhVSEpwYm1OcGNHRnNUbUZ0WlQ1bWJHRnphR0ZqWTJWemN6d3ZVSEpwYm1OcGNHRnNUbUZ0WlQ0OEwxQnlhVzVqYVhCaGJENDhibk0wT2xCbGNtMXBjM05wYjI0Z1FXTmpaWE56UFNKQlRFeFBWeUlnVUdWeWJXbHpjMmx2Yms1aGJXVTlJbU52YlM1aFpHOWlaUzVtYkdGemFHRmpZMlZ6Y3k1eWFXZG9kSE11Y0d4aGVTSWdlRzFzYm5NOUltaDBkSEE2THk5M2QzY3VZV1J2WW1VdVkyOXRMMlpzWVhOb1lXTmpaWE56TDNZeElpQjRiV3h1Y3pwdWN6UTlJbWgwZEhBNkx5OTNkM2N1WVdSdlltVXVZMjl0TDNOamFHVnRZUzh4TGpBdmNHUnliQ0krUEc1ek5EcERiMjV6ZEhKaGFXNTBJRU52Ym5OMGNtRnBiblJPWVcxbFBTSlBkWFJ3ZFhSUWNtOTBaV04wYVc5dUlqNDhibk0wT2xCeWIzQmxjblI1SUZCeWIzQmxjblI1VG1GdFpUMGlZM0pwZEdsallXd2lQanh1Y3pRNlVISnZjR1Z5ZEhsV1lXeDFaVDUwY25WbFBDOXVjelE2VUhKdmNHVnlkSGxXWVd4MVpUNDhMMjV6TkRwUWNtOXdaWEowZVQ0OGJuTTBPbEJ5YjNCbGNuUjVJRkJ5YjNCbGNuUjVUbUZ0WlQwaVlXNWhiRzluSWo0OGJuTTBPbEJ5YjNCbGNuUjVWbUZzZFdVK01Ud3Zibk0wT2xCeWIzQmxjblI1Vm1Gc2RXVStQQzl1Y3pRNlVISnZjR1Z5ZEhrK1BHNXpORHBRY205d1pYSjBlU0JRY205d1pYSjBlVTVoYldVOUltUnBaMmwwWVd3aVBqeHVjelE2VUhKdmNHVnlkSGxXWVd4MVpUNHhQQzl1Y3pRNlVISnZjR1Z5ZEhsV1lXeDFaVDQ4TDI1ek5EcFFjbTl3WlhKMGVUNDhMMjV6TkRwRGIyNXpkSEpoYVc1MFBqd3Zibk0wT2xCbGNtMXBjM05wYjI0K1BDOVFiMnhwWTNsRmJuUnllVDQ4TDFCdmJHbGplVDRLQ2c9PaAKDAgyLjAuMDI5MKENDAtJZGVudGl0eSEhIaNIMUYwRAw3Y29tLmFkb2JlLmZsYXNoYWNjZXNzLmF0dHJpYnV0ZXMuYXV0aGVudGljYXRpb25SZXF1aXJlZDEJBAdDSFVfQ0hVpTkxNzAODARNZWF0MQYEBExhbWIwDwwERmlzaDEHBAVQZXJjaDAUDAV1c2FnZTELBAlTdWJzY3JpYmUxggTsMIIE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";
		private static const IDENT_ENCRYPTED:String = "http://moonpie.corp.adobe.com/HTTP/FLV/_DILL_2.0/Identity/Cat_Soup.flv";
		
		//In file metadata
		private static const ANONYMOUS_INLINE:String = "http://moonpie.corp.adobe.com/HTTP/FLV/_DILL_2.0/Anonymous/Aya_momoiro.flv";
		private static const IDENT_INLINE:String = "http://moonpie.corp.adobe.com/HTTP/FLV/_DILL_2.0/Identity/Aya_dokidoki.flv";
		
		private var mediaPlayer:MediaPlayer = new MediaPlayer();
		
		public function testAnonSidecar():void
		{					
			//Anonymous w/ metadata sidecar
			
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(ANONYMOUS_METADATA);				
			//Separate DRM metadata										
			var facet:Facet = new Facet(MetadataNamespaces.DRM_METADATA);
			facet.addValue(MetadataNamespaces.DRM_CONTENT_METADATA_KEY,  decoder.toByteArray());
			
			var resource:URLResource = new URLResource(ANONYMOUS_ENCRYPTED);
			resource.metadata.addFacet(facet);
			
			testElementAnon(resource);								
		}
		
		override public function tearDown():void
		{
			mediaPlayer.media = null;				
		}

		public function testIdentSidecar():void
		{						 
			// Identity based credentials w/ metadata sidecar
			
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(IDENT_METADATA);				
			// Separate DRM metadata										
			var facet:Facet = new Facet(MetadataNamespaces.DRM_METADATA);
			facet.addValue(MetadataNamespaces.DRM_CONTENT_METADATA_KEY,  decoder.toByteArray());
			
			var resource:URLResource = new URLResource(IDENT_ENCRYPTED);
			resource.metadata.addFacet(facet);
			
			testElementCred(resource, "dmo", "password");
		}	
					
		public function testAnonEncrypted():void
		{
			// Anonymous Encrypted content without metadata sidecar
			var resource:URLResource = new URLResource(ANONYMOUS_INLINE);
			var protectable:DRMTrait;
			var testFinished:Function = addAsync( function (event:Event):void {}, 20000);
			
			// We never get the IContentProtectableTrait here, so we have to basicly dectect decyption by checking for  the files duration
			var elem:VideoElement = new VideoElement(resource);
			
			
					
			mediaPlayer =  new MediaPlayer();
			mediaPlayer.media = elem;
			
			elem.addEventListener(MediaElementEvent.TRAIT_ADD,  onTrait );
			
			function onTrait(event:MediaElementEvent):void
			{
				if (event.traitType == MediaTraitType.DRM)
				{
					protectable = (elem.getTrait(MediaTraitType.DRM) as DRMTrait);					
					elem.removeEventListener(MediaElementEvent.TRAIT_ADD,  onTrait);				
					assertNotNull(protectable);
					//This  is as far as we get with anonymous inline.
					var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();			
				}
			}	
													
			function onFinished(event:TimerEvent):void
			{
				testFinished(null);
			}					
							
		}
		
		public function testAuthenticationToken():void
		{		
			var testFinished:Function = addAsync( function (event:Event):void {}, 20000);
									
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(IDENT_METADATA);				
			// Separate DRM metadata										
			var facet:Facet = new Facet(MetadataNamespaces.DRM_METADATA);
			facet.addValue(MetadataNamespaces.DRM_CONTENT_METADATA_KEY,  decoder.toByteArray());
			
			var resource:URLResource = new URLResource(IDENT_ENCRYPTED);
			resource.metadata.addFacet(facet);
						
			var elem:VideoElement = new VideoElement(resource);
			var protectable:DRMTrait;
		
			elem.addEventListener(MediaElementEvent.TRAIT_ADD,  onTrait );
				
			var token:Object;
										
			mediaPlayer.media = elem;
			
			function onTrait(event:MediaElementEvent):void
			{
				if (event.traitType == MediaTraitType.DRM)
				{
					protectable = (elem.getTrait(MediaTraitType.DRM) as DRMTrait);
					protectable.addEventListener(DRMEvent.DRM_STATE_CHANGE, onStateChange );	
					elem.removeEventListener(MediaElementEvent.TRAIT_ADD,  onTrait);				
					if ( protectable.drmState == DRMState.AUTHENTICATION_COMPLETE)
					{
						var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();
					}
				}
			}
			
			if (protectable && protectable.drmState == DRMState.AUTHENTICATION_COMPLETE)
			{				
				var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
				timer.start();
			}
			function onStateChange(event:DRMEvent):void
			{				
				switch(protectable.drmState)
				{
					case DRMState.AUTHENTICATION_NEEDED:
						protectable.authenticate("dmo", "password");
						break;
					case DRMState.AUTHENTICATION_COMPLETE:
						protectable.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onStateChange );
						token = event.token;					
						var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();
						break;
				}
			}
										
			function onFinished(event:TimerEvent):void
			{
				mediaPlayer.media = null;
				mediaPlayer.media = new VideoElement(resource);
				protectable = (mediaPlayer.media.getTrait(MediaTraitType.DRM) as DRMTrait);
				protectable.addEventListener(DRMEvent.DRM_STATE_CHANGE, onTokenAuth);
				protectable.authenticateWithToken(token);
			}
			function onTokenAuth(event:DRMEvent):void
			{
				switch(protectable.drmState)
				{
					case DRMState.AUTHENTICATION_COMPLETE:
						testFinished(null);
						break;
				}
			}
		}
	
		public function testIdentEncrypted():void
		{
			// Identity Encrypted content without metadata sidecar
			var resource:URLResource = new URLResource(IDENT_INLINE);
			testElementCred(resource, "dmo", "password");				
		}
		
		private function testElementCred(resource:MediaResourceBase, user:String, pass:String):void
		{
			var testFinished:Function = addAsync( function (event:Event):void {}, 20000);
			
			var elem:VideoElement = new VideoElement(resource);
			var protectable:DRMTrait;
			
			elem.addEventListener(MediaElementEvent.TRAIT_ADD,  onTrait );
						
			mediaPlayer.media = elem;
			
			function onTrait(event:MediaElementEvent):void
			{
				if (event.traitType == MediaTraitType.DRM)
				{
					protectable = (elem.getTrait(MediaTraitType.DRM) as DRMTrait);
					protectable.addEventListener(DRMEvent.DRM_STATE_CHANGE, onStateChange );	
					elem.removeEventListener(MediaElementEvent.TRAIT_ADD,  onTrait);
					if ( protectable.drmState == DRMState.AUTHENTICATION_COMPLETE)
					{
						var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();
					}
				}
			}
			
			if (protectable && protectable.drmState == DRMState.AUTHENTICATION_COMPLETE)
			{				
				var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
				timer.start();
			}
			function onStateChange(event:DRMEvent):void
			{
				switch(protectable.drmState)
				{
					case DRMState.AUTHENTICATION_NEEDED:
						protectable.authenticate(user, pass);
						break;
					case DRMState.AUTHENTICATION_COMPLETE:
						var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();
						break;	
				}
			}				
			function onFinished(event:TimerEvent):void
			{
				testFinished(null);
			}
		}
				
		private function testElementAnon(resource:MediaResourceBase):void
		{						
			var testFinished:Function = addAsync( function (event:Event):void {}, 20000);
					
			var protectable:DRMTrait;
			var elem:VideoElement = new VideoElement(resource);
			
			elem.addEventListener(MediaElementEvent.TRAIT_ADD,  onTrait );
						
			mediaPlayer.media = elem;
			
			function onTrait(event:MediaElementEvent):void
			{					
				if (event.traitType == MediaTraitType.DRM)
				{
					protectable = (elem.getTrait(MediaTraitType.DRM) as DRMTrait);
					protectable.addEventListener(DRMEvent.DRM_STATE_CHANGE, onStateChange);
					if ( protectable.drmState == DRMState.AUTHENTICATION_COMPLETE)
					{
						var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();
					}
				}
				
			}
			
			if (protectable && protectable.drmState == DRMState.AUTHENTICATION_COMPLETE)
			{				
				var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
				timer.start();
			}
			
			function onStateChange(event:DRMEvent):void
			{				
				switch(protectable.drmState)
				{				
					case DRMState.AUTHENTICATION_COMPLETE:
						var timer:Timer = new Timer(0, 1); //required to let the video element finish loading
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinished);
						timer.start();
						break;	
				}
			}				
								
			function onFinished(event:TimerEvent):void
			{
				testFinished(null);
			}						
		}
	}
}
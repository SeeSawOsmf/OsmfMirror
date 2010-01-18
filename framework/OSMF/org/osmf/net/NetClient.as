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
package org.osmf.net
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * The NetClient class provides support for handling
	 * callbacks dynamically from an RTMP server that is streaming
	 * to an AudioElement or VideoElement. 
	 * 
	 * <p>Use this class to listen for callbacks on the NetConnection
	 * and NetStream created by a NetLoader's load operation.</p>
	 * <p>Assign the value of the <code>client</code>
	 * property of the NetConnection or NetStream
	 * to an instance of the NetClient class.
	 * Then use the NetClient's <code>addHandler()</code>
	 * and <code>removeHandler()</code> methods to register and unregister handlers for
	 * the NetStream callbacks. 
	 * The names of these callbacks are the constants with names beginning with "ON_" 
	 * enumerated in the NetStreamCodes class.</p>
	 * 
	 * @see NetLoader
	 * @see NetStreamCodes
	 * @see flash.net.NetConnection
	 * @see flash.net.NetStream
	 */	
	dynamic public class NetClient extends Proxy
	{
		/**
		 * Adds a handler for the specified callback name.
		 * 
		 * <p>If multiple handlers register for the same callback,
		 * the result of the callback is an array holding the results
		 * of each handler's invocation.
		 * </p>
		 * <p>
		 * This example sets up handler for the <code>ON_METADATA</code>
		 * callback.
		 * <listing>
		 * function onMetaData(value:Object):void
		 * {
		 * 	trace("Got metadata.");
		 * }
		 * 
		 * var stream:NetStream;
		 * var client:NetClient = (stream.client as NetClient); //assign the stream to the NetClient
		 * client.addHandler(NetStreamCodes.ON_METADATA, onMetaData); //add the handler
		 * </listing>
		 * </p>
		 * 
		 * @param name Name of callback to handle.
		 * The callback names are enumerated in the 
		 * and NetStreamCodes class.
		 * @param handler Handler to add.
		 * @priority The priority level of the handler.  The higher the number, the higher the priority.
		 * All handlers with priority N are processed before handlers of priority N-1.  If two or more
		 * handlers are added with the same priority, they are processed in the order in which they
		 * were added.
		 * @see NetStreamCodes
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function addHandler(name:String, handler:Function, priority:int=0):void
		{
			var handlersForName:Array 
				= handlers.hasOwnProperty(name)
					? handlers[name]
					: (handlers[name] = []);
			
			if (handlersForName.indexOf(handler) == -1)
			{
				var inserted:Boolean = false;
				
				priority = Math.max(0, priority);
				
				// Higher priority handlers are at the front of the list.
				if (priority > 0)
				{
					for (var i:int = 0; i < handlersForName.length; i++)
					{
						var handlerWithPriority:Object = handlersForName[i];
						
						// Stop iterating when we're passed all handlers of
						// this priority.
						if (handlerWithPriority.priority < priority)
						{
							handlersForName.splice(i, 0, {handler:handler, priority:priority});
							inserted = true;
							break;
						}
					}
				}
				if (!inserted)
				{
					handlersForName.push({handler:handler, priority:priority});
				}
			}
		}
		
		/**
		 * Removes a handler method for the specified callback name.
		 * 
		 * @param name Name of callback for whose handler is being removed.
		 * The callback names are those constants enumerated in the
		 * NetStreamCodes class that have the prefix "ON_", such as 
		 * ON_CUE_POINT, ON_IMAGE_DATA, etc.
		 * @param handler Handler to remove.
		 * @return Returns <code>true</code> if the specified handler was found and
		 * successfully removed. 
		 * @see NetStreamCodes
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function removeHandler(name:String,handler:Function):Boolean
		{
			var result:Boolean;
			
			if (handlers.hasOwnProperty(name))
			{
				var handlersForName:Array = handlers[name];
				for (var i:int = 0; i < handlersForName.length; i++)
				{
					var handlerWithPriority:Object = handlersForName[i];
					if (handlerWithPriority.handler == handler)
					{
						handlersForName.splice(i, 1);
						
						result = true;
						break;
					}
				}
			}
			
			return result;	
		}
		
		// Proxy Overrides
		//
		
		/**
		 * @private
		 */		
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			return invokeHandlers(methodName, args);
        }
        
        /**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):* 
		{
			var result:*;			
			if (handlers.hasOwnProperty(name))
			{
				result 
					=  function():*
						{
							return invokeHandlers(arguments.callee.name, arguments);
						}
				
				result.name = name;
			}
			
			return result;
		}
		
        /**
		 * @private
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return handlers.hasOwnProperty(name);
		}

		// Internals
		//
		
		/**
		 * @private
		 * 
		 * Holds an array of handlers per callback name. 
		 */		
		private var handlers:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 
		 * Utility method that invokes the handlers for the specified
		 * callback name.
		 *  
		 * @param name The callback name to invoke the handlers for.
		 * @param args The arguments to pass to the individual handlers on
		 * invoking them.
		 * @return <code>null</code> if no handlers have been added for the
		 * specified callback, or otherwise an array holding the result of
		 * each individual handler invokation. 
		 * 
		 */				
		private function invokeHandlers(name:String, args:Array):*
		{
			var result:Array;
			
        	if (handlers.hasOwnProperty(name))
			{
				result = [];
				var handlersForName:Array = handlers[name];
				for each (var handler:Object in handlersForName)
				{
					result.push(handler.handler.apply(null,args));
				}
			}
			
			return result;
		}
	}
}
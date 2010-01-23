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
package org.osmf.layout
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.logging.ILogger;
	import org.osmf.metadata.Facet;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.MetadataUtils;
	import org.osmf.metadata.MetadataWatcher;
	import org.osmf.utils.BinarySearch;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;
	
	/**
	 * Use LayoutRendererBase as the base class for custom layout renders. The class
	 * provides a number of facilities:
	 * 
	 *  * A base implementation for collecting and managing layout layoutTargets.
	 *  * A base implementation for metadata watching: override usedMetadataFacets to
	 *    return the set of metadata facet namespaces that	your renderer reads from its
	 *    target on rendering them. All specified facets will be watched for change, at
	 *    which the invalidate methods gets invoked.
	 *  * A base invalidation scheme that postpones rendering until after all other frame
	 *    scripts have finished executing, by means of managing a dirty flag an a listener
	 *    to Flash's EXIT_FRAME event. The invokation of validateNow will always result
	 *    in the 'render' method being invoked right away.
	 * 
	 * On doing a subclass, the render method must be overridden.
	 * 
	 * Optionally, the following protected methods may be overridden:
	 * 
	 *  * get usedMetadataFacets, used when layoutTargets get added or removed, to add
	 *    change watchers that will trigger invalidation of the renderer.
	 *  * compareTargets, which is used to put the layoutTargets in a particular display
	 *    list index order.
	 * 
	 *  * processContextChange, invoked when the renderer's context changed.
	 *  * processStagedTarget, invoked when a target is put on the stage of the
	 *    context's container.
	 *  * processUnstagedTarget, invoked when a target is removed from the stage
	 *    of the context's container.  
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class LayoutRenderer extends EventDispatcher
	{
		// LayoutRenderer
		//
		
		/**
		 * Defines the renderer that this renderer is a child of.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function get parent():LayoutRenderer
		{
			return _parent;	
		}
		final protected function setParent(value:LayoutRenderer):void
		{
			_parent = value;
		}
		
		/**
		 * Defines the context against which the renderer will calculate the size
		 * and position values of its targets. The renderer additionally manages
		 * targets being added and removed as children of the set context's
		 * display list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function get context():ILayoutContext
		{
			return _context;
		}
		final public function set context(value:ILayoutContext):void
		{
			if (value != _context)
			{
				if (_context != null)
				{
					reset();
				}
			
				var oldContext:ILayoutContext = _context;	
				_context = value;
				
				if (_context)
				{
					container = _context.container;
					metadata = _context.metadata;
					
					absoluteLayoutWatcher
						= MetadataUtils.watchFacet
							( metadata
							, MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS
							, absoluteLayoutChangeCallback
							);
					
					_context.addEventListener
						( DisplayObjectEvent.MEDIA_SIZE_CHANGE
						, invalidatingEventHandler
						, false, 0, true
						);
						
					invalidate();
				}
				
				processContextChange(oldContext, value);
			}
		}
		
		/**
		 * Method for adding a target to the layout renderer's list of objects
		 * that it calculates the size and position for. Adding a target will
		 * result the associated display object to be placed on the display
		 * list of the renderer's context.
		 * 
		 * @param target The target to add.
		 * @throws IllegalOperationError when the specified target is null, or 
		 * already a target of the renderer.
		 * @returns The added target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function addTarget(target:ILayoutTarget):ILayoutTarget
		{
			if (target == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (layoutTargets.indexOf(target) != -1)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			// Get the index where the target should be inserted:
			var index:int = Math.abs(BinarySearch.search(layoutTargets, compareTargets, target));
			
			// Add the target to our listing:
			layoutTargets.splice(index, 0, target);	
			
			// Parent the added layout renderer (if available):
			var targetContext:ILayoutContext = target as ILayoutContext;
			if (targetContext && targetContext.layoutRenderer)
			{
				targetContext.layoutRenderer.setParent(this);
			}
			
			// Watch the facets on the target's metadata that we're interested in:
			var watchers:Array = metaDataWatchers[target] = new Array();
			for each (var namespaceURL:URL in usedMetadataFacets)
			{
				watchers.push
					( MetadataUtils.watchFacet
						( target.metadata
						, namespaceURL
						, targetMetadataChangeCallback
						)
					);
			}
			
			// Watch the target's displayObject and dimenions change:
			target.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, invalidatingEventHandler);
			target.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, invalidatingEventHandler);
			
			invalidate();
			
			processTargetAdded(target);
			
			return target;
		}
		
		/**
		 * Method for removing a target from the layout render's list of objects
		 * that it will render. See addTarget for more information.
		 * 
		 * @param target The target to remove.
		 * @throws IllegalOperationErrror when the specified target is null, or
		 * not a target of the renderer.
		 * @returns The removed target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function removeTarget(target:ILayoutTarget):ILayoutTarget
		{
			if (target == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var removedTarget:ILayoutTarget;
			var index:Number = layoutTargets.indexOf(target);
			if (index != -1)
			{
				// Remove the target from the context stage:
				removeFromStage(target);
				
				// Remove the target from our listing:
				removedTarget = layoutTargets.splice(index,1)[0];
				
				// Un-parent the target if it is a layout renderer:
				var targetContext:ILayoutContext = target as ILayoutContext;
				if (targetContext && targetContext.layoutRenderer)
				{
					targetContext.layoutRenderer.setParent(null);
				}
				
				// Un-watch the target's displayObject and dimenions change:
				target.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, invalidatingEventHandler);
				target.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, invalidatingEventHandler);
								
				// Remove the metadata change watchers that we added:
				for each (var watcher:MetadataWatcher in metaDataWatchers[target])
				{
					watcher.unwatch();
				}
				
				delete metaDataWatchers[target];
				
				processTargetRemoved(target);
				
				invalidate();
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return removedTarget;
		}
		
		/**
		 * Method for querying if a layout target is currently a target of this
		 * layout renderer.
		 *  
		 * @return True if the specified target is a target of this renderer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function targets(target:ILayoutTarget):Boolean
		{
			return layoutTargets.indexOf(target) != -1;
		}
		
		/**
		 * Method that will mark the renderer's last rendering pass invalid. At
		 * the descretion of the implementing instance, the renderer may either
		 * directly re-render, or do so at a later time.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function invalidate():void
		{
			// If we're either cleaning or dirty already, then invalidation
			// is a no-op:
			if (cleaning == false && dirty == false)
			{
				// Raise the 'dirty' flag, signalling that layout need recalculation:
				dirty = true;
				
				if (_parent != null)
				{
					// Forward further processing to our parent:
					_parent.invalidate();
				}
				else
				{
					// Since we don't have a parent, put us in the queue
					// to be recalculated when the next frame exits:
					flagDirty(this, _context.container);
				}
			}
		}
		
		/**
		 * Method ordering the direct recalculation of the position and size
		 * of all of the renderer's assigned targets. The implementing class
		 * may still skip recalculation if the renderer has not been invalidated
		 * since the last rendering pass. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function validateNow():void
		{
			if (_context == null || container == null || cleaning == true)
			{
				// no-op:
				return;	
			}
			
			if (_parent)
			{
				// Have validation triggered from the root-node down:
				_parent.validateNow();
				return;
			}
			
			// This is a root-node. Flag that we're cleaning up:
			cleaning = true;
			
			updateCalculatedBounds();
			updateLayout();
			
			cleaning = false;
		}
		
		/**
		 * @private
		 */
		protected function updateCalculatedBounds():Rectangle
		{
			var bounds:Rectangle = calculateTargetBounds(_context);
			var counter:int = 0;
			
			var targetContext:ILayoutContext
			var targetRenderer:LayoutRenderer;
			var targetBounds:Rectangle;
			var unifiedTargetBounds:Rectangle;
			
			// Traverse, execute bottom-up:
			for each (var target:ILayoutTarget in layoutTargets)
			{
				targetContext = target as ILayoutContext;
				targetRenderer = null;
				targetBounds = null;
				
				if (targetContext != null)
				{
					// Reset the last calculations:
					targetContext.calculatedWidth = NaN;
					targetContext.calculatedHeight = NaN;
					targetContext.projectedWidth = NaN;
					targetContext.projectedHeight = NaN;
					
					targetRenderer = targetContext.layoutRenderer;
				}
						
				if (targetRenderer != null) 
				{
					// Process another node (going in, top to bottom):
					targetBounds = targetRenderer.updateCalculatedBounds();
					flagClean(targetRenderer as LayoutRenderer);
				}
				else
				{
					// This is a leaf:
					targetBounds = calculateTargetBounds(target);
				}
				
				if (targetBounds != null)
				{
					if (targetContext)
					{
						targetContext.calculatedWidth = targetBounds.width;
						targetContext.calculatedHeight = targetBounds.height;
					}
					
					// Set X and Y to zero: if they're NaN, then the union with the
					// previously calculated bounds fails:
					targetBounds.x ||= 0;
					targetBounds.y ||= 0;
				
					unifiedTargetBounds
						= unifiedTargetBounds
							? unifiedTargetBounds.union(targetBounds)
							: targetBounds;
				}
			}
			
			_context.calculatedWidth
				= (bounds && bounds.width)
					? bounds.width
					: unifiedTargetBounds
						? unifiedTargetBounds.width
						: NaN;
						
			_context.calculatedHeight
				= (bounds && bounds.height)
					? bounds.height
					: unifiedTargetBounds
						? unifiedTargetBounds.height
						: NaN;
			
			bounds 
				= (_context.calculatedWidth || _context.calculatedHeight)
					? new Rectangle(0, 0, _context.calculatedWidth, _context.calculatedHeight) 
					: null;
					
			return bounds;
		}
		
		/**
		 * @private
		 */
		protected function updateLayout():void
		{
			// Take care of all targets being staged correctly:
			prepareTargets();
			
			// Traverse, execute top-down:
			for each (var target:ILayoutTarget in layoutTargets)
			{
				var targetContext:ILayoutContext = target as ILayoutContext;
				var targetRenderer:LayoutRenderer = targetContext ? targetContext.layoutRenderer : null;
				var targetBounds:Rectangle 
					= applyTargetLayout
						( target
						, _context.projectedWidth || _context.calculatedWidth
						, _context.projectedHeight || _context.calculatedHeight
						);
				
				if (targetContext)
				{
					targetContext.projectedWidth = targetBounds.width;
					targetContext.projectedHeight = targetBounds.height;
				}
				
				if (targetRenderer)
				{
					targetRenderer.updateLayout();
				}
			}
			
			_context.updateIntrinsicDimensions();
			
			dirty = false;
		}
		
		// Subclass stubs
		//
		
		/**
		 * Subclasses may override this method to have it return the list
		 * of URL namespaces that identify the metadata facets that the
		 * renderer uses on its calculations.
		 * 
		 * The base class will make sure that the renderer gets invalidated
		 * when any of the specified facets change value.
		 * 
		 * @return The list of URL namespaces that identify the metadata facets
		 * that the renderer uses on its calculations. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function get usedMetadataFacets():Vector.<URL>
		{
			return new Vector.<URL>;
		}
		
		/**
		 * Subclasses may override this method, providing the algorithm
		 * by which the list of targets gets sorted.
		 * 
		 * @returns -1 if x comes before y, 0 if equal, and 1 if x comes
		 * after y.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function compareTargets(x:ILayoutTarget, y:ILayoutTarget):Number
		{
			// The base comparision function assumes all targets are equal:
			return 0;
		}
		
		/**
		 * Subclasses may override this method to process the renderer's context
		 * changing.
		 * 
		 * @param oldContext The old context.
		 * @param newContext The new context.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processContextChange(oldContext:ILayoutTarget, newContext:ILayoutTarget):void
		{	
		}
		
		/**
		 * Subclasses may override this method to do processing on a target
		 * item being added.
		 *   
		 * @param target The target that has been added.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processTargetAdded(target:ILayoutTarget):void
		{	
		}
		
		/**
		 * Subclasses may override this method to do processing on a target
		 * item being removed.
		 *   
		 * @param target The target that has been removed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processTargetRemoved(target:ILayoutTarget):void
		{	
		}
		
		/**
		 * Subclasses may override this method should they require special
		 * processing on the displayObject of a target being staged.
		 *  
		 * @param target The target that is being staged
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processStagedTarget(target:ILayoutTarget):void
		{	
			CONFIG::LOGGING { logger.debug("staged: {0}", target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
		}
		
		/**
		 * Subclasses may override this method should they require special
		 * processing on the displayObject of a target being unstaged.
		 *  
		 * @param target The target that has been unstaged
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processUnstagedTarget(target:ILayoutTarget):void
		{	
			CONFIG::LOGGING { logger.debug("unstaged: {0}", target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
		}
		
		protected function calculateTargetBounds(target:ILayoutTarget):Rectangle
		{
			return target.displayObject.getBounds(target.displayObject);
		}
		
		protected function applyTargetLayout(target:ILayoutTarget, availableWidth:Number, availableHeight:Number):Rectangle
		{
			var displayObject:DisplayObject;
			
			return new Rectangle(0, 0, target.intrinsicWidth, target.intrinsicHeight);
		}
		
		protected function updateTargetOrder(target:ILayoutTarget):void
		{
			var index:int = layoutTargets.indexOf(target);
			if (index != -1)
			{
				layoutTargets.splice(index, 1);
				
				index = Math.abs(BinarySearch.search(layoutTargets, compareTargets, target));
				layoutTargets.splice(index, 0, target);
			}
		}
		
		// Internals
		//
		
		private function reset():void
		{
			if (absoluteLayoutWatcher)
			{
				absoluteLayoutWatcher.unwatch();
				absoluteLayoutWatcher = null;
			}
			
			for each (var target:ILayoutTarget in layoutTargets)
			{
				removeTarget(target);
			}
			
			if (_context)
			{
				_context.removeEventListener
					( DisplayObjectEvent.MEDIA_SIZE_CHANGE
					, invalidatingEventHandler
					);
						
				// Make sure to update the existing context
				// before we loose it:
				validateNow();
			}
			
			_context = null;
			this.container = null;
			this.metadata = null;
		}
		
		private function targetMetadataChangeCallback(facet:Facet):void
		{
			invalidate();
		}
		
		private function invalidatingEventHandler(event:Event):void
		{
			CONFIG::LOGGING 
			{
				var targetMetadata:Metadata
					= event.target is ILayoutTarget
						? ILayoutTarget(event.target).metadata
						: null;
						
				logger.debug
					( "invalidated: {0} eventType: {1}, target: {2} sender ID: {3}"
					, metadata.getFacet(MetadataNamespaces.ELEMENT_ID)
					, event.type, event.target
					, targetMetadata ? targetMetadata.getFacet(MetadataNamespaces.ELEMENT_ID) : "?" 
					); 
			}
			invalidate();
		}
		
		private function absoluteLayoutChangeCallback(absoluteLayout:AbsoluteLayoutFacet):void
		{
			if (_parent == null && absoluteLayout != null)
			{
				_context.projectedWidth = absoluteLayout.width;
				_context.projectedHeight = absoluteLayout.height;
				
				_context.container.width = absoluteLayout.width;
				_context.container.height = absoluteLayout.height;
				
				invalidate();
			}
		}
		
		private function prepareTargets():void
		{
			// Setup a displayObject counter:
			var displayListCounter:int = _context.firstChildIndex;
			
			for each (var target:ILayoutTarget in layoutTargets)
			{
				var displayObject:DisplayObject = target.displayObject;
				if (displayObject)
				{
					addToStage(target, target.displayObject, displayListCounter);
					displayListCounter++;
				}
				else
				{
					removeFromStage(target);
				}
			}
		}
		
		private function addToStage(target:ILayoutTarget, object:DisplayObject, index:Number):void
		{
			var currentObject:DisplayObject = stagedDisplayObjects[target];
			if (currentObject == object)
			{
				// Make sure that the object is at the right position in the display list:
				container.setChildIndex(object, Math.min(Math.max(0,container.numChildren-1), index));
				CONFIG::LOGGING { logger.debug("setChildIndex, {0}",target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
			}
			else
			{
				if (currentObject != null)
				{
					// Remove the current object:
					container.removeChild(currentObject);
					CONFIG::LOGGING { logger.debug("removeChild, {0}",target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
				}
				
				// Add the new object:
				container.addChildAt(object, index);
				stagedDisplayObjects[target] = object;
				CONFIG::LOGGING { logger.debug("addChild, {0}",target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
				
				// If there wasn't an old object, then trigger the staging processor:
				if (currentObject == null)
				{
					processStagedTarget(target);
				}
			}
		}
		
		private function removeFromStage(target:ILayoutTarget):void
		{
			var currentObject:DisplayObject = stagedDisplayObjects[target];
			if (currentObject != null)
			{
				container.removeChild(currentObject);
				delete stagedDisplayObjects[target];
				CONFIG::LOGGING { logger.debug("removeChild, {0}",target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
			}
		}
		
		private var _parent:LayoutRenderer;
		private var _context:ILayoutContext;		
		private var container:DisplayObjectContainer;
		private var metadata:Metadata;
		private var absoluteLayoutWatcher:MetadataWatcher;
		
		private var layoutTargets:Vector.<ILayoutTarget> = new Vector.<ILayoutTarget>;
		private var stagedDisplayObjects:Dictionary = new Dictionary(true);
		
		private var dirty:Boolean;
		private var cleaning:Boolean;
		
		private var metaDataWatchers:Dictionary = new Dictionary();
		
		// Private Static
		//
		
		private static function flagDirty(renderer:LayoutRenderer, displayObject:DisplayObject):void
		{
			if (renderer == null || dirtyRenderers.indexOf(renderer) != -1)
			{
				// no-op;
				return;
			}
			
			if (displayObject == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			dirtyRenderers.push(renderer);
			
			if	(	cleaningRenderers == false
				&&	dispatcher == null
				)
			{
				dispatcher = displayObject;
				dispatcher.addEventListener(Event.EXIT_FRAME, onExitFrame);
			}
		}
		
		private static function flagClean(renderer:LayoutRenderer):void
		{
			var index:Number = dirtyRenderers.indexOf(renderer);
			if (index != -1)
			{
				dirtyRenderers.splice(index,1);
			}
		}
		
		private static function onExitFrame(event:Event):void
		{
			dispatcher.removeEventListener(Event.EXIT_FRAME, onExitFrame);
			dispatcher = null;
			
			cleaningRenderers = true;
			
			while (dirtyRenderers.length != 0)
			{
				var renderer:LayoutRenderer = dirtyRenderers.shift();
				if 	(	renderer.parent == null
					||	dirtyRenderers.indexOf(renderer.parent) == -1
					)
				{
					renderer.validateNow();
				}
			}
			
			cleaningRenderers = false;
		}
		
		private static var dispatcher:DisplayObject;
		private static var cleaningRenderers:Boolean;
		private static var dirtyRenderers:Vector.<LayoutRenderer> = new Vector.<LayoutRenderer>;
		
		CONFIG::LOGGING private static const logger:org.osmf.logging.ILogger = org.osmf.logging.Log.getLogger("LayoutRendererBase");
	}
}
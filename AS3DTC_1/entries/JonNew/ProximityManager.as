/*
The MIT License

Copyright (c) 2009 Jonathan New

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	final public class ProximityManager
	{
		private static const ORIGIN:Point = new Point(0,0);
		
		private var _objects:Vector.<DisplayObject> = null;
		private var _results:Vector.<DisplayObject> = new Vector.<DisplayObject>;
		private var _positionPoint:Point = new Point(0,0);
		
		private var _gridSize:uint = 0;
		private var _bounds:Rectangle = null;
		private var _boxSize:int = 0;
		
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			super();
			_gridSize = gridSize;
			_bounds = bounds;
			_boxSize = _gridSize * 3;
		}
		
		/**
		 * Returns all display objects in the current and adjacent grid cells of the
		 * specified display object.
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			//resetting results.  Faster than creating a new Vector all the time.
			_results.length = 0;
			var cachedOffsets:Dictionary = new Dictionary(true);
			
			//we can't assume the given display object is in the same coordinate space
			//as the supplied list of displayobjects from the update() method
			//so we need to compare them on the global coordinate space
			
			//reusing the point object
			_positionPoint.x = displayObject.x;
			_positionPoint.y = displayObject.y;
			_positionPoint = displayObject.parent.localToGlobal(_positionPoint);
			
			//it's a little cheaper to use var once than over and over.
			//the left, right, top, and bottomBounds refer to the x/y coords of the rectangular area that neighbors can live in.
			var dispObj:DisplayObject,
			leftBounds:int = (int(_positionPoint.x / _gridSize) - 1) * _gridSize, 
				topBounds:int = (int(_positionPoint.y / _gridSize) - 1) * _gridSize,
				rightBounds:int = leftBounds + _boxSize,
				bottomBounds:int = topBounds + _boxSize,
				dispObjectParent:DisplayObjectContainer,
				positionPointSet:Boolean = false;
			
			//looping though the vector of objects supplied in update()
			for each(dispObj in _objects){
				
				/**
				 * Once again, we can't assume that all dispObj in _objects are going to be in the same coordinate plane as the passed in displayObject
				 * To account for this we have to compare everything on the global coordinate space using localToGlobal
				 * 
				 * However, localToGlobal is an expensive call (relatively speaking), so we cache all the offsets 
				 * from localToGlobal calls per displayobject parent.  This way we never need to call localToGlobal
				 * more than once for the same DisplayObjectContainer.  It seems likely that all the items passed in 
				 * through update will have the same parent or have 1 of a few parents. 
				 * If this is the case we get a performance boost!  
				 * */
				
				positionPointSet = false;
				dispObjectParent = dispObj.parent;
				
				var offsetPoint:Point = cachedOffsets[dispObjectParent];
				if(!offsetPoint){
					//we haven't seen this parent before
					//reusing the point object
					_positionPoint.x = dispObj.x;
					_positionPoint.y = dispObj.y;
					
					_positionPoint = dispObjectParent.localToGlobal(_positionPoint);
					positionPointSet = true;
					cachedOffsets[dispObjectParent] = new Point(_positionPoint.x - dispObj.x, _positionPoint.y - dispObj.y);
				}
				
				if(!positionPointSet){
					_positionPoint.x = offsetPoint.x + dispObj.x;
					_positionPoint.y = offsetPoint.y + dispObj.y;
				}
				
				
				if(	_positionPoint.x >= leftBounds &&
					_positionPoint.x <= rightBounds &&
					_positionPoint.y >= topBounds &&
					_positionPoint.y <= bottomBounds)
				{
					_results.push(dispObj);
				}
			}
			return _results
		}
		
		/**
		 * Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update(objects:Vector.<DisplayObject>):void
		{
			//objects is a reference to a vector of display objects.  By the time getNeighbors is called
			//the DisplayObjects could have moved, or been removed from the vector.  Therefore, it doesn't make
			//sense to try to store their positions or anything like that.  We can only store a reference.
			_objects = objects;
		}
		
	}
}

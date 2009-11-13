/*
	The MIT License

	Copyright (c) 2009 Andrew Traviss

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
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class ProximityManager
	{
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			_gridSize = gridSize;
			_gridY = new Vector.<int>();
			_gridX = new Vector.<int>();
		}
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var neighbors:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var neighbour:DisplayObject;
			var minX:int = int(displayObject.x / _gridSize)-2;
			var minY:int = int(displayObject.y / _gridSize)-2;
			var maxX:int = minX + 4;
			var maxY:int = minY + 4;
			var i:int = _objects.length;
			if(_cached)
			{
				while(--i > -1)
				{
					if(_gridX[i] > minX && _gridX[i] < maxX && _gridY[i] > minY && _gridY[i] < maxY)
					{
						neighbors[neighbors.length] = _objects[i];
					}
				}
			}
			else
			{
				// preset the length so that fast --i iteration can be used
				if(_objects.length != _gridX.length)
				{
					_gridX.length = _objects.length;
					_gridY.length = _objects.length;
				}
				while(--i > -1)
				{
					neighbour = _objects[i];
					// Store the row and column numbers for each object for future checks
					_gridX[i] = int(neighbour.x / _gridSize);
					_gridY[i] = int(neighbour.y / _gridSize);
					if(_gridX[i] > minX && _gridX[i] < maxX && _gridY[i] > minY && _gridY[i] < maxY)
					{
						neighbors[neighbors.length] = _objects[i];
					}
				}
				// Until the next update(), we know the column and row of all objects
				_cached = true;
			}
			return neighbors;
		}
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update(objects:Vector.<DisplayObject>):void
		{
			// Create a copy to protect from outside changes
			_objects = objects.concat();
			// Every update invalidates the cache
			_cached = false;
			// Since a request for neighbors may not even happen before the next update,
			// we wait to take any further action
		}
		/**
		 * @private
		 * The size of the grid cells.
		 */
		private var _gridSize:Number;
		/**
		 * @private
		 * Stores the x-coordinate of each object in grid cells.
		 */
		private var _gridX:Vector.<int>;
		/**
		 * @private
		 * Stores the y-coordinate of each object in grid cells.
		 */
		private var _gridY:Vector.<int>;
		/**
		 * @private
		 * The complete list of objects to be checked for proximity.
		 */
		private var _objects:Vector.<DisplayObject>;
		/**
		 * @private
		 * Whether or not the grid coordinates of each object have been determined.
		 */
		private var _cached:Boolean = false;
	}
}
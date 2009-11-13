/*
	The MIT License

	Copyright (c) 2009 Kermit Hu

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
	import flash.geom.Rectangle;
	
	public class ProximityManager {
		/**
		 * The length of an edge of a grid cell
		 */
		private var _gridSize:uint;

		/**
		 * The number of virtual columns in the grid
		 */
		private var _gridX:uint;

		/**
		 * The number of virtual rows in the grid
		 */
		private var _gridY:uint;

		/**
		 * The unfurled grid laid end-to-end by row
		 */
		private var _grid:Vector.<Vector.<DisplayObject>>;

		/**
		 * The last virtual column index of the grid
		 */
		private var _lastCol:uint;

		/**
		 * The last virtual row index of the grid
		 */
		private var _lastRow:uint;

		/**
		 * Constructor for ProximityManager
		 * 
		 * @param gridSize the size of the grid cell in pixels
		 * @param bounds the bounds of the area that contains the DisplayObjects
		 */
		public function ProximityManager(gridSize:uint, bounds:Rectangle) {
			super();

			_gridSize = gridSize;

			// Calcuate the number of virtual columns and rows
			_gridX = Math.ceil(bounds.width / _gridSize);
			_gridY = Math.ceil(bounds.height / _gridSize);

			// Calcuate the number of grid cells
			var size:uint = _gridX * _gridY;

			// Create the grid and initialize
			_grid = new Vector.<Vector.<DisplayObject>>(size, true);
			for (var i:int=0; i<size; i++) {
				_grid[i] = new Vector.<DisplayObject>();
			}

			// Pre-calculate the last row and last column indices
			_lastCol = _gridX - 1;
			_lastRow = _gridY - 1;
		}
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 * 
		 * @param displayObject the DisplayObject to check agains
		 * 
		 * @return Vector of DisplayObjects that are the neighbors of the original displayObject
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject> {

			// Calculate the column and row indices
			var gx:uint = displayObject.x / _gridSize;
			var gy:uint = displayObject.y / _gridSize;

			// Calculate the actual index into the grid Vector
			var index:uint = gy * _gridX + gx;

			// Is the displayObject positioned in either the first or last column?
			var isFirstCol:Boolean = (gx == 0);
			var isLastCol:Boolean = (gx == _lastCol);

			// Create the return Vector
			var objects:Vector.<DisplayObject> = new Vector.<DisplayObject>();

			// Process the cell that contains the displayObject and the cells to the left and right as appropriate
			if (!isFirstCol) {
				copyVectorContents(objects, _grid[index-1]);
			}
			copyVectorContents(objects, _grid[index]);
			if (!isLastCol) {
				copyVectorContents(objects, _grid[index+1]);
			}

			// Process the cells in the row above the displayObject
			var current:uint = index - _gridX;
			if (gy != 0) {
				if (!isFirstCol) {
					copyVectorContents(objects, _grid[current-1]);
				}
				copyVectorContents(objects, _grid[current]);
				if (!isLastCol) {
					copyVectorContents(objects, _grid[current+1]);
				}
			}

			// Process the cells in the row below the displayObject
			current = index + _gridX;
			if (gy != _lastRow) {
				if (!isFirstCol) {
					copyVectorContents(objects, _grid[current-1]);
				}
				copyVectorContents(objects, _grid[current]);
				if (!isLastCol) {
					copyVectorContents(objects, _grid[current+1]);
				}
			}

			return objects;
		}

		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 * 
		 * @param objects the list of DisplayObjects to check against
		 */
		public function update(objects:Vector.<DisplayObject>):void {
			var obj:DisplayObject;
			for (var i:int=0; i<objects.length; i++) {
				obj = objects[i];
				_grid[_getIndex(obj.x, obj.y)].push(obj);
			}
		}
		
		/**
		 * Copies the contents of the source Vector into the destination Vector.
		 * 
		 * @param dst destination Vector
		 * @param src source Vector
		 */
		private function copyVectorContents(dst:Vector.<DisplayObject>, src:Vector.<DisplayObject>):void {
			if (src && src.length > 0) {
				for (var i:int=0; i<src.length; i++) {
					dst.push(src[i]);
				}
			}
		}

		/**
		 * Computes the index into the _grid Vector based on the x and y coordinates.
		 * 
		 * @param x the x-position
		 * @param y the y-position
		 * 
		 * @return index into the _grid Vector
		 */
		private function _getIndex(x:Number, y:Number):uint {
			var gx:uint = x / _gridSize;
			var gy:uint = y / _gridSize;
			return gy * _gridX + gx;
		}
	}
}

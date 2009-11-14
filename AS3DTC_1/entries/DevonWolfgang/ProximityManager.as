/*
	The MIT License

	Copyright (c) 2009 Devon O Wolfgang

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

package {
	
	import flash.display.DisplayObject;
	import __AS3__.vec.Vector;
	import flash.geom.Rectangle;
	
	
	/**
	 * ProximityManager gathers the neighbors surrounding a specified DisplayObject instance (within a specified grid range) and returns them in a Vector.
	 * @author Devon O. Wolfgang
	 */
	public class ProximityManager {
		
		private var _gridSize:uint;
		
		private var _columns:int;
		private var _rows:int;
		
		private var _grid:Vector.<Vector.<Vector.<DisplayObject> > >;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle) {
			super();
			
			_gridSize = gridSize;
			
			initGrid(bounds.width, bounds.height);
		}
		
		/**
		 * Creates our grid. The grid is a multi-dimensional Vector instance containing vectors of DisplayObjects.
		 * So, e.g. a vector of all display objects within column 4 and row 3 of our grid can be reference with _grid[4][3].
		 */
		private function initGrid(w:Number, h:Number):void {
			_grid = new Vector.<Vector.<Vector.<DisplayObject> > >();
			
			_columns = Math.ceil(w / _gridSize);
			_rows = Math.ceil(h / _gridSize);
			
			for (var i:int = 0; i < _columns; i++) {
				_grid[int(i)] = new Vector.<Vector.<DisplayObject> >();
				for (var j:int = 0; j < _rows; j++) {
					_grid[int(i)][int(j)] = new Vector.<DisplayObject>();
				}
			}
			
			// wondering if this is of benefit
			//_grid.fixed = true;
		}
		
		/**
		 * update() populates the grid with with the display objects contained in the passed parameter
		 * @param	a Vector instance of DisplayObjects to be added to the grid
		 */
		public function update(objects:Vector.<DisplayObject>):void {
			var i:int = objects.length;
			
			// find which column and row each DisplayObject is in and push it into the correct Vector in the _grid Vector
			while (i--) {
				var x:int = objects[i].x / _gridSize;
				var y:int = objects[i].y / _gridSize;
				_grid[x][y].push(objects[i]);
			}
		}
		
		/**
		 * getNeighbors() returns all DisplayObjects neighboring the passed parameter
		 * @param	the DisplayObject to test
		 * @return	a Vector of neighboring DisplayObjects
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject> {
			var neighbors:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// Find the _grid coordinates of the tested DisplayObject
			var x:int 		= displayObject.x / _gridSize;
			var y:int 		= displayObject.y / _gridSize;
			
			// Some loop vars
			var ind:int		= 0;
			var ypos:int	= y - 1;
			var sx:int		= x - 1;
			var ex:int		= x + 2;
			
			// loop through the 9 surrounding grid areas and add all the neighboring DO's to the returning Vector
			for (var i:int = 0; i < 3; i++) {
				for (var xpos:int = sx; xpos < ex; xpos++) {
					// check to be sure we're not on the edge and referencing a non-existant Vector.
					// perhaps not the most elegant way of doing so, but, hey, it works
					if (xpos >= 0 && xpos < _columns && ypos >= 0 && ypos < _rows) {
						var j:int = _grid[xpos][ypos].length;
						while (j--) {
							// don't return the DisplayObject being tested.
							// If it wasn't for this, we could just concat the vector rather than adding each member individually
							if (_grid[int(xpos)][int(ypos)][int(j)] != displayObject) {
								neighbors[ind] = _grid[int(xpos)][int(ypos)][int(j)];
								ind++;
							}
						}
					}
				}
				ypos++;
			}
			return neighbors;
		}
	}
}
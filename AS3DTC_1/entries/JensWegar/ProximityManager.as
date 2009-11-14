/*
@author Jens Wegar (jens.wegar@deju.nu, http://playground.deju.nu)

The MIT License

Copyright (c) 2009 Jens Wegar

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
	
	public class ProximityManager
	{
		protected var compareVector:Vector.<DisplayObject>;
		protected var gridSize:uint = 0;
		
		/**
		 * @param gridSize The size of one cell within the grid
		 * @param bounds Not used by this algorithm (see below for reasoning). 
		 * 
		 * <p>
		 * Assuming all items passed into the update method are within the bounds, all items are always valid to be checked and 
		 * if my logic is correct, the bounds are in fact irrelevant.
		 * <p>
		 * A neighbour either exists in a valid cell or it doesn't. Valid cells as per definition of the task are 
		 * a) the cell where the target exists and 
		 * b) the 8 bordering cells.
		 * </p>
		 * <p>
		 * The size of the stage is irrelevant as the algorithm should consider only these 9 cells anyway. So the only real use of bounds
		 * is to limit the search domain when it is updated to include only items that are actually within the bounds. 
		 * I have not implemented this check in the update method as it gave me a 8ms performance penalty.</p>
		 */ 
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			super();
			
			this.gridSize = gridSize;
		}
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 * 
		 * <p>The algorithm first calculates the minimum and maximum allowed x and y 
		 * coordinates allowed based on the gridSize, assuming that allowed cells are 9 total 
		 * (1 center + 8 surrounding).</p>
		 * 
		 * <p>Next, we simply iterate through each item in the compareVector and check if the item's x and y values
		 * are within the allowed bounds.</p>
		 * 
		 * <p>Things that had the most speed impact were to define item, x and y outside the loop, and to fetch the current item 
		 * into a temporary variable before accessing the item.x and item.y values. Also, writing the code inline and pushing the 
		 * result into a new Vector instead of using the Vector.filter method resulted in about 3.5 times faster code. </p>
		 * 
		 * @param displayObject The displayObject who's neighbours should be found.
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			// dividing displayObject.x and y with the gridSize gives us the cell number our target is in
			// This algorithm assumes there can be no negative x,y -positions
			var minX:int = int(displayObject.x / gridSize)*gridSize-gridSize;
			var minY:int = int(displayObject.y / gridSize)*gridSize-gridSize;
			
			// The bitwise shift really doesn't have that much of an impact, just thought it was a cool way to do gridSize*2
			var maxX:int = int(displayObject.x / gridSize)*gridSize + gridSize << 1;
			var maxY:int = int(displayObject.y / gridSize)*gridSize + gridSize << 1;

			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var numItems:uint = compareVector.length;

			// define variables outside loop for a slight increase in speed
			var item:DisplayObject;
			var x:Number;
			var y:Number;
			
			for(var i:uint = 0; i < numItems; i++) {
				// fetching the current item into the temp variable instead of using compareVector[i].x, compareVector[i].y, result.push(compareVector[i]);
				// is aprox 1.7 times faster
				item = compareVector[i];
				x = item.x;
				y = item.y;
				
				if( x >= minX && x <= maxX && y >= minY && y <= maxY ) {
					result.push(item);
				}				
			}
			
			return result;
		}
		
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 * 
		 * @param objects The Vector of DisplayObjects that will be used to compare against.
		 */
		public function update(objects:Vector.<DisplayObject>):void {
			compareVector = objects;
		}
		
	}
}


/*
	The MIT License

	Copyright (c) 2009 Marcin Szczepanski <marcins@gmail.com>

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

/*
My approach to the problem is to:

 - on construction of the class great a Vector that represents the grid - this is a
   linear Vector (not multi-dim) that will be addressed by index.  Each grid item 
   is an instance of GridNode which internally contains a Vector of DisplayObjetcs
   at that grid node, and a Vector of adjacent GridNode objects.  Building the
   adjacency list is done only once at construction time.  The "current" GridNode
   is included in the list of adjacent nodes, so that when building a neighbour list
   we just run through adjacentNodes instead of doing something different for "this"
   node

 - The update method clears the grid (if not the first time it's run) and allocates
   the provided DisplayObjecs to grid slots as required

  - getNeighbors determines the grid index of the passed in DisplayObject, and
    uses the adjacentNodes list to get all of the neighbour DisplayObjects

The bottleneck in this approach is update() - it clears out the grid every time and 
puts all the objects given back into the grid. Obviously if nothing has changed then
this is expensive, however otherwise we would have to check if objects have moved, 
objects have been added, or objects have been removed.  Without testing it I would
assume that the overhead of all those checks would end up making the method cost the
same even if the grid was not being cleared.

update() with 10,000 objects as per the test takes about 5.7 of the 6.2ms to run, so 
any optimisations that could be found there would be welcome!!

Depending on the real-world use case, the way I'd probably build this class
to improve performance would be to have methods to add and remove objects from
the grid (which could take either a single object or a Vector of objects), update 
would just be used to update positions of existing objects. 

*/

package
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class ProximityManager
	{
		private var _grid:Vector.<GridNode>;
		
		private var _gridSize:uint;
		private var _oneOverSize:Number;
		
		private var _gridSquares:int;
		private var _bounds:Rectangle;
		
		private var _boundsX:Number;
		private var _boundsY:Number;
		
		private var _gridX:int;
		private var _gridY:int;
		
		private var _firstRun:Boolean = true;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			super();
			
			_gridSize = gridSize;
	
			// doing this saves about 0.05ms (getting desperate! :))
			_boundsX = bounds.x;
			_boundsY = bounds.y;
			
			// Shane McCartney says that multiplication is faster than division, so
			// we get the 1 / _gridSize so we can then multiply when working out grid
			// positions rather than divide.
			_oneOverSize = 1 / _gridSize; 
			
			_gridX = int(Math.ceil(bounds.width * _oneOverSize));
			_gridY = int(Math.ceil(bounds.height * _oneOverSize));
			
			_gridSquares = _gridX * _gridY;			
			
			/* the "grid" is actually a single dimension vector, we use math to work out
			the right grid index for a particular x,y pair 
			
			Note that there doesn't really appear to be any performance differnece in fixing the size of
			this vector, but it's good for ensuring we're not overruning the expected buffer
			*/
			_grid = new Vector.<GridNode>(_gridSquares, true);
			
			/* create the GridNode for each grid square - this is actually again about 0.05ms faster
			as a while than a for */
			var i:int = 0;
			while(i < _gridSquares) {
				_grid[i++] = new GridNode();
			}
			
			// Now we go through each GridNode and determine the adjacent GridNodes so that we won't need
			// to calculate it later, we just run through the pre-generated list
			var x:int = 0;
			var y:int = 0;
			var c:int = 0;
			var node:GridNode;
			
			while(c < _gridSquares) {
				node = _grid[c];
				
				node.adjacentNodes[0] = node; // self reference to save a loop when finding objects
				
				if(x > 0) {
					node.adjacentNodes[node.adjacentNodes.length] = _grid[c-1]; // to the left
					if(y > 0) {
						node.adjacentNodes[node.adjacentNodes.length] = _grid[c - _gridX - 1]; // above to the left
					}
					if(y < _gridY - 1) {
						node.adjacentNodes[node.adjacentNodes.length] = _grid[c + _gridX - 1]; // down to the left 
					}
				}
				
				if(x < _gridX - 1) {
					node.adjacentNodes[node.adjacentNodes.length] = _grid[c + 1]; // to the right
					if(y > 0) {
						node.adjacentNodes[node.adjacentNodes.length] = _grid[c - _gridX + 1]; // above to the right
					}
					if(y < _gridY - 1) {
						node.adjacentNodes[node.adjacentNodes.length] = _grid[c + _gridX + 1]; // below to the right 
					}
				}
				
				if(y > 0) {
					node.adjacentNodes[node.adjacentNodes.length] = _grid[c - _gridX]; // above 					
				}
				
				if(y < _gridY - 1) {
					node.adjacentNodes[node.adjacentNodes.length] = _grid[c + _gridX]; // below  
				}
				c++;
				x++;
				if(x == _gridX) {
					x = 0;
					y++;
				}
			}
		}
		
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update(objects:Vector.<DisplayObject>):void
		{
			var node:GridNode;
			
			// clear the grid if this is not the first time we're 
			// updating (first time it'll be clear already)
			if(!_firstRun) {				
				for each(node in _grid) {
					node.objects.length = 0;
				}
			}			
			_firstRun = false;
			
			// loop through each object in the provided vector and add it to the right 
			// spot on the grid - for each on a vector is actually faster than a regular
			// for loop with index lookup! (which I think wasn't the case for arrays - 
			// probably to do with type safety
			for each(var object:DisplayObject in objects) {
				// orginally this was assigning to x and y ints and then using those in the calc. Removing
				// that assignment here and in getNeighbors saved about 0.5ms
				var gridIndex:int = int((object.x - _boundsX) * _oneOverSize) + (int((object.y - _boundsY) * _oneOverSize) * _gridX);
				
				// only include this object if it's in the grid
				// For the contest we're allowed to assume all items are, 
				// so this is commented out.
				//if(gridIndex < 0 || gridIndex >= _gridSquares) continue;
				
				// if I don't pre-fetch grid[gridIndex] into node as below, it's
				// about 2ms slower (avg)
				node = _grid[gridIndex];
				node.objects[node.objects.length] = object;
				
			}	
		}
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var neighbours:Vector.<DisplayObject> = new Vector.<DisplayObject>();

			// calculate the gridIndex of the passed in displayObject
			var gridIndex:int = int((displayObject.x - _boundsX) * _oneOverSize) + (int((displayObject.y - _boundsY) * _oneOverSize) * _gridX);
			
			var node:GridNode = _grid[gridIndex];
			
			var adjacentNode:GridNode;			
			var object:DisplayObject;		
			
			// we use the pre-calculated adjacentNode vector to quickly get the nodes that contain 
			// neighbours.  Note that the adjacentNodes vector includes the current node as well to
			// avoid a separate loop to copy those items across
			for each(adjacentNode in node.adjacentNodes) {
				
				// Tried using vector.concat here, but it was slower than this approach by about 0.2ms
				for each(object in adjacentNode.objects) {					
					neighbours[neighbours.length] =  object;
				}
				
			}
			
			return neighbours;
		}
		
	}

}
import flash.display.DisplayObject;

internal class GridNode {
	public var objects:Vector.<DisplayObject> = new Vector.<DisplayObject>();
	public var adjacentNodes:Vector.<GridNode> = new Vector.<GridNode>();
}

/*

Progress
========
NOTE initially it was unclear and I believed that objects could
move between calls to getNeighbors - so my code was checking if any objects had
moved every time - obviously a lot slower that doing it only in update!)

Baseline												92.96 ms

getting coords was originally a function call (because it's used
in getNeighbor as well), but it's about 50% faster when
unrolled (probably due to not having to create vectors 
over and over 

Unroll getGridCoords									43.58 ms (!)

Changed to using GridNode objects and adjacent nodes 	46.50 ms
- addObjectsToGrid is the bottleneck

Finally, a speed boost! caching x,y,grid position and only updating
what is required:										39.52ms

Profiling analysis:
- The initial objects.length in update takes some time (200ms or so)

No real meaningful progress on any significant optimisations 38.14ms in non-debug

Still around 38ms after fixing a few minor issues.

After changing so object postiions only update in update()	9ms (!)

Making it a linked list for object nodes makes it worse		16ms

Back to the one above.. 									9.3/9.4ms

d'oh! realised I was Math.floor'ing and then 
casting to int (redundant) 									7.8ms

Removing explicit cast to int								7.5ms

Multiply by 1/gridSize instead of divide					7.3ms

Replace for loops with for each for vectors					7.1ms

.. not having to check if the object provided is even in the grid
drops this down, but will have to see what Mike says about DOs
outside the bounds (someone asked already)					6.6ms

Not using GridNode, but instead two vectors (one for grid, one to
store adjacent vectors) is slightly slower.					6.8ms

Changing adjacent vector to storing grid indices instead of references
to actual vector was marginally faster but still			6.75ms

Going back to GridNode... only a little bit faster than the multi-vector
approach, but more readable / easy to work with. Seems to hover 
around														6.7ms

Wow! Just removed some unneccessary assignment to variables that were just
being used in a single calculation (mainly calculating gridIndex) and
saved almost half a ms!!									6.2ms

We've now reduced time by about 30% from the initial approach (the one where
we didn't need to check for moving objects in neighbors that was 9ms).

Not needlessly clearing the grid on the first update		6.1ms

Just realised that I should be subtracting the bounds.x/y from the object
coordinates for completness..								6.35ms

Changed a for loop to a while loop in ctor					6.3ms

Few other unneccessary assignments cleaned up				6.2ms

*/

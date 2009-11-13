/*
	The MIT License

	Copyright (c) 2009 Jim Cheng <jim.cheng@effectiveui.com>

	Revision 1.01

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
	
	public class ProximityManager2
	{
		/**
		 *  Number of columns
		 */
		protected var cols:uint;
	
		/** 
		 * Number of total cells in the grid
		 */
		protected var gridCellCount:uint;

		/** 
		 * Vector containing vectors of each cell's display objects
		 */
		protected var gridCache:Vector.<Vector.<DisplayObject>>; 			  
		
		/**
		 * Vector containing vectors of each cell's neighbor's
		 */
		protected var neighborCache:Vector.<Vector.<Vector.<DisplayObject>>>;  
		
		/**
		 *  Size of each square cell in the grid (in pixels)
		 */
		protected var gridSize:uint;
		
		/**
		 * Reciprocal of grid size (for speed)
		 */
		protected var recipGridSize:Number;
				
		/**
		 * Creates a ProximityManager instance.
		 * 
		 * @param	The size of each cell's edge in the grid in pixels.		
		 * @param	The bounds of the area to be managed.
		 * 
		 */
		public function ProximityManager2(gridSize:uint, bounds:Rectangle = null)
		{
			// Since time in the constructor is not counted, we use this to set
			// up some data structures for later use here to save time later.

			var i:uint, j:int, lastColumn:int, lastCell:int;
			var v:Vector.<Vector.<DisplayObject>>;
			var rows:int = Math.ceil(bounds.width / gridSize);
			
			cols = Math.ceil(bounds.height / gridSize);					
			gridCellCount = rows * cols;
			this.gridSize = gridSize;
			recipGridSize = 1 / gridSize;
			
			// Fixed size vectors are quicker to instantiate and access.  Since we know
			// the total number cells that we're going to need, specify a size now.
			gridCache = new Vector.<Vector.<DisplayObject>>(gridCellCount, true);
			neighborCache = new Vector.<Vector.<Vector.<DisplayObject>>>(gridCellCount, true);
			
			// Setup initial grid cell cache with empty vectors of display objects.
			for (i = 0; i < gridCellCount; i++) {
				gridCache[i] = new Vector.<DisplayObject>();
			}
			
			lastColumn = cols - 1;
			lastCell = gridCellCount - 1;
						
			// Precompute the neighbors of each cell.  Each element of the 
			// neighborCache vector will contain pointers to all neighboring
			// cells' displayObject vectors.  This allows us to quickly
			// collapse the neighboring cells' list of display objects into
			// a single vector in getNeighbors() without further lookups.
			
			for (i = 0; i < gridCellCount; i++) {
				
				// Use a local variable "v" for performance here.
				neighborCache[i] = v = new Vector.<Vector.<DisplayObject>>;
				
				// Boolean checks for whether the current cell is at the
				// various edges of the grid.  Those are handled specially
				// as they have fewer neighbors, e.g. corner cells only have
				// 4 neighbors (including themselves), edge cells have 6,
				// while inner cells have 9.
				var isLeftEdge:Boolean = ((i % cols) == 0);
				var isRightEdge:Boolean = ((i % cols) == lastColumn);
				var isTopEdge:Boolean = ((i - cols) < 0);
				var isBottomEdge:Boolean = ((i + cols) > lastCell);
			
				// Push references to each neighboring cell onto "v" as
				// appropriate given the current cell's location in the grid.
				if (!isTopEdge) {
					j = i - cols - 1;
					if (!isLeftEdge) {
						v.push(gridCache[j]);
					}
					
					j++;
					v.push(gridCache[j]);
					
					j++;
					if (!isRightEdge) {
						v.push(gridCache[j]);
					}
				}			
				
				
				j = i - 1;
				if (!isLeftEdge) {
					v.push(gridCache[j]);
				}
				
				j++;
				v.push(gridCache[j]);
				
				j++;
				if (!isRightEdge) {
					v.push(gridCache[j]);
				}
				
				
				if (!isBottomEdge) {
					j = i + cols - 1;
					if (!isLeftEdge) {
						v.push(gridCache[j]);
					}
					
					j++;
					v.push(gridCache[j]);
					
					j++;
					if (!isRightEdge) {
						v.push(gridCache[j]);
					}
				}					
			}					
		}
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 * 
		 *  @param		The display object for which to obtain neighbors.
		 *  @returns	A vector containing all neighboring display objects.
		 * 
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			// A vector containing references to the display object's
			// neighboring cells' vectors of their display object
			// contents.  Note that several casts to uint are used
			// here for performance, and cells are stored in a flat
			// list indexed by:
			//
			//   uint(x / gridSize) * cols + uint(y / gridSize)
			//
			// This is better than a two-dimensional vector, as that
			// would require an additional dereference and consume
			// additional CPU cycles.
			var vects:Vector.<Vector.<DisplayObject>> = neighborCache[uint(uint(displayObject.x * recipGridSize) * cols + uint(displayObject.y * recipGridSize))];
		
			// Check the length of the vector (e.g. the number of
			// neighboring cells), and then return a collapsed vector
			// their contents.  We use the concat() method here in a
			// less-than-obvious way to quickly collect the contents
			// of each member of the "vects" vector into a new vector
			// that is then immediately returned.  The if-else cascade
			// is organized in decreasing order of commonality to 
			// minimize the number of comparisons needed on average.
			//
			// Note that we could cache these results for improved
			// getNeighbor() performance if many queries are expected
			// such that the same cells are hit multiple times.  This
			// approach, however, does come at some cost to overall
			// performance though, so it was not taken in this case.
			var len:uint = vects.length;
			if (len == 9) {			// [Inner Cell]
				return vects[0].concat(vects[1], vects[2], vects[3], vects[4], vects[5], vects[6], vects[7], vects[8]);
			}
			else if (len == 6) {	// [Edge, Non-Corner Cell]
				return vects[0].concat(vects[1], vects[2], vects[3], vects[4], vects[5]);
			}
			else {	// In this case, len must equal 3, but don't bother
					// checking since the compare wastes time.  [Corner]
				return vects[0].concat(vects[1], vects[2], vects[3]);
			}
		}
		
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 * 
		 *  @param A vector containing the display objects.
		 */
		public function update(objects:Vector.<DisplayObject>):void
		{
			// Get local references to these instance variables.  Access to
			// locals are quicker, and as we expect to make ample use of
			// them in this method, this saves time overall.
			var gc:Vector.<Vector.<DisplayObject>> = gridCache;
			var rgs:Number = recipGridSize;
			var c:uint = cols;
			
			var i:uint, len:uint;
			var displayObject:DisplayObject;
			var list:Vector.<DisplayObject>;
			
			// Empty out each item in the gridCache vector by setting the
			// vector's length to zero.  This is much quicker than making
			// them anew (which would cause problems with the references
			// stored in neighborCache), or by removing their contents 
			// one at a time with the shift() or pop() methods.		
			for(i = 0; i < gridCellCount; ++i) {
				gc[i].length = 0;
			}
			
			// Iterate through the list of display objects passed in, and
			// add a reference to each into it's proper cell's vector.
			for(i = 0, len = objects.length; i < len; ++i) {
				displayObject = objects[i];	
				
				// Get the vector containing display object contents for
				// the current cell.  Note that we use a flattened single
				// dimensional vector here rather than a more conventional
				// two-dimensional set of vectors.  This saves a deference
				// on each pass and reduces the overall cost in cycles.
				list = gc[uint(uint(displayObject.x * rgs) * c + uint(displayObject.y * rgs))];
				
				// Append the display object onto the vector.  This is
				// another non-obvious notation, used for speed.  The
				// push() method is unfortunately, very slow, but this
				// is tantamount to:
				//
				//   list.push(displayObject);
				// 
				list[uint(list.length)] = displayObject;			
			}
		}			
	}
}


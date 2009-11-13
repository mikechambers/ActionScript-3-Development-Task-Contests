/*
	The MIT License

	Copyright (c) 2009 Iiam Lobb

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
	import __AS3__.vec.Vector;
	import flash.geom.Rectangle;
	
	public class ProximityManager
	{
		private var gridSize:uint; // the width & height of each tile, in pixels
		private var gridWidth:uint; // how many squares the grid is wide
		private var gridHeight:uint; // how many squares the grid is high 
		private var grid:Vector.<Vector.<DisplayObject>>; // a simulated 2D array of the grid, each node is a list of DisplayObjects
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			this.gridSize = gridSize;
			gridWidth = Math.ceil(bounds.width / gridSize);
			gridHeight = Math.ceil(bounds.height / gridSize);
			
			super();
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var neighbours:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// Get the position of the displayObject as grid co-ordinates. The +1 moves everything an extra square in to give an empty border. 
			
			var gridX:int = (displayObject.x / gridSize) + 1;
			var gridY:int = (displayObject.y / gridSize) + 1;
			
			// Get the index in grid from the co-ordinate, simulating a 2D lookup
			
			var index:int = (gridY * gridWidth) +  gridX;
			
			// Get the index of the surrounding co-ordinates
			
			// North West:
			var northWestIndex:uint = ((gridY - 1) * gridWidth) +  (gridX - 1);
			
			// North:
			var northIndex:uint = ((gridY - 1) * gridWidth) + gridX;
			
			// North East:
			var northEastIndex:uint = ((gridY - 1) * gridWidth) +  (gridX + 1);
			
			// West:
			var westIndex:uint = (gridY * gridWidth) +  (gridX - 1);
			
			// East:
			var eastIndex:uint = (gridY * gridWidth) +  (gridX + 1);
			
			// South West:
			var southWestIndex:uint = ((gridY + 1) * gridWidth) +  (gridX - 1);
			
			// South:
			var southIndex:uint = ((gridY + 1) * gridWidth) + gridX;
			
			// South East:
			var southEastIndex:uint = ((gridY + 1) * gridWidth) +  (gridX + 1);
			
			// Join all the lists of DisplayObjects
			
			neighbours = grid[index].concat(grid[northWestIndex], grid[northIndex], grid[northEastIndex], grid[westIndex], grid[eastIndex], grid[southWestIndex], grid[southIndex], grid[southEastIndex]);
			
			// Show visually:
			//for each (var displayObject:DisplayObject in neighbours)
			//{
			//	displayObject.alpha = 0.1;
			//}
			
			return neighbours;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			// Grid is a simulated 2D look-up containing lists of which objects are in each square
			grid = new Vector.<Vector.<DisplayObject>>();
			
			// Give the grid a 1 square border all around, to avoid null checks.
			var gridLength:uint = (gridWidth + 2) * (gridHeight + 2);
			
			// populate vector with empty lists
			for (var i:uint = 0; i < gridLength; i++)
			{
				grid.push(new Vector.<DisplayObject>());
			}
			
			// Add each displayObject to the correct square's list, again moved in 1 square to provide a border.
			for each (var displayObject:DisplayObject in objects)
			{
				var gridX:int = (displayObject.x / gridSize) + 1;
				var gridY:int = (displayObject.y / gridSize) + 1;
				var index:int = (gridY * gridWidth) +  gridX;
				
				grid[index].push(displayObject);
			}
		}
		
	}
}


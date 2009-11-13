/*
	The MIT License

	Copyright (c) 2009 Huyen Tue Dao
	daotueh@gmail.com
	twitter.com/queencodemonkey
	http://queencodemonkey.com

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
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class ProximityManager
	{
		
		/**
		 * A SpatialGrid object that divides the stage into a grid and performs
		 * calculations that determine in which cell a DisplayObject lies in and
		 * the cells adjacent to a given cell.  
		 */
		private var _grid : SpatialGrid;
		
		/**
		 * A mapping of grid cells to a set of DisplayObjects that lie in each.
		 * The key of the map is the cell number assigned to the cell by the
		 * SpatialGrid.  
		 */
		private var _cellObjectsMap : Object	= {};
		
		/**
		 * Constructor.
		 * 
		 * @param gridSize The dimensions of each square cell of the grid.
		 * @param bounds The bounds of the two-dimensional area to be divided
		 * into a grid.
		 * 
		 */
		public function ProximityManager(gridSize : uint, bounds : Rectangle)
		{
			super();
			
			_grid	= new SpatialGrid(gridSize, bounds);
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var neighbors : Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var adjacentCells : Vector.<uint>;
			var numAdjacent : int;
			
			// Variables used when looping through adjacent cells to store the
			// the cell number of the adjacent cells, the objects residing in
			// each cell, the number of objects residing in each cell and each
			// invidividual object.
			var cellNumber	: Number	= _grid.getCellNumber(displayObject.x, displayObject.y);
			var cellObjects : Vector.<DisplayObject>;
			var numCellObjects : int;
			var cellObject : DisplayObject;
			// Loop iterators
			var i : int, j : int, k : int;
			
			// Neighbors include all of the other DisplayObjects residing in
			// <code>displayObject</code>'s cell, so add these to the vector of
			// neighbors.
			neighbors = neighbors.concat(_cellObjectsMap[cellNumber]);

			// Get the assigned cell numbers of all of the cells adjacent to
			// <code>displayObjects</code>'s cell.  Iterate through the adjacent
			// cells and add them to vector of neighbors.
			adjacentCells = _grid.getAdjacentCells(cellNumber);
			numAdjacent = adjacentCells.length;
			for(j = 0; j < numAdjacent; j++)
			{
				cellNumber = adjacentCells[j];
				neighbors = neighbors.concat(_cellObjectsMap[cellNumber]);
			}
			return neighbors;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			// Number of objects on the stage
			var numObjects : int = objects.length;
			// The set of DisplayObjects's stored in a cell
			var cellObjects : Vector.<DisplayObject>;
			// The total number of cells in the grid
			var numCell : Number = _grid.numCells;
			// The assigned number of a cell
			var cellNumber : uint;
			// The current DisplayObject on the stage being processed.
			var object : DisplayObject;
			// Iterator variable
			var i : int;
			// Initialize the cell->objects map, creating a key->value pair
			// for each cell in the grid, where the key is the cell number and
			// the value is a new vector to hold the DisplayObjects in that
			// cell.
			for(i = 0; i < numCell; i++)
			{
				_cellObjectsMap[i]	= new Vector.<DisplayObject>();				
			}
			// Iterate through all of the objects and add them as appropriate to
			// the cell->objects map.
			for(i = 0; i < numObjects; i++)
			{
				object	= objects[i];
				cellNumber	= _grid.getCellNumber(object.x, object.y);
				cellObjects = _cellObjectsMap[cellNumber];
				cellObjects[cellObjects.length]	= object;
			}
		}
	}
}

import flash.geom.Rectangle;
/**
 * 
 * A SpatialGrid object is a representation of a 2-dimensional space divided
 * into a rectangular grid where each cell is a square of a given dimension.
 * The SpatialGrid class contains properties and methods for determining in
 * which cell an x-y coordinate lies or with which cells a rectangular
 * area intersects.
 * 
 * The rectangular 2-dimensional area covered by the grid is an arbitrary
 * section of 2-dimensional space.  Each cell of the SpatialGrid is assigned
 * a positive integer, starting at 0 in the top-left corner cell, and which
 * increments left-to-right and top-to-bottom.
 * 
 * 
 * 
 * @author Huyen Tue Dao
 * 
 */
class SpatialGrid
{
	private static const NA	: String = '-1';
	
	private var _gridSize	: Number = 0;
	
	private var _bounds	: Rectangle	= new Rectangle();
	
	private var _width	: Number = 0;
	private var _height	: Number = 0;
	
	private var _gridWidth		: Number = 0;
	private var _gridWidthCeil	: Number = 0;
	private var _gridHeight		: Number = 0;
	private var _gridHeightCeil	: Number = 0;
	
	private var _numCell	: Number = 0;
	
	/**
	 * The dimension of each square cell of the grid, in pixels. 
	 *
	 * @default 35 
	 */
	public function get gridSize() : int { return _gridSize; }
	public function set gridSize(value : int) : void
	{
		_gridSize 	= value;
	}

	/**
	 * A Rectangle object determining the 2-dimensional bounds of the 
	 * rectangular area covered and divided by the grid.
	 * 
	 */
	public function get bounds() : Rectangle { return _bounds; }
	public function set bounds(value : Rectangle) : void
	{
		_bounds = value;
		
		gridWidth	= _bounds.width / _gridSize;
		gridHeight	= _bounds.height / _gridSize;
		_numCell	= _gridWidthCeil * _gridHeightCeil;
	}
	
	/**
	 * The width of the grid in pixels.
	 * 
	 */
	public function get width() : Number { return _bounds.width; }


	/**
	 * The height of the grid in pixels.
	 * 
	 */
	public function get height() : Number { return _bounds.height; }


	/**
	 * The width of the grid by number of cells.
	 *  
	 */
	public function get gridWidth() : Number { return _gridWidth; }
	public function set gridWidth(value : Number) : void
	{
		_gridWidth = value;
		var gridWidthFloor	: Number	= int(_gridWidth);
		_gridWidthCeil = (_gridWidth > gridWidthFloor)? (gridWidthFloor + 1) : _gridWidth;
	}


	/**
	 * The height of the grid by number of cells.
	 *  
	 */
	public function get gridHeight() : Number { return _gridHeight; }
	public function set gridHeight(value : Number) : void
	{
		_gridHeight = value;
		var gridHeightFloor	: Number = int(_gridHeight);
		_gridHeightCeil = (_gridHeight > gridHeightFloor)? (gridHeightFloor + 1) : _gridHeight;
	}
	
	public function get numCells() : Number { return _numCell; }
	
	/**
	 * Constructor.
	 *  
	 * @param gridSize The square dimensions of each cell in the grid.
	 * @param bounds The bounds of the two-dimensional area to be divided
	 * into a grid.
	 * 
	 */
	public function SpatialGrid(gridSize : int	= 0, bounds : Rectangle	= null)
	{
		this.gridSize = gridSize;
		if(bounds)
			this.bounds = bounds; 	
	}
	
	//======================================================================
	//
	//    P U B L I C    M E T H O D S
	//
	//======================================================================
	/**
	 * Returns the assigned cell numbers of all adjacent cells of any given cell
	 * in the grid.  A cell can have a maximum of 8 adjacent cells and a minimum
	 * of three for cells at the corners.
	 *  
	 * @param cellNumber The assigned number of a cell.
	 * @return A Vector of the cell numbers of adjacent cells to the cell
	 * assigned <code>cellNumber</code>.
	 * 
	 */
	public function getAdjacentCells(cellNumber : int) : Vector.<uint>
	{
		// Variables holding the cell numbers of the eight possible adjacent
		// cells.  If the cell sits on an edge or corner and thus does not have
		// an adjacent cell in some directionts, these directions are assigned
		// a value of -1.
		var left : int, right : int;
		var topLeft : int, topMiddle : int, topRight: int;
		var bottomLeft : int, bottomMiddle : int, bottomRight : int;
		
		// If the cell sits on the first row of the grid, there will be no 
		// top-middle cell and the bottom-middle cell is calculated as normal.
		if(cellNumber < _gridWidthCeil)
		{
			topMiddle	= -1;
			bottomMiddle	= cellNumber + _gridWidthCeil;
		}
		// If the cell sits on the last row of the grid, there will be no 
		// bottom-middle cell and the top-middle cell is calculated as normal.
		else if(cellNumber >=  (_numCell - _gridWidthCeil))
		{
			topMiddle		= cellNumber - _gridWidthCeil;
			bottomMiddle	= -1;
		}
		// Else the cell sits in a middle row, and the top-middle and
		// bottom-middle cell are calculated as normal.
		else
		{
			topMiddle		= cellNumber - _gridWidthCeil;
			bottomMiddle	= cellNumber + _gridWidthCeil;
		}
		// If the cell is not in the first column, calculate the left, top-left,
		// and bottom-left as normal.
		if(cellNumber % _gridWidthCeil != 0)
		{	
			left 	= cellNumber - 1;
			topLeft	= (topMiddle >= 0)? (topMiddle - 1) : -1;
			bottomLeft = (bottomMiddle >= 0)? (bottomMiddle - 1) : -1;
		}
		// If the cell is in the first column, there are no cells to the left.
		else
		{
			left	= -1;
			topLeft	= -1;
			bottomLeft	= -1;
		}
		// If the cell is not in the last column, calculate the right, top-right,
		// and bottom-right as normal.
		if((cellNumber + 1) % _gridWidthCeil != 0)
		{
			right		= cellNumber + 1;
			topRight	= (topMiddle >= 0)? (topMiddle + 1) : -1;
			bottomRight	=  (bottomMiddle >= 0)? (bottomMiddle + 1) : -1;
		}
		// If the cell is in the last column, there are no cells to the right.
		else
		{
			right		= -1;
			topRight	= -1;
			bottomRight = -1;
		}
		
		// Check all 8 adjacent directions, and if for each direction there is a
		// valid cell, then add the adjacent cell number to the vector of 
		// adjacent cells.
		var adjacentCells : Vector.<uint> = new Vector.<uint>();
		if(left != -1)	adjacentCells[adjacentCells.length] = left;
		if(right != -1)	adjacentCells[adjacentCells.length] = right;
		if(topMiddle != -1)
		{
			adjacentCells[adjacentCells.length] = topMiddle;
			if(topLeft != -1)	adjacentCells[adjacentCells.length] = topLeft;
			if(topRight != -1)	adjacentCells[adjacentCells.length] = topRight;
		}
		if(bottomMiddle != -1)
		{
			adjacentCells[adjacentCells.length] = bottomMiddle;
			if(bottomLeft != -1)	adjacentCells[adjacentCells.length] = bottomLeft;
			if(bottomRight != -1)	adjacentCells[adjacentCells.length] = bottomRight;
		}
		return adjacentCells;
	}
	
	/**
	 * Returns the cell number of the cell in which the given coordinates lie.
	 * 
	 * @param x The x-value of a point on the stage.
	 * @param y The y-value of a point on the stage.
	 * @return The assigned number of the cell containing (<code>x</code>,<code>y</code>).
	 * 
	 */
	public function getCellNumber(x : Number, y : Number) : int
	{
		var column	: Number = x / _gridSize;
		var row		: Number = y / _gridSize;
		return (int(row) * _gridWidthCeil) + int(column);
	}
}

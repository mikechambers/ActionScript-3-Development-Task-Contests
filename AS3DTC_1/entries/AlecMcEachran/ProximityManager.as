/*
	The MIT License

	Copyright (c) 2009 Alec McEachran

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

	/**
	 * ProximityManager which attempts to satisfy the criteria of Mike Chambers' competition:
	 * 
	 * @see http://www.mikechambers.com/blog/2009/11/10/actionscript-3-development-task-contest-1/
	 * 
	 * This implementation seeks generates an array of GridSquare objects which each contains a neighbour
	 * list of adjacent squares. A GridSquare's position i in the array is found by: i = x + y * columns
	 * where (x,y) is the 0-based position of the grid on an x-y plane, and columns is the number of columns
	 * in the grid.
	 * 
	 * The neighbours of an object is found by concatenating the member lists of the GridSquare under a displayobject
	 * and the GridSquare's neighbours.
	 * 
	 * This implementation can be found along-side some sanity-testing unit-tests at github:
	 *
	 * http://github.com/alecmce/alecmceAS3DevTaskEntry
	 * 
	 * @author Alec McEachran
	 */
	public class ProximityManager
	{
		/** the edge-length of the grid squares */
		private var _gridSize:uint;
		
		/** 1/_gridSize, which is used to avoid division calculations */
		private var _inverseGridSize:Number;
		
		/** the number of columns in the grid */
		private var _columns:int;
		
		/** the number of rows in the grid */
		private var _rows:int;
		
		/** the total number of squares in the grid */
		private var _count:int;
		
		/** an array of grid */
		private var _gridNeighbours:Vector.<GridSquare>;
		
		/**
		 * Class Constructor
		 * 
		 * @param gridSize The size of the edge of the squares into which the rectangular bounds is divided
		 * @param bounds The rectangular bounds of the grid
		 */
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			_gridSize = gridSize;
			_inverseGridSize = 1 / _gridSize;
			_columns = (bounds.width * _inverseGridSize) + 1;
			_rows = (bounds.height * _inverseGridSize) + 1;
			_count = _columns * _rows;
			_gridNeighbours = new Vector.<GridSquare>(_count);
			
			generateGrid();
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(object:DisplayObject):Vector.<DisplayObject>
		{
			var n:int = int(object.x * _inverseGridSize) + _columns * int(object.y * _inverseGridSize);
			var square:GridSquare = _gridNeighbours[n];
			
			return square.getNeighbours();
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			var i:int;
			
			i = _count;
			while (i--)
				_gridNeighbours[i].reset();
			
			i = objects.length;
			while (i--)
			{
				var object:DisplayObject = objects[i];
				var n:int = int(object.x * _inverseGridSize) + _columns * int(object.y * _inverseGridSize);
				
				_gridNeighbours[n].addMember(object);
			}
		}
		
		/**
		 * retrieves a square by its x,y coordinates; used to sanity-test the result of the generateGrid
		 * method, below
		 * 
		 * @param x The horizontal-index of the desired grid square
		 * @param y The vertical-index of the desired grid square
		 * @return The resultant grid square
		 */
		internal function getSquare(x:int, y:int):GridSquare
		{
			return _gridNeighbours[y * _columns + x];
		}
		
		/**
		 * generate a grid of GridSquare objects which are joined to all other GridSquare objects that
		 * are adjacent to them (including diagonals)
		 */
		private function generateGrid():void
		{
			var g:GridSquare;
			var h:GridSquare;
			var n:int;
			
			var y:int = _rows;
			var notFirstY:Boolean = false;
			while (y--)
			{
				var x:int = _columns;
				var notFirstX:Boolean = false;
				while (x--)
				{
					n = y * _columns + x;
					_gridNeighbours[n] = g = new GridSquare(x, y);
					
					if (notFirstX && notFirstY)
					{
						h = _gridNeighbours[n + _columns + 1];
						linkSquares(g, h);
					}
					
					if (notFirstY)
					{
						h = _gridNeighbours[n + _columns];
						linkSquares(g, h);
						
						if (x > 0)
						{
							h = _gridNeighbours[n + _columns - 1];
							linkSquares(g, h);
						}
					}
					
					if (notFirstX)
					{
						h = _gridNeighbours[n + 1];
						linkSquares(g, h);
					}
					
					notFirstX = true;
				}
				
				notFirstY = true;
			}
		}
		
		
		/**
		 * joins two squares together by adding them to each other's neighbour list
		 * 
		 * @param a A GridSquare
		 * @param b A GridSquare
		 */
		private function linkSquares(a:GridSquare, b:GridSquare):void
		{
			a.addNeighbour(b);
			b.addNeighbour(a);
		}
	}
}

import flash.display.DisplayObject;

/**
 * The GridSquare is an internal class used by the ProximityManager to act as a bucket
 * into which DisplayObjects in a certain locus of positions are put.
 * 
 * The GridSquare also contains an array of other GridSquares to which it is adjacent.
 * The neighbours are defined by the ProximityManager when it generates the grid
 * 
 * @author Alec McEachran
 */
final internal class GridSquare 
{
	/** the x-position for debugging */
	private var _x:int;
	
	/** the y-position, for debugging */
	private var _y:int;
	
	/** the array of display objects that are contained within this GridSquare */
	public var members:Vector.<DisplayObject>;
	
	/** the top-index of the members array */
	private var memberIndex:int;
	
	/** the array of GridSquares that lie adjacent to this GridSquare */
	public var neighbours:Vector.<GridSquare>;
	
	/** the top-index of the neighbour array */
	private var neighbourIndex:int;
	
	/**
	 * Class Constructor
	 * 
	 * @param x The object's x-position in the grid defined by ProximityManager
	 * @param y The object's y-position in the grid defined by ProximityManager
	 */
	public function GridSquare(x:int, y:int)
	{
		_x = x;
		_y = y;
		
		neighbours = new Vector.<GridSquare>(8);
		neighbourIndex = 0;
		
		members = new Vector.<DisplayObject>();
		memberIndex = 0;
	}
	
	/**
	 * clear the members array
	 */
	public function reset():void
	{
		members.length = 0;
		memberIndex = 0;
	}
	
	/**
	 * add a neighbour reference to an adjacent GridSquare
	 * 
	 * @param gridSquare The adjacent GridSquare to be added as a neighbour
	 */
	public function addNeighbour(gridSquare:GridSquare):void
	{
		neighbours[neighbourIndex++] = gridSquare;
	}
	
	/**
	 * Add a display object as a member
	 * 
	 * @param object The object to be added as a member
	 */
	public function addMember(object:DisplayObject):void
	{
		members[memberIndex++] = object;
	}
	
	/**
	 * @return an array of members of this and of all the neighbours
	 */
	public function getNeighbours():Vector.<DisplayObject>
	{
		var list:Vector.<DisplayObject> = members.concat();
		
		var i:int = neighbourIndex;
		while (i--)
			list = list.concat(neighbours[i].members);
		
		return list;
	}
	
	
	/**
	 * A human-readable string describing this object's position in the grid
	 * 
	 * @param listNeighbours Whether to list all the neighbours of this GridSquare
	 * 
	 * @return A string dsecribing this GridSquare
	 */
	public function toString(listNeighbours:Boolean = false):String
	{
		var str:String = "(@X@,@Y@)";
		str = str.replace("@X@", _x);
		str = str.replace("@Y@", _y);
		
		if (!listNeighbours)
			return str;
		
		var arr:Array = [];
		var i:int = neighbourIndex;
		while (i--)
			arr[i] = neighbours[i].toString();
			
		str += " -> " + arr.join(",");
		
		return str;
	}
			
}
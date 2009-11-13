/*
	The MIT License

	Copyright (c) 2009 Aaron Spjut

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
	
	[SWF(width="500", height="450", frameRate="24", backgroundColor="#FFFFFF")]
	public class ProximityManager
	{
		private var _gridSize:uint;
		private var _cellWidth:Number;
		private var _cellHeight:Number;
		private var _cells:Vector.<Vector.<DisplayObject>>;
		private var _bounds:Rectangle;
		private var _totalCells:uint;
		private var _rows:uint;
		private var _cols:uint;

		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
			_gridSize = gridSize;
			_cellWidth = gridSize;
			_cellHeight = gridSize;
			_bounds = bounds;
			
			_rows = Math.ceil(_bounds.height/_cellHeight);
			_cols = Math.ceil(_bounds.width/_cellWidth);
			
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var x:Number = displayObject.x - _bounds.x;
			var y:Number = displayObject.y - _bounds.y;
			
			//Here we find the row col which is used to find the index of the cell.
			//Would normally use a method to get the index but inline is faster
			var col:Number = ( Math.ceil((x - _bounds.x)/_cellWidth));
			var row:Number = ( Math.ceil((y - _bounds.y)/_cellHeight));
			
			if(row == 0)
				++row;
				
			if(col == 0)
				++col;
				
			var index:uint = ((( row -1) * ( _cols ) ) + col)-1;
			
			var top:Boolean = (index < _cols);
			var bottom:Boolean = (index >= (_cells.length) - _cols)
			
			var left:Boolean = (index % _cols == 0);
			var right:Boolean = ((index % _cols) == _cols-1);
			
			var neighbors:Vector.<DisplayObject> = _cells[index];
			
			//Determine if the object is on an edge or not. Add cells that are available.
			if(!left && !right && !top && !bottom)
			{
				neighbors = neighbors.concat(_cells[index - 1],
											 _cells[index - _cols - 1],
											 _cells[index - _cols],
											 _cells[index - _cols + 1],
											 _cells[index + 1],
											 _cells[index + _cols + 1],
											 _cells[index + _cols],
											 _cells[index + _cols - 1]
											);
			}
			else if(left)
			{
				neighbors = neighbors.concat(_cells[index + 1]);
				if(!top)
				{
					neighbors = neighbors.concat(_cells[index - _cols],
												 _cells[index - _cols + 1]
												);
				}
				if(!bottom)
				{
					neighbors = neighbors.concat(_cells[index + _cols + 1],
												 _cells[index + _cols]
												);
				}
			}
			else if(right)
			{
				neighbors = neighbors.concat(_cells[index - 1]);
				if(!top)
				{
					neighbors = neighbors.concat(_cells[index - _cols],
												 _cells[index - _cols - 1]
												);
				}
				if(!bottom)
				{
					neighbors = neighbors.concat(_cells[index + _cols - 1],
												 _cells[index + _cols]
												);
				}
			}
			else if(top)
			{
				neighbors = neighbors.concat(_cells[index + _cols - 1],
											 _cells[index + _cols + 1],
											 _cells[index + _cols],
											 _cells[index + 1],
											 _cells[index - 1]
											);
			}
			else if(bottom)
			{
				neighbors = neighbors.concat(_cells[index - _cols - 1],
											 _cells[index - _cols + 1],
											 _cells[index - _cols],
											 _cells[index + 1],
											 _cells[index - 1]
											);
			}
						  
			return neighbors;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			_cells = new Vector.<Vector.<DisplayObject>>(_rows * _cols);
			//Add each display object to a cell based on its cords
			var length:uint = objects.length;
			for(var a:int = 0; a < length; ++a)
			{
				var obj:DisplayObject = DisplayObject(objects[a]);
				
				//Here we find the row col which is used to find the index of the cell.
				//Would normally use a method to get the index but inline is faster
				var col:Number = ( Math.ceil((obj.x - _bounds.x)/_cellWidth));
				var row:Number = ( Math.ceil((obj.y - _bounds.y)/_cellHeight));
				
				if(row == 0)
					++row;
					
				if(col == 0)
					++col;
					
				var index:uint = ((( row -1) * ( _cols ) ) + col)-1;
					
				if(_cells[index] == null)
					_cells[index] = new Vector.<DisplayObject>();
				
				//objects are divided up into the cells they belong to
				 _cells[index].push(obj);
			}
		}
	}
}


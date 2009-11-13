/**
 * @author lab9 - Bertrand Larrieu
 * @mail lab9.fr@gmail.com
 * @link http://lab9.fr
 * @version 0.3

	The MIT License

	Copyright (c) 2009 lab9

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
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public final class ProximityManager
	{
		
		private var _grid:Vector.<Vector.<DisplayObject>>;
		private var _divider:Number;
		private var _gridWidth:int;
		private var _gridHeight:int;
		private var _gridX:int;
		private var _gridY:int;
		private var _added:int;
		private var _length:int;
		private var _i:int;
		private var _pos:int;
		private var _disp:DisplayObject;
		private var _vect:Vector.<DisplayObject>;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
			
			_divider = 1 / gridSize;
			
			_gridWidth = bounds.width * _divider + 2; 
			_gridHeight = bounds.height * _divider + 2;
			_added = _gridWidth + 1;
			
			/**
			 * make a grid with a free space on each bound so we can request gy -1 && gy + 1 without testing existence.
			 */
			
			_length = (_gridWidth) * (_gridHeight + 1) + 1; 
			
			_grid = new Vector.<Vector.<DisplayObject>>(_length, false);
			
			_i = _length;
			while (--_i > -1) _grid[_i] = new Vector.<DisplayObject>();	
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			
			_pos = (displayObject.x * _divider)|0 + ((displayObject.y * _divider)|0) * _gridWidth + _added;
			
			/**
			 * concat the 9 cells 
			 * 				-_gridWidth - 1	|	-_gridWidth	|	-_gridWidth + 1
			 * 				----------------+---------------+------------------
			 * 					- 1			|	 	0		|	  + 1
			 * 				----------------+---------------+------------------
			 * 				+_gridWidth - 1	|	+_gridWidth	|	+_gridWidth + 1
			 */
			
			//return new Vector.<DisplayObject>();
			
			return _grid[_pos].concat(_grid[(_pos - _gridWidth - 1)|0], _grid[(_pos - _gridWidth)|0], _grid[(_pos - _gridWidth + 1)|0], _grid[(_pos - 1)|0], _grid[(_pos + 1)|0], _grid[(_pos + _gridWidth - 1)|0], _grid[(_pos + _gridWidth)|0], _grid[(_pos +_gridWidth + 1)|0]);
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			/**
			 * reset the grid
			 */
			for each(_vect in _grid) _vect.length = 0;
			
			
			/**
			 * fill each cell of the grid with the corresponding displayObject
			 */
			for each(_disp in objects)
			{
				_vect = _grid[(((_disp.x * _divider) | 0) + ((_disp.y * _divider) | 0) * _gridWidth + _added)|0];
				_vect [_vect.length] = _disp;				
			}
			
		}
		
	}
}
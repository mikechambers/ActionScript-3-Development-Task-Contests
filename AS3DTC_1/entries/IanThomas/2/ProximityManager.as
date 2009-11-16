/*
	The MIT License

	Copyright (c) 2009 Ian Thomas (@anatomic)

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
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;


	/**
	 * @author Ian Thomas (@anatomic)
	 */
	public class ProximityManager
	{
		private var _gridSize				:uint;
		private var _bounds					:Rectangle;
		
		private var _cols					:int;
		private var _rows					:int;
	
		private var _gridSquares			:Vector.<Rectangle> = new Vector.<Rectangle>();
		private var _gridCount				:int= 0;
		private var _gridTotal				:int = 0;
		private var _squareContents			:Dictionary = new Dictionary();
		
		private var _objects				:Vector.<DisplayObject>;
		private var checkArea				:Rectangle;
		private  var returnVector			:Vector.<DisplayObject>;
		
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			_gridSize = gridSize;
			_bounds = bounds;
			
			_cols = Math.ceil(_bounds.width / _gridSize);
			_rows = Math.ceil(_bounds.height / _gridSize);
			
			var colCount:int = 0;
			var rowCount:int = 0;
			
			while(rowCount < _rows) {
				while(colCount < _cols) {
					var rect : Rectangle = new Rectangle(colCount * _gridSize, rowCount * _gridSize, _gridSize, _gridSize);
					_gridSquares.push(rect);
					_gridTotal +=1;
					_squareContents[rect] = new Vector.<DisplayObject>();
					colCount +=1;
				}
				colCount = 0;
				rowCount +=1;
			}
			
		}

		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			returnVector = new Vector.<DisplayObject>();
			
			_gridCount = 0;	
			while(_gridCount < _gridTotal){
				if(_gridSquares[_gridCount].contains(displayObject.x, displayObject.y)){		
					checkArea = _gridSquares[_gridCount];				
					checkArea = (_gridCount - _cols - 1) > -1 ? checkArea.union(_gridSquares[_gridCount - _cols - 1]) : checkArea;
					checkArea = (_gridCount - _cols ) > -1 ? checkArea.union(_gridSquares[_gridCount - _cols]) : checkArea;
					checkArea = (_gridCount - _cols + 1) > -1 ? checkArea.union(_gridSquares[_gridCount - _cols + 1]) : checkArea;
					
					checkArea = (_gridCount - 1) > -1 ?checkArea.union(_gridSquares[_gridCount -1]) : checkArea;
					checkArea = (_gridCount + 1) < _gridTotal ? checkArea.union(_gridSquares[_gridCount +1]) : checkArea;
					
					checkArea = (_gridCount + _cols - 1) < _gridTotal ? checkArea.union(_gridSquares[_gridCount + _cols -1 ]) : checkArea;
					checkArea = (_gridCount + _cols ) < _gridTotal ? checkArea.union(_gridSquares[_gridCount + _cols]) : checkArea;
					checkArea = (_gridCount + _cols + 1) < _gridTotal ? checkArea.union(_gridSquares[_gridCount + _cols +1]) : checkArea;
					break;
				}
				_gridCount+=1;;
			}
				
			var itemCount:int = 0;
			var numItems:int = _objects.length;	
			
			while(itemCount < numItems ){
				if(checkArea.contains(_objects[itemCount].x, _objects[itemCount].y)){
					returnVector.push(_objects[itemCount]);
				}
				itemCount+=1;;
			}
			
			return returnVector;
		}
				
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{			
			_objects = objects;			
		}
	}
}


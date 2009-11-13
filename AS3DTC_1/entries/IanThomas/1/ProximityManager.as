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
		private var _gridSize				:int;
		private var _bounds					:Rectangle;
		private var _off					:int;
		
//		private var index					:int = 0;
	
		private var _gridSquares			:Array;
		private var _cache					:Array;
		private  var returnVector			:Vector.<DisplayObject>;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle):void
		{
			_gridSize = gridSize;
			_bounds = bounds;
			 _off = _gridSize * 1024;
		}

		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var index:int = ((displayObject.x + _off) / _gridSize) << 11 | ((displayObject.y + _off) / _gridSize);
			if(_cache[index]) return _cache[index];
			
			returnVector = _gridSquares[index] ? _gridSquares[index] : returnVector;
			returnVector = _gridSquares[index - 2047] ? returnVector.concat(_gridSquares[index - 2047]) : returnVector;			returnVector = _gridSquares[index - 2048] ? returnVector.concat(_gridSquares[index-2048]) : returnVector;			returnVector = _gridSquares[index - 2049] ? returnVector.concat(_gridSquares[index-2049]) : returnVector;
						returnVector = _gridSquares[index - 1] ? returnVector.concat(_gridSquares[index-1]) : returnVector;			returnVector = _gridSquares[index + 1] ? returnVector.concat(_gridSquares[index+1]) : returnVector;
			
			returnVector = _gridSquares[index + 2047] ? returnVector.concat(_gridSquares[index+2047]) : returnVector;
			returnVector = _gridSquares[index + 2048] ? returnVector.concat(_gridSquares[index+2048]) : returnVector;
			returnVector = _gridSquares[index + 2049] ? returnVector.concat(_gridSquares[index+2049]) : returnVector;
						
			_cache[index] = returnVector;
			
			return returnVector;
		}
				
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{			
			_gridSquares = [];
			_cache = [];
			
			var total:int = objects.length;
			var count:int = 0;
			var object:DisplayObject;
			var index:int;
			
			while(count < total){
				object = objects[count];
				index = ((object.x + _off) / _gridSize) << 11 | ((object.y + _off) / _gridSize);
				if(!_gridSquares[index]){
					_gridSquares[index] = new Vector.<DisplayObject>();
					_gridSquares[index][0] = object;
					++count;
					continue;
				}
				_gridSquares[index].push(object);
				++count;
			}
//			
//			for each(var object:DisplayObject in objects){//				index = ((object.x + _off) / _gridSize) << 11 | ((object.y + _off) / _gridSize);
//				if(!_gridSquares[index]){
//					_gridSquares[index] = new Vector.<DisplayObject>();
//					_gridSquares[index][0] = object;
//					continue;
//				}
//				_gridSquares[index].push(object);
//			}
//
//			
		}
	}
}


/*
	The MIT License

	Copyright (c) 2009 William Tsang, Digicrafts
	www.digicrafts.com.hk/components
	tsangwailam@gmail.com

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
	
	public class ProximityManager
	{
		private var _items:Vector.<DisplayObject>;
		private var _gridSize:Number = 0;
		private var _invGridSize:Number = 0;
		private var _bounds:Rectangle;
		private var _gridCount:Number = 0;
		private var _gridW:Number = 0;
		private var _gridH:Number = 0;
		private var _cells:Vector.<Vector.<DisplayObject>>;
		private var _index:Vector.<Vector.<int>>;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			super();
			
			// Save the gridSize and bounds
			_gridSize = gridSize;
			_invGridSize = 1/_gridSize;
			_bounds = bounds;	 
			
			// Cal the number oF cell in vertical and horizontal
			_gridW = Math.ceil(_bounds.width/_gridSize);
			_gridH = Math.ceil(_bounds.height/_gridSize);
			
			// Calculate the total number of cell
			_gridCount = _gridW*_gridH;
			
			// Construct object to hold the chexk index for each cell
			_index = new Vector.<Vector.<int>>(_gridCount,true);
			
			// Calculate the check index
			var i:Number = _gridCount;
			while(i--) {
				var indexs:Vector.<int> = new Vector.<int>();
				if(i - _gridW > 0) {
					indexs.push(int(i - _gridW));
					if(i - _gridW - 1 >= 0 && (int((i - _gridW -1)/_gridW) == int((i - _gridW)/_gridW)) ) indexs.push(int(i - _gridW - 1));
					if(i - _gridW + 1 > 0 && (int((i - _gridW +1)/_gridW) == int((i - _gridW)/_gridW))) indexs.push(int(i - _gridW + 1));
				}
				if(i + _gridW < _gridCount) {
					indexs.push(int(i + _gridW));
					if(i + _gridW - 1 > 0 && (int((i + _gridW -1)/_gridW) == int((i + _gridW)/_gridW)) ) indexs.push(int(i + _gridW - 1));
					if(i + _gridW + 1 > 0 && (int((i + _gridW +1)/_gridW) == int((i + _gridW)/_gridW)) ) indexs.push(int(i + _gridW + 1));
				}
				if(i - 1 > 0 && (int((i-1)/_gridW) == int((i)/_gridW)) ) indexs.push(int(i - 1));
				if(i + 1 > 0 && (int((i+1)/_gridW) == int((i)/_gridW)) ) indexs.push(int(i + 1));
				//trace("idx",i,"content",indexs,"c",i - _gridW - 1 > 0 && (int((i - _gridW -1)/_gridW) == int((i - _gridW)/_gridW)));
				_index[i] = indexs;
			}
			
			_cells = new Vector.<Vector.<DisplayObject>>(_gridCount,false);
			
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var v:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// Calculate the cell index
			var i:int = int(displayObject.x*_invGridSize + int(displayObject.y*_invGridSize)*_gridW);
			
			// get the display object in center cell
			v = v.concat(_cells[i]);
		
			// get the display object in surounded cell
			for each (var c:int in _index[i]) v = v.concat(_cells[c]);

			// return all display object in the corresponding cells
			return v;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{			
			
			// Construct Vector object to hold object in each cell
			// ******************************************************************
			// *remark: Use fixed length with slower 5% when using for loop on Vector
			//          No different when use while loop.
			//if(_cells == null) _cells = new Vector.<Vector.<DisplayObject>>(_gridCount,false);
			var i:int = _gridCount;
			while(i--) _cells[i] = new Vector.<DisplayObject>();
			
			// Loop each DOs and fill the display object in each cell
			// ******************************************************************
			for each(var v:DisplayObject in objects) _cells[int(v.x*_invGridSize + int(v.y*_invGridSize)*_gridW)].push(v);
			// Use for loop instead of Vector.forEach() for better perforamce, 30% +
			//objects.forEach(updateCell);

		}
		
		
	}
}


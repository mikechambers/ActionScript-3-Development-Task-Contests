/*
	The MIT License

	Copyright (c) 2009 Ross Gerbasi

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
 * Ross Gerbasi
 */
package {
	import flash.display.DisplayObject;
	import __AS3__.vec.Vector;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class ProximityManager {
		
		private var _possibleTargets:Vector.<DisplayObject>
		private var _bounds:Rectangle;
		private var _gridSize:uint;
		
		private var _objectCellIDLookup:Dictionary = new Dictionary();
		private var _gridLookup:Array
		private var _rows:uint;
		private var _cols:uint;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle) {
			super();
			
			_gridSize 		= gridSize;
			_bounds	 		= bounds;
			initGrid();		
		}
		
		private function initGrid():void {
			this._gridLookup = new Array();
			this._rows = Math.ceil(_bounds.width / _gridSize);
			this._cols = Math.ceil(_bounds.height/ _gridSize);

			for (var row_index:int = 0; row_index < this._rows; row_index++) {
				for (var col_index:int = 0; col_index < this._cols; col_index++) {
					var cellID:int = (this._rows * col_index) + (row_index + 1)
					this._gridLookup[cellID] = new Dictionary();
				}
			}	
		}
		
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject> {
			var cellID: int = getCellID(displayObject);
			
			
			return dictsToVector(
				[
					this._gridLookup[cellID],
					this._gridLookup[cellID - 1],
					this._gridLookup[cellID +1],
					this._gridLookup[cellID -_rows],
					this._gridLookup[cellID -_rows+1],
					this._gridLookup[cellID -_rows-1],
					this._gridLookup[cellID +_rows],
					this._gridLookup[cellID +_rows+1],
					this._gridLookup[cellID +_rows-1]
				] );
			//return new Vector.<DisplayObject>();
		}
		
		private function dictsToVector(dicts:Array):Vector.<DisplayObject>{
			var v:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for each (var dict:Object in dicts) {
				for (var key:Object in dict) {
					v.push(key as DisplayObject);
				}
			}
			return v;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void {
			objects.forEach(updateLocation, null);
		}
		
		private function updateLocation(item:DisplayObject, index:int, vector:Vector.<DisplayObject>):void {
			var cellID:uint = getCellID(item); 
			if (_objectCellIDLookup[item]) delete this._gridLookup[_objectCellIDLookup[item]][item];
			
			this._gridLookup[cellID][item] = true;
			_objectCellIDLookup[item] = cellID
		}
		
		private function getCellID(item:DisplayObject):uint {
			var x_grid_loc:int = Math.ceil(item.x / _gridSize)
			var y_grid_loc:int = Math.ceil(item.y / _gridSize)
			
			if (item.x == 0) {
				x_grid_loc = 1;
			}else {
				x_grid_loc-=1
			}
			
			if (item.y == 0) {
				y_grid_loc = 1;
			}else {
				y_grid_loc -= 1;
			}
			
			return (1 + x_grid_loc + (y_grid_loc * this._rows));
		}
	}
}


/*
	The MIT License

	Copyright (c) 2009 Mike Chambers

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
	import flash.text.TextField;
	
/*
 * ProximityManager is aimed to find DisplayObjects around a point, as quickly as possible
 * To improve performance, Vectors are used instead of Arrays
*/
	public class ProximityManager
	{
		// listObjects : 2D vector of DisplayObjects groups
		private var listObjects:Vector.<Vector.<Vector.<DisplayObject>>>;
		// predefined list of neighbors (represented as couple of row/col) for each cell
		// coordinates are int because I heard that int is faster than uint (feel free to correct me if I'm wrong !)
		private var listNeighbors:Vector.<Vector.<Vector.<Vector.<int>>>>;
		
		// internal variables
		private var gridSize:uint;
		private var bounds:Rectangle;
		private var nRows:uint;
		private var nCols:uint;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			this.gridSize = gridSize;
			this.bounds = bounds;
			createGrid();
		}
		
		/**
		*	Returns cells around the cell specified by it's index in listObjects
		* 	the cell is included in the Vector that is returned
		*/
		private function getCellsAround(r:int, c:int):Vector.<Vector.<int>>{
			var v:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			// the cell itself is included in neighbors
			v.push(vec(r, c));
			
			if (r > 0) {
				v.push(vec(r-1, c));
				if(c > 0) v.push(vec(r - 1, c-1));
				if(c < (nCols-1)) v.push(vec(r - 1, c + 1));
			}
			if (r < (nRows-1)) {
				v.push(vec(r+1, c));
				if(c > 0) v.push(vec(r + 1, c - 1));
				if(c < (nCols-1)) v.push(vec(r + 1, c + 1));
			}
			if (c > 0) v.push(vec(r, c-1));
			if (c < (nCols - 1)) v.push(vec(r, c + 1));
			return v;
		}
		
		private function vec(r:uint, c:uint):Vector.<int>{
			var v:Vector.<int> = new Vector.<int>();
			v[0] = r;
			v[1] = c;
			return v;
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			// result : this vector will contain all DisplayObjects around displayObject
			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// I just use a division to get the cell coordinates, seems to be the fastest way
			// no need to use Math.floor, the conversion from Number to int do it faster !
			var r:int = displayObject.y / gridSize;
			var c:int = displayObject.x / gridSize;
			var neighbors:Vector.<Vector.<int>> = listNeighbors[r][c];
			for each(var v:Vector.<int> in neighbors) {
				result = result.concat(listObjects[v[0]][v[1]]);
			}
			return result;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		* 	A 2D Vector of DisplayObject groups is build for each cell, with all DisplayObjects contained in this cell.
		* 	These Vectors are stored in listObjects.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			var obj:DisplayObject;
			var r:int, c:int;
			
			// reinitialize the list of DisplayObjects for each cell, because the DOs are pushed
			// if we don't clear the list, it will get bigger and bigger...
			listObjects = createEmptyListCells();

			// loop thru the list of objects
			for each(obj in objects) {
				// same way as in update, the coordinates are calculated with a division
				r = obj.y / gridSize;
				c = obj.x / gridSize;
				// add DisplayObject reference to the linear list of cells
				listObjects[r][c].push(obj);
			}
		}
		
		/**
		*	createGrid is used in the constructor to init the variables of the class (nCols, nRows, nTotal)
		* 	and prepare a list of neighbors for each cell, so when we need it, we don't have to perform all
		* 	tests to control if cells are within the bounds
		*/
		private function createGrid():void{
			nCols = Math.ceil(bounds.width / gridSize);
			nRows = Math.ceil(bounds.height / gridSize);
			
			// init list of neighbors, it's done here to improve performance
			// it could have been done in getNeighbors() also, because we don't really need
			// to get neighbors for all cells but making this improve performance
			var c:int, r:int;
			listNeighbors = new Vector.<Vector.<Vector.<Vector.<int>>>>();
			for (r = 0; r < nRows; r++) {
				listNeighbors[r] = new Vector.<Vector.<Vector.<int>>>;
				for (c = 0; c < nCols; c++ ) {
					listNeighbors[r][c] = getCellsAround(r, c);
				}
			}
		}
		
		/**
		*	Create a vector of nTotal DisplayObjectVector empty vectors
		* 	It's strange but if I put this code directly in update function, it's a little bit slower than
		* 	calling this function (according to the tests I made)
		*/
		private function createEmptyListCells():Vector.<Vector.<Vector.<DisplayObject>>>{
			var list:Vector.<Vector.<Vector.<DisplayObject>>> = new Vector.<Vector.<Vector.<DisplayObject>>>();
			var c:int, r:int;
			for (r = 0; r < nRows; r++) {
				list[r] = new Vector.<Vector.<DisplayObject>>;
				for (c = 0; c < nCols; c++){
					list[r][c] = new Vector.<DisplayObject>();
				}
			}
			return list;
		}
		
		/**
		*	getCellIndex is supposed to be faster than the division operation (obj.x/gridSize)
		* 	but when I tested it, it was slower, so it's no more used
		* 	I leaved it for information, and to have feedback on the utility of such a method
		*/
		private function getCellIndex(pos:uint):int{
			var offset:uint;
			var index:int;
			while (pos >= offset) { offset += gridSize; index++; }
			return index-1;
		}
		
		
	}
}


/*
	The MIT License

	Copyright (c) 2009 Phillip Chertok

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
		//Keep a multidimensional Vector of all of our rows, each row will contain a Vector of columns.
		//Those columns contains Vectors of objects that corresond to a single square on our grid.
		private var _rows:Vector.<Vector.<GridSquare>> = new Vector.<Vector.<GridSquare>>();
		
		//Store all of the display objects when used with Update()
		private var _objects:Vector.<DisplayObject>;
		
		//Keep track of our grid size and bounds (don't realy use them later)
		private var _gridSize:int;
		private var _bounds:Rectangle;
		
		//Keep track of our row and column counts
		private var _rowCount:int;
		private var _colCount:int;
		
		public function ProximityManager(gridSize:int, bounds:Rectangle)
		{
			_gridSize = gridSize;
			_bounds = bounds;
			
			//Determine the amount of rows and columns in our grid
			var rows:int = Math.ceil(bounds.height / gridSize);
			var columns:int = Math.ceil(bounds.width / gridSize);				
			
			//Store those values
			_rowCount = rows;
			_colCount = columns;	
			
			//Loop through each row and create a vector of column objects
			for (var r:int = 0; r < rows; ++r) {
				
				var row:Vector.<GridSquare> =  new Vector.<GridSquare>();
				
				//Determine the y position of the row
				var rowY:int = r * gridSize;
				
				//Loop through all the columns
				for (var c:int = 0; c < columns; ++c) 
				{
					//Determine the x position of the column
					var colX:int = c * gridSize;
					
					//Custom mini class - essentially a struct see bottom of class
					var obj:GridSquare = new GridSquare(colX, rowY );
					
					//Store that object
					row[c] = obj;
				}
				
				//Add the row to our vector
				_rows.push( row );
			}
			
			super();
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			//Find the rown and column of the supplied object
			var row:int = getRowOf(displayObject),
				col:int = getColOf(displayObject),			
			
				//Determine the x and y position from where to start our bounding box
				boundsX:int = (col > 0) ? _rows[row][col].x - _gridSize : 0,
				boundsY:int = (row > 0) ? _rows[row][col].y - _gridSize : 0,
			
				//Determine the width and height of our bounding box
				boundsWidth:int = (col > 0 && col < _colCount) ? _gridSize * 3 : _gridSize * 2,
				boundsHeight:int = (row > 0 && row < _rowCount) ? _gridSize * 3 : _gridSize * 2;
			
			//Find all the objects within those bounds and return them.
			return getObjectsWithinBounds( new Rectangle(boundsX, boundsY, boundsWidth, boundsHeight) );
		}	
		
		/**
		 * Return all of the displayObjects in our _objects Vector that are within the provided bounds
		 * 
		 * @param	$bounds
		 * @return
		 */
		private function getObjectsWithinBounds($bounds:Rectangle):Vector.<DisplayObject>
		{
			var i:int = 0,
				l:int = _objects.length,
				objectsWithinBounds:Vector.<DisplayObject> = new Vector.<DisplayObject>(),		
				
				maxX:int = $bounds.right,
				maxY:int = $bounds.bottom;			
			
			//Loop through all the provided objects and check to see if they are within the bounds
			for (i; i < l; ++i) {
				
				var obj:DisplayObject = _objects[i];				

				//If our object's X value is outside of our bonds skip to the next iteration of our loop
				if ( ( obj.x >= $bounds.x && obj.x <=  maxX ) == false ) continue;	
			
				//If our object's Y value is outside of our bonds skip to the next iteration of our loop				
				if ( obj.y >= $bounds.y && obj.y <=  maxY ) {
					//If we've made it this far the object is in bounds and we should add it to our Vector
					objectsWithinBounds.push( obj );
				}			
			}
			
			return objectsWithinBounds;
		}
		
		/**
		 * Returns the column index of a particular display object
		 * 
		 * @param	$do
		 * @return
		 */
		private function getColOf($do:DisplayObject):int
		{
			return int($do.x / _gridSize);

		}
		
		/**
		 * Returns the row index of a particular display object
		 * 
		 * @param	$do
		 * @return
		 */
		private function getRowOf($do:DisplayObject):int
		{
			return int($do.y / _gridSize);
		}

		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			_objects = objects;				
		}
		
//---- ALTERNATIVE METHOD OF GETTING NEIGHBORS -------------------------------------------------------------------------		

		/**
		 * This is an alternatie method of returning the neighbours.  It is fater than the other GetNeighbors() method
		 * but because it requires more time when used with the updateStoredObjects() it fails for the purposes of this test.
		 * In the case where a user knows they will be retrieve an object's neightbours FAR more than calling the update method,
		 * this is by far the faster means to get the neighbours.
		 * 
		 * 
		 * @param	displayObject
		 * @return
		 */
		public function getNeighborsStoredObjects(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			//Find the row of the supplied display object.
			var row:int = getRowOf(displayObject),
				col:int = getColOf(displayObject),		
			
			//Calculate the minimum and maximum row and column values
				minRow:int = (row > 0) ? row - 1 : 0,
				maxRow:int = (row < _rowCount -1) ? row + 1 : row,
			
				minCol:int = (col > 0) ? col - 1 : 0,
				maxCol:int = (col < _colCount - 1) ? col + 1 : col,
			
			//Create a Vector to store our results
				results:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			//Loop through all the rows and colums
			for (var r:int = minRow; r <= maxRow; ++r) {
				
				for (var c:int = minCol; c <= maxCol; ++c) {					
					
					//Get the contents of that row/column pair and add it to our results Vector
					results = results.concat( _rows[r][c].contents );
				}				
			}
			return results;
		}
		
		/**
		 * When used in conjuction with getNeighborsStoredObjects() it provides a faster means 
		 * of finding neighbours in the case where a user will move display objects infrequently compared to 
		 * a frequent need to find an object's neighbours.
		 */
		public function updateStoredObjects(objects:Vector.<DisplayObject>):void
		{
			var l:int = objects.length;	
			
			//Reset all our Vectors
			clearContents();			
			
			//Loop through all the objets
			for (var i:int = 0; i < l; ++i) {
				
				var obj:DisplayObject = objects[i],
				
					//Find the row and column
					row:int = getRowOf(obj),
					col:int = getColOf(obj),
				
					//Store that object in the contents of te appropriate row/column object in our multi-dimmensional Vector
					contents:Vector.<DisplayObject> = _rows[row][col].contents;				
				
				contents.push( obj );
			}
		}
		
		/**
		 * Used by updateStoredObjects() to clear all the of contents objects in our _rowsAndColumns multi-dimensional vector
		 */
		private function clearContents():void
		{
			for (var r:int = 0; r < _rowCount; ++r) {
				
				for (var c:int = 0; c < _colCount; ++c){
					 _rows[r][c].contents = new Vector.<DisplayObject>();
				}				
			}
		}
	}
}

/**
 * UTILITY CLASS TO HOLD SOME VALUES
 */
class GridSquare {
	
	import __AS3__.vec.Vector;
	import flash.display.DisplayObject;
	
	public var x:int;
	public var y:int;	
	public var contents:Vector.<DisplayObject> = new Vector.<DisplayObject>();
	
	public function GridSquare($x:int, $y:int) {
		x = $x;
		y = $y;	
	}
}


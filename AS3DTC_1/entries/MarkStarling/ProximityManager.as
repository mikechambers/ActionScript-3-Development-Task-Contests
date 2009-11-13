/*
   The MIT License

   Copyright (c) 2009 Mark Starling
   Website: http://www.markstar.co.uk
   Twitter: @mark_star

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
		private var _displayObjects:Vector.<DisplayObject>;
		private var _gridSize:uint;
		private var _bounds:Rectangle;
		
		// this method of proximity testing does not rely on the update method to be called if
		// the positions of the display objects change. it is only necessary to call the update
		// method if display objects are added or removed from the stage. furthermore the vector
		// of returned neighbours all fall within the bounds specified.
		
		public function ProximityManager( gridSize:uint, bounds:Rectangle ):void
		{
			// store the grid size and bounds in class properties.  
			_gridSize = gridSize;
			_bounds = bounds;
		}
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 */
		public function getNeighbors( displayObject:DisplayObject ):Vector.<DisplayObject>
		{
			// create copies of class properties with method scope for faster access.
			var displayObjects:Vector.<DisplayObject> = _displayObjects;
			var gridSize:uint = _gridSize;
			var bounds:Rectangle = _bounds;
			
			// determine where in the grid the displayObject is.
			var column:uint = ( displayObject.x / gridSize ) | 0;
			var row:uint = ( displayObject.y / gridSize ) | 0;
			
			// set the boundaries of where the neighbouring display objects can reside.
			var xMin:int = gridSize * ( column - 1 );
			var xMax:int = gridSize * ( column + 2 );
			var yMin:int = gridSize * ( row - 1 );
			var yMax:int = gridSize * ( row + 2 );
			
			// create variable for use when looping through all display objects on the stage.
			var objectToTest:DisplayObject;
			
			// create the vector to be returned that will contain the neighbours
			var neighbours:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// validate that the boundaries set for the neighbouring display objects
			// against the bounds specified.
			if( xMin < bounds.x )
			{
				xMin = 0;
			}
			
			if( xMax > bounds.x + bounds.width )
			{
				xMax = bounds.x + bounds.width;
			}
			
			if( yMin < bounds.y )
			{
				yMin = 0;
			}
			
			if( yMax > bounds.y + bounds.height )
			{
				yMax = bounds.y + bounds.height;
			}
			
			// loop through the display objects on the stage and check whether or not they reside
			// within the boundaries. If they do then add them to the vector to be returned.
			for each( objectToTest in displayObjects )
			{
				if( objectToTest.x > xMin && objectToTest.x < xMax && objectToTest.y > yMin &&
					objectToTest.y < yMax )
				{
					neighbours[ neighbours.length ] = objectToTest;
				}
			}
			
			// return the vector of neighbouring display objects. 
			return neighbours;
		}
		
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update( objects:Vector.<DisplayObject> ):void
		{
			// set the current list of display objects to null.
			_displayObjects = null;
			
			// store a copy of the list of display objects in the class property. a copied is needed so
			// we are not keeping references to the original vector (for GC, etc).
			_displayObjects = objects.concat();
			
			// fix the length of the vector as this will not change.
			_displayObjects.fixed = true;
		}
	
	}
}


/*
	The MIT License

	Copyright (c) 2009 Steve Sedlmayr

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
	
	public class ProximityManager {
		/**
		 * Variable, mutator and accessor for the bounds.
		 */
		private static var $BOUNDS:Rectangle = new Rectangle();
		
		public static function get BOUNDS() : Rectangle {
			return $BOUNDS;
		}
		
		public static function set BOUNDS(value:Rectangle) : void {
			$BOUNDS = value;
		}
		
		/**
		 * Variable, mutator and accessor for the grid size.
		 */
		private static var $GRID_SIZE:uint = 0;
		
		public static function get GRID_SIZE() : uint {
			return $GRID_SIZE;
		}
		
		public static function set GRID_SIZE(value:uint) : void {
			$GRID_SIZE = value;
		}
		
		/**
		 * Variable, mutator and accessor for the DisplayObject collection.
		 */
		private static var $ITEMS:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		public static function get ITEMS() : Vector.<DisplayObject> {
			return $ITEMS;
		}
		
		public static function set ITEMS(value:Vector.<DisplayObject>) : void {
			$ITEMS = value;
		}
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle) {
			super();
			
			//Store the bounds and gridSize for later.
			ProximityManager.BOUNDS = bounds;
			ProximityManager.GRID_SIZE = gridSize;
		}
		
		/**
		 * Returns all display objects in the current and adjacent grid cells of the
		 * specified display object.
		 */
		public function getNeighbors(displayObject:DisplayObject) : Vector.<DisplayObject> {
			/* Create as many local variables as possible to cut the number 
			   of references to any non-local variable to no more than one. */
			var bounds:Rectangle = ProximityManager.BOUNDS;
			var displayObjectX:Number = displayObject.x;
			var displayObjectY:Number = displayObject.y;
			var gridSize:uint = ProximityManager.GRID_SIZE;
			var items:Vector.<DisplayObject> = ProximityManager.ITEMS;
			
			//Get the x and y of the target DisplayObject's grid square.
			var sourceX:Number = displayObjectX - (displayObjectX % gridSize);
			var sourceY:Number = displayObjectY - (displayObjectY % gridSize);
			
			var currentObject:DisplayObject; //Initialize an object for the current object being evaluated.
			var currentObjectX:int; //Initialize the current object's x.
			var currentObjectY:int; //Initialize the current object's y.
			var hitSpan:Number = gridSize * 3; //The span of the hit bounds.
			var hitThreshholdX:Number = displayObject.width/2; //A variable to evaluate check Sprites overlapping a grid line in the x axis.
			var hitThreshholdY:Number = displayObject.height/2; //A variable to evaluate check Sprites overlapping a grid line in the y axis.
			var hitX:int = sourceX - gridSize; //The left boundary of the hit area.
			var hitY:int = sourceY - gridSize; //The top boundary of the hit area.
			var hitRight:int = hitX + hitSpan; //The right boundary of the hit area.
			var hitBottom:int = hitY + hitSpan; //The bottom boundary of the hit area.
			var itemIndex:int = 0; //Initialze the current item index.
			var returnVector:Vector.<DisplayObject> = new Vector.<DisplayObject>(); //Initialize the vector we will return.
			
			/* If the check Sprite overlaps a grid line by more than half its width in the x
			   or half its height in the y, shift the hit bounds in the appropriate direction
			   by 1 grid size. */
			if ( displayObjectX < sourceX - hitThreshholdX ) { hitX -= gridSize; } else if ( displayObjectX > sourceX + gridSize + hitThreshholdX ) { hitX += gridSize; }
			if ( displayObjectY < sourceY - hitThreshholdY ) { hitY -= gridSize; } else if ( displayObjectY > sourceY + gridSize + hitThreshholdY ) { hitY += gridSize; }
			
			//Bias to the constructor bounds if the hit bounds overlap them.
			if ( hitX < bounds.x ) { hitX = bounds.x; }
			if ( hitY < bounds.y ) { hitY = bounds.y; }
			if ( hitRight > bounds.width ) { hitRight = bounds.width; }
			if ( hitBottom > bounds.height ) { hitBottom = bounds.height; }
			
			/* Since all of the Sprites are placed randomly, we have to iterate
			   over the whole collection at least once. Use 'while' instead of 'for'
			   and an externalized index variable to cut down on the overhead.
			   Values are externalized to local variables as much as possible. 
			   These techniques save about 60 ms. */
			while ( itemIndex < items.length ) {
				//Define the current object and its properties.
				currentObject = items[itemIndex];
				currentObjectX = currentObject.x;
				currentObjectY = currentObject.y;
				
				//Skip any object outside the current hit bounds (not adjusting for overlap here).
				if ( currentObjectX < hitX ) { ++itemIndex; continue; }
				if ( currentObjectX > hitRight ) { ++itemIndex; continue; }
				if ( currentObjectY < hitY ) { ++itemIndex; continue; }
				if ( currentObjectY > hitBottom ) { ++itemIndex; continue; }
				
				//currentObject.alpha = 0; //Uncomment this line to visually test the results. Adds about 1 ms.
				returnVector[returnVector.length] = currentObject; //Push a matching object into the Vector we will return;
				++itemIndex;
			}
			
			return returnVector;
		}
		
		/**
		 * Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update(objects:Vector.<DisplayObject>) : void {
			/* We can't be sure where the randomly generated check Sprites will 
			   be placed, so no preprocessing (for instance, reorganizing the 
			   collection into a binary tree or something similar) is possible. 
			   Just store the Vector. */
			ProximityManager.ITEMS = objects;
		}
	}
}
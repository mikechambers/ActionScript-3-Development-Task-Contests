/*
	The MIT License

	Copyright (c) 2009 Daniel Kerner

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

	import flash.utils.Dictionary;
	
	/**
	 * ProximityManager 
	 * 
	 * @author Daniel Kerner (kontakt@danielkerner.com)
	 * @version 2009-11-11
	 * @note For Contest hosted by Mike Chambers
	 * 		 http://www.mikechambers.com/blog/2009/11/10/actionscript-3-development-task-contest-1/
	 * 
	 * 
	 */
	public class ProximityManager
	{
		private var _gridSize:uint;
		private var _bounds:Rectangle;
		private var _objects:Vector.<DisplayObject>;
		
		/**
		 * Dictionary to store vectors which contain DisplayObjects
		 * ["1_1" => vector.<DisplayObject>]
		 * filled in update()
		 * read in getNeighbors()
		 */
		private var _allVectors:Dictionary;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			this._gridSize = gridSize;
			this._bounds = bounds;
			super();
		}
		
	
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			// vector that is returned and that will hold all our DisplayObjects
			var returnVector:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// Calculate x/y coordinates used for next step
			var xFieldCoordinate:uint = Math.floor(displayObject.x/this._gridSize-1)*this._gridSize;
			var yFieldCoordinate:uint = Math.floor(displayObject.y/this._gridSize-1)*this._gridSize;
			
			// rectangle that describes an area around my display Object that contans all Neighbours
//			var neighbourHoodRectangle:Rectangle = new Rectangle((xFieldCoordinate-1)*this._gridSize,(yFieldCoordinate-1)*this._gridSize,3*this._gridSize,3*this._gridSize);
			var neighbourHoodRectangle:Rectangle = new Rectangle(xFieldCoordinate,yFieldCoordinate,3*this._gridSize,3*this._gridSize);
			

			for each(var dO:DisplayObject in this._objects){

				//   check if display Object is inside the bounds Rectangle
				// + check if display Object is inside the neighbourHoodRectangle
				if(this._bounds.contains(dO.x,dO.y) && neighbourHoodRectangle.contains(dO.x,dO.y)){ 
				
					returnVector.push(dO);
				}
			}
			return returnVector;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
	    * 
	    *	save all objects
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			this._objects = objects;
			
		}	
	}
}


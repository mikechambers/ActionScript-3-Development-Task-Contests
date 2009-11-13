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
			
			// Calculate GridCoordinates used for next step
			var xFieldCoordinate:uint = Math.floor(displayObject.x/this._gridSize);
			var yFieldCoordinate:uint = Math.floor(displayObject.y/this._gridSize);
			
 			/* Create strings in the form of 0_0 to n_n describing the neighbours position 
 			   of the DisplayObject
			   Concat vectors to returnVector if they exist
			   In case neightbour fields are empty or offScreen the vector won't exist*/
			var fieldString:String;
			
			for(var i:int = -1; i <= 1; i++){				
				for(var j:int = -1; j <= 1; j++){
					
					fieldString = (xFieldCoordinate+i) + "_" + (yFieldCoordinate+j);
					
					if (this._allVectors[fieldString] != undefined)
						returnVector = returnVector.concat(this._allVectors[fieldString]);
					
					
				}			
			} 
			
			
			return returnVector;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
	    * 
	    *	All DisplayObjects that are in the same grid are out into the same Vector
		*	That Vector is stored in this._allVectors [String => Vector]
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			this._allVectors = new Dictionary();

			for each(var dO:DisplayObject in objects){
				
				//var displayObject:DisplayObject = objects[i];	
				
				//check if display Object is inside the bounds Rectangle
				if(this._bounds.contains(dO.x,dO.y)){ 
				
					/* Creates a string in the form of 1_1 to n_n depending in which
				   	   grid the display Object is positioned */
		 			var xFieldCoordinate:uint = Math.floor(dO.x/this._gridSize);
					var yFieldCoordinate:uint = Math.floor(dO.y/this._gridSize);	
					var fieldCoordinate:String =  xFieldCoordinate + "_" + yFieldCoordinate; 
		
 					// create a new Vector if it does not exist yet
					if (this._allVectors[fieldCoordinate] == undefined)
						this._allVectors[fieldCoordinate] = new Vector.<DisplayObject>();
					
					 
					// add display Object to Vector
					this._allVectors[fieldCoordinate].push(dO);
				}
			}
			
		}	
	}
}


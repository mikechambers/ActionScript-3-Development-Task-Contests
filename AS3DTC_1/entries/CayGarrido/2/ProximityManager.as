/*
	The MIT License

	Copyright (c) 2009 Cay Garrido

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
	import flash.display.BitmapData;
	import __AS3__.vec.Vector;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	
	public class ProximityManager {
		
		//bi-dimentional array of coordinates
		var arr:Array=new Array();
		
		private var GRIDSIZE:Number;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null) {
			GRIDSIZE=1/gridSize;
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(o:DisplayObject):Vector.<DisplayObject> {
			var x:uint=o.x*GRIDSIZE;
			var y:uint=o.y*GRIDSIZE;
			
			//populate and return the vector of each cell
			return new Vector.<DisplayObject>().concat(
				getVectorForCell(x		, y		),
				getVectorForCell(x		, y-1	),
				getVectorForCell(x+1	, y-1	),
				getVectorForCell(x+1	, y		),
				getVectorForCell(x+1	, y+1	),
				getVectorForCell(x		, y+1	),
				getVectorForCell(x-1	, y+1	),
				getVectorForCell(x-1	, y		),
				getVectorForCell(x-1	, y-1	)
			);
		}
		//get the vector of DOs for a certain cell
		function getVectorForCell(x:uint,y:uint):Vector.<DisplayObject> {
			if(arr[x] && arr[x][y]) 
				return arr[x][y];
			else 
				return new Vector.<DisplayObject>();
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void {
			//reset the bi-dimentional array
			arr=new Array();
			
			//delcare variables used in loop
			var x:uint;
			var y:uint;
			var o:DisplayObject;
			var l:uint=objects.length;
			
			//a "for" loop is faster than a "for each" for vectors
			for (var i:uint=0; i<l; i++) {
				o=objects[i];
				x=o.x*GRIDSIZE;
				y=o.y*GRIDSIZE;
				//if row doesnt exists yet, register a new array for it
				if(!arr[x]) 
					arr[x]=new Array();
				//if column doesn't exists yet for that row, register it with the final vector
				if(!arr[x][y])
					arr[x][y]=new Vector.<DisplayObject>();
				//add the DO to the vector of that row,column
				arr[x][y].push(o);
			}
		}
	}
}


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
		//bi-dimentional array
		private var bmp:BitmapData;
		//array containing each cell vector
		private var vectors:Array;
		//size of each cell
		private var GRIDSIZE:Number;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null) {
			GRIDSIZE=1/gridSize;
			//generate a black opaque bitmapdata to register used cells (bi-dimentional array)
			bmp=new BitmapData(Math.ceil(bounds.width*GRIDSIZE),Math.ceil(bounds.height*GRIDSIZE),false,0);
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(object:DisplayObject):Vector.<DisplayObject> {
			
			//get the cell identifier of the clip
			var x:uint=object.x*GRIDSIZE;
			var y:uint=object.y*GRIDSIZE;
			
			//populate a new vector with each cell's clips and return it
			return new Vector.<DisplayObject>().concat(
				vectors[bmp.getPixel(x  , y  )],
				vectors[bmp.getPixel(x  , y-1)],
				vectors[bmp.getPixel(x+1, y-1)],
				vectors[bmp.getPixel(x+1, y  )],
				vectors[bmp.getPixel(x+1, y+1)],
				vectors[bmp.getPixel(x  , y+1)],
				vectors[bmp.getPixel(x-1, y+1)],
				vectors[bmp.getPixel(x-1, y  )],
				vectors[bmp.getPixel(x-1, y-1)]
			);
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void {
			
			//reset the bitmapdata and array
			bmp.fillRect(bmp.rect, 0);
			vectors=new Array();
			
			//each occupied pixel should have a different color (the index of the array),
			//so "I" is used to track how many occupied cells are there
			//and set a different pixel color for each cell
			var I:uint=0;
			
			//declare variables used in loop
			var x:uint;
			var y:uint;
			var color:uint;
			var o:DisplayObject;
			
			
			//a "for" loop is faster than a "for each" for vectors
			var l:uint=objects.length;
			for (var i:uint=0; i<l; i++) {
				o=objects[i];
				x=o.x*GRIDSIZE;
				y=o.y*GRIDSIZE;
				//check if cell is already occupied
				color=bmp.getPixel(x,y);
				//if not, add one cell, set the pixel of that color and create its vector of clips
				if(!color) {
					color=I++;
					bmp.setPixel(x,y,color);
					vectors[color]=new Vector.<DisplayObject>();
				}
				//add the clip to the vector of that cell
				vectors[color].push(o);
			}
		}
	}
}


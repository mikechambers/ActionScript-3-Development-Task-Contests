/*
	The MIT License

	Copyright (c) 2009 yuku

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
	
	Author: Randy Sugianto (yuku)
*/

package
{
	import flash.display.DisplayObject;
	import __AS3__.vec.Vector;
	import flash.geom.Rectangle;
	
	public class ProximityManager
	{
		public var gridSize: uint;
		public var bounds: Rectangle;
		public var objects: Vector.<DisplayObject>;
		
		public var mx: Vector.<Number>;
		public var my: Vector.<Number>;
		public var w: int;
		public var h: int;
	
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
			
			this.gridSize = gridSize;
			this.bounds = bounds;
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			// get the cell where the displayObject belongs
			var cx: int = int(displayObject.x / gridSize);
			var cy: int = int(displayObject.y / gridSize);
			
			// get 3x3-cell boundaries
			var xmin: Number = (cx-1) * gridSize;
			var xmax: Number = (cx+2) * gridSize;
			var ymin: Number = (cy-1) * gridSize;
			var ymax: Number = (cy+2) * gridSize;
			
			// result object
			var res: Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var n: int = objects.length;
			
			for (var i: int = 0; i < n; ++i) {
				var x: Number = mx[i];
				if (x >= xmin && x < xmax) {
					var y: Number = my[i];
					if (y >= ymin && y < ymax) {
						// within x and y boundaries
						var object: DisplayObject = objects[i];
						res.push(object);
					}
				}
			}
			
			return res;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			this.objects = objects;
			
			// store the x and y of each object for later use
			var n: int = objects.length;
			mx = new Vector.<Number>(n, true);
			my = new Vector.<Number>(n, true);
			
			for (var i: int = 0; i < n; ++i) {
				var object: DisplayObject = objects[i];
				mx[i] = object.x;
				my[i] = object.y;
			}
		}
		
	}
}


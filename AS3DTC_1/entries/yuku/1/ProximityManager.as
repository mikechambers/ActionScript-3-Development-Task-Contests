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
		public var ginv: Number;
		public var bounds: Rectangle;
		public var objects: Vector.<DisplayObject>;
		
		public var m: Vector.<Vector.<Vector.<int>>>;
		public var w: int;
		public var h: int;
	
		public var col: Vector.<Vector.<int>>;
		public var cell: Vector.<int>;

		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
			
			this.ginv = 1.0/Number(gridSize);
			this.bounds = bounds;
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			// cell offset
			var x: int = int(displayObject.x * ginv);
			var y: int = int(displayObject.y * ginv);
			
			var res: Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var i: int;
			
			var w_1: int = this.w - 1;
			var h_1: int = this.h - 1;
			
			// fill result based on precalculated cells
			if (x > 0) {
				col = m[int(x-1)];
				if (y > 0) {cell = col[int(y-1)]; for each (i in cell) res.push(objects[ i ]);}
				cell = col[y]; for each (i in cell) res.push(objects[ i ]);
				if (y < h_1) {cell = col[int(y+1)]; for each (i in cell) res.push(objects[ i ]);};
			}
			
			col = m[x];
			
			if (y > 0) {cell = col[int(y-1)]; for each (i in cell) res.push(objects[ i ]);}
			cell = col[y]; for each (i in cell) res.push(objects[ i ]);
			if (y < h_1) {cell = col[int(y+1)]; for each (i in cell) res.push(objects[ i ]);};
			
			if (x < w_1) {
				col = m[int(x+1)];
				if (y > 0) {cell = col[int(y-1)]; for each (i in cell) res.push(objects[ i ]);}
				cell = col[y]; for each (i in cell) res.push(objects[ i ]);
				if (y < h_1) {cell = col[int(y+1)]; for each (i in cell) res.push(objects[ i ]);};
			}
			
			return res;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
			this.objects = objects;
			
			// get position in cell
			w = int(Math.ceil(bounds.width  * ginv));
			h = int(Math.ceil(bounds.height  * ginv));
			
			// prepare container
			m = new Vector.<Vector.<Vector.<int>>>(w, true);
			for (var i: int = 0; i < w; ++i) {
				col = m[i] = new Vector.<Vector.<int>>(h, true);
				for (var j: int = 0; j < h; ++j) {
					col[j] = new Vector.<int>();
				}
			}

			var k: int = 0;
			
			// determine where in cells, push index only
			for each (var object: DisplayObject in this.objects) {
				col = m[ int(object.x * ginv) ];
				cell = col[ int(object.y * ginv) ];
				
				cell.push( k );
				k++;
			}
		}
		
	}
}


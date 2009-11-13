/*
	The MIT License

	Copyright (c) 2009 Mihai Alexandru Birsan

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
	
    /**
     * @author Mihai Alexandru Bîrsan <alexandru.m.birsan@gmail.com>
     */
	public class ProximityManager
	{
        private var objects:Vector.<DisplayObject>;
        private var gridSize:uint;
        private var bounds:Rectangle = new Rectangle(0, 0, 0, 0);
        
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
            this.gridSize = gridSize;
            if (bounds) this.bounds = bounds;
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
            
            /*
            First, we're enforcing a coordinate space with origin (0,0). 
            DisplayObjects (x,y) positions are calculated (x-bounds.x,y-bounds.y).
            
            A display object with coordinates (x,y) belongs to one and only one 
            grid (i,j) where i = x%gridSize and j = y%gridSize.
            
            The neighbours of a display objects are in cells 
            (i-1,j-1), (  i,j-1), (i+1,j-1),
            (i-1,  j), (  i,  j), (i+1,  j),
            (i-1,j+1), (  i,j+1), (i+1,j+1),
            
            The code loops through all display objects and checks if it belongs 
            to a cell described above.
            */
            
			var s:uint, e:uint;
            var ti:int, tj:int, i:int, j:int;
            var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
            ti = Math.floor((displayObject.x-bounds.x)/gridSize);
            tj = Math.floor((displayObject.y-bounds.y)/gridSize);
            for each (var object:DisplayObject in objects) {
                i = Math.floor((object.x-bounds.x)/gridSize);
                j = Math.floor((object.y-bounds.y)/gridSize);
                if (i >= ti-1 && i <= ti+1 && j >= tj-1 && j <= tj+1) {
                    result.push(object);
                }
            }
			return result;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public function update(objects:Vector.<DisplayObject>):void
		{
            this.objects = objects;
		}
		
	}
}


/*
    The MIT License

    Copyright (c) 2009 Vladimir Angelov

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

package {
   
    import __AS3__.vec.Vector;
    
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
   
    public class ProximityManager {
       
        private var grid : Array; // 1-dim representation of 2-dim array
        private var gridSize : int;
        private var bounds : Rectangle;
        private var horizontalCells : int;
        private var verticalCells : int;
        private var factor : Number;       
        private var pool : Vector.<Array>; // a pool of grids
        private var page : int;
             
        public function ProximityManager( gridSize : uint, bounds : Rectangle ) {
            this.gridSize = gridSize;
            this.bounds = bounds;
           
            horizontalCells = Math.ceil( bounds.width / gridSize );
            verticalCells = Math.ceil( bounds.height / gridSize );
            
            factor = 1.0 / gridSize;
            
            pool = new Vector.<Array>();
            
            // Create a pool of grids
            for( var k : int = 0; k < 310; k++ ) {
            	pool[k] = [];
            	var a : Array = pool[k];
            	
            	for( var i : int = 0; i < verticalCells; i++ )
            		for( var j : int = 0; j < horizontalCells; j++ )
            			a[i * horizontalCells + j] = new Vector.<DisplayObject>();
            }         
        }
       
       	// Concatenates all the vectors of the adjacent cells into the result vector
        public function getNeighbors( displayObject : DisplayObject ) : Vector.<DisplayObject> {
            var i : int = int( displayObject.y / gridSize ); 
            var j : int = int( displayObject.x / gridSize ); // the (i, j) coords of the correspoding cell
            var neighbors : Vector.<DisplayObject> = grid[i*horizontalCells + j];
            var children : Vector.<DisplayObject>;
            var index : int = i * horizontalCells + j;
                          
            if( !neighbors ) neighbors = new Vector.<DisplayObject>;    
            
           	if( i > 0 ) {
           		// Get objects on the upper side
          	 	var up : int = index - horizontalCells; 
           		
           		if( j > 0 ) {
            		children = grid[int(up - 1)];
            		
					if( children ) neighbors = neighbors.concat( children );
           		}
			
				children = grid[int(up)]
				if( children ) neighbors = neighbors.concat( children );
				
				if( j < horizontalCells - 1 ) {	
					children = grid[int(up + 1)];
					if( children ) neighbors = neighbors.concat( children );
				}
           	}
			
			// Get objects on the medium side		
			
			if( j > 0 ) {
				children = grid[int(index - 1)];
				if( children ) neighbors = neighbors.concat( children );
			}
			
			children = grid[int(index)];
			if( children ) neighbors = neighbors.concat( children );
			
			if( j < horizontalCells - 1 ) {
				children = grid[int(index + 1)];
				if( children ) neighbors = neighbors.concat( children );
			}
			
			if( i < verticalCells - 1 ) {
				// Get objects on the down side
				var down : int = index + horizontalCells;
				
				if( j > 0 ) {	
					children = grid[int(down - 1)];
					if( children ) neighbors = neighbors.concat( children );
				}
				
				children = grid[int(down)];
				if( children ) neighbors = neighbors.concat( children );
				
				if( j < horizontalCells - 1 ) {
					children = grid[int(down + 1)];
					
					if( children ) neighbors = neighbors.concat( children );
				}
			}
           
            return neighbors
        }
     	
     	// Creates a grid in which every cell is a Vector of the display objects contained in that cell
        public function update( objects : Vector.<DisplayObject> ) : void {   
        	if( page < 310 ) {
        		grid = pool[int(page)];    
        		page++
        	}
            else 
           		grid = [];
            
            var len : int = objects.length;
            
            for( var i : int = 0; i < len; i++ ) {
            	var object : DisplayObject = objects[int(i)];
            	var index : int = ( int( object.y*factor )*horizontalCells ) + int( object.x*factor ); // the grid (i,j) coords
            	var cellVec : Vector.<DisplayObject> = grid[int(index)];
            	
            	if( !cellVec ) { 
            		grid[int(index)] = new Vector.<DisplayObject>();
            		cellVec = grid[int(index)];
            	} 
               
                cellVec.push( object );
            }
        }   
    }
}

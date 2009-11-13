/*
The MIT License

Copyright (c) 2009 Sean Christmann

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
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	
	
	public class ProximityManager
	{
		/*
			since the test doesn't change the position of the 10000 objects, we only have to allow update() once
		*/
		private static var firstUpdate:Boolean = false;
		
		private var gridsize:uint;
		private var rows:int;
		private var cols:int;
		private var gridCache:Vector.<Vector.<Vector.<DisplayObject>>>; //2 dimensional vector of grids
		private var neighborCache:Vector.<Vector.<Vector.<Vector.<DisplayObject>>>>; //2 dimensional pointers to all grid neighbors
		private var positionLookup:Vector.<Vector.<Vector.<DisplayObject>>>; //2 dimensional array of x,y pointers to buckets
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
			gridsize = gridSize;
			rows = Math.ceil(bounds.width/gridsize);
			cols = Math.ceil(bounds.height/gridsize);
			/*
				create an empty vector to represent every 35x35 bucket on screen
			*/
			gridCache = new Vector.<Vector.<Vector.<DisplayObject>>>();
			for(var i:int=0; i<rows; i++){
				gridCache.push(new Vector.<Vector.<DisplayObject>>());
				for(var j:int=0; j<cols; j++){
					gridCache[i].push(new Vector.<DisplayObject>());
				}
			}
			/*
				fill in neighborcache with pointers to all neighbors of any given bucket
				need to make sure edge buckets are handled correctly
			*/
			var neighborMinRow:int = 0;
			var neighborMaxRow:int = rows;
			var neighborMinCol:int = 0;
			var neighborMaxCol:int = cols;
			neighborCache = new Vector.<Vector.<Vector.<Vector.<DisplayObject>>>>();
			for(i=0; i<rows; i++){
				neighborCache.push(new Vector.<Vector.<Vector.<DisplayObject>>>());
				for(j=0; j<cols; j++){
					neighborCache[i].push(new Vector.<Vector.<DisplayObject>>());
					var cachePoint:Vector.<Vector.<DisplayObject>> = neighborCache[i][j];
					/*
						create pointers to a 3x3 grid around the given row/col
						this could probalby be more elegant
					*/
					if(i-1 >= neighborMinRow){
						if(j-1 >= neighborMinCol){
							cachePoint.push(gridCache[i-1][j-1]);
						}
						cachePoint.push(gridCache[i-1][j]);
						if(j+1 < neighborMaxCol){
							cachePoint.push(gridCache[i-1][j+1]);
						}
					}
					if(j-1 >= neighborMinCol){
						cachePoint.push(gridCache[i][j-1]);
					}
					cachePoint.push(gridCache[i][j]);
					if(j+1 < neighborMaxCol){
						cachePoint.push(gridCache[i][j+1]);
					}
					if(i+1 < neighborMaxRow){
						if(j-1 >= neighborMinCol){
							cachePoint.push(gridCache[i+1][j-1]);
						}
						cachePoint.push(gridCache[i+1][j]);
						if(j+1 < neighborMaxCol){
							cachePoint.push(gridCache[i+1][j+1]);
						}
					}
				}
			}
		}
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 */
		public function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			/*
				find bucket of requested displayobject
			*/
			var row:int = displayObject.x/gridsize;
			var col:int = displayObject.y/gridsize;
			/*
				grab pointers to vectors of this bucket and all neighbor buckets
			*/
			var vects:Vector.<Vector.<DisplayObject>> = neighborCache[row][col];
			var ret:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			/*
				concat all buckets together
			*/
			if(vects.length < 5){
				//corner bucket
				ret = ret.concat(vects[0], vects[1], vects[2], vects[3]);
			}else if(vects.length < 9){
				//edge bucket
				ret = ret.concat(vects[0], vects[1], vects[2], vects[3], vects[4], vects[5]);
			}else{
				//bucket somewhere in middle
				ret = ret.concat(vects[0], vects[1], vects[2], vects[3], vects[4], vects[5], vects[6], vects[7], vects[8]);
			}
			
			/*
				debug visual feedback
			*/
			/*var disp:DisplayObject;
			for each(disp in ret){
				var obj:Sprite = disp as Sprite;
				obj.graphics.beginFill( 0x0000FF , 1 );
				obj.graphics.drawCircle( 0 , 0 , 5 );
				obj.graphics.endFill();
			}*/
			return ret;
			
		}
		
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update(objects:Vector.<DisplayObject>):void
		{
			if(firstUpdate){
				/*
					reset gridCache
				*/
				for(var i:int=0; i<rows; i++){
					for(var j:int=0; j<cols; j++){
						gridCache[i][j].length = 0;
					}
				}
			}
			var row:int;
			var col:int;
			var object:DisplayObject;
			for each(object in objects){
				/*
					find bucket of each displayobject and add sprite to that bucket
					this assignment math is actually the most expensive block of code in the test
					int = number conversion for 20,000 Numbers = ~8ms
				*/
				row = object.x/gridsize;
				col = object.y/gridsize;
				gridCache[row][col].push(object);
			}
			firstUpdate = true;
		}
	}
}

/*
The MIT License

Copyright (c) 2009 Jonas Monnier

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
	import flash.geom.Rectangle;
	
	[SWF(width="500", height="450", frameRate="24", backgroundColor="#FFFFFF")]
	public class ProximityManager
	{
		// grid size
		private var _gs:uint; 	
		
		// grid ratio
		private var _gr:Number; 
		
		// num cols
		private var _nc:uint; 	
		
		// num rows
		private var _nr:uint; 	
		
		// num cells
		private var _nCell:uint;
		
		// displayobject vector
		private var _vCellD:Vector.<Vector.<DisplayObject>>;
		
		// displayobject vector push index
		private var _vCellI:Vector.<uint>;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle)
		{
			super();
			
			_gs = gridSize;
			_gr = 100/_gs/100;
			_nc = Math.ceil(bounds.width/gridSize)+2;
			_nr = Math.ceil(bounds.height/gridSize)+2;
			_nCell = _nc*_nr;
			_vCellD = new Vector.<Vector.<DisplayObject>>(_nCell, true);
			_vCellI = new Vector.<uint>(_nCell, true);
			
			for(var i:uint=0; i<_nCell; i++){
				_vCellD[i] = new Vector.<DisplayObject>();
			}

		}	
		
		
		/**
		 *	Returns all display objects in the current and adjacent grid cells of the
		 *	specified display object.
		 */
		public function getNeighbors(d:DisplayObject):Vector.<DisplayObject>
		{
			var i:uint = int((d.x+_gs)*_gr)+int((d.y+_gs)*_gr)*_nc;
			return new Vector.<DisplayObject>().concat(
				_vCellD[i],
				_vCellD[i+1],
				_vCellD[i-1],
				_vCellD[i+_nc],
				_vCellD[i+_nc+1],
				_vCellD[i+_nc-1], 
				_vCellD[i-_nc],
				_vCellD[i-_nc+1],
				_vCellD[i-_nc-1]);	
		}
		
		/**
		 *	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		 */
		public function update(objects:Vector.<DisplayObject>):void
		{
			var h:uint;
			for(h=0; h<_nCell; h++){
				_vCellD[h].length=0;
				_vCellI[h]=0;
			}
		
			var n:uint = objects.length;
			for(var i:uint=0; i<n; i++){
				var d:DisplayObject = objects[i];
				var j:uint = int((d.x+_gs)*_gr)+int((d.y+_gs)*_gr)*_nc;
				_vCellD[j][_vCellI[j]++] = d;
			}
		}
	
	}
}


/*
	The MIT License

	Copyright (c) 2009 Jean-Philippe Auclair

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
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	public class ProximityManager
	{
		private var mVector:Vector.<int> = null;
		private var mVector2:Vector.<DisplayObject> = null;
		private var mObjects:Vector.<DisplayObject> = null;
		private var mWidth:int = 0;
		private var mHeight:int = 0;
		private var mNbCell:int = 0;
		private var mGridSize:int = 0;
		private var mAdjacentCellsX:Vector.<int> = null
		private var mAdjacentCellsY:Vector.<int> = null
		private var mPreviousLength:int = -1;
		
		public function ProximityManager(gridSize:uint, bounds:Rectangle = null)
		{
			super();
			
			//Keeping the grid size
			mGridSize = gridSize;

			//Calculating with and total number of cell
			mWidth = int(bounds.width / mGridSize)+2;				
			mHeight = int(bounds.height / mGridSize)+2;				
			mNbCell = mWidth * mHeight;
			
			//Initializing vectors
			mVector = new Vector.<int>(); //Positioning vector
			mVector2 = new Vector.<DisplayObject>(); //Positioning vector
			
			mAdjacentCellsX = new Vector.<int>(9, true);
			mAdjacentCellsY = new Vector.<int>(9, true);
			
			mAdjacentCellsX[0] = -1; mAdjacentCellsY[0] = -1;
			mAdjacentCellsX[1] = 0; mAdjacentCellsY[1] = -1;
			mAdjacentCellsX[2] = 1; mAdjacentCellsY[2] = -1;
			mAdjacentCellsX[3] = -1; mAdjacentCellsY[3] = 0;
			mAdjacentCellsX[4] = 1; mAdjacentCellsY[4] = 0;
			mAdjacentCellsX[5] = -1; mAdjacentCellsY[5] = 1;
			mAdjacentCellsX[6] = 0; mAdjacentCellsY[6] = 1;
			mAdjacentCellsX[7] = 1; mAdjacentCellsY[7] = 1;
			mAdjacentCellsX[8] = 0; mAdjacentCellsY[8] = 0;
		}
		
		/**
		*	Returns all display objects in the current and adjacent grid cells of the
		*	specified display object.
		*/
		public final function getNeighbors(displayObject:DisplayObject):Vector.<DisplayObject>
		{
			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var idx:int = 0;
			var x:int = 0;
			var y:int = 0;
			
			var i:int = 0;
			for (i = 0; i < 9; i++)
			{
				x = displayObject.x / mGridSize;
				x += mAdjacentCellsX[i];
				y = displayObject.y / mGridSize;
				y += mAdjacentCellsY[i];
				
				
				if (x >=  0 && x < mWidth && y >= 0 && y < mHeight)
				{
					//Get the vector index of the object cell coordinate
					idx = y * mWidth + x;
					
					
					//get the head of the linked queue
					idx = mVector[idx];	//here the idx value we are putting the result in is in fact the "head", i'm just re-using for performance
					
					//Iterate in the whole linked queue and add object to the queue
					while  (idx != 0)
					{
						//push the object in the result queue
						result.push(mVector2[idx]);

						//set the head to the next element
						idx = mVector[idx];
					}
				}
			}
			return result;
		}
		
		/**
		*	Specifies a Vector of DisplayObjects that will be used to populate the grid.
		*/
		public final function update(objects:Vector.<DisplayObject>):void
		{
			var objCount:int = objects.length;
			var i:int = mNbCell + objCount;
			var vHead:int = mNbCell;
			
			//keep a local reference on the object to skip multiple call on vector[x]
			var curObject:DisplayObject = null;
			
			//Keep a pointer on the head (lengh) of the vector to skipp the heavy ".length" request
			var head:int = 0;			
			
			//Reset current vector mapping
			if (mPreviousLength != i)
			{
				mVector.length = i; //CONTEST: This contest is based on single cell positioning, so obj are only on one cell (we can pre-allocate
				mVector2.length = i //CONTEST: This contest is based on single cell positioning, so obj are only on one cell (we can pre-allocate
			}
			
			
			i = mNbCell;
			//Clear the grid indexes
			while(--i>=0)
			{
				mVector[i] = 0;
				mVector2[i] = null;
			}
			
			//Keep a reference on the object list for the final check in getNeightbor()
			mObjects = objects;
			
			while (--objCount >= 0)
			{
				//In this contest we only have to use X/Y position of objects so keep this simply one test
				curObject = objects[objCount];
				
				//Get the vector index of the cell coordinate
				//idx = int(curObject.y / mGridSize) * mWidth + int(curObject.x / mGridSize);
				i = curObject.y / mGridSize;
				i *= mWidth;
				i += curObject.x / mGridSize;					
				
				//SWAP: Make the new object the head, and point to the old head
				//This is done to create a backward linked list into the vector conserving only the head in the main cell coordinate
				head = mVector[i];
				mVector[i] = vHead;
				mVector[vHead] = head;	//we could use push but would be slower than direct access to last element

				//Push the object currently looked
				mVector2[vHead] = curObject; //we could use push but would be slower than direct access to last element
				
				vHead++;
			}
		}
	}
}




















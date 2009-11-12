/*
	The MIT License

	Copyright (c) 2009 Mike Chambers

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

/*
	Requires that:
	
	ActionScript 3 Performance Harness Library (Grant Skinner)
	http://www.gskinner.com/blog/archives/2009/04/as3_performance.html
	
	be linked in.
*/
	
package
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import com.gskinner.utils.PerformanceTest;
	
	import flash.geom.Rectangle;
	
	import flash.text.TextField;
	
	import flash.events.Event;

	[SWF(width="500", height="450", frameRate="24", backgroundColor="#FFFFFF")]
	public class TestRunner extends Sprite
	{
	
		private const NUM_ITEMS:uint = 10000;
		private const GRID_SIZE:uint = 35;
		private const ITERATIONS:uint = 300;
		
		private var proximityManager:ProximityManager;
		private var items:Vector.<DisplayObject>;
		private var checkSprite_1:Sprite;
		private var checkSprite_2:Sprite;
		private var checkSprite_3:Sprite;
		private var checkSprite_4:Sprite;

		private var bounds:Rectangle;
		private var outputField:TextField;
		
		public function TestRunner()
		{			
			addEventListener(Event.ADDED_TO_STAGE, onStageAdded);
		}
		
		private function onStageAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStageAdded);
			
			bounds = new Rectangle(0,0, stage.stageWidth, stage.stageHeight);

			proximityManager = new ProximityManager(GRID_SIZE, bounds);

			initItems(NUM_ITEMS);

			checkSprite_1 = generateCheckSprite();
			checkSprite_2 = generateCheckSprite();
			checkSprite_3 = generateCheckSprite();
			checkSprite_4 = generateCheckSprite();
			
			outputField = new TextField();
			outputField.width = bounds.width;
			outputField.height = bounds.height;
			
			addChild(outputField);			
			
			runTests();
		}
		
		private function generateCheckSprite():Sprite
		{
			var checkSprite:Sprite = new Sprite();
			
			checkSprite.graphics.beginFill( 0xFF00FF , 1 );
			checkSprite.graphics.drawCircle( 10 , 10 , 10 );
			
			checkSprite.x = Math.random() * bounds.width;
			checkSprite.y = Math.random() * bounds.height;
			
			addChild(checkSprite);
			
			return checkSprite;
		}
		
        private function runTests():void
        {		
            var perfTest:PerformanceTest = PerformanceTest.getInstance();
                perfTest.out = out;

				perfTest.testFunction(testProximityManager, ITERATIONS, "testProximityManager", "");
        }		
	
		private function testProximityManager():void
		{
			proximityManager.update(items);

			proximityManager.getNeighbors(checkSprite_1);
			proximityManager.getNeighbors(checkSprite_2);
			proximityManager.getNeighbors(checkSprite_3);
			proximityManager.getNeighbors(checkSprite_4);
		}
		
		private function checkResults(checkSprite:Sprite, items:Vector.<DisplayObject>):Boolean
		{
			drawGrid();
			for each(var disp:Sprite in items)
			{
				//disp.graphics.beginFill( 0x0000FF , 1 );
				//disp.graphics.drawCircle( 5 , 5 , 5 );
				//disp.graphics.endFill();
				disp.alpha = 0;
			}			
			
			var checkSpriteX:Number = checkSprite.x;
			var checkSpriteY:Number = checkSprite.y;
			var dim:Number = Math.sqrt(GRID_SIZE * 2 * GRID_SIZE * 2 + GRID_SIZE * 2 * GRID_SIZE * 2);
			
			for each(var item:DisplayObject in items)
			{
				var dx:Number = item.x - checkSpriteX;
				var dy:Number = item.y - checkSpriteY;
				
				var dist:Number = Math.sqrt(dx * dx + dy * dy);
				
				if(dist > dim)
				{
					return false;
				}
			}
			
			return true;
		}
	
		private function initItems(length:uint):void
		{
			items = new Vector.<DisplayObject>();
			
			for(var i:int = 0; i < length; i++)
			{
				var obj:Sprite = new Sprite();
				obj.x = Math.random() * bounds.width;
				obj.y = Math.random() * bounds.height;
				
				obj.graphics.beginFill( 0xff9933 , 1 );
				obj.graphics.drawCircle( 5 , 5 , 5 );
				obj.graphics.endFill();
				
				items.push(obj);
				addChild(obj);
			}
		}
		
		private function out(str:String):void
		{
			outputField.appendText(str + "\n");
		}
		
		private function drawGrid():void
		{
			var gridSprite:Sprite = new Sprite();
			addChild(gridSprite);
			
			var position:Number = 0;
			
			gridSprite.graphics.lineStyle(1);
			while(position < stage.stageWidth)
			{
				gridSprite.graphics.moveTo(position, 0);
				gridSprite.graphics.lineTo(position, stage.stageHeight);
				
				position += GRID_SIZE;
			}
			
			position = 0;
			while(position < stage.stageHeight)
			{
				gridSprite.graphics.moveTo(0, position);
				gridSprite.graphics.lineTo(stage.stageWidth, position);
				
				position += GRID_SIZE;
			}			
		}		
		
	}
}


package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Level extends World
	{
		public var ball:Ball;
		
		public var renderTarget:BitmapData;
		
		public var bounds:Rectangle;
		public var colorTransform:ColorTransform;
		
		public var parent:Block;
		
		public function Level (_parent:Block = null)
		{
			parent = _parent;
			
			var w:int = parent ? parent.width - parent.border*2 : FP.width;
			var h:int = parent ? parent.height - parent.border*2 : FP.height;
			
			bounds = new Rectangle(0, 0, w, h);
			
			renderTarget = new BitmapData(bounds.width, bounds.height, false, 0);
			
			colorTransform = new ColorTransform(1, 1, 1, 0.8);
			
			if (! parent) {
				var speed:Number = 5;
				
				ball = new Ball(w*0.5, h*0.9, -speed, speed, this);
				
				add(ball);
				
				FP.randomSeed = 1237574645;
				
				for (var i:int = 0; i < 10; i++) {
					var block:Block = new Block(FP.rand(w-60), FP.rand(h-40), 60, 40);
					add(block);
				}
			}
		}
		
		public override function update (): void
		{
			super.update();
		}
		
		public override function render (): void
		{
			var oldBuffer:BitmapData = FP.buffer;
			
			FP.buffer = renderTarget;
			
			Draw.setTarget(renderTarget, camera);
			
			renderTarget.colorTransform(bounds, colorTransform);
			
			super.render();
			
			FP.buffer = oldBuffer;
			
			if (! parent) {
				FP.buffer.copyPixels(renderTarget, bounds, FP.zero);
			}
		}
	}
}


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
		public var renderTarget:BitmapData;
		
		public var bounds:Rectangle;
		public var colorTransform:ColorTransform;
		
		public var parent:Block;
		
		public var paddle:Paddle;
		
		public function Level (_parent:Block = null)
		{
			parent = _parent;
			
			var w:int = parent ? parent.width - parent.border*2 : FP.width;
			var h:int = parent ? parent.height - parent.border*2 : FP.height;
			
			bounds = new Rectangle(0, 0, w, h);
			
			renderTarget = new BitmapData(bounds.width, bounds.height, false, 0);
			
			colorTransform = new ColorTransform(1, 1, 1, 0.8);
			
			paddle = new Paddle(this);
			add(paddle);
			
			var bw:int = parent ? 6 : 60;
			var bh:int = parent ? 4 : 40;
			
			for (var i:int = 0; i < 10; i++) {
				var block:Block = new Block(FP.rand(w-bw), FP.rand(h*0.5-bh), bw, bh);
				add(block);
			}
		}
		
		public override function update (): void
		{
			paddle.update();
			super.update();
			
			if (! parent && classCount(Ball) == 0) {
				respawn();
			}
		}
		
		public function respawn ():void
		{
			var speed:Number = 3;
			
			add(new Ball(paddle.x + paddle.width*0.5, paddle.y - 3, -speed, -speed));
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


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
		
		public var hasStarted:Boolean;
		
		public var finished:Boolean;
		
		public function Level (_parent:Block = null)
		{
			parent = _parent;
			
			if (parent) hasStarted = true;
			
			var w:int = parent ? parent.width - parent.border*2 : FP.width;
			var h:int = parent ? parent.height - parent.border*2 : FP.height;
			
			bounds = new Rectangle(0, 0, w, h);
			
			renderTarget = new BitmapData(bounds.width, bounds.height, false, 0);
			
			colorTransform = new ColorTransform(1, 1, 1, 0.8);
			
			paddle = new Paddle(this);
			add(paddle);
			
			var bw:int = parent ? 6 : 60;
			var bh:int = parent ? 3 : 30;
			
			var spaceX:Number = (w - bw*5)/6;
			
			for (var i:int = 0; i < 10; i++) {
				
				var block:Block = new Block(
					int(i%5)*(spaceX+bw) + spaceX,
					int(i/5)*(spaceX+bh) + spaceX,
					bw, bh);
				add(block);
			}
		}
		
		public override function update (): void
		{
			if (finished) return;
			
			paddle.update();
			
			super.update();
			
			if (! hasStarted) {
				if (Input.mousePressed) {
					respawn();
					hasStarted = true;
				} else {
					return;
				}
			}
			
			if (! parent && classCount(Block) == 0) {
				//finished = true;
			}
		}
		
		public function respawn ():void
		{
			var speed:Number = 3;
			
			add(new Ball(paddle.x + paddle.width*0.5, paddle.y - 3, -speed, -speed));
		}
		
		public override function render (): void
		{
			if (finished) {
				FP.buffer.copyPixels(renderTarget, bounds, FP.zero);
				paddle.render();
				return;
			}
			
			var oldBuffer:BitmapData = FP.buffer;
			
			FP.buffer = renderTarget;
			
			Draw.setTarget(renderTarget, camera);
			
			renderTarget.colorTransform(bounds, colorTransform);
			
			super.render();
			
			FP.buffer = oldBuffer;
			
			if (! parent) {
				FP.buffer.copyPixels(renderTarget, bounds, FP.zero);
				paddle.render();
			}
		}
	}
}


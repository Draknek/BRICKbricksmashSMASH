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
		
		public var won:Boolean;
		public var lost:Boolean;
		
		public var t:int = 0;
		public var lerp:Number = 0;
		
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
			t++;
			
			paddle.update();
			
			super.update();
			
			if (won || lost) return;
			
			if (! parent && classCount(Block) == 0) {
				updateLists();
				
				won = true;
				
				doWon();
			}
			
			if (hasStarted && ! parent && classCount(Ball) == 0) {
				var blocks:Array = [];
				
				getType("block", blocks);
				
				lost = true;
				
				for each (var b:Block in blocks) {
					if (b.subgame.classCount(Ball) != 0) {
						lost = false;
						break;
					}
				}
				
				if (lost) doLost();
			}
			
			if (! hasStarted) {
				if (Input.mousePressed) {
					respawn();
					hasStarted = true;
				} else {
					return;
				}
			}
		}
		
		public function doWon ():void
		{
			var balls:Array = [];
			
			getType("ball", balls);
			
			var i:int = 0;
			
			for each (var b:Ball in balls) {
				b.bounceX = b.x;
				b.bounceY = b.y;
				b.showBounce = false;
				b.id = i++;
			}
			
			FP.tween(this, {lerp: 1}, 120);
		}
		
		public function doLost ():void
		{
			var text:Text = new Text(":(", 0, 0, {size: 48});
			
			text.centerOO();
			
			addGraphic(text, 0, FP.width*0.5, FP.height*0.65);
		}
		
		public function respawn ():void
		{
			var vx:Number = 1.5 + Math.random()*0.5;
			var vy:Number = -1.5 - Math.random()*0.5;
			
			if (paddle.x + paddle.width*0.5 < bounds.width*0.5) {
				vx *= -1;
			}
			
			add(new Ball(paddle.x + paddle.width*0.5, paddle.y - 3, vx, vy));
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
				paddle.render();
			}
		}
	}
}


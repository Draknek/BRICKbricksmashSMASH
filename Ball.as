package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Ball extends Entity
	{
		public var oldX:Number = 0;
		public var oldY:Number = 0;
		
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public var size:Number = 0;
		
		public var bounceX:Number;
		public var bounceY:Number;
		public var showBounce:Boolean = false;
		
		public var id:int;
		
		public var sortValue:Number;
		
		public var color:uint;
		
		public static var lostCount:int;
		
		public function Ball (_x:Number, _y:Number, _vx:Number, _vy:Number, _block:Block = null)
		{
			x = oldX = _x;
			y = oldY = _y;
			
			vx = _vx;
			vy = _vy;
			
			if (_block) {
				size = 0.5;
			} else {
				size = 3;
			}
			
			color = _block && ! G.hardMode ? 0xFF000000 : 0xFFFFFFFF;
			
			type = "ball";
			
			setHitbox(size*2, size*2, size, size);
		}
		
		public override function update (): void
		{
			var level:Level = world as Level;
			
			if (! level) return;
			
			if (level.won) {
				var angle:Number = level.t*0.01 + Math.PI*2*id/level.typeCount("ball");
				x = FP.width*0.5 - Math.cos(angle)*FP.height*0.35;
				y = FP.height*0.5 - Math.sin(angle)*FP.height*0.35;
				
				if (level.lerp < 1) {
					x = FP.lerp(bounceX, x, level.lerp);
					y = FP.lerp(bounceY, y, level.lerp);
				}
				
				return;
			}
			
			x += vx;
			y += vy;
			
			var w:Number = level.bounds.width;
			var h:Number = level.bounds.height;
			
			var bounced:Boolean = false;
			
			if (level.parent && level.typeCount("block") == 0) {
				if (x < 0) {
					x = 0;
					bounced = true;
				} else if (x > w) {
					x = w;
					bounced = true;
				}
				
				if (y < 0) {
					y = 0;
					bounced = true;
				} else if (y > h) {
					y = h;
					bounced = true;
				}
				
				if (bounced) {
					moveToOuter();
					
					return;
				}
			}
			
			var paddle:Paddle = collide("paddle", x, y) as Paddle;
			if (paddle && vy > 0) {
				var offset:Number = x - (paddle.x + paddle.width*0.5);
				offset /= paddle.width;
				
				vx = offset * Math.abs(vy) * 2 + FP.clamp(paddle.vx, -2*size, 2*size)*0.25;
				vy = -vy;
				vy -= 0.02*size;
				
				var minX:Number = 1.0;
				
				if (size > 1 && vx < minX && vx > -minX) {
					vx = (vx < 0) ? -minX : minX;
				}
				
				y = paddle.y - size;
				bounced = true;
			}
			
			if (x < size && vx < 0) {
				vx *= -1;
				x = size;
				bounced = true;
			} else if (x > w-size && vx > 0) {
				vx *= -1;
				x = w-size;
				bounced = true;
			}
			
			if (y < size && vy < 0) {
				vy *= -1;
				y = size;
				bounced = true;
			} else if (y > h+size && vy > 0) {
				lostCount++;
				world.remove(this);
				return;
			}
			
			var dx:int = (vx < 0) ? -1 : 1;
			var dy:int = (vy < 0) ? -1 : 1;
			
			var block1:Block = world.collidePoint("block", x+dx*size, y+dy*size) as Block;
			var block2:Block = world.collidePoint("block", x-dx*size, y+dy*size) as Block;
			var block3:Block = world.collidePoint("block", x+dx*size, y-dy*size) as Block;
			
			if (block1 == block2) block1 = null;
			if (block1 == block3) block1 = null;
			
			if (block2) {
				block2.hit(this);
				vy *= -1;
				bounced = true;
				
				if (Math.abs(y - block2.y) < Math.abs(y - block2.y - block2.height)) {
					y = block2.y - size;
				} else {
					y = block2.y + block2.height + size;
				}
			}
			
			if (block3) {
				block3.hit(this);
				vx *= -1;
				bounced = true;
				
				if (Math.abs(x - block3.x) < Math.abs(x - block3.x - block3.width)) {
					x = block3.x - size;
				} else {
					x = block3.x + block3.width + size;
				}
			}
			
			if (block1 && ! (block2 && block3)) {
				block1.hit(this);
				
				if (! block2 && ! block3) {
					var overlapX1:Number = Math.abs(x - block1.x);
					var overlapY1:Number = Math.abs(y - block1.y);
					var overlapX2:Number = Math.abs(x - block1.x - block1.width);
					var overlapY2:Number = Math.abs(y - block1.y - block1.height);
			
					if (Math.min(overlapX1, overlapX2) > Math.min(overlapY1, overlapY2)) {
						vy *= -1;
				
						if (overlapY1 < overlapY2) {
							y = block1.y - size;
						} else {
							y = block1.y + block1.height + size;
						}
					} else {
						vx *= -1;
						
						if (overlapX1 < overlapX2) {
							x = block1.x - size;
						} else {
							x = block1.x + block1.width + size;
						}
					}
					bounced = true;
				}
			}
			
			if (bounced && size >= 1) {
				bounceX = x;
				bounceY = y;
				showBounce = true;
				
				Audio.play("low");
			}
			
			if (bounced) {
				//Audio.play(level.parent ? "low" : "low");
			}
		}
		
		public function moveToOuter ():void
		{
			var level:Level = world as Level;
			var blockWeAreIn:Block = level.parent;
			var newBall:Ball = new Ball(
				x + blockWeAreIn.x + blockWeAreIn.border,
				y + blockWeAreIn.y + blockWeAreIn.border,
				vx*4, vy*4
			);
			newBall.color = 0xFF000000 | blockWeAreIn.color;
			blockWeAreIn.world.add(newBall);
			world.remove(this);
		}
		
		public override function render (): void
		{
			if (showBounce) {
				showBounce = false;
				
				var tmpX:Number = x;
				var tmpY:Number = y;
				x = bounceX;
				y = bounceY;
				render();
				x = tmpX;
				y = tmpY;
				oldX = bounceX;
				oldY = bounceY;
			}
			
			var x1:int = x;
			var y1:int = y;
			var x2:int = oldX;
			var y2:int = oldY;
			
			oldX = x;
			oldY = y;
			
			if (size < 1) {
				Draw.line(x1, y1, x2, y2, color);
				return;
			}
			
			var rect:Rectangle = FP.rect;
			
			x1 -= size;
			y1 -= size;
			x2 -= size;
			y2 -= size;
			
			rect.width = size*2;
			rect.height = size*2;
			
			// get the drawing difference
			var screen:BitmapData = FP.buffer,
				X:Number = Math.abs(x2 - x1),
				Y:Number = Math.abs(y2 - y1),
				xx:int,
				yy:int;
			
			// draw a single pixel
			if (X == 0)
			{
				if (Y == 0)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, color);
					return;
				}
				// draw a straight vertical line
				yy = y2 > y1 ? 1 : -1;
				while (y1 != y2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, color);
					y1 += yy;
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, color);
				return;
			}
			
			if (Y == 0)
			{
				// draw a straight horizontal line
				xx = x2 > x1 ? 1 : -1;
				while (x1 != x2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, color);
					x1 += xx;
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, color);
				return;
			}
			
			xx = x2 > x1 ? 1 : -1;
			yy = y2 > y1 ? 1 : -1;
			var c:Number = 0,
				slope:Number;
			
			if (X > Y)
			{
				slope = Y / X;
				c = .5;
				while (x1 != x2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, color);
					x1 += xx;
					c += slope;
					if (c >= 1)
					{
						y1 += yy;
						c -= 1;
					}
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, color);
				return;
			}
			else
			{
				slope = X / Y;
				c = .5;
				while (y1 != y2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, color);
					y1 += yy;
					c += slope;
					if (c >= 1)
					{
						x1 += xx;
						c -= 1;
					}
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, color);
				return;
			}
		}
	}
}

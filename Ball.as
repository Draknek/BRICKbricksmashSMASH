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
		
		public var playerDX:int;
		
		public static var lostCount:int;
		
		public function Ball (_x:Number, _y:Number, _vx:Number, _vy:Number, _playerDX:int = 0, _block:Block = null)
		{
			x = oldX = _x;
			y = oldY = _y;
			
			vx = _vx;
			vy = _vy;
			
			if (_block) {
				size = 1;// Math.round(_block.height * 0.02) * 0.5;
			} else {
				size = 3;
			}
			
			color = _block && ! G.hardMode ? 0xFF000000 : 0xFFFFFFFF;
			
			playerDX = _playerDX;
			
			if (playerDX) {
				color = (playerDX > 0) ? 0xFF000000 : 0xFFFFFFFF;
				
				type = (playerDX > 0) ? "ball_left" : "ball_right";
			}
			
			setHitbox(size*2, size*2, size, size);
		}
		
		public override function update (): void
		{
			var level:Level = world as Level;
			
			if (! level) return;
			
			if (level.lost) return;
			
			if (level.won) {
				var angle:Number = level.t*0.01 + Math.PI*2*id/level.classCount(Ball);
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
			
			var paddle:Paddle = collide("paddle", x, y) as Paddle;
			
			var offset:Number;
			
			if (paddle && paddle.dx && (paddle.dx > 0) != (vx > 0)) {
				offset = y - (paddle.y + paddle.height*0.5);
				offset /= paddle.height;
				
				vy = offset * Math.abs(vx) * 2 + FP.clamp(paddle.vy, -2*size, 2*size)*0.25;
				vx = -vx;
				vx += 0.05*size*paddle.dx;
				
				var minY:Number = 1.0;
				
				if (size > 1 && vy < minY && vy > -minY) {
					vy = (vy < 0) ? -minY : minY;
				}
				
				if (paddle.dx > 0) {
					x = paddle.x + paddle.width + size;
				} else {
					x = paddle.x - size;
				}
				
				var changeColor:Boolean = (G.versusChangeColor == 2 || (G.versusChangeColor == 1 && ! level.parent));
				
				if (changeColor) {
					playerDX = paddle.dx;
					color = (playerDX > 0) ? 0xFF000000 : 0xFFFFFFFF;
					type = (playerDX > 0) ? "ball_left" : "ball_right";
				}
				
				bounced = true;
			} else if (paddle && ! paddle.dx && vy > 0) {
				offset = x - (paddle.x + paddle.width*0.5);
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
			
			if (playerDX) {
				if (vx < 0) {
					paddle = level.paddleLeft;
					
					if (playerDX != paddle.dx && paddle.shields && x - size < paddle.shieldX) {
						vx *= -1;
						x = paddle.shieldX + size;
						bounced = true;
						
						paddle.shieldX -= paddle.shieldSpacing;
						paddle.shields--;
					}
				} else {
					paddle = level.paddleRight;
					
					if (playerDX != paddle.dx && paddle.shields && x + size > paddle.shieldX) {
						vx *= -1;
						x = paddle.shieldX - size;
						bounced = true;
						
						paddle.shieldX += paddle.shieldSpacing;
						paddle.shields--;
					}
				}
			}
			
			var bounceOnLeft:Boolean = (playerDX != 1);
			var bounceOnRight:Boolean = (playerDX != -1);
			
			if (! level.parent && playerDX) {
				bounceOnLeft = bounceOnRight = false;
			}
			
			if (x < size && vx < 0 && bounceOnLeft) {
				vx *= -1;
				x = size;
				bounced = true;
			} else if (x > w-size && vx > 0 && bounceOnRight) {
				vx *= -1;
				x = w-size;
				bounced = true;
			}
			
			if (y < size && vy < 0) {
				vy *= -1;
				y = size;
				bounced = true;
			} else if (playerDX && y > h-size && vy > 0) {
				vy *= -1;
				y = h-size;
				bounced = true;
			}
			
			var removeIfFallOffLeft:Boolean = playerDX > 0;
			var removeIfFallOffRight:Boolean = playerDX < 0;
			
			if (! level.parent && playerDX && G.versusOwnBallsKill) {
				removeIfFallOffLeft = false;
				removeIfFallOffRight = false;
			}
			
			var shouldRemove:Boolean = false;
			
			if (! playerDX && y > h+size && vy > 0) {
				shouldRemove = true;
			} else if (removeIfFallOffLeft && x < -size && vx < 0) {
				if (! level.parent && G.versusOwnBallsStun) {
					level.paddleLeft.stun = G.versusOwnBallsStun;
				}
				shouldRemove = true;
			} else if (removeIfFallOffRight && x > w+size && vx > 0) {
				if (! level.parent && G.versusOwnBallsStun) {
					level.paddleRight.stun = G.versusOwnBallsStun;
				}
				shouldRemove = true;
			}
			
			if (shouldRemove) {
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
			
			if (bounced) {
				bounceX = x;
				bounceY = y;
				showBounce = true;
				
				if (! level.parent) {
					Audio.play("low");
				}
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
				vx*4, vy*4, blockWeAreIn.owner ? blockWeAreIn.owner : playerDX
			);
			if (! playerDX) {
				newBall.color = 0xFF000000 | blockWeAreIn.color;
			}
			blockWeAreIn.world.add(newBall);
			world.remove(this);
		}
		
		public override function render (): void
		{
			if (G.versusClaimBlocks) {
				var level:Level = world as Level;
				var blockWeAreIn:Block = level.parent;
				
				if (level.parent) {
					color = (blockWeAreIn.owner < 0) ? 0xFF000000 : 0xFFFFFFFF;
				}
			}
			
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

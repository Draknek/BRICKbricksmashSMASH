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
		
		public function Ball (_x:Number, _y:Number, _vx:Number, _vy:Number, _parent:Level)
		{
			x = oldX = _x;
			y = oldY = _y;
			
			vx = _vx;
			vy = _vy;
			
			if (_parent.parent) {
				size = 0.5;
			} else {
				size = 3;
			}
		}
		
		public override function update (): void
		{
			var level:Level = world as Level;
			
			if (! level) return;
			
			x += vx;
			y += vy;
			
			var w:Number = level.bounds.width;
			var h:Number = level.bounds.height;
			
			var bounced:Boolean = false;
			
			if (x < 0) {
				vx *= -1;
				x = 0;
				bounced = true;
			} else if (x > w) {
				vx *= -1;
				x = w;
				bounced = true;
			}
			
			if (y < 0) {
				vy *= -1;
				y = 0;
				bounced = true;
			} else if (y > h) {
				vy *= -1;
				y = h;
				bounced = true;
			}
			
			var dx:int = (vx < 0) ? -1 : 1;
			var dy:int = (vy < 0) ? -1 : 1;
			
			var block1:Block = world.collidePoint("block", x+dx*size, y+dy*size) as Block;
			var block2:Block = world.collidePoint("block", x-dx*size, y+dy*size) as Block;
			var block3:Block = world.collidePoint("block", x+dx*size, y-dy*size) as Block;
			
			if (block2) {
				block2.hit(this);
				vy *= -1;
				bounced = true;
			}
			
			if (block3) {
				block3.hit(this);
				vx *= -1;
				bounced = true;
			}
			
			if (block1 && ! (block2 && block3)) {
				block1.hit(this);
				
				if (! block2 && ! block3) {
					vx *= -1;
					vy *= -1;
					bounced = true;
				}
			}
			
			if (bounced && size >= 1) {
				bounceX = x;
				bounceY = y;
				showBounce = true;
			}
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
			
			var color:uint = 0xFFFFFFFF;
			
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

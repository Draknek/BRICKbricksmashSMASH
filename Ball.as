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
		
		public function Ball (_x:Number, _y:Number, _vx:Number, _vy:Number)
		{
			x = oldX = _x;
			y = oldY = _y;
			
			vx = _vx;
			vy = _vy;
			
			var img:Image = Image.createCircle(5, 0xFFFFFF);
			
			img.centerOO();
			
			graphic = img;
		}
		
		public override function update (): void
		{
			var level:Level = world as Level;
			
			if (! level) return;
			
			x += vx;
			y += vy;
			
			var w:Number = level.bounds.width;
			var h:Number = level.bounds.height;
			
			if (x < 0) {
				vx *= -1;
				x = 0;
			} else if (x > w) {
				vx *= -1;
				x = w;
			}
			
			if (y < 0) {
				vy *= -1;
				y = 0;
			} else if (y > h) {
				vy *= -1;
				y = h;
			}
		}
		
		public override function render (): void
		{
			var x1:int = x;
			var y1:int = y;
			var x2:int = oldX;
			var y2:int = oldY;
			
			oldX = x;
			oldY = y;
			
			var color:uint = 0xFFFFFFFF;
			
			var level:Level = world as Level;
			
			if (level.parent) {
				Draw.line(x1, y1, x2, y2, color);
				return;
			}
			
			var rect:Rectangle = FP.rect;
			
			x1 -= 3;
			y1 -= 3;
			x2 -= 3;
			y2 -= 3;
			
			rect.width = 6;
			rect.height = 6;
			
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

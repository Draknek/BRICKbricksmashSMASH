package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Paddle extends Entity
	{
		public var vx:Number = 0;
		
		public static var globalPos:Number = 0;
		
		public function Paddle (_level:Level)
		{
			width = _level.bounds.width * 0.25;
			height = width*0.1;
			
			width = Math.round(width);
			height = Math.floor(height);
			
			y = _level.bounds.height - height*2;
			
			type = "paddle";
			
			active = false;
			
			if (! _level.parent) visible = false;
		}
		
		public override function added ():void
		{
			var level:Level = world as Level;
			
			if (G.mouseInput) {
				x = FP.clamp(Input.mouseX / FP.width, 0, 1) * (level.bounds.width) - width*0.5;
			} else {
				x = FP.width*0.5 - width*0.5;
			}
		}
		
		public override function update (): void
		{
			var level:Level = world as Level;
			
			var toX:Number;
			
			if (G.mouseInput) {
				toX = FP.clamp(Input.mouseX / FP.width, 0, 1) * (level.bounds.width) - width*0.5;
				
				vx = (toX - x)*0.2;
				
			} else {
				if (! level.parent) {
					var inputX:int = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
					
					vx *= 0.8;
					
					vx += inputX*1.5;
				} else {
					toX = globalPos * (level.bounds.width - width);
					
					vx = toX - x;
				}
			}
			
			x += vx;
			
			if (! G.mouseInput && ! level.parent) {
				if (x <= 0) {
					globalPos = 0;
					vx = 0;
					x = 0;
				} else if (x >= level.bounds.width - width) {
					globalPos = 1;
					vx = 0;
					x = level.bounds.width - width;
				} else {
					globalPos = x / (level.bounds.width - width);
				}
			}
		}
		
		public override function render (): void
		{
			var level:Level = world as Level;
			
			var c:uint = (level.parent && ! G.fadeColors) ? 0xFF000000 : 0xFFFFFFFF
			
			FP.rect.x = x;
			FP.rect.y = y;
			FP.rect.width = width;
			FP.rect.height = height;
			
			FP.buffer.fillRect(FP.rect, c);
			
			if (! level.hasStarted) {
				FP.rect.x = x + width*0.5 - 3;
				FP.rect.y = y - 6;
				FP.rect.width = 6;
				FP.rect.height = 6;
				
				FP.buffer.fillRect(FP.rect, c);
			}
		}
	}
}

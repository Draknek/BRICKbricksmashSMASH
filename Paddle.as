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
			update();
		}
		
		public override function update (): void
		{
			var level:Level = world as Level;
			x = FP.clamp(Input.mouseX / FP.width, 0, 1) * (level.bounds.width - width);
		}
		
		public override function render (): void
		{
			FP.rect.x = x;
			FP.rect.y = y;
			FP.rect.width = width;
			FP.rect.height = height;
			
			FP.buffer.fillRect(FP.rect, 0xFFFFFFFF);
			
			var level:Level = world as Level;
			
			if (! level.hasStarted) {
				FP.rect.x = x + width*0.5 - 3;
				FP.rect.y = y - 6;
				FP.rect.width = 6;
				FP.rect.height = 6;
				
				FP.buffer.fillRect(FP.rect, 0xFFFFFFFF);
			}
		}
	}
}

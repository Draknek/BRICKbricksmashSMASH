package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Block extends Entity
	{
		public var subgame:Level;
		
		public var border:int = 2;
		
		public function Block (_x:Number, _y:Number, _w:Number, _h:Number)
		{
			x = _x;
			y = _y;
			
			width = _w;
			height = _h;
			
			layer = -5;
			
			type = "block";
		}
		
		public override function added ():void
		{
			var level:Level = world as Level;
			
			if (! level.parent) {
				subgame = new Level(this);
				subgame.updateLists();
			}
		}
		
		public function hit (ball:Ball):void
		{
			var level:Level = world as Level;
			
			if (level.parent) {
				world.remove(this);
				return;
			}
			
			if (subgame.typeCount("block") == 0) return;
			
			var newX:Number = ball.x;
			var newY:Number = ball.y;
			
			newX -= x + border;
			newY -= y + border;
			
			var newBall:Ball = new Ball(newX, newY, ball.vx*0.2, ball.vy*0.2, this);
			
			subgame.add(newBall);
			subgame.updateLists();
		}
		
		public override function update (): void
		{
			if (subgame) {
				subgame.update();
				subgame.updateLists();
				
				if (subgame.classCount(Ball) == 0 && subgame.typeCount("block") == 0) {
					world.remove(this);
					Main.tint = 1.0;
				}
			}
		}
		
		public override function render (): void
		{
			FP.rect.x = x;
			FP.rect.y = y;
			FP.rect.width = width;
			FP.rect.height = height;
			
			FP.buffer.fillRect(FP.rect, 0xFFFFFFFF);
			
			if (! subgame) return;
			
			subgame.render();
			
			FP.point.x = x + (width - subgame.bounds.width)*0.5;
			FP.point.y = y + (height - subgame.bounds.height)*0.5;
			
			FP.buffer.copyPixels(subgame.renderTarget, subgame.bounds, FP.point);
		}
	}
}

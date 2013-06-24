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
		
		public function Block (_x:Number, _y:Number, _w:Number, _h:Number)
		{
			x = _x;
			y = _y;
			
			width = _w;
			height = _h;
			
			layer = -5;
			
			subgame = new Level(this);
			subgame.updateLists();
		}
		
		public override function update (): void
		{
			subgame.updateLists();
			subgame.update();
			subgame.updateLists();
		}
		
		public override function render (): void
		{
			subgame.render();
			
			FP.point.x = x;
			FP.point.y = y;
			
			FP.buffer.copyPixels(subgame.renderTarget, subgame.bounds, FP.point);
		}
	}
}

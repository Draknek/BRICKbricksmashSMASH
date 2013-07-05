package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	import net.flashpunk.tweens.misc.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Block extends Entity
	{
		public var subgame:Level;
		
		public var border:int = G.invertSubGame ? 1 : 3;
		
		public var color:uint;
		
		public var colorTween:ColorTween;
		
		public var ix:int;
		public var iy:int;
		
		public var fadingOut:Boolean;
		
		public function Block (_x:Number, _y:Number, _w:Number, _h:Number, _ix:int, _iy:int, _parent:Level)
		{
			var hasSubgame:Boolean = _parent.parent ? false : true;
			x = int(_x);
			y = int(_y);
			
			width = _w;
			height = _h;
			
			layer = 5;
			
			type = "block";
			
			ix = _ix;
			iy = _iy;
			
			if (hasSubgame) {
				if (G.colors && ! G.hardMode) {
					color = getTargetColor();
				} else {
					color = 0xFFFFFF;
				}
			} else if (G.multiplayer) {
				color = _parent.parent.ix ? 0xFFFFFF : 0x0;
			} else {
				color = G.hardMode ? 0xFFFFFF : 0x0;
			}
			
			color = color & 0xFFFFFF;
			
			if (hasSubgame && ! G.hardMode) {
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
			
			if (! subgame) {
				subgame = new Level(this);
				subgame.updateLists();
			}
			
			if (G.hardMode) {
				if (! colorTween) {
					colorTween = new ColorTween(null, Tween.PERSIST);
					addTween(colorTween);
				}
				colorTween.tween(60, color, getTargetColor());
				fadingOut = false;
			}
			
			if (subgame.typeCount("block") == 0) return;
			
			if (G.oneBallPerWorld && subgame.classCount(Ball) != 0) return;
			
			var newX:Number = ball.x;
			var newY:Number = ball.y;
			
			newX -= x + border;
			newY -= y + border;
			
			var newBall:Ball = new Ball(newX, newY, ball.vx*0.2, ball.vy*0.2, ball.playerDX, this);
			
			subgame.add(newBall);
			subgame.updateLists();
		}
		
		public override function update (): void
		{
			if (colorTween) {
				color = colorTween.color;
				
				if (ix == 0 && iy == 1) {
					FP.log(color.toString(16));
				}
			}
			
			if (fadingOut && subgame && color == 0xFFFFFF) {
				subgame = null;
				fadingOut = false;
			}
			
			if (subgame) {
				subgame.update();
				subgame.updateLists();
				
				if (subgame.typeCount("block") == 0) {
					var balls:Array = [];
					subgame.getClass(Ball, balls);
					
					for each (var ball:Ball in balls) {
						ball.moveToOuter();
					}
					
					world.remove(this);
					Main.tint = 1.5;
					Audio.play("high");
				}
				
				if (G.hardMode && ! fadingOut && subgame.classCount(Ball) == 0) {
					colorTween.tween(120, color, 0xFFFFFF);
					fadingOut = true;
				}
			}
		}
		
		public function getTargetColor ():uint
		{
			var c:uint;
			
			if (G.multiplayer) {
				c = FP.getColorHSV(y / FP.height, ix ? 0.8 : 0.5, 0.8);
			} else {
				c = FP.getColorHSV(x / FP.width, iy ? 0.8 : 0.5, 0.8);
			}
			
			return 0xFFFFFF & c;
		}
		
		public override function render (): void
		{
			var level:Level = world as Level;
			
			FP.rect.x = x;
			FP.rect.y = y;
			FP.rect.width = width;
			FP.rect.height = height;
			
			if (! level.parent) {
				FP.rect.x += 1;
				FP.rect.y += 1;
				FP.rect.width -= 2;
				FP.rect.height -= 2;
			}
			
			FP.buffer.fillRect(FP.rect, 0xFF000000 | color);
			
			if (! subgame) return;
			
			subgame.render();
			
			FP.point.x = x + (width - subgame.bounds.width)*0.5;
			FP.point.y = y + (height - subgame.bounds.height)*0.5;
			
			FP.buffer.copyPixels(subgame.renderTarget, subgame.bounds, FP.point, null, null, true);
		}
	}
}

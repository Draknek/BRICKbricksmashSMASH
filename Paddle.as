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
		public var vy:Number = 0;
		
		public static var globalPos:Number = 0;
		public static var globalPosLeft:Number = 0;
		public static var globalPosRight:Number = 0;
		
		public var sideways:Boolean;
		
		public var dx:int;
		
		public var lost:Boolean;
		
		public function Paddle (_level:Level, _dx:int = 0)
		{
			var wSize:Number = 0.25;
			
			if (G.hardMode && _level.parent) wSize = 0.4;
			
			width = _level.bounds.width * wSize;
			height = width*0.1;
			
			width = Math.round(width);
			height = Math.floor(height);
			if (height == 0) height = 1;
			
			y = _level.bounds.height - height*2;
			
			if (_dx) {
				dx = _dx;
				sideways = true;
				
				height = _level.bounds.height * wSize;
				width = height*0.1;
				
				width = Math.floor(width);
				height = Math.round(height);
				if (width == 0) width = 1;
				
				var offset:int = _level.parent ? width : width*5;
				
				if (dx > 0) {
					x = offset;
				} else {
					x = _level.bounds.width - width - offset;
				}
			}
			
			type = "paddle";
			
			active = false;
			
			if (! _level.parent) visible = false;
		}
		
		public override function added ():void
		{
			var level:Level = world as Level;
			
			if (sideways) {
				y = FP.height*0.5 - height*0.5;
			} else if (G.mouseInput) {
				x = FP.clamp(Input.mouseX / FP.width, 0, 1) * (level.bounds.width) - width*0.5;
			} else {
				x = FP.width*0.5 - width*0.5;
			}
		}
		
		public override function update (): void
		{
			if (lost) return;
			
			var level:Level = world as Level;
			
			if (sideways) {
				var toY:Number;
				if (! level.parent) {
					var inputY:int;
					
					if (dx > 0) {
						inputY = int(Input.check(Key.S)) - int(Input.check(Key.W));
					} else {
						inputY = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
					}
					
					vy *= 0.8;
					
					vy += inputY*1.5;
				} else {
					toY = (dx > 0) ? globalPosLeft : globalPosRight;
					toY *= (level.bounds.height - height);
					
					vy = toY - y;
				}
				
				y += vy;
				
				if (! level.parent) {
					if (y <= 0) {
						if (dx > 0) {
							globalPosLeft = 0;
						} else {
							globalPosRight = 0;
						}
						vy = 0;
						y = 0;
					} else if (y >= level.bounds.height - height) {
						if (dx > 0) {
							globalPosLeft = 1;
						} else {
							globalPosRight = 1;
						}
						vy = 0;
						y = level.bounds.height - height;
					} else {
						if (dx > 0) {
							globalPosLeft = y / (level.bounds.height - height);
						} else {
							globalPosRight = y / (level.bounds.height - height);
						}
					}
				}
				return;
			}
			
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
		
		public function spawnBall ():void
		{
			var level:Level = world as Level;
			
			var vx:Number = 1.5 + Math.random()*0.5;
			var vy:Number = -1.5 - Math.random()*0.5;
			
			if (sideways) {
				vx = 1.5 * dx;
				
				if (Math.random() < 0.5) {
					vy *= -1;
				}
				
				world.add(new Ball((dx > 0) ? x + width : x - 3, y + height*0.5, vx, vy, dx));
			} else {
				if (vx < -0.5) {
					vx *= -1;
				} else if (vx < 0.5) {
					if (x + width*0.5 < level.bounds.width*0.4) {
						vx *= -1;
					} else if (x + width*0.5 < level.bounds.width*0.6) {
						if (Math.random() < 0.5) {
							vx *= -1;
						}
					}
				}
				
				world.add(new Ball(x + width*0.5, y - 3, vx, vy));
			}
		}
		
		public override function render (): void
		{
			var level:Level = world as Level;
			
			var c:uint = (level.parent && ! G.hardMode) ? 0xFF000000 : 0xFFFFFFFF
			
			if (sideways) {
				c = (dx > 0) ? 0xFF000000 : 0xFFFFFFFF;
			}
			
			FP.rect.x = x;
			FP.rect.y = y;
			FP.rect.width = width;
			FP.rect.height = height;
			
			FP.buffer.fillRect(FP.rect, c);
			
			if (! level.hasStarted) {
				if (sideways) {
					if (dx < 0) {
						FP.rect.x = x - 6;
					} else {
						FP.rect.x = x + width;
					}
					
					FP.rect.y = y + height*0.5 - 3;
				} else {
					FP.rect.x = x + width*0.5 - 3;
					FP.rect.y = y - 6;
				}
				
				FP.rect.width = 6;
				FP.rect.height = 6;
				
				FP.buffer.fillRect(FP.rect, c);
			}
		}
	}
}

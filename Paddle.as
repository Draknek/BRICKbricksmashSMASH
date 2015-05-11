package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class Paddle extends Entity
	{
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public static var globalPos:Number = 0.5;
		public static var globalPosLeft:Number = 0.5;
		public static var globalPosRight:Number = 0.5;
		
		public var sideways:Boolean;
		
		public var dx:int;
		
		public var lost:Boolean;
		
		public var stun:int;
		
		public var touchID:int;
		public var hasTouchID:Boolean;
		public var touchX:Number = 0.5;
		public var touchY:Number = 0.5;
		public var touchDX:Number = 0;
		public var touchDY:Number = 0;
		
		public var ready:Number = 0;
		
		public var shields:int;
		public var shieldSpacing:int;
		public var shieldX:int;
		
		public function Paddle (_level:Level, _dx:int = 0)
		{
			var wSize:Number = 0.25;
			
			if (G.hardMode && _level.parent) wSize = 0.4;
			if (G.multiplayer) {
				if (_level.parent && G.versusLargeSubgamePaddle) wSize = 0.4;
				if (! _level.parent && G.versusLargeMainPaddle) wSize = 0.4;
			}
			
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
			
			if (sideways && ! _level.parent) {
				initShields();
			}
		}
		
		public function initShields ():void
		{
			if (! G.versusShieldCount) {
				return;
			}
			
			shields = G.versusShieldCount;
			
			var w:int = Math.ceil(width*0.3);
			
			if (dx < 0) {
				shieldSpacing = FP.width - x - width;
			} else {
				shieldSpacing = x;
			}
			
			shieldSpacing -= shields*w;
			
			shieldSpacing /= (shields + 1);
			
			shieldSpacing += w;
			
			shieldX = (dx < 0) ? FP.width : 0;
			
			shieldX += dx * shieldSpacing * shields;
		}
		
		public function onTouchBegin(event:TouchEvent):void
		{
			if (hasTouchID) {
				return;
			}
			
			if (sideways && (event.stageX < FP.stage.stageWidth*0.5) != (dx > 0)) {
				return;
			}
			
			hasTouchID = true;
			
			touchID = event.touchPointID;
			
			touchX = event.stageX / FP.stage.stageWidth;
			touchY = event.stageY / FP.stage.stageHeight;
			
			touchDX = 0;
			touchDY = 0;
		}
		
		public function onTouchMove(event:TouchEvent):void
		{
			if (! hasTouchID || event.touchPointID != touchID) {
				return;
			}
			
			var nowX:Number = event.stageX / FP.stage.stageWidth;
			var nowY:Number = event.stageY / FP.stage.stageHeight;
			
			touchDX += nowX - touchX;
			touchDY += nowY - touchY;
			
			touchX = nowX;
			touchY = nowY;
		}
		
		public function onTouchEnd(event:TouchEvent):void
		{
			if (! hasTouchID || event.touchPointID != touchID) {
				return;
			}
			
			var nowX:Number = event.stageX / FP.stage.stageWidth;
			var nowY:Number = event.stageY / FP.stage.stageHeight;
			
			touchDX += nowX - touchX;
			touchDY += nowY - touchY;
			
			touchX = nowX;
			touchY = nowY;
			
			hasTouchID = false;
			touchID = 0;
		}
		
		public override function added ():void
		{
			var level:Level = world as Level;
			
			if (sideways) {
				y = level.bounds.height*0.5 - height*0.5;
			} else if (G.mouseInput) {
				x = FP.clamp(Input.mouseX / FP.width, 0, 1) * (level.bounds.width) - width*0.5;
			} else {
				x = FP.width*0.5 - width*0.5;
			}
		}
		
		public override function update (): void
		{
			if (stun) {
				stun--;
				
				vx *= 0.8;
				vy *= 0.8;
				
				return;
			}
			
			if (lost) return;
			
			var level:Level = world as Level;
			
			if (sideways) {
				if (G.touchscreen) {
					if (! level.hasStarted) {
						if (hasTouchID) {
							ready += 1/30;
							if (ready > 1) ready = 1;
						} else {
							ready -= 0.1;
							if (ready < 0) ready = 0;
						}
					}
					update_2P_Touch();
				} else {
					update_2P_Keyboard();
				}
			} else if (SliderGamepad.active) {
				update_1P_Slider();
			} else {
				if (G.touchscreen) {
					update_1P_Touch();
				} else if (G.mouseInput) {
					update_1P_Mouse();
				} else if (level.parent) {
					update_1P_Keyboard_SubGame();
				} else {
					update_1P_Keyboard_MainGame();
				}
			}
		}
		
		public function update_1P_Slider ():void
		{
			var level:Level = world as Level;
			
			var sliderPosition:Number;
			
			if (level.parent) {
				sliderPosition = G.sliderPositions[(int)(level.parent.ix / 2)];
			} else {
				sliderPosition = G.sliderPosition;
			}
			
			var toX:Number = FP.clamp(sliderPosition, 0, 1) * (level.bounds.width - width*0.9) - width*0.05;
			
			vx = (toX - x)*0.4;
			
			x += vx;
		}
		
		public function update_1P_Mouse ():void
		{
			var level:Level = world as Level;
			
			var toX:Number = FP.clamp(Input.mouseX / FP.width, 0, 1) * (level.bounds.width) - width*0.5;
			
			vx = (toX - x)*0.2;
			
			x += vx;
		}
		
		public function update_1P_Touch ():void
		{
			var level:Level = world as Level;
			
			if (! level.parent) {
				globalPos += touchDX * G.touchRelativeSpeed1P;
				globalPos = FP.clamp(globalPos, 0, 1);
				touchDX = touchDY = 0;
			}
			
			var toX:Number = globalPos * (level.bounds.width) - width*0.5;
			
			vx = (toX - x)*0.2;
			
			x += vx;
		}
		
		public function update_1P_Keyboard_MainGame ():void
		{
			var level:Level = world as Level;
			
			var inputX:int = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
			
			vx *= 0.8;
			
			vx += inputX*1.5;
			
			x += vx;
			
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
		
		public function update_1P_Keyboard_SubGame ():void
		{
			var level:Level = world as Level;
			
			var toX:Number = globalPos * (level.bounds.width - width);
			
			vx = toX - x;
			
			x += vx;
		}
		
		public function update_2P_Touch ():void
		{
			var level:Level = world as Level;
			
			if (! level.parent) {
				if (dx > 0) {
					globalPosLeft += touchDY * G.touchRelativeSpeed2P;
					globalPosLeft = FP.clamp(globalPosLeft, 0, 1);
				} else {
					globalPosRight += touchDY * G.touchRelativeSpeed2P;
					globalPosRight = FP.clamp(globalPosRight, 0, 1);
				}
				
				touchDX = touchDY = 0;
			}
					
			var toY:Number = (dx > 0) ? globalPosLeft : globalPosRight;
			
			toY = toY * (level.bounds.height) - height*0.5;
			
			vy = (toY - y)*0.2;
			
			y += vy;
		}
		
		public function update_2P_Keyboard ():void
		{
			var level:Level = world as Level;
			
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
		}
		
		public function spawnBall ():void
		{
			ready = 0;
			
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
				
				if (level.parent && level.parent.owner) {
					c = (level.parent.owner < 0) ? 0xFF000000 : 0xFFFFFFFF;
				}
			}
			
			FP.rect.x = x;
			FP.rect.y = y;
			FP.rect.width = width;
			FP.rect.height = height;
			
			if (stun) {
				var s:Number = stun / G.versusOwnBallsStun;
				var shake:int = s * 2 + 1;
				FP.rect.x += FP.rand(shake*2+1) - shake;
				FP.rect.y += FP.rand(shake*2+1) - shake;
			}
			
			FP.buffer.fillRect(FP.rect, c);
			
			if (sideways && shields) {
				renderShields();
			}
			
			if (ready > 0) {
				if (sideways) {
					if (dx < 0) {
						FP.rect.x = x - 6*ready;
					} else {
						FP.rect.x = x + width - 6 + 6*ready;
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
		
		public function renderShields ():void
		{
			var c:uint = (dx > 0) ? 0xFF000000 : 0xFFFFFFFF;
			
			var w:int = Math.ceil(width*0.3);
			
			FP.rect.y = 0;
			FP.rect.width = w;
			FP.rect.height = FP.height;
			
			for (var i:int = 0; i < shields; i++) {
				FP.rect.x = shieldX - dx*shieldSpacing*i;
				
				if (dx > 0) FP.rect.x -= w;
				
				FP.buffer.fillRect(FP.rect, c);
			}
		}
	}
}

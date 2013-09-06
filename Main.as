package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.geom.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.display.*;
	
	public class Main extends Engine
	{
		[Embed(source = 'fonts/orbitron-medium.ttf', embedAsCFF="false", fontFamily = 'orbitron')]
		public static const FONT:Class;
		
		public static var tint:Number = 0.0;
		
		public static var tintTransform:ColorTransform = new ColorTransform();
		
		public function Main ()
		{
			G.init();
			
			super(480, 320, 60, true);
			
			Text.font = 'orbitron';
			
			FP.world = new Menu();
			
			FP.screen.color = 0x0;
		}
		
		public override function init (): void
		{
			super.init();
			
			FP.stage.addEventListener(Event.RESIZE, onResize);
			
			if (G.touchscreen) {
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				
				FP.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				FP.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				FP.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			}
			
			if (G.platform == "android") {
				try {
					var NativeApplication:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;
					
					NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, androidKeyListener);
				}
				catch (e:Error) {}
			}
		}
		
		public override function setStageProperties():void
		{
			super.setStageProperties();
			
			if (G.touchscreen) {
				try {
					stage.displayState = StageDisplayState['FULL_SCREEN_INTERACTIVE'];
				} catch (e:Error) {}
			}
			
			onResize(null);
		}
		
		public function onResize (e:Event):void
		{
			var sw:int = FP.stage.stageWidth;
			var sh:int = FP.stage.stageHeight;
			
			var w:int = FP.width;
			var h:int = FP.height;
			
			var scale:int = Math.min(Math.floor(sw/w), Math.floor(sh/h));
			
			FP.screen.scale = scale;
			
			this.x = (sw - w*scale)*0.5;
			this.y = (sh - h*scale)*0.5;
			
			//FP.console.enable();
		}
		
		private static function androidKeyListener(e:KeyboardEvent):void
		{
			try {
			const BACK:uint   = ("BACK" in Keyboard)   ? Keyboard["BACK"]   : 0;
			const MENU:uint   = ("MENU" in Keyboard)   ? Keyboard["MENU"]   : 0;
			const SEARCH:uint = ("SEARCH" in Keyboard) ? Keyboard["SEARCH"] : 0;
			
			if(e.keyCode == BACK) {
				if (FP.world is Menu) {
					if (G.rootMenu) {
						return;
					} else {
						Menu.gotoRootMenu();
					}
				} else {
					FP.world = new Menu;
				}
			} else if(e.keyCode == SEARCH) {
				
			} else {
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			} catch (e:Error) {}
		}
		
		public function onTouchBegin(event:TouchEvent):void
		{
			FP.world.onTouchBegin(event);
		}
		
		public function onTouchMove(event:TouchEvent):void
		{
			FP.world.onTouchMove(event);
		}
		
		public function onTouchEnd(event:TouchEvent):void
		{
			FP.world.onTouchEnd(event);
		}

		public override function update (): void
		{
			Input.mouseCursor = G.mouseInput ? "auto" : "hide";
			
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				FP.console.enable();
			}
			
			super.update();
		}
	}
}


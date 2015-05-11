package
{
	import flash.text.TextField;
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.geom.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.display.*;
	
	//[SWF(width = "480", height = "320", backgroundColor="#000000")]
	public class Main extends Engine
	{
		[Embed(source = 'fonts/orbitron-medium.ttf', embedAsCFF="false", fontFamily = 'orbitron')]
		public static const FONT:Class;
		
		public static var tint:Number = 0.0;
		
		public static var tintTransform:ColorTransform = new ColorTransform();
		
		public static var fpsIndicator:Bitmap;
		
		public static var whiteBG:Bitmap;
		
		public static var errorMessage:TextField;
		
		public function Main ()
		{
			G.init();
			
			super(480, 320, 60, true);
			
			Text.font = 'orbitron';
			
			FP.screen.color = 0x0;
			
			errorMessage = new TextField();
			errorMessage.text = "hi";
			errorMessage.y = -20;
			errorMessage.width = 400;
			//addChild(errorMessage);
			
			SliderGamepad.init(this);
		}
		
		public override function init (): void
		{
			super.init();
			
			toggleFPSCounter();
			
			FP.stage.addEventListener(Event.RESIZE, onResize);
			
			onResize();
			
			FP.world = new Menu();
			
			if (G.touchscreen) {
				whiteBG = new Bitmap(new BitmapData(FP.stage.stageWidth, FP.stage.stageHeight, false, 0xFFFFFF));
				
				whiteBG.visible = false;
				
				FP.stage.addChildAt(whiteBG, 0);
				
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
		
		public function onResize (e:Event = null):void
		{
			var sw:int = FP.stage.stageWidth;
			var sh:int = FP.stage.stageHeight;
			
			var w:int = 480;
			var h:int = 320;
			
			var scale:int = Math.round(sh/h);
			
			if (scale < 1) scale = 1;
			
			//var scale:int = Math.min(Math.floor(sw/w), Math.floor(sh/h));
			
			FP.screen.scale = scale;
			
			w = Math.ceil(sw / scale);
			h = Math.ceil(sh / scale);
			
			FP.resize(w, h);
			
			if (FP.world is Menu)
			{
				FP.world = new Menu();
			}
			
			//this.x = (sw - w*scale)*0.5;
			//this.y = (sh - h*scale)*0.5;
			
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
			
			if (whiteBG) {
				whiteBG.visible = (FP.world is Level && ! G.multiplayer);
			}
			
			super.update();
		}
		
		public override function render ():void
		{
			super.render();
			
			if (fpsIndicator) {
				var c:uint = 0;
				
				if (FPS.fps < 30) {
					c = 0xFF0000;
				} else if (FPS.fps < 50) {
					c = 0xFFFF00;
				} else {
					c = 0x00FF00;
				}
				
				Main.fpsIndicator.bitmapData.setPixel(0, 0, c);
			}
		}
		
		public static function toggleFPSCounter ():void
		{
			FPS.init(FP.stage);
			
			if (Main.fpsIndicator) {
				Main.fpsIndicator.visible = ! Main.fpsIndicator.visible;
			} else {
				Main.fpsIndicator = new Bitmap;
				Main.fpsIndicator.bitmapData = new BitmapData(1, 1, false, 0x0);
				Main.fpsIndicator.scaleX = Main.fpsIndicator.scaleY = 10;
				
				FP.stage.addChild(Main.fpsIndicator);
			}
		}
		
	}
}


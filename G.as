package
{
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
	public class G
	{
		public static const so:SharedObject = SharedObject.getLocal("brickbricksmashsmash", "/");
		
		public static var rootMenu:Boolean = false;
		
		public static var mouseInput:Boolean = true;
		
		public static var touchscreen:Boolean = false;
		
		public static var invertSubGame:Boolean = true;
		public static var colors:Boolean = true;
		public static var hardMode:Boolean = false;
		public static var oneBallPerWorld:Boolean = false;
		
		public static var touchRelativeSpeed1P:Number = 2;
		public static var touchRelativeSpeed2P:Number = 1.5;
		
		public static var multiplayer:Boolean = true;
		public static var versusChangeColor:int = 0; // 0 = never, 1 = in main game, 2 = in all games
		public static var versusOwnBallsKill:Boolean = false;
		public static var versusOwnBallsStun:int = 0;
		public static var versusBlocksWide:int = 2;
		public static var versusBlocksHigh:int = 5;
		public static var versusSubgameBlocksWide:int = 2;
		public static var versusSubgameBlocksHigh:int = 5;
		public static var versusEmptyColumn:Boolean = false;
		public static var versusGapBetweenBlocks:Boolean = false;
		public static var versusGapAtEdges:Boolean = false;
		public static var versusLargeMainPaddle:Boolean = false;
		public static var versusLargeSubgamePaddle:Boolean = false;
		public static var versusClaimBlocks:Boolean = false;
		public static var versusShieldCount:int = 0;
		
		public static var chooseMode:Boolean = false;
		
		public static var mode:String;
		
		public static var platform:String;
		
		private static const properties:Array = [
			"games",
			"besttime",
			"bestballsleft",
			"bestballslost",
			"totaltime",
			"totalballsleft",
			"totalballslost",
			"gameslost",
			"bestblocksremoved"
		];
			
		public static function init ():void
		{
			// Platform detection
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				platform = "ios";
				touchscreen = true;
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				platform = "android";
				touchscreen = true;
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				platform = "blackberry";
				touchscreen = true;
			}
			
			if (touchscreen) {
				rootMenu = true;
				multiplayer = false;
			}
			
			if (! touchscreen && ! so.data.control) {
				so.data.control = "mouse";
			}
			
			var property:String;
			var value:int;
			
			if (! so.data.modes) {
				so.data.modes = {};
				so.data.modes["normal"] = {};
				
				for each (property in properties) {
					value = so.data[property];
					so.data.modes["normal"][property] = value;
					delete so.data[property];
				}
			}
			
			so.data.version = "1";
			
			resetMode();
		}
		
		public static function resetMode ():void
		{
			mode = "normal";
			
			if (hardMode) {
				mode = "hard";
			}
			
			if (oneBallPerWorld) {
				mode += "-oneball";
			}
			
			var property:String;
			
			if (! so.data.modes[mode]) {
				so.data.modes[mode] = {};
				for each (property in properties) {
					so.data.modes[mode][property] = 0;
				}
			}
		}
	}
}
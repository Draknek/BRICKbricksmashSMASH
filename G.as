package
{
	import flash.net.SharedObject;
	
	public class G
	{
		public static const so:SharedObject = SharedObject.getLocal("brickbricksmashsmash", "/");
		
		public static var mouseInput:Boolean = true;
		
		public static var invertSubGame:Boolean = true;
		public static var colors:Boolean = true;
		public static var hardMode:Boolean = false;
		public static var oneBallPerWorld:Boolean = false;
		public static var multiplayer:Boolean = true;
		
		public static var chooseMode:Boolean = false;
		
		public static var mode:String;
		
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
			if (! so.data.control) {
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
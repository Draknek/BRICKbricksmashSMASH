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
		
		public static var mode:String;
		
		public static function init ():void
		{
			if (! so.data.control) {
				so.data.control = "mouse";
			}
			
			const properties:Array = [
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
			
			const modes:Array = [
				"normal",
				"hard"
			];
			
			for each (mode in modes) {
				if (! so.data.modes[mode]) {
					so.data.modes[mode] = {};
					for each (property in properties) {
						so.data.modes[mode][property] = 0;
					}
				}
			}
			
			so.data.version = "1";
			
			mode = "normal";
			
			if (hardMode) {
				mode = "hard";
			}
		}
	}
}
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
		
		public static function init ():void
		{
			if (! so.data.control) {
				so.data.control = "mouse";
			}
			
			if (! so.data.gameslost) {
				so.data.gameslost = 0;
				so.data.bestblocksremoved = 0;
			}
			
			if (! so.data.games) {
				so.data.games = 0;
				so.data.besttime = 0;
				so.data.bestballsleft = 0;
				so.data.bestballslost = 0;
				so.data.totaltime = 0;
				so.data.totalballsleft = 0;
				so.data.totalballslost = 0;
			}
			
			if (! so.data.gameslost_hard) {
				so.data.gameslost_hard = 0;
				so.data.bestblocksremoved_hard = 0;
			}
			
			if (! so.data.games_hard) {
				so.data.games_hard = 0;
				so.data.besttime_hard = 0;
				so.data.bestballsleft_hard = 0;
				so.data.bestballslost_hard = 0;
				so.data.totaltime_hard = 0;
				so.data.totalballsleft_hard = 0;
				so.data.totalballslost_hard = 0;
			}
		}
	}
}
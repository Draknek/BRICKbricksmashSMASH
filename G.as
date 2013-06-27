package
{
	import flash.net.SharedObject;
	
	public class G
	{
		public static const so:SharedObject = SharedObject.getLocal("brickbricksmashsmash", "/");
		
		public static var mouseInput:Boolean = false;
		
		public static function init ():void
		{
			if (! so.data.games) {
				so.data.games = 0;
				so.data.besttime = 0;
				so.data.bestballsleft = 0;
				so.data.bestballslost = 0;
				so.data.totaltime = 0;
				so.data.totalballsleft = 0;
				so.data.totalballslost = 0;
			}
		}
	}
}
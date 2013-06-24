package
{
	import net.flashpunk.*;
	import net.flashpunk.tweens.sound.*
	import flash.display.*;
	import flash.events.*;
	
	public class Audio
	{
		[Embed(source="audio/sfx.swf#low1")] public static const Sfx_low1:Class;
		[Embed(source="audio/sfx.swf#low2")] public static const Sfx_low2:Class;
		[Embed(source="audio/sfx.swf#low3")] public static const Sfx_low3:Class;
		[Embed(source="audio/sfx.swf#low4")] public static const Sfx_low4:Class;
		[Embed(source="audio/sfx.swf#low5")] public static const Sfx_low5:Class;
		
		[Embed(source="audio/sfx.swf#high1")] public static const Sfx_high1:Class;
		[Embed(source="audio/sfx.swf#high2")] public static const Sfx_high2:Class;
		[Embed(source="audio/sfx.swf#high3")] public static const Sfx_high3:Class;
		[Embed(source="audio/sfx.swf#high4")] public static const Sfx_high4:Class;
		[Embed(source="audio/sfx.swf#high5")] public static const Sfx_high5:Class;
		
		private static var inited:Boolean = false;
		
		public static function init ():void
		{
			inited = true;
		}
		
		public static function play (soundID:String):void
		{
			soundID += (FP.rand(5)+1);
			
			var embed:Class = Audio["Sfx_" + soundID];
			
			if (! embed) return;
			
			var sound:Sfx = new Sfx(embed);
			
			var volume:Number = 0.5;
			
			sound.play(volume);
		}
	}
}

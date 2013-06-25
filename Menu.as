package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Menu extends World
	{
		public function Menu ()
		{
			var title:Text = new Text("", 0, 0, {size: 40});
			
			title.setStyle("small", {size: 12});
			
			title.richText = "BRICK<small>[bricksmash]</small>SMASH";
			
			title.x = (FP.width - title.width)*0.5;
			title.y = title.x;
			
			addGraphic(title);
			
			var by:Text = new Text("By Alan Hazelden", 0, 0, {size: 18});
			
			by.x = (FP.width - by.width)*0.5;
			by.y = title.y + title.height + title.y*0.25;
			
			addGraphic(by);
			
			var best:Text = new Text("Best:   ", 0, 0, {size: 18});
			
			if (G.so.data.games) {
				var time:String = "";
				
				time += int(G.so.data.besttime / (60*60));
				time += ":";
				
				var seconds:int = int(G.so.data.besttime/60) % 60;
				
				if (seconds < 10) time += "0";
				time += seconds;
				
				best.text += time + "   " + G.so.data.bestballsleft + "   -" + G.so.data.bestballslost;
				
				best.x = (FP.width - best.width)*0.5;
				best.y = FP.height - best.height - title.y*0.25;
				
				addGraphic(best);
			} else {
				best.y = FP.height;
			}
			
			var play:Text = new Text("PLAY", 0, 0, {size: 50});
			
			play.x = (FP.width - play.width)*0.5;
			play.y = by.y + by.height + (best.y - by.y - by.height - play.height)*0.5;
			
			addGraphic(play);
		}
		
		public override function update ():void
		{
			if (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
				FP.world = new Level;
			}
		}
	}
}
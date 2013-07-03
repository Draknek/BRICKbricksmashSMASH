package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;
	
	public class Menu extends World
	{
		public var mouseButton:Button;
		public var keyboardButton:Button;
		public var muteButton:Button;
		
		public function Menu ()
		{
			var title:Text = new Text("", 0, 0, {size: 40});
			
			title.setStyle("small", {size: 12});
			
			title.richText = "BRICK<small>[bricksmash]</small>SMASH";
			
			title.x = (FP.width - title.width)*0.5;
			title.y = title.x;
			
			addGraphic(title);
			
			var by:Button = new Button("By Alan Hazelden", 18, gotoWebsite);
			
			by.x = (FP.width - by.width)*0.5;
			by.y = title.y + title.height + title.y*0.25;
			
			add(by);
			
			var best:Text = new Text("Best:   ", 0, 0, {size: 18});
			
			if (G.so.data.games) {
				var time:String = "";
				
				time += int(G.so.data.besttime / (60*60));
				time += ":";
				
				var seconds:int = int(G.so.data.besttime/60) % 60;
				
				if (seconds < 10) time += "0";
				time += seconds;
				
				best.text += time + "   " + G.so.data.bestballsleft;
				
				best.x = (FP.width - best.width)*0.5;
				best.y = FP.height - best.height - title.y*0.25;
				
				addGraphic(best);
			} else if (G.so.data.gameslost){
				best.text += G.so.data.bestblocksremoved + " / 16";
				best.x = (FP.width - best.width)*0.5;
				best.y = FP.height - best.height - title.y*0.25;
				
				addGraphic(best);
			} else {
				best.y = FP.height;
			}
			
			var play:Button = new Button("PLAY", 50, startGame);
			
			play.x = (FP.width - play.width)*0.5;
			play.y = by.y + by.height + (best.y - by.y - by.height - play.height)*0.5;
			
			add(play);
			
			if (Preloader.hostedOn == "flashgamelicense.com") {
				var moreGames:Button = new Button("MORE GAMES", 25, gotoWebsite);
				
				var space:int = (best.y - by.y - by.height - play.height - moreGames.height)*3/7;
				
				play.y = by.y + by.height + space;
				
				moreGames.x = (FP.width - moreGames.width)*0.5;
				moreGames.y = play.y + play.height + space;
				
				add(moreGames);
			}
			
			mouseButton = new Button("Mouse", 12, useKeyboard);
			keyboardButton = new Button("Keyboard", 12, useMouse);
			
			keyboardButton.x = title.y*0.25;
			keyboardButton.y = FP.height - keyboardButton.height - title.y*0.25;
			
			mouseButton.x = keyboardButton.x;
			mouseButton.y = keyboardButton.y;
			
			if (G.so.data.control == "mouse") {
				useMouse();
			} else {
				useKeyboard();
			}
			
			muteButton = new Button("Muted", 12, toggleMute);
			
			Text(muteButton.image).align = "center";
			if (! G.so.data.mute) {
				Text(muteButton.image).text = "Mute";
			}
			
			muteButton.x = FP.width - muteButton.width - title.y*0.25;
			muteButton.y = FP.height - muteButton.height - title.y*0.25;
			
			add(muteButton);
		}
		
		public function useMouse ():void
		{
			add(mouseButton);
			remove(keyboardButton);
			
			G.mouseInput = true;
			
			G.so.data.control = "mouse";
			G.so.flush();
		}
		
		public function useKeyboard ():void
		{
			add(keyboardButton);
			remove(mouseButton);
			
			G.mouseInput = false;
			
			G.so.data.control = "keyboard";
			G.so.flush();
		}
		
		public function toggleMute ():void
		{
			G.so.data.mute = G.so.data.mute ? false : true;
			G.so.flush();
			
			Text(muteButton.image).text = G.so.data.mute ? "Muted" : "Mute";
		}
		
		public function startGame ():void
		{
			FP.world = new Level;
		}
		
		public function gotoWebsite ():void
		{
			var request:URLRequest = new URLRequest("http://www.draknek.org/");
			navigateToURL(request, "_blank");
		}
		
		public override function update ():void
		{
			super.update();
			
			if (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
				startGame();
			}
		}
	}
}
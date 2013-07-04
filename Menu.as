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
			
			var buttons:Array = [];
			
			if (G.chooseMode) {
				buttons.push(["NORMAL", playNormal]);
				buttons.push(["HARD", playHard]);
				buttons.push(["HARDER", playHarder]);
			} else if (G.multiplayer) {
				buttons.push(["VERSUS", startGame]);
			} else {
				buttons.push(["PLAY", playNormal]);
			}
			
			if (Preloader.hostedOn == "flashgamelicense.com") {
				buttons.unshift(0);
				buttons.push(0);
				buttons.push(["MORE GAMES", gotoWebsite, 0.5]);
			}
			
			var scoreData:Object;
			
			if (! G.chooseMode && ! G.multiplayer) {
				scoreData = G.so.data.modes[G.mode];
			}
			
			var best:Text = new Text("Best:   ", 0, 0, {size: 18});
			
			if (scoreData && scoreData.games) {
				var time:String = "";
				
				time += int(scoreData.besttime / (60*60));
				time += ":";
				
				var seconds:int = int(scoreData.besttime/60) % 60;
				
				if (seconds < 10) time += "0";
				time += seconds;
				
				best.text += time + "   " + scoreData.bestballsleft;
				
				best.x = (FP.width - best.width)*0.5;
				best.y = FP.height - best.height - title.y*0.25;
				
				addGraphic(best);
			} else if (scoreData && scoreData.gameslost){
				best.text += scoreData.bestblocksremoved + " / 16";
				best.x = (FP.width - best.width)*0.5;
				best.y = FP.height - best.height - title.y*0.25;
				
				addGraphic(best);
			} else {
				best.y = FP.height;
			}
			
			addButtons(buttons, by.y + by.height, best.y);
			
			var startText:String = "PLAY";
			if (G.hardMode) {
				startText += " HARD";
			}
			if (G.oneBallPerWorld) {
				startText += "+";
			}
			
			if (! G.multiplayer) {
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
		
		public function addButtons (list:Array, startY:int, endY:int):void
		{
			var textSize:int = 50 - (list.length - 1)*5;
			
			var space:int = endY - startY;
			
			var buttons:Array = [];
			var button:Button;
			
			for each (var buttonData:* in list) {
				if (! buttonData) {
					buttons.push(null);
					continue;
				}
				
				var thisSize:Number = textSize;
				if (buttonData[2]) thisSize *= buttonData[2];
				
				button = new Button(buttonData[0], thisSize, buttonData[1]);
				button.x = (FP.width - button.width)*0.5;
				add(button);
				
				buttons.push(button);
				
				space -= button.height;
			}
			
			space /= (buttons.length + 1);
			
			var y:int = startY + space;
			
			for each (button in buttons) {
				if (button) {
					button.y = y;
					y += button.height;
				}
				
				y += space;
			}
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
		
		public function playNormal ():void
		{
			G.hardMode = false;
			G.oneBallPerWorld = false;
			G.resetMode();
			startGame();
		}
		
		public function playHard ():void
		{
			G.hardMode = true;
			G.oneBallPerWorld = false;
			G.resetMode();
			startGame();
		}
		
		public function playHarder ():void
		{
			G.hardMode = true;
			G.oneBallPerWorld = true;
			G.resetMode();
			startGame();
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
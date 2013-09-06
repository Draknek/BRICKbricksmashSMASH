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
		
		public var title:Text;
		public var by:Button;
		public var best:Text;
		
		public function Menu ()
		{
			title = new Text("", 0, 0, {size: 40});
			
			title.setStyle("small", {size: 12});
			
			title.richText = "BRICK<small>[bricksmash]</small>SMASH";
			
			title.x = (FP.width - title.width)*0.5;
			title.y = title.x;
			
			addGraphic(title);
			
			by = new Button("By Alan Hazelden", 18, gotoWebsite);
			
			by.x = (FP.width - by.width)*0.5;
			by.y = title.y + title.height + title.y*0.25;
			
			add(by);
			
			var buttons:Array = [];
			
			if (G.rootMenu) {
				buttons.push(["1P", goto1PMenu]);
				buttons.push(["2P", goto2PMenu]);
			} else if (G.chooseMode) {
				buttons.push(["NORMAL", playNormal]);
				buttons.push(["HARD", playHard]);
				buttons.push(["HARDER", playHarder]);
			} else if (G.multiplayer) {
				buttons.push(["VERSUS", startGame]);
			} else {
				buttons.push(["PLAY", playNormal]);
			}
			
			if (G.touchscreen && ! G.rootMenu) {
				buttons.push(["BACK", gotoRootMenu, 0.5]);
			}
			
			if (Preloader.hostedOn == "flashgamelicense.com") {
				buttons.unshift(0);
				buttons.push(0);
				buttons.push(["MORE GAMES", gotoWebsite, 0.5]);
			}
			
			var scoreData:Object;
			
			if (! G.chooseMode && ! G.multiplayer && ! G.rootMenu) {
				scoreData = G.so.data.modes[G.mode];
			}
			
			best = new Text("Best:   ", 0, 0, {size: 18});
			
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
			
			if (G.multiplayer) {
				addMultiplayerOptions();
			} else if (! G.touchscreen) {
				addControlOptions();
			}
			
			addButtons(buttons, by.y + by.height, best.y);
			
			if (! G.touchscreen) {
				addMuteOptions();
			}
		}
		
		public override function begin ():void
		{
			if (G.touchscreen) {
				FP.engine.y = (FP.stage.stageHeight - FP.height*FP.screen.scale)*0.5;
			}
		}
		
		public override function end ():void
		{
			removeAll();
		}
		
		public function addControlOptions ():void
		{
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
		
		public function addMuteOptions ():void
		{
			muteButton = new Button("Muted", 12, toggleMute);
			
			Text(muteButton.image).align = "center";
			if (! G.so.data.mute) {
				Text(muteButton.image).text = "Mute";
			}
			
			muteButton.x = FP.width - muteButton.width - title.y*0.25;
			muteButton.y = FP.height - muteButton.height - title.y*0.25;
			
			add(muteButton);
		}
		
		public static var multiplayerOptions:Array;
		public static var activeMenu:Menu;
		
		public function addMultiplayerOptions ():void
		{
			activeMenu = this;
			
			title.y *= 0.25;
			
			remove(by);
			
			by.y = title.y + title.height - by.height;
			
			var i:int;
			var option:*;
			var button:Button;
			
			if (! multiplayerOptions) {
				multiplayerOptions = [];
				
				addMultiplayerOption(
					"Bricks wide",
					{name: "2", BlocksWide: 2, EmptyColumn: false},
					{name: "1", BlocksWide: 1, EmptyColumn: false},
					{name: "2, separated", BlocksWide: 2, EmptyColumn: true}
				);
				
				addMultiplayerOption(
					"Bricks high",
					{name: "4", BlocksHigh: 4, GapBetweenBlocks: false},
					{name: "5", BlocksHigh: 5, GapBetweenBlocks: false},
					{name: "2, with gap", BlocksHigh: 2, GapBetweenBlocks: true},
					{name: "3", BlocksHigh: 3, GapBetweenBlocks: false}
				);
				
				addMultiplayerOption(
					"Gaps",
					{name: "none", GapAtEdges: false},
					{name: "at edges", GapAtEdges: true}
				);
				
				addMultiplayerOption(
					"Subgame brick layout",
					{name: "2x5", SubgameBlocksHigh: 5},
					{name: "2x6", SubgameBlocksHigh: 6},
					{name: "2x3", SubgameBlocksHigh: 3},
					{name: "2x4", SubgameBlocksHigh: 4}
				);
				
				addMultiplayerOption(
					"Paddle size",
					{name: "normal", LargeMainPaddle: false, LargeSubgamePaddle: false},
					{name: "large in subgames", LargeMainPaddle: false, LargeSubgamePaddle: true},
					{name: "large", LargeMainPaddle: true, LargeSubgamePaddle: true}
				);
				
				addMultiplayerOption(
					"Lives",
					{name: "0", ShieldCount: 0},
					{name: "1", ShieldCount: 1},
					{name: "2", ShieldCount: 2},
					{name: "3", ShieldCount: 3},
					{name: "4", ShieldCount: 4}
				);
				
				addMultiplayerOption(
					"Losing own ball",
					{name: "ignored", OwnBallsKill: false, OwnBallsStun: false},
					{name: "stuns for 0.25s", OwnBallsKill: false, OwnBallsStun: 15},
					{name: "stuns for 0.5s", OwnBallsKill: false, OwnBallsStun: 30},
					{name: "stuns for 0.75s", OwnBallsKill: false, OwnBallsStun: 45},
					{name: "game over", OwnBallsKill: true, OwnBallsStun: false}
				);
				
				addMultiplayerOption(
					"Color changing",
					{name: "never", ChangeColor: 0},
					{name: "in main game", ChangeColor: 1},
					{name: "in all games", ChangeColor: 2}
				);
			} else {
				for (i = 0; i < multiplayerOptions.length; i++) {
					option = multiplayerOptions[i];
					button = option.buttons[option.selected];
					
					add(button);
				}
			}
			
			var y:int = FP.height - title.y;
			
			for (i = multiplayerOptions.length - 1; i >= 0; i--) {
				option = multiplayerOptions[i];
				for each (button in option.buttons) {
					button.x = title.y;
					button.y = y - button.height;
				}
				
				y -= button.height + 2;
			}
			
			best.y = button.y;
		}
		
		public function addMultiplayerOption (name:String, ...choices):void
		{
			var optionID:int = multiplayerOptions.length;
			
			var buttons:Array = [];
			
			var button:Button;
			
			var i:int;
			
			for (i = 0; i < choices.length; i++) {
				var choice:* = choices[i];
				
				button = new Button(name + ": " + choice.name, 12, makeCallback(optionID, i));
				
				buttons.push(button);
			}
			
			var optionData:* = {
				buttons: buttons,
				params: choices
			};
			
			multiplayerOptions.push(optionData);
			
			button.callback();
		}
		
		public function makeCallback (optionID:int, choiceID:int):Function
		{
			return function ():void
			{
				var optionData:Object = multiplayerOptions[optionID];
				
				var buttons:Array = optionData.buttons;
				var selectedID:int = optionData.selected;
				
				activeMenu.remove(buttons[choiceID]);
				
				var nextChoiceID:int = (choiceID+1)%buttons.length;
				
				activeMenu.add(buttons[nextChoiceID]);
				
				optionData.selected = nextChoiceID;
				
				var params:Object = optionData.params[nextChoiceID];
				
				for (var param:String in params) {
					if (param == "name") continue;
					G["versus" + param] = params[param];
				}
			}
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
		
		public function goto1PMenu ():void
		{
			G.rootMenu = false;
			G.multiplayer = false;
			FP.world = new Menu;
		}
		
		public function goto2PMenu ():void
		{
			G.rootMenu = false;
			G.multiplayer = true;
			FP.world = new Menu;
		}
		
		public static function gotoRootMenu ():void
		{
			G.rootMenu = true;
			G.multiplayer = false;
			FP.world = new Menu;
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
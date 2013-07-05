package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Level extends World
	{
		public var renderTarget:BitmapData;
		
		public var bounds:Rectangle;
		public var colorTransform:ColorTransform;
		
		public var parent:Block;
		
		public var paddle:Paddle;
		public var paddleLeft:Paddle;
		public var paddleRight:Paddle;
		
		public var hasStarted:Boolean;
		
		public var won:Boolean;
		public var lost:Boolean;
		
		public var t:int = 0;
		public var lerp:Number = 0;
		
		public var extraRender:World;
		
		public function Level (_parent:Block = null)
		{
			parent = _parent;
			
			if (parent) {
				hasStarted = true;
			} else {
				Ball.lostCount = 0;
			}
			
			var w:int = parent ? parent.width - parent.border*2 : FP.width;
			var h:int = parent ? parent.height - parent.border*2 : FP.height;
			
			bounds = new Rectangle(0, 0, w, h);
			
			renderTarget = new BitmapData(bounds.width, bounds.height, (parent || G.multiplayer) ? true : false, 0);
			
			colorTransform = new ColorTransform(1, 1, 1, (parent && ! G.multiplayer) ? 0.9 : 0.85);
			
			if (G.multiplayer) {
				add(paddleLeft = new Paddle(this, 1));
				add(paddleRight = new Paddle(this, -1));
			} else {
				add(paddle = new Paddle(this));
			}
			
			var bw:int = parent ? 6 : 60;
			var bh:int = parent ? 3 : 32;
			
			var blocksWide:int = parent ? 5 : 8;
			var blocksHigh:int = parent ? 2 : 2;
			
			var spaceX:int = (w - bw*blocksWide)/(blocksWide+1);
			
			var spaceY:int = parent ? spaceX : 0;
			
			var startX:int = (w - bw*blocksWide - spaceX*(blocksWide+1))*0.5 + spaceX;
			var startY:int = parent ? spaceY : bh*1.5;
			
			if (G.multiplayer) {
				if (parent) {
					bh = Math.round(parent.height*0.1);
					bw = Math.floor(bh*0.5);
					
					blocksWide = 2;
					blocksHigh = 6;
					
					spaceY = (h - bh*blocksHigh)/(blocksHigh+1);
					spaceX = spaceY;
				} else {
					blocksWide = G.versusBlocksWide;
					blocksHigh = G.versusBlocksHigh;
					
					bh = h / blocksHigh;
					bw = bh*0.6;
					
					spaceY = 0;
					spaceX = G.versusEmptyColumn ? bw*1.5 : 0;
				}
					
				startX = w*0.5 - bw - spaceX*0.5;
				startY = (h - bh*blocksHigh - spaceY*(blocksHigh+1))*0.5 + spaceY;
			}
			
			for (var i:int = 0; i < blocksWide*blocksHigh; i++) {
				var block:Block = new Block(
					int(i%blocksWide)*(spaceX+bw) + startX,
					int(i/blocksWide)*(spaceY+bh) + startY,
					bw, bh, i%blocksWide, i/blocksWide, this);
				add(block);
			}
		}
		
		public override function update (): void
		{
			t++;
			
			if (paddle) {
				paddle.update();
			} else {
				paddleLeft.update();
				paddleRight.update();
			}
			
			super.update();
			
			updateLists();
			
			if (! parent && Input.pressed(Key.ESCAPE)) {
				FP.world = new Menu;
				return;
			}
			
			if (won || lost) {
				if (! parent && (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER) || Input.pressed(Key.R))) {
					newGame();
				}
				
				return;
			}
			
			if (classCount(Block) == 0 && ! G.multiplayer && ! parent) {
				won = true;
				
				doWon();
			}
			
			/*if (! parent && (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER) || Input.pressed(Key.R))) {
				won = true;
					doWon();
				}*/
			
			if (hasStarted && ! parent) {
				checkLost();
			}
			
			if (! hasStarted) {
				if ((G.mouseInput && ! G.multiplayer) ? Input.mousePressed : (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER))) {
					respawn();
					hasStarted = true;
				} else {
					return;
				}
			}
		}
		
		public function checkLost ():void
		{
			var b:Block;
			var blocks:Array = [];
			
			getType("block", blocks);
			
			if (G.multiplayer) {
				var leftLost:Boolean;
				var rightLost:Boolean;
				
				// Check if either side has scored
				
				var leftPaddleEdge:Number = paddleLeft.x;
				var rightPaddleEdge:Number = paddleRight.x + paddleRight.width;
				
				var ball:Ball;
				
				var leftBalls:Array = [];
				var rightBalls:Array = [];
				
				if (G.versusOwnBallsKill) {
					rightBalls = leftBalls;
				}
				
				getType("ball_left", leftBalls);
				getType("ball_right", rightBalls);
				
				for each (ball in leftBalls) {
					if (ball.x > bounds.width + ball.size) {
						rightLost = true;
						break;
					}
				}
				
				for each (ball in rightBalls) {
					if (ball.x < -ball.size) {
						leftLost = true;
						break;
					}
				}
				
				// Check if this is actually a tie
				
				if (leftLost) {
					for each (ball in leftBalls) {
						if (ball.x > rightPaddleEdge + ball.size) {
							rightLost = true;
							break;
						}
					}
				} else if (rightLost) {
					for each (ball in rightBalls) {
						if (ball.x < leftPaddleEdge - ball.size) {
							leftLost = true;
							break;
						}
					}
				}
				
				if (! leftLost && ! rightLost) {
					if (G.versusChangeColor) {
						// Check if both sides have lost all their balls
						leftLost = rightLost = ! hasAnyBalls(blocks);
					} else {
						// Check if either side has lost all their balls
						leftLost = ! hasBallsOfType("ball_left", blocks);
						rightLost = ! hasBallsOfType("ball_right", blocks);
						
						// Check if this is actually a tie
						if (leftLost) {
							cullBallsOfType("ball_right", blocks);
							rightLost = ! hasBallsOfType("ball_right", blocks);
						} else if (rightLost) {
							cullBallsOfType("ball_left", blocks);
							leftLost = ! hasBallsOfType("ball_left", blocks);
						}
					}
				}
				
				var leftText:Text;
				var rightText:Text;
				
				if (leftLost) {
					paddleLeft.lost = true;
					lost = true;
					
					for each (b in blocks) {
						if (b.subgame) {
							b.subgame.paddleLeft.lost = true;
						}
					}
					
					leftText = new Text(rightLost ? "TIE" : "LOSE", 0, 0, {size: 50, color: 0xFFFFFF});
				}
				
				if (rightLost) {
					paddleRight.lost = true;
					lost = true;
					
					for each (b in blocks) {
						if (b.subgame) {
							b.subgame.paddleRight.lost = true;
						}
					}
					
					rightText = new Text(leftLost ? "TIE" : "LOSE", 0, 0, {size: 50, color: 0x000000});
				}
				
				if (lost) {
					extraRender = new World;
					
					for each (b in blocks) {
						if (b.subgame) {
							b.subgame.lost = true;
						}
					}
					
					if (! leftText) {
						leftText = new Text("WIN", 0, 0, {size: 50, color: 0x000000});
					}
					
					if (! rightText) {
						rightText = new Text("WIN", 0, 0, {size: 50, color: 0xFFFFFF});
					}
					
					leftText.centerOO();
					rightText.centerOO();
					
					leftText.angle = -90;
					rightText.angle = 90;
					
					extraRender.addGraphic(leftText, 0, FP.width * 0.25, FP.height*0.5)
					extraRender.addGraphic(rightText, 0, FP.width * 0.75, FP.height*0.5)
					
					extraRender.updateLists();
				}
			} else if (! hasAnyBalls(blocks)) {
				lost = true;
				
				doLost();
			}
		}
		
		public function hasAnyBalls (blocks:Array):Boolean
		{
			if (classCount(Ball) > 0) {
				return true;
			}
			
			var b:Block;
			
			for each (b in blocks) {
				if (! b.subgame) continue;
				if (b.subgame.classCount(Ball) > 0) {
					return true;
				}
			}
			
			return false;
		}
		
		public function hasBallsOfType (type:String, blocks:Array):Boolean
		{
			if (typeCount(type) > 0) {
				return true;
			}
			
			var b:Block;
			
			for each (b in blocks) {
				if (! b.subgame) continue;
				if (b.subgame.typeCount(type) > 0) {
					return true;
				}
			}
			
			return false;
		}
		
		public function cullBallsOfType (type:String, blocks:Array):void
		{
			var balls:Array = [];
			var ball:Ball;
			
			var leftPaddleEdge:Number = paddleLeft.x;
			var rightPaddleEdge:Number = paddleRight.x + paddleRight.width;
			
			getType(type, balls);
			
			for each (ball in balls) {
				if (ball.x < leftPaddleEdge - ball.size || ball.x > rightPaddleEdge + ball.size) {
					remove(ball);
				}
			}
			
			updateLists();
			
			var b:Block;
			
			for each (b in blocks) {
				if (! b.subgame) continue;
				
				balls.length = 0;
				b.subgame.getType(type, balls);
				
				leftPaddleEdge = b.subgame.paddleLeft.x;
				rightPaddleEdge = b.subgame.paddleRight.x + b.subgame.paddleRight.width;
				
				for each (ball in balls) {
					if (ball.x < leftPaddleEdge - ball.size || ball.x > rightPaddleEdge + ball.size) {
						b.subgame.remove(ball);
					}
				}
				
				b.subgame.updateLists();
			}
		}
		
		public function doWon ():void
		{
			extraRender = new World;
			
			var tweenTime:int = 90;
			
			var balls:Array = [];
			
			getClass(Ball, balls);
			
			var i:int = 0;
			var b:Ball;
			
			for each (b in balls) {
				b.sortValue = Math.atan2(b.y - bounds.height*0.5, b.x - bounds.width*0.5);
			}
			
			FP.sortBy(balls, "sortValue");
			
			for (i = 0; i < balls.length; i++) {
				b = balls[i];
				b.bounceX = b.x;
				b.bounceY = b.y;
				b.showBounce = false;
				b.id = i;
			}
			
			var scoreData:Object = G.so.data.modes[G.mode];
			
			if (! scoreData.games) {
				scoreData.besttime = t;
				scoreData.bestballsleft = balls.length;
				scoreData.bestballslost = Ball.lostCount;
			}
			
			scoreData.games++;
			
			var isNewBestTime:Boolean = false;
			var isNewMostBalls:Boolean = false;
			
			if (t < scoreData.besttime) {
				scoreData.besttime = t;
				isNewBestTime = true;
			}
			if (balls.length > scoreData.bestballsleft) {
				scoreData.bestballsleft = balls.length;
				isNewMostBalls = true;
			}
			if (Ball.lostCount < scoreData.bestballslost) {
				scoreData.bestballslost = Ball.lostCount;
			}
			
			scoreData.totaltime += t;
			scoreData.totalballsleft += balls.length;
			scoreData.totalballslost += Ball.lostCount;
			
			G.so.flush();
			
			FP.tween(this, {lerp: 1}, tweenTime);
			
			FP.tween(paddle, {y: FP.height + 1}, tweenTime, {tweener: FP.tweener});
			
			var time:String = "";
			
			time += int(t / (60*60));
			time += ":";
			
			var seconds:int = int(t/60) % 60;
			
			if (seconds < 10) time += "0";
			time += seconds;
			
			var text:Text;
			
			var textOffset:Number = FP.height*0.02;
			
			text = new Text(time, 0, 0, {size: 50});
			text.x = textOffset;
			text.y = textOffset;
			text.alpha = 0;
			extraRender.addGraphic(text);
			FP.tween(text, {alpha:1}, 30, {delay:tweenTime});
			
			text = new Text("" + balls.length, 0, 0, {size: 50});
			text.x = FP.width - textOffset - text.width;
			text.y = textOffset;
			text.alpha = 0;
			extraRender.addGraphic(text);
			FP.tween(text, {alpha:1}, 30, {delay:tweenTime});
			
			var restart:Button = new Button("AGAIN", 50, newGame);
			
			restart.x = FP.width*0.5 - restart.width*0.5;
			restart.y = FP.height*0.5 - restart.height*0.5;
			restart.image.alpha = 0;
			FP.tween(restart.image, {alpha:1}, 30, {delay:tweenTime});
			
			add(restart);
			
			t = 0;
			
			FP.tween(this, {t: 0}, tweenTime);
			
			if (scoreData.games > 1) {
				time = "";
				
				time += int(scoreData.besttime / (60*60));
				time += ":";
				
				seconds = int(scoreData.besttime/60) % 60;
				
				if (seconds < 10) time += "0";
				time += seconds;
				
				var bestY:Number = text.y + text.height;
				
				var message:String;
				
				message = isNewBestTime ? "New best!" : "Best: " + time;
				text = new Text(message, 0, 0, {size: 18});
				text.x = textOffset;
				text.y = bestY;
				text.alpha = 0;
				extraRender.addGraphic(text);
				FP.tween(text, {alpha:1}, 30, {delay:tweenTime});
				
				message = isNewMostBalls ? "New best!" : "Best: " + scoreData.bestballsleft;
				text = new Text(message, 0, 0, {size: 18});
				text.x = FP.width - textOffset - text.width;
				text.y = bestY;
				text.alpha = 0;
				extraRender.addGraphic(text);
				FP.tween(text, {alpha:1}, 30, {delay:tweenTime});
			}
			
			extraRender.updateLists();
		}
		
		public function newGame ():void
		{
			FP.world = new Level;
		}
		
		public function doLost ():void
		{
			var restart:Button = new Button("AGAIN", 50, newGame);
			
			restart.x = FP.width*0.5 - restart.width*0.5;
			restart.y = FP.height*0.65 - restart.height*0.5;
			
			add(restart);
			
			var scoreData:Object = G.so.data.modes[G.mode];
			
			scoreData.gameslost += 1;
			
			var blocksRemoved:int = 16 - classCount(Block);
			
			var isNewBest:Boolean = false;
			
			if (scoreData.bestblocksremoved < blocksRemoved) {
				scoreData.bestblocksremoved = blocksRemoved;
				isNewBest = true;
			}
			
			if (! scoreData.games) {
				var best:Text = new Text("", 0, 0, {size: 18});
				
				if (scoreData.gameslost == 1) {
					best.text = blocksRemoved + " / 16";
				} else if (isNewBest) {
					best.text = "New best: " + blocksRemoved + " / 16";
				} else {
					best.text = blocksRemoved + " / 16 (Best: " + scoreData.bestblocksremoved + " / 16)";
				}
				
				restart.y = FP.height*0.6 - restart.height*0.5;
				
				best.x = FP.width*0.5 - best.width*0.5;
				best.y = restart.y + restart.height + (paddle.y - restart.y - restart.height)*0.5 - best.height*0.5;
				
				extraRender = new World;
				extraRender.addGraphic(best);
				extraRender.updateLists();
			}
			
			G.so.flush();
		}
		
		public function respawn ():void
		{
			t = 0;
			
			if (paddle) {
				paddle.spawnBall();
			} else {
				paddleLeft.spawnBall();
				paddleRight.spawnBall();
			}
			
			Audio.play("high", 0.5);
		}
		
		public override function render (): void
		{
			if (! parent && G.multiplayer) {
				FP.buffer.fillRect(FP.bounds, 0x708090);
			}
			
			var oldBuffer:BitmapData = FP.buffer;
			
			FP.buffer = renderTarget;
			
			if (! lost || ! G.multiplayer) renderTarget.colorTransform(bounds, colorTransform);
			
			Draw.setTarget(renderTarget, FP.zero);
			
			super.render();
			
			FP.buffer = oldBuffer;
			
			if (! parent) {
				FP.buffer.copyPixels(renderTarget, bounds, FP.zero);
				
				if (paddle) {
					paddle.render();
				} else {
					paddleLeft.render();
					paddleRight.render();
				}
			}
			
			if (extraRender) extraRender.render();
			
			if (! parent && Main.tint > 0.0) {
				var t:Number = Main.tint;
				if (t > 1) t = 1;
				var ct:ColorTransform = Main.tintTransform
				ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = -t*2 + 1;
				ct.redOffset = ct.greenOffset = ct.blueOffset = t*255;
				FP.buffer.colorTransform(FP.bounds, Main.tintTransform);
				
				Main.tint -= 0.1;
			}
		}
	}
}


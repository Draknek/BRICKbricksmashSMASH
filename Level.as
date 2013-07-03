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
			
			renderTarget = new BitmapData(bounds.width, bounds.height, parent ? true : false, 0);
			
			colorTransform = new ColorTransform(1, 1, 1, parent ? 0.9 : 0.85);
			
			paddle = new Paddle(this);
			add(paddle);
			
			var bw:int = parent ? 6 : 60;
			var bh:int = parent ? 3 : 32;
			
			var blocksWide:int = parent ? 5 : 8;
			var blocksHigh:int = parent ? 2 : 2;
			
			var spaceX:int = (w - bw*blocksWide)/(blocksWide+1);
			
			var spaceY:int = parent ? spaceX : 0;
			
			var startX:int = (w - bw*blocksWide - spaceX*(blocksWide+1))*0.5 + spaceX;
			var startY:int = parent ? spaceY : bh*1.5;
			
			for (var i:int = 0; i < blocksWide*blocksHigh; i++) {
				var block:Block = new Block(
					int(i%blocksWide)*(spaceX+bw) + startX,
					int(i/blocksWide)*(spaceY+bh) + startY,
					bw, bh, i%blocksWide, i/blocksWide, parent ? false : true);
				add(block);
			}
		}
		
		public override function update (): void
		{
			t++;
			
			paddle.update();
			
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
			
			if (classCount(Block) == 0) {
				if (! parent) {
					won = true;
					
					doWon();
				} else {
					paddle.y += 0.1;
				}
			}
			
			/*if (! parent && (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER) || Input.pressed(Key.R))) {
				won = true;
					doWon();
				}*/
			
			if (hasStarted && ! parent && classCount(Ball) == 0) {
				var blocks:Array = [];
				
				getType("block", blocks);
				
				lost = true;
				
				for each (var b:Block in blocks) {
					if (b.subgame && b.subgame.classCount(Ball) != 0) {
						lost = false;
						break;
					}
				}
				
				if (lost) doLost();
			}
			
			if (! hasStarted) {
				if (G.mouseInput ? Input.mousePressed : (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER))) {
					respawn();
					hasStarted = true;
				} else {
					return;
				}
			}
		}
		
		public function doWon ():void
		{
			extraRender = new World;
			
			var tweenTime:int = 90;
			
			var balls:Array = [];
			
			getType("ball", balls);
			
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
			
			if (t < scoreData.besttime) scoreData.besttime = t;
			if (balls.length > scoreData.bestballsleft) scoreData.bestballsleft = balls.length;
			if (Ball.lostCount < scoreData.bestballslost) scoreData.bestballslost = Ball.lostCount;
			
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
				
				text = new Text("Best: " + time, 0, 0, {size: 18});
				text.x = textOffset;
				text.y = bestY;
				text.alpha = 0;
				extraRender.addGraphic(text);
				FP.tween(text, {alpha:1}, 30, {delay:tweenTime});
				
				text = new Text("Best: " + scoreData.bestballsleft, 0, 0, {size: 18});
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
			
			if (scoreData.bestblocksremoved < blocksRemoved) {
				scoreData.bestblocksremoved = blocksRemoved;
			}
			
			G.so.flush();
		}
		
		public function respawn ():void
		{
			t = 0;
			
			var vx:Number = 1.5 + Math.random()*0.5;
			var vy:Number = -1.5 - Math.random()*0.5;
			
			if (paddle.vx < -0.5) {
				vx *= -1;
			} else if (paddle.vx < 0.5) {
				if (paddle.x + paddle.width*0.5 < bounds.width*0.4) {
					vx *= -1;
				} else if (paddle.x + paddle.width*0.5 < bounds.width*0.6) {
					if (Math.random() < 0.5) {
						vx *= -1;
					}
				}
			}
			
			add(new Ball(paddle.x + paddle.width*0.5, paddle.y - 3, vx, vy));
			
			Audio.play("high", 0.5);
		}
		
		public override function render (): void
		{
			var oldBuffer:BitmapData = FP.buffer;
			
			FP.buffer = renderTarget;
			
			renderTarget.colorTransform(bounds, colorTransform);
			
			Draw.setTarget(renderTarget, FP.zero);
			
			super.render();
			
			FP.buffer = oldBuffer;
			
			if (! parent) {
				FP.buffer.copyPixels(renderTarget, bounds, FP.zero);
				paddle.render();
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


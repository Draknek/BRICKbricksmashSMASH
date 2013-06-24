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
		public var ball:Ball;
		
		public var renderTarget:BitmapData;
		
		public var bounds:Rectangle;
		public var colorTransform:ColorTransform;
		
		public function Level ()
		{
			bounds = new Rectangle(0, 0, FP.width, FP.height);
			
			renderTarget = new BitmapData(bounds.width, bounds.height, false, 0);
			
			colorTransform = new ColorTransform(1, 1, 1, 0.8);
			
			ball = new Ball(FP.width*0.5, FP.height - 10, -5, 5);
			
			add(ball);
		}
		
		public override function update (): void
		{
			super.update();
		}
		
		public override function render (): void
		{
			var oldBuffer:BitmapData = FP.buffer;
			
			FP.buffer = renderTarget;
			
			renderTarget.colorTransform(bounds, colorTransform);
			
			super.render();
			
			FP.buffer = oldBuffer;
			
			FP.buffer.copyPixels(renderTarget, bounds, FP.zero);
		}
	}
}


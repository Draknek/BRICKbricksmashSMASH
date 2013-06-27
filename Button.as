package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Button extends Entity
	{
		public var image:Image;
		
		public var callback:Function;
		
		public function Button (text:String, size:Number, _callback:Function)
		{
			image = new Text(text, 0, 0, {size: size});
			
			graphic = image;
			
			setHitbox(image.width, image.height);
			
			type = "button";
			
			layer = 10;
			
			callback = _callback;
		}
		
		public override function update (): void
		{
			if (!world || !collidable || image.alpha == 0) {
				image.color = 0xFFFFFF;
				return;
			}
			
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			
			if (over) {
				Input.mouseCursor = "button";
			}
			
			image.color = over ? 0x000000 : 0xFFFFFF;
			
			if (over && Input.mousePressed && callback != null) {
				callback();
			}
		}
		
		public override function render (): void
		{
			if (image.color != 0xFFFFFF) {
				Draw.setTarget(FP.buffer, FP.zero);
				Draw.rectPlus(x, y, width, height, 0xFFFFFF, 1, true, 0, height*0.4);
			}
			
			super.render();
		}
	}
}


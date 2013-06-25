package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	public class Main extends Engine
	{
		[Embed(source = 'fonts/orbitron-medium.ttf', embedAsCFF="false", fontFamily = 'orbitron')]
		public static const FONT:Class;
		
		public function Main () 
		{
			G.init();
			
			super(480, 320, 60, true);
			
			Text.font = 'orbitron';
			
			FP.world = new Menu();
			
			FP.screen.color = 0x0;
		}
		
		public override function init (): void
		{
			super.init();
		}
		
		public override function update (): void
		{
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				FP.console.enable();
			}
			
			super.update();
		}
	}
}


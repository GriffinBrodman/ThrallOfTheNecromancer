package ;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

/**
 * ...
 * @author Potato Studios
 */
class Human extends FlxSprite
{
		//[Embed(source = "data/fishes.png")] protected var ImgThing:Class;
		public static var distanceStart:Int = 5;
		public function new() 
		{
			
			super(0, 0);
			makeGraphic(10, 10, FlxColor.YELLOW);
			/*
			loadGraphic(ImgThing, true, true, 22, 18);
			
			
			var side:Number;
			debug = new FlxText(0, 0, 500);
			debug.text = "" + width*scale.x;
			addAnimation("walking", [30,31,32,33,34,35,36], 8, true);
			addAnimation("idle", [30]);
			
			play("walking");
			*/
		}

		override public function destroy():Void
		{
			super.destroy();
		}
		
		override public function update():Void
		{
			
			if (FlxG.keys.justPressed.W)
			{
			this.y-=5;
			}
			
			else if (FlxG.keys.justPressed.S)
			{
			this.y+=5;
			}
			else if (FlxG.keys.justPressed.A)
			{
			this.x-=5;
			}
			else if (FlxG.keys.justPressed.D)
			{
			this.x+=5;
			}
			
		}
		
	}

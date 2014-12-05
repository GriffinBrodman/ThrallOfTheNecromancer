package characters ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;
import flixel.group.FlxGroup;
import states.PlayState;

class SnakeBody extends FlxSprite
{

	var next:FlxSprite; //Sprite to follow
	var sizeOfBuffer:Int; //numFrames to be delayed
	
	//Position to take on
	var prevPos:Array<FlxPoint>;
	var nextPos:Int;
	
	
	
	public function new(p:FlxSprite, type:Int)
	{
		super(p.x, p.y);

		if (type == 0) loadGraphic("assets/images/subhead1.png", true, 256, 256);
		else if (type == 1) loadGraphic("assets/images/subhead2.png", true, 256, 256);
		else if (type == 2) loadGraphic("assets/images/body1.png", true, 256, 256);
		else if (type == PlayState.NUM_SNAKE_PARTS - 2) loadGraphic("assets/images/tail1.png", true, 256, 256);
		else if (type == PlayState.NUM_SNAKE_PARTS - 1) loadGraphic("assets/images/tail2.png", true, 256, 256);
		else loadGraphic("assets/images/body2.png", true, 256, 256);
		scale = new FlxPoint(.125, .125); // 1/8 the size
		setSize(32, 32);
		offset = new FlxPoint(112, 112);

		next = p;//Save the thing to follow
		sizeOfBuffer = 5;
				
		prevPos = new Array<FlxPoint>();
		for (i in 0...sizeOfBuffer) 
		{
			prevPos[i] = new FlxPoint(p.x, p.y); //Start at position of parent
		}
		nextPos = 0;
		
		
	}

	private function movement():Void
	{
		angle = FlxAngle.angleBetween(this, next, true) + 90;
		
		var pozz = new FlxPoint(next.x, next.y); //I'm not changing this either Mark
		setPosition(prevPos[nextPos].x, prevPos[nextPos].y);
		prevPos[nextPos] = pozz;
		nextPos++;
		nextPos = nextPos % sizeOfBuffer;
		
	}	

	override public function update():Void
	{
		movement();
		super.update();
	}

	

	override public function destroy():Void
	{
		super.destroy();
	}
}

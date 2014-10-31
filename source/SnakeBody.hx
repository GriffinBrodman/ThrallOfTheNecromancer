package;

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

class SnakeBody extends FlxSprite
{

	var next:FlxSprite;
	var prevAng:Array<Float>;
	var nextAng:Int;
	var sizeOfBuffer:Int;
	
	var prevPos:Array<FlxPoint>;
	var nextPos:Int;
	
	
	
	public function new(p:FlxSprite, type:Int)
	{
		super(p.x, p.y);

		if (type == 1) loadGraphic("assets/images/subhead1.png", true, 256, 256);
		else if (type == 2) loadGraphic("assets/images/subhead2.png", true, 256, 256);
		else if (type == 3) loadGraphic("assets/images/body1.png", true, 256, 256);
		else if (type == 4) loadGraphic("assets/images/body2.png", true, 256, 256);
		else if (type == 5) loadGraphic("assets/images/tail1.png", true, 256, 256);
		else loadGraphic("assets/images/tail2.png", true, 256, 256);
		scale = new FlxPoint(.125, .125);
		setSize(32, 32);
		offset = new FlxPoint(112, 112);

		next = p;
		prevAng = new Array<Float>();
		sizeOfBuffer = 16;
		for (i in 0...sizeOfBuffer) 
		{
			prevAng[i] = 0;
		}
		nextAng = 0;
		
		prevPos = new Array<FlxPoint>();
		for (i in 0...sizeOfBuffer) 
		{
			prevPos[i] = new FlxPoint(p.x, p.y);
		}
		nextPos = 0;
		
		
	}

	private function movement():Void
	{
		var ang = next.angle;
		angle = prevAng[nextAng];
		prevAng[nextAng] = ang;
		nextAng++;
		nextAng = nextAng % sizeOfBuffer;
		
		var pozz = new FlxPoint(next.x, next.y);
		setPosition(prevPos[nextPos].x, prevPos[nextPos].y);
		prevPos[nextPos] = pozz;
		nextPos++;
		nextPos = nextPos % sizeOfBuffer;
		
		
		/*
		var currAng = angle;
		currAng += 90;
		setPosition(next.x + 22* Math.cos(currAng * Math.PI / 180), next.y + 22* Math.sin(currAng * Math.PI / 180));
		*/
		
		
		
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

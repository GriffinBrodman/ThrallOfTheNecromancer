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

class SnakeBody extends FlxSprite
{

	var next:Player;
	
	
	
	public function new(p:Player)
	{
		super(p.x, p.y);

		loadGraphic("assets/images/body1.png", true, 256, 256);
		scale = new FlxPoint(.125, .125);
		setSize(32, 32);
		offset = new FlxPoint(112, 112);

		next = p;
	}

	private function movement():Void
	{
		var ang = next.angle;
		angle = ang;
		ang += 90;
		setPosition(next.x + 32* Math.cos(ang * Math.PI / 180), next.y + 32* Math.sin(ang * Math.PI / 180)); 
		
		
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

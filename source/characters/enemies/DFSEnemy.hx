package characters.enemies;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVelocity;
using flixel.util.FlxSpriteUtil;
import entities.Exit;

class DFSEnemy extends Enemy
{


	override public function new(X:Float=0, Y:Float=0, walls:FlxTilemap, ground:FlxTilemap) 
	{
		super(X,Y, walls, ground);
		speed = 65;		
		scared = false;
		pathing= false;
		state = "idle";
		scaredTime = 0;
	}
	
	//public function DFS():Array<FlxPoint>
	//{
		
	//}
	
	override public function update():Void 
	{
		super.update();
	}
	
	override public function idle():Void
	{
		super.idle();
	}
	
	override public function chase():Void
	{
		super.chase();
	}	
		
	override public function inLOS(x:Float, y:Float):Bool
	{
		return super.inLOS(x,y);
	}
	
	override public function draw():Void 
	{
		super.draw();
	}
	
	override public function stun(duration:Int) 
	{
		super.stun(duration);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
}

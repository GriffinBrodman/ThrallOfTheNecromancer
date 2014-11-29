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

class DFSEnemy implements Enemy
{
	public var speed:Int = 65;		
	public var scared:Bool = false;
	public var pathing:Bool = false;
	public var snakePos(default, null):FlxPoint;
	private var stunDuration:Int;
	private var path:FlxPath;
	private var endPoint:FlxPoint;
	private var goals:FlxTypedGroup<Exit>;
	private var walls:FlxTilemap;
	public var state:String = "idle";
	private var fleeingTime:Int = 0;
	private var scaredTime:Int = 0;
	public var minimapDot:FlxSprite;	// Reference to dot on minimap to blink when necessary; Used by minimap
	public var minimapDotTweening:Bool;

	override public function new(X:Float=0, Y:Float=0, map:FlxTilemap) 
	{
		super(X,Y,map);
	}
	
	public function DFS():Array<FlxPoint>
	
	override public function update():Void 
	{
		super.update();
	}
	
	public function idle():Void
	{
		super.idle();
	}
	
	public function chase():Void
	{
		super.chase();
	}	
		
	public function inLOS(player:FlxSprite):Bool
	{
		super.inLOS();
	}
	
	override public function draw():Void 
	{
		super.draw();
	}
	
	public function stun(duration:Int) 
	{
		super.stun;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
}

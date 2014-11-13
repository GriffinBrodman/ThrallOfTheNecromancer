package characters ;

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

class Enemy extends FlxSprite
{
	public var speed:Int = 65; 		//TODO MAKE CONSTANT
	public var etype(default, null):Int;
	private var _idleTmr:Float;
	private var _moveDir:Float;
	public var seesPlayer:Bool = false;
	public var pathing:Bool = false;
	public var playerPos(default, null):FlxPoint;
	private var stunDuration:Int;
	private var path:FlxPath;
	private var endPoint:FlxPoint;
	private var goals:FlxTypedGroup<Exit>;
	private var walls:FlxTilemap;
	public var state:String = "idle";
	private var fleeingTime:Int = 0;
	private var scaredTime:Int = 0;
	
	public function new(X:Float=0, Y:Float=0, m:FlxTilemap) 
	{
		super(X, Y);
		if(Std.random(2) == 0)
		{
			loadGraphic(AssetPaths.walkinganimation1__png, true, 32, 32);
			width = 20;
			height = 30;
			offset.x = 6;
			offset.y = 2;
		}
		else
		{
			loadGraphic(AssetPaths.greenjacket__png, true, 32, 32);
			width = 21;
			height = 32;
			offset.x = 4;
			offset.y = 0;
		}
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		drag.x = drag.y = 10;
		width = 20;
		height = 30;
		offset.x = 6;
		offset.y = 2;
		
		_idleTmr = 0;
		playerPos = FlxPoint.get();
		
		walls = m;
		path = new FlxPath();
		
	}
	
	private function updateCooldowns() {
		if (stunDuration > 0)
			stunDuration--;
		if (fleeingTime > 0)
		{
			fleeingTime--;
			if (fleeingTime == 0) speed -=30;
		}
			
	}
	
	public function setGoal(goal:FlxTypedGroup<Exit>) {
		goals = goal;
		endPoint = (goals.getRandom()).getMidpoint();
	}
	
	override public function update():Void 
	{
		if (isFlickering())
			return;
		if (state == "idle") idle();
		if (state == "chase") chase();
		
		updateCooldowns();
		
		super.update();
		
		if (stunDuration > 0)
			this.setColorTransform(3, 3, 1);
		else if (seesPlayer)
			this.setColorTransform(3, 1, 1);
		else
			this.setColorTransform(1, 1, 1);
	}
	
	public function idle():Void
	{
		if (seesPlayer)
		{
			path.cancel();
			pathing = false;
			state = "chase";
			fleeingTime = 50;
			speed += 30;
		}
		else 
		{
			if (path.finished)
			{
				path.cancel();
				pathing = false;
			}
			else if (stunDuration > 0)
			{
				path.cancel();
				pathing = false;
			}
			
			if (!pathing) {
				var newEnd:FlxPoint = goals.getRandom().getMidpoint();
				while (newEnd == endPoint) newEnd = goals.getRandom().getMidpoint();
				endPoint = newEnd;
				var pathPoints:Array<FlxPoint> = walls.findPath(getMidpoint(), endPoint);
				if (pathPoints != null && !pathing) 
				{
					pathing = true;
					path.start(this,pathPoints, speed);
				}
			}
		}
	}
	
	public function chase():Void
	{
		if (fleeingTime == 0)
		{
			state = "idle";
		}

		else 
		{
			if (stunDuration > 0)
			{
				path.cancel();
				pathing = false;
			}
			else if (pathing == false ) {
				var newEnd:FlxPoint = goals.getRandom().getMidpoint();
				while (newEnd == endPoint) newEnd = goals.getRandom().getMidpoint();
				endPoint = newEnd;
				var pathPoints:Array<FlxPoint> = walls.findPath(getMidpoint(), endPoint);
				if (pathPoints != null && !pathing) 
				{
					pathing = true;
					path.start(this,pathPoints, speed);
				}
			}
		
		}
	}
	
		
	public function canSee(player:FlxSprite):Bool
	{
		if (this.facing == FlxObject.LEFT)
		return player.x < this.x;
		if (this.facing == FlxObject.RIGHT)
		return player.x > this.x;
		if (this.facing == FlxObject.UP)
		return player.y < this.y;
		else
		return player.y > this.y;
	}
	
	override public function draw():Void 
	{
		if ((velocity.x != 0 || velocity.y != 0) )
		{
			
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
					facing = FlxObject.LEFT;
				else
					facing = FlxObject.RIGHT;
			}
			else
			{
				if (velocity.y < 0)
					facing = FlxObject.UP;
				else
					facing = FlxObject.DOWN;
			}
			
			switch(facing)
			{
				case FlxObject.LEFT, FlxObject.RIGHT:
					//animation.play("lr");
					
				case FlxObject.UP:
					//animation.play("u");
					
				case FlxObject.DOWN:
					//animation.play("d");
			}
		}
			
		super.draw();
	}
	
	public function stopAndStun(stunDuration:Int) {
		this.velocity.x = 0;
		this.velocity.y = 0;
		stun(stunDuration);
	}
	
	public function stun(stunDuration:Int) {
		this.stunDuration = stunDuration;
	}
	
	override public function destroy():Void 
	{
		if (pathing){
			path.cancel();
			FlxDestroyUtil.destroy(path);
			pathing = false;
		}
		super.destroy();
		
	}
}
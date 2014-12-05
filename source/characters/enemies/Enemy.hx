package characters.enemies ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
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
	public var speed:Int; 		
	public var scared:Bool;
	public var pathing:Bool;
	public var snakePos(default, null):FlxPoint;

	private var path:FlxPath;
	private var endPoint:FlxPoint;
	private var goals:FlxTypedGroup<Exit>;
	private var walls:FlxTilemap;
	private var ground:FlxTilemap;
	public var state:String;
	
	private var stunDuration:Int;
	private var fleeingTime:Int;
	private var scaredTime:Int;
	
	public var minimapDot:FlxSprite;	// Reference to dot on minimap to blink when necessary; Used by minimap
	public var minimapDotTweening:Bool;
	
	private var oldFacing:Int;
	
	public var debug:FlxText = new FlxText();
	
	public function new(X:Float=0, Y:Float=0, map:FlxTilemap, ground:FlxTilemap)
	{
		super(X, Y);

			loadGraphic(AssetPaths.walkinganimation1__png, true, 32, 32);
			width = 20;
			height = 30;
			offset.x = 6;
			offset.y = 2;
			animation.add("run", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 8, true);
			animation.add("lr", [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21], 8, true);
			animation.play("run", true);
		
		setFacingFlip(FlxObject.UP, false, true);
		drag.x = drag.y = 10;
		width = 20;
		height = 30;
		offset.x = 6;
		offset.y = 2;
		
		snakePos = FlxPoint.get();
		
		walls = map;
		path = new FlxPath();
	}
	
	public function updateCooldowns() 
	{
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
		{
			return;
		}
		if (state == "idle") 
		{
			idle();
		}
		if (state == "chase") 
		{
			chase();
		}
		
		updateCooldowns();
		
		super.update();
		
		if (stunDuration > 0)
			this.setColorTransform(3, 3, 1);
		else if (scared)
			this.setColorTransform(3, 1, 1);
		else
			this.setColorTransform(1, 1, 1);
	}
	
	public function idle():Void
	{
		if (scared)
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
			else if (pathing == false ) 
			{
				var newEnd:FlxPoint = goals.getRandom().getMidpoint();
				while (newEnd == endPoint) 
				{
					newEnd = goals.getRandom().getMidpoint();
				}
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
	
		
	public function inLOS(X:Float, Y:Float):Bool
	{
		if (this.facing == FlxObject.LEFT)
		{
			return X < this.x;
		}
		if (this.facing == FlxObject.RIGHT)
		{
			return X > this.x;
		}
		if (this.facing == FlxObject.UP)
		{
			return Y < this.y;
		}
		else
		{
			return Y > this.y;
		}
	}
	
	override public function draw():Void 
	{
		oldFacing = facing;
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
				case FlxObject.LEFT:
					if (facing != oldFacing)
					{
						animation.pause();
						animation.play("lr");
						trace("left");
					}
				case FlxObject.RIGHT:
					if (facing != oldFacing)
					{
						animation.pause();
						animation.play("lr");
						trace("right");
					}
				case FlxObject.UP:
					if (facing != oldFacing)
					{
						animation.pause();
						animation.play("run");
						trace("up");
					}
				case FlxObject.DOWN:	
					if (facing != oldFacing)
					{
						animation.pause();
						animation.play("run");
						trace("down");
					}

			}
		}
			
		super.draw();
	}
	
	public function stun(duration:Int) {
		this.velocity.x = 0;
		this.velocity.y = 0;
		this.stunDuration = duration;
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
	
	public function tileType(map:FlxTilemap,X:Float, Y:Float):Int 
	{
		return map.getTile(Std.int(X/128), Std.int(Y /128.0));
	}
	
	public function getNeighborTiles(map:FlxTilemap, X:Float, Y:Float):Array<FlxPoint> 
	{
		var neighbors = new Array<FlxPoint>();
		if (tileType(map, X, Y + 1) == 0) 
		{
			var n1 =  new FlxPoint(X, Y + 1);
			neighbors.push(n1);
		}
		if (tileType(map, X, Y - 1) == 0) 
		{
			var n2 =  new FlxPoint(X, Y - 1);
			neighbors.push(n2);
		}
		if (tileType(map, X + 1, Y) == 0) 
		{
			var n3 =  new FlxPoint(X + 1, Y);
			neighbors.push(n3);
		}
		if (tileType(map, X - 1, Y) == 0) 
		{
			var n4 =  new FlxPoint(X - 1, Y);
			neighbors.push(n4);
		}
		return neighbors;
	}
	
}
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
import haxe.ds.IntMap;
using flixel.util.FlxSpriteUtil;
import entities.Exit;

class Enemy extends FlxSprite
{
	public static var exits:IntMap<Bool>;
	
	private var normalSpeed:Int;
	private var scaredSpeed:Int;
	private var curSpeed:Int;
	public var scared:Bool;
	public var pathing:Bool;
	public var snakePos(default, null):FlxPoint;

	private var currentTile:FlxPoint;	
	private var pathArray:Array<FlxPoint>;	//Stores the enemy path
	
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

		var type:Int = FlxRandom.int() % 4;
		if (type == 0) loadGraphic(AssetPaths.walkinganimation1__png, true, 64, 64);
		else if (type == 1) loadGraphic(AssetPaths.walkinganimation2__png, true, 64, 64);
		else if (type == 2) loadGraphic(AssetPaths.walkinganimation3__png, true, 64, 64);
		else if (type == 3) loadGraphic(AssetPaths.walkinganimation4__png, true, 64, 64);
		width = 20;
		height = 30;
		offset.x = 6;
		offset.y = 1;
		animation.add("run", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 8, true);
		animation.add("lr", [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21], 8, true);
		animation.play("run", true);
		
		setFacingFlip(FlxObject.DOWN, false, false);
		setFacingFlip(FlxObject.UP, false, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, true);
		drag.x = drag.y = 10;
		curSpeed = normalSpeed;
		
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
			if (fleeingTime == 0){
				curSpeed = normalSpeed;
				path.speed = normalSpeed;
			}
		}			
	}
	
	public function setGoal(goal:FlxTypedGroup<Exit>) {
		goals = goal;
		endPoint = (goals.getRandom()).getMidpoint();
	}
	
	override public function update():Void 
	{
		updateCurrentTile();
		if (isFlickering())
		{
			return;
		}
		if (state == "idle") 
		{
			idle();
		}
		if (state == "fleeing") 
		{
			fleeing();
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
			state = "fleeing";
			fleeingTime = 50;
			curSpeed = scaredSpeed;
			path.speed = scaredSpeed;
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
					path.start(this,pathPoints, curSpeed);
				}
			}
		}
	}
	
	public function fleeing():Void
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
					path.start(this,pathPoints, curSpeed);
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
		if (Math.abs(velocity.x) > Math.abs(velocity.y))
		{
			if (velocity.x < 0)
				facing = FlxObject.LEFT;
			else
				facing = FlxObject.RIGHT;
		}
		else if (Math.abs(velocity.x) < Math.abs(velocity.y))
		{
			if (velocity.y < 0)
				facing = FlxObject.UP;
			else
				facing = FlxObject.DOWN;
		}
		else {
			facing = FlxObject.NONE;
		}
		
		if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT)
		{
			animation.play("lr");
		} 
		else if (facing == FlxObject.DOWN || facing == FlxObject.UP)
		{
			animation.play("run");
		}
		else
		{
			animation.pause();
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
	
	
	public function updateCurrentTile():Void 
	{
		currentTile = new FlxPoint(Std.int(this.x/128), Std.int(this.y/128.0));
	}
	
	//Returns the type of the tile at the given tile (not world) coordinates
	public function tileType(map:FlxTilemap,X:Float, Y:Float):Int 
	{
		return map.getTile(Std.int(X/128), Std.int(Y /128.0));
	}
	
	//Takes in a tilemap and tile coordinates; Returns an array of all the pathable neighbor tiles
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
	
	private function isExit(location:FlxPoint):Bool {
		if (exits == null){
			trace("exits has not been initialized yet");
			return false;
		}
		else {
			var val:Null<Bool> = exits.get(Std.int(location.x + location.y * walls.widthInTiles));
			return val == true;
		}
		
	}
	
}
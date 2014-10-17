package;

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
	public var speed:Int = FlxRandom.intRanged(40, 60);
	public var etype(default, null):Int;
	private var _idleTmr:Float;
	private var _moveDir:Float;
	public var seesPlayer:Bool = false;
	public var pathing:Bool = false;
	public var isTriedLured:Bool = false;
	public var isLured:Bool = false;
	public var playerPos(default, null):FlxPoint;
	private var _sndStep:FlxSound;
	private var stunDuration:Int;
	private var path:FlxPath;
	private var endPoint:FlxPoint;
	private var goals:FlxTypedGroup<Exit>;
	private var map:FlxTilemap;
	private var state:String = "idle";
	private var fleeingTime:Int = 0;
	
	public function new(X:Float=0, Y:Float=0, m:FlxTilemap) 
	{
		super(X, Y);
		loadGraphic("assets/images/player.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		drag.x = drag.y = 10;
		width = 8;
		height = 14;
		offset.x = 4;
		offset.y = 2;
		
		_idleTmr = 0;
		playerPos = FlxPoint.get();
		
		_sndStep = FlxG.sound.load(AssetPaths.step__wav,.4);
		_sndStep.proximity(x, y, FlxG.camera.target, FlxG.width * .6);
		
		map = m;
		path = new FlxPath();
		
	}
	
	private function updateCooldowns() {
		if (stunDuration > 0)
			stunDuration--;
		if (fleeingTime > 0)
			fleeingTime--;
	}
	
	public function setGoal(goal:FlxTypedGroup<Exit>) {
		goals = goal;
		endPoint = (goals.getRandom()).getMidpoint();
	}
	
	override public function update():Void 
	{
		if (isFlickering())
			return;
		super.update();
		if (state == "idle") idle();
		if (state == "chase") chase();
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
		{
			_sndStep.setPosition(x + _halfWidth, y + height);
			_sndStep.play();
		}
		updateCooldowns();
	}
	
	public function idle():Void
	{
		
		if (seesPlayer)
		{
			isLured = false;
			path.cancel();
			pathing = false;
			state = "chase";
			fleeingTime = 1;
		}
		else 
		{
			if (stunDuration > 0)
			{
				isLured = false;
				path.cancel();
				pathing = false;
			}
			else if (!pathing) {
				var newEnd:FlxPoint = goals.getRandom().getMidpoint();
				while (newEnd == endPoint) newEnd = goals.getRandom().getMidpoint();
				endPoint = goals.getRandom().getMidpoint();
				var pathPoints:Array<FlxPoint> = map.findPath(getMidpoint(), endPoint);
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
		if (stunDuration > 0)
			return;
		if (fleeingTime == 0)
		{
			state = "idle";
		}
		/*else if (Player.luring)
		{
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
		}*/
		else 
		{
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int( -speed));
		}
	}
	
		
	public function canSee(player:Player):Bool
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
					animation.play("lr");
					
				case FlxObject.UP:
					animation.play("u");
					
				case FlxObject.DOWN:
					animation.play("d");
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
	
	public function lure(x:Float, y:Float, range:Int):Void {
		if (isLured)
			return;

		isTriedLured = true;
		var lured:Bool = FlxMath.isDistanceToPointWithin(this, new FlxPoint(x, y), range);
		if (!isTriedLured)
			lured = lured || Math.random() < 0.5;
		if (lured) {
			isLured = true;
			var pathPoints:Array<FlxPoint> = map.findPath(this.getMidpoint(), new FlxPoint(x, y));
			if (pathPoints != null) {
				path.cancel();
				path.start(this, pathPoints, speed);
			}
		}
	}
	
	public function unlure() {
		isLured = false;
		path.cancel();
		pathing = false;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}
}
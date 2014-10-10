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

class Enemy extends FlxSprite
{
	public var speed:Int = FlxRandom.intRanged(40, 60);
	public var etype(default, null):Int;
	private var _brain:FSM;
	private var _idleTmr:Float;
	private var _moveDir:Float;
	public var seesPlayer:Bool = false;
	public var pathing:Bool = false;
	public var isLured:Bool = false;
	public var playerPos(default, null):FlxPoint;
	private var _sndStep:FlxSound;
	private var stunDuration:Int;
	private var path:FlxPath;
	private var endPoint:FlxPoint;
	private var map:FlxTilemap;
	private var trapped:Bool = false;
	private var helping:Bool = false;
	public var party:FlxTypedGroup<Enemy>;
	
	public function new(X:Float=0, Y:Float=0, EType:Int, m:FlxTilemap) 
	{
		super(X, Y);
		etype = EType;
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
		_brain = new FSM(idle);
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
	}
	
	public function setGoal(end:FlxPoint) {
		endPoint = end;
		

	}
	
	override public function update():Void 
	{
		if (isFlickering())
			return;
		super.update();
		_brain.update();
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
		{
			_sndStep.setPosition(x + _halfWidth, y + height);
			_sndStep.play();
		}
		updateCooldowns();
	}
	
	public function idle():Void
	{
		if (trapped) return;
		if (helpComrade())
		{
			if (!helping)
			{
				helping = true;
				pathing = false;
				path.cancel();
			}
			if (stunDuration > 0)
			{
			path.cancel();
			pathing = false;
			return;
			}
			var trappedGuy = getTrappedComrade();
			var pathPoints:Array<FlxPoint> = map.findPath(getMidpoint(), trappedGuy.getMidpoint());
			if (pathPoints != null && !pathing) 
			{
				path.cancel();
				pathing = true;
				path.start(this,pathPoints, speed);
			}
			
			if (path.finished)
			{
				path.cancel();
				pathing = false;
				trappedGuy.trapped = false;
			}
			
			
			return;
		}
		if (helping)
		{
			helping = false;
			path.cancel();
			pathing = false;
		}
		if (seesPlayer)
		{
			path.cancel();
			pathing = false;
			_brain.activeState = chase;
		}
		else 
		{
			if (stunDuration > 0)
			{
				path.cancel();
				pathing = false;
			}
			else if (!pathing){
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
		if (trapped) return;
		if (stunDuration > 0)
			return;
		
		if (!seesPlayer)
		{
			_brain.activeState = idle;
		}
		else if (Player.luring)
		{
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
		}
		else 
		{
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(-speed));
		}
	}
	
	override public function draw():Void 
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching != FlxObject.NONE)
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
	
	public function changeEnemy(EType:Int):Void
	{
		if (etype != EType)
		{
			etype = EType;
			loadGraphic("assets/images/enemy-" + Std.string(etype) + ".png", true, 16, 16);
		}
	}
	
	public function stopAndStun(stunDuration:Int) {
		this.velocity.x = 0;
		this.velocity.y = 0;
		stun(stunDuration);
	}
	
	public function stun(stunDuration:Int) {
		this.stunDuration = stunDuration;
	}
	
	public function trap() {
		this.velocity.x = 0;
		this.velocity.y = 0;
		this.trapped = true;
		pathing = false;
		path.cancel();
	}
	
	public function helpComrade():Bool {
		for (i in 0...party.length)
		{
			if(party.members[i].trapped) return true;
		}
		return false;
	}
	
	public function getTrappedComrade():Enemy {
		for (i in 0...party.length)
		{
			if(party.members[i].trapped) return party.members[i];
		}
		return null;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}
}
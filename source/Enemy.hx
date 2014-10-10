package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
	public var speed:Float = 80;
	public var etype(default, null):Int;
	private var _brain:FSM;
	private var _idleTmr:Float;
	private var _moveDir:Float;
	public var seesPlayer:Bool = false;
	public var isLured:Bool = false;
	public var playerPos(default, null):FlxPoint;
	private var _sndStep:FlxSound;
	private var stunDuration:Int;
	private var path:FlxPath;
	private var endPoint:FlxPoint;
	private var map:FlxTilemap;
	
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
		var pathPoints:Array<FlxPoint> = map.findPath(FlxPoint.get(this.x + this.width / 2, this.y + this.height / 2), endPoint);
		
		// Tell unit to follow path
		if (pathPoints != null) 
		{
			path.start(this,pathPoints);
		}
	}
	
	override public function update():Void 
	{
		if (isFlickering())
			return;
		_brain.update();
		super.update();
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
			_brain.activeState = chase;
		}
		
	}
	
	public function chase():Void
	{
		if (stunDuration > 0)
			return;
		
		if (!seesPlayer || !FlxMath.isDistanceToPointWithin(this, playerPos, 100))
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
	
	public function stun(stunDuration:Int) {
		this.velocity.x = 0;
		this.velocity.y = 0;
		this.stunDuration = stunDuration;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}
}
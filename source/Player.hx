package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.tweens.FlxTween;

class Player extends FlxSprite
{
	//Controls
	private static var UP_INPUT:Array<String> = ["UP", "W"];
	private static var DOWN_INPUT:Array<String> = ["DOWN", "S"];
	private static var LEFT_INPUT:Array<String> = ["LEFT", "A"];
	private static var RIGHT_INPUT:Array<String> = ["RIGHT", "D"];
	private static var SCREECH_INPUT:Array<String> = ["SPACE", "J"];
	
	private static var SCREECH_COOLDOWN:Int = 180;
	private static var SCREECH_STUN_DURATION:Int = 120;
	private static var SCREECH_RANGE:Int = 100;
	
	public static var luring:Bool = false;
	public var speed:Float = 200;
	private var _sndStep:FlxSound;
	private var screechCooldown:Int;
	private var grpEnemies:FlxTypedGroup<Enemy>;
	private var addSprite:FlxSprite -> Void;
	
	public function new(X:Float=0, Y:Float=0, grpEnemies:FlxTypedGroup<Enemy>, add:FlxSprite -> Void) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/enemy-0.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("screech", [0], 6, false);
		drag.x = drag.y = 1600;
		setSize(8, 14);
		offset.set(4, 2);
		
		this.grpEnemies = grpEnemies;
		this.addSprite = add;
		
		_sndStep = FlxG.sound.load(AssetPaths.step__wav);
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		#if !FLX_NO_KEYBOARD
		_up = FlxG.keys.anyPressed(UP_INPUT);
		_down = FlxG.keys.anyPressed(DOWN_INPUT);
		_left = FlxG.keys.anyPressed(LEFT_INPUT);
		_right = FlxG.keys.anyPressed(RIGHT_INPUT);
		#end
		#if mobile
		_up = _up || PlayState.virtualPad.buttonUp.status == FlxButton.PRESSED;
		_down = _down || PlayState.virtualPad.buttonDown.status == FlxButton.PRESSED;
		_left  = _left || PlayState.virtualPad.buttonLeft.status == FlxButton.PRESSED;
		_right = _right || PlayState.virtualPad.buttonRight.status == FlxButton.PRESSED;
		#end
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
		
		if ( _up || _down || _left || _right)
		{
			var mA:Float = 0;
			if (_up)
			{
				mA = -90;
				if (_left)
					mA -= 45;
				else if (_right)
					mA += 45;
					
				facing = FlxObject.UP;
			}
			else if (_down)
			{
				mA = 90;
				if (_left)
					mA += 45;
				else if (_right)
					mA -= 45;
				
				facing = FlxObject.DOWN;
			}
			else if (_left)
			{
				mA = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				mA = 0;
				facing = FlxObject.RIGHT;
			}
			FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);
		}
		
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
		{
			_sndStep.play();
			
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
	}
	
	public function lure() {
		luring = FlxG.keys.anyPressed(["Space"]);
	}
	
	private function screech() {
		if (FlxG.keys.anyJustPressed(SCREECH_INPUT) && screechCooldown <= 0) {
			screechCooldown = SCREECH_COOLDOWN;
			animation.play("screech");
			
			var screechSprite = new FlxSprite(this.getMidpoint().x, this.getMidpoint().y);
			screechSprite.loadGraphic(AssetPaths.screech__png, false, 64, 64);
			screechSprite.x -= screechSprite.width / 2;
			screechSprite.y -= screechSprite.height / 2;
			screechSprite.scale.x = 0;
			screechSprite.scale.y = 0;
			addSprite(screechSprite);
			FlxTween.tween(screechSprite.scale, { x: 2 * SCREECH_RANGE / 64, y: 2 * SCREECH_RANGE / 64}, 0.2, 
			{ complete: function (f:FlxTween) {
				screechSprite.destroy();
			}});
			FlxTween.tween(screechSprite, { alpha: 0.5 }, 0.2);
			
			grpEnemies.forEachAlive(function(e:Enemy) {
				if (FlxMath.isDistanceWithin(this, e, SCREECH_RANGE)){
					e.stun(SCREECH_STUN_DURATION);
				}
			});
		}
	}
	
	override public function update():Void 
	{
		movement();
		screech();
		lure();
		handleCooldowns();
		super.update();
	}
	
	private function handleCooldowns() {
		if (screechCooldown > 0)
			screechCooldown--;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}
}

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

class Player extends FlxSprite
{
	//Controls
	private static var UP_INPUT:Array<String> = ["UP", "W"];
	private static var DOWN_INPUT:Array<String> = ["DOWN", "S"];
	private static var LEFT_INPUT:Array<String> = ["LEFT", "A"];
	private static var RIGHT_INPUT:Array<String> = ["RIGHT", "D"];
	private static var SCREECH_INPUT:Array<String> = ["SPACE", "J"];
	private static var LURE_INPUT:Array<String> = ["Z", "K"];

	private static var SCREECH_WIDTH:Int = 64;
	private static var SCREECH_HEIGHT:Int = 64;
	private static var SCREECH_COOLDOWN:Int = 180;
	private static var SCREECH_STUN_DURATION:Int = 120;
	private static var SCREECH_RANGE:Int = 100;

	private static var LURE_COOLDOWN:Int = 300;
	
	private static var MAX_SPEED:Float = 8;	//Completely random
	private static var MAX_ANGLE:Float = 2; //Because radians. Just trust me.

	public static var luring:Bool = false;

	private var _sndStep:FlxSound;
	private var screechCooldown:Int;
	private var lureCooldown:Int;
	private var grpEnemies:FlxTypedGroup<Enemy>;
	private var walls:FlxTilemap;
	private var addSprite:FlxSprite -> Void;
	
	//Variables for player input
	private var  up:Bool = false;		//}
	private var  down:Bool = false;		//}These are kinda self-explanatory. 
	private var  left:Bool = false;		//}True when respective key is pressed, false otherwise
	private var  right:Bool = false;	//}
	
	//Variables for player movement
	private var speed:Float = 0;		//Speed
	private var accel:Float = .15;		//Acceleration
	private var decel:Float = .90;		//Deceleration
	private var friction:Float = .95;	//Slowdown factor
	
	//Variables for turning
	private var turnAngle:Float = 0;		//Basically the direction the player is facing	
	private var turnAccel:Float = .15;		//Rate at which player turns
	private var turnFriction:Float = .98;	//For smoothness
	
	public function new(X:Float=0, Y:Float=0, grpEnemies:FlxTypedGroup<Enemy>, walls:FlxTilemap, add:FlxSprite -> Void)
	{
		super(X, Y);

		loadGraphic("assets/images/enemy-0.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("screech", [0], 6, false);
		animation.add("lure", [0], 6, false);
		drag.x = drag.y = 1600;
		setSize(8, 14);
		offset.set(4, 2);

		this.grpEnemies = grpEnemies;
		this.walls = walls;
		this.addSprite = add;

		_sndStep = FlxG.sound.load(AssetPaths.step__wav);
	}

	private function movement():Void
	{
		//Determines the state of the input keys
		#if !FLX_NO_KEYBOARD
		up = FlxG.keys.anyPressed(UP_INPUT);
		down = FlxG.keys.anyPressed(DOWN_INPUT);
		left = FlxG.keys.anyPressed(LEFT_INPUT);
		right = FlxG.keys.anyPressed(RIGHT_INPUT);
		#end
		
		//Portability!
		#if mobile
		up = up || PlayState.virtualPad.buttonUp.status == FlxButton.PRESSED;
		down = down || PlayState.virtualPad.buttonDown.status == FlxButton.PRESSED;
		left  = left || PlayState.virtualPad.buttonLeft.status == FlxButton.PRESSED;
		right = right || PlayState.virtualPad.buttonRight.status == FlxButton.PRESSED;
		#end
		
		//Determines speed based on user input		
		//Speeds up until MAX_SPEED is hit
		if (up)
			{
				speed = Math.min(MAX_SPEED, speed += accel);
			}
		//Slows down until your speed is ZERO
		if (down)
		{
			speed = Math.max(0, speed -= decel);
		}
		
		//Turns you left (relative)
		if (left)
		{
			turnAngle = Math.min(MAX_ANGLE, turnAngle -= turnAccel);
		}
		//Turns you right (relative)
		if (right)
		{
			turnAngle = Math.max( -MAX_ANGLE, turnAngle += turnAccel);
		}
		
		// If no input, slow down naturally
		speed *= friction;	
		
		//Prevents weirdness
		if(speed > 0 && speed < 0.05)
		{
			speed = 0;
		}
		
		// Prevent turn weirdness 
		if(turnAngle > 0) //(right)
		{
			// check if turnAngle value is really low, set to 0
			if(turnAngle < 0.05)
			{
				turnAngle = 0;
			}		
		}		
		else if(turnAngle < 0) //(left)
		{
			//Same deal
			if(turnAngle > -0.05)
			{
				turnAngle = 0;
			}		
		}
		
		// Update position based on speed. Because if you want things done right you do them yourself.
		//Although I may find a way to make the actual velocity field work...eventually.
		this.x += Math.sin (this.angle * Math.PI / 180) * speed;  //Position.x += Velocity.x
		this.y += Math.cos (this.angle * Math.PI / 180) * -speed; //Position.y += Velocity.y

		
		// Makes you go straight after you stop turning. Took forever to realize not having this caused a major bug.
		//fap, fap, fap, fap
		turnAngle -= (turnAngle * 0.1); //Just take a moment to appreciate how wonderful this line is
				
		//Apply turn friction
		turnAngle = turnAngle * turnFriction;	//Becuase why not. I think the turn speed is too low 
												//to matter now but it might come in handy later one
		
		//Rotate sprite
		this.angle += turnAngle * speed; //Bae caught me turnin'
	}	

	public function lure() {
		if (FlxG.keys.anyJustPressed(LURE_INPUT) && lureCooldown <= 0) {
			lureCooldown = LURE_COOLDOWN;
			animation.play("lure");

			var lureSprite = new Lure(this.getMidpoint().x, this.getMidpoint().y, grpEnemies);
			addSprite(lureSprite);
		}
	}

	private function screech() {
		if (FlxG.keys.anyJustPressed(SCREECH_INPUT) && screechCooldown <= 0) {
			screechCooldown = SCREECH_COOLDOWN;
			animation.play("screech");

			var screechSprite = new FlxSprite(this.getMidpoint().x - SCREECH_WIDTH / 2, this.getMidpoint().y - SCREECH_HEIGHT / 2);
			screechSprite.loadGraphic(AssetPaths.screech__png, false, SCREECH_WIDTH, SCREECH_HEIGHT);
			screechSprite.scale.x = 0;
			screechSprite.scale.y = 0;
			addSprite(screechSprite);
			FlxTween.tween(screechSprite.scale, { x: 2 * SCREECH_RANGE / SCREECH_WIDTH, y: 2 * SCREECH_RANGE / SCREECH_HEIGHT}, 0.2,
			{ complete: function (f:FlxTween) {
				screechSprite.destroy();
			}});
			FlxTween.tween(screechSprite, { alpha: 0.5 }, 0.2);

			grpEnemies.forEachAlive(function(e:Enemy) {
				if (FlxMath.isDistanceWithin(this, e, SCREECH_RANGE)){
					e.stopAndStun(SCREECH_STUN_DURATION);
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
		if (lureCooldown > 0)
			lureCooldown--;
	}

	override public function destroy():Void
	{
		super.destroy();

		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}
}

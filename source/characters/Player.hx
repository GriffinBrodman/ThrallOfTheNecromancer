package characters ;

import characters.enemies.Enemy;
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
import spells.Screech;
import flixel.util.FlxAngle;
import ui.Camera;

class Player extends FlxSprite
{
	//Controls
	private static var UP_INPUT:Array<String> = ["UP", "W"];
	private static var DOWN_INPUT:Array<String> = ["DOWN", "S"];
	private static var LEFT_INPUT:Array<String> = ["LEFT", "A"];
	private static var RIGHT_INPUT:Array<String> = ["RIGHT", "D"];

	private static var SCREECH_INPUT:Array<String> = ["Z", "J"];
	private static var DASH_INPUT:Array<String> = ["X", "K"];

	public static var SCREECH_COOLDOWN:Int = 200;
	public static var DASH_COOLDOWN:Int = 200;
	
	private static var MAX_SPEED:Float = 400;	//Completely random
	private static var MAX_ANGLE:Float = 10;
	private static var DASH_MULTIPLIER:Float = 1.5;
	private static var DASH_TURN_MULTIPLIER = .5;
	private static var SNAKE_SCALE = .23;

	
	private var screechCooldown:Int;
	private var dashCooldown:Int;
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
	private var accel:Float = .18;		//Acceleration
	private var decel:Float = .90;		//Deceleration
	private var friction:Float = .95;	//Slowdown factor
	
	//Variables for turning
	public var turnAngle:Float = 0;		//Basically the direction the player is facing	
	private var turnAccel:Float = 0.8;		//Rate at which player turns
	private var turnFriction:Float = .98;	//For smoothness
	
	private var dashing:Bool = false;
	
	public function new(X:Float=0, Y:Float=0, grpEnemies:FlxTypedGroup<Enemy>, walls:FlxTilemap, add:FlxSprite -> Void)
	{
		super(X, Y);

		loadGraphic("assets/images/head.png", true, 256, 256);
		scale = new FlxPoint(SNAKE_SCALE, SNAKE_SCALE);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		//animation.add("screech", [0], 6, false);
		updateHitbox();
		//setSize(64, 64);
		//offset = new FlxPoint(224, 224);
		
		this.grpEnemies = grpEnemies;
		this.walls = walls;
		this.addSprite = add;


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
		
		if (up && down) {
			up = down = false;
		}
		if (left && right) {
			left = right = false;
		}
		
		/*
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
		
		// If no input, slow down naturally
		speed *= friction;	
		
		//Prevents weirdness
		if(speed > 0 && speed < 0.05)
		{
			speed = 0;
		}
		*/
		
		
		// Update position based on speed. Because if you want things done right you do them yourself.
		//Although I may find a way to make the actual velocity field work...eventually.
		//this.x += Math.sin (this.angle * Math.PI / 180) * speed;  //Position.x += Velocity.x
		this.x = Math.max(this.x, 0);
		this.x = Math.min(this.x, walls.width - this.width);
		//this.y += Math.cos (this.angle * Math.PI / 180) * -speed; //Position.y += Velocity.y
		this.y = Math.max(this.y, 0);
		this.y = Math.min(this.y, walls.height - this.height);
		
		/*
		//Turns you left (relative)
		if (left)
		{
			if (!dashing)	turnAngle = Math.min(MAX_ANGLE, turnAngle - turnAccel);
			else turnAngle = Math.min(MAX_ANGLE, turnAngle - turnAccel * DASH_TURN_MULTIPLIER);
		}
		//Turns you right (relative)
		if (right)
		{
			if (!dashing) turnAngle = Math.max( -MAX_ANGLE, turnAngle + turnAccel);
			else turnAngle = Math.max( -MAX_ANGLE, turnAngle + turnAccel * DASH_TURN_MULTIPLIER);
		}
		
		// Prevent turn weirdness; If turnAngle value is really low, set to 0
		if (Math.abs(turnAngle) < 0.05) {
			turnAngle = 0;
		}
		
		// Makes you go straight after you stop turning. Took forever to realize not having this caused a major bug.
		turnAngle -= (turnAngle * 0.1); //Just take a moment to appreciate how wonderful this line is
				
		//Apply turn friction
		turnAngle = turnAngle * turnFriction;	//Becuase why not. I think the turn speed is too low 
												//to matter now but it might come in handy later one
		
		//Rotate sprite
		this.angle += turnAngle; //Bae caught me turnin'
		
		this.angle = this.angle % 360;
		*/
		
		var targetAngle:Float = this.angle;
		if (up) {
			targetAngle = 0;
			if (left)
				targetAngle = 315;
			else if (right)
				targetAngle = 45;
		}
		else if (down) {
			targetAngle = 180;
			if (left)
				targetAngle = 225;
			else if (right)
				targetAngle = 135;
		} else if (left) {
			targetAngle = 270;
		} else if (right) {
			targetAngle = 90;
		}
		
		var changeInAngle:Float = (targetAngle - this.angle + 360) % 360;
		if (changeInAngle > 180) {
			this.angle -= MAX_ANGLE;
		}
		else if (changeInAngle > 0) {
			this.angle += MAX_ANGLE;
		}
		
		this.angle = this.angle % 360;
		
		// Set the velocity based on angle; Constant speed
		if (!dashing) this.velocity = FlxAngle.rotatePoint(0, MAX_SPEED, 0, 0, this.angle);
		else this.velocity = FlxAngle.rotatePoint(0, MAX_SPEED * DASH_MULTIPLIER, 0, 0, this.angle);
	}

	private function screech() {
		if (FlxG.keys.anyJustPressed(SCREECH_INPUT) && screechCooldown <= 0) {
			screechCooldown = SCREECH_COOLDOWN;
			//animation.play("screech");
		FlxG.sound.play(AssetPaths.shriek__mp3, .5, false);

			addSprite(new Screech(this.getMidpoint().x, this.getMidpoint().y, grpEnemies));
			
			Camera.shake(0.005, 30, true);
		}
	}
	
	private function dash() {
		if (FlxG.keys.anyJustPressed(DASH_INPUT) && dashCooldown <= 0) {
			dashCooldown = DASH_COOLDOWN;
			dashing = true;
		}
	}

	override public function update():Void
	{
		movement();
		screech();
		dash();
		handleCooldowns();
		super.update();
	}

	private function handleCooldowns() {
		if (screechCooldown > 0)
			screechCooldown--;
		if (dashCooldown > 0)
			dashCooldown--;
			if (dashCooldown == 0)
			{
				dashing = false;
			}
	}

	override public function destroy():Void
	{
		super.destroy();
	}
	
	public function getScreechCooldown():Int {
		return screechCooldown;
	}
	
	public function getDashCooldown():Int {
		return dashCooldown;
	}

}

package spellEffects;

import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.util.FlxVelocity;

/**
 * ...
 * @author Peter Shi
 */
class Bats extends SpellEffect
{
	public static var BATS_SPEED:Int = 150;
	public static var BATS_DURATION:Int = 90;
	public static var BATS_DRAG_SPEED:Int = 20;
	private var duration:Int;

	public function new(X1:Float=0, Y1:Float=0, X2:Float=0, Y2:Float=0) 
	{
		super(X1, Y1);
		duration = BATS_DURATION;
		
		loadGraphic(AssetPaths.bats__png, false, 50, 25);
		x -= this.width / 2;
		y -= this.height / 2;
		
		var angle:Float = FlxAngle.getAngle(new FlxPoint(X1, Y1), new FlxPoint(X2, Y2)) - 90;
		this.set_angle(angle);
		this.velocity = FlxVelocity.velocityFromAngle(angle, BATS_SPEED);
	}
	
	override public function touchedBy(E:Enemy)
	{
		// TODO: Fill with some effect
		var angle:Float = FlxAngle.angleBetween(E, this, true);
		var vel = FlxVelocity.velocityFromAngle(angle, BATS_DRAG_SPEED);
		E.velocity.x += vel.x;
		E.velocity.y += vel.y;		
	}
	
	override public function update() {
		super.update();
		
		duration--;
		if (duration <= 0)
			this.destroy();
	}
}
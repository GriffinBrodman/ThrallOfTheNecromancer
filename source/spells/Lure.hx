package spells ;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import flixel.util.FlxVelocity;
import flixel.tweens.FlxTween;

/**
 * ...
 * @author Peter Shi
 */
class Lure extends FlxSprite
{
	private static var LURE_WIDTH = 32;
	private static var LURE_HEIGHT = 45;
	private static var LURE_RANGE = 100;
	private static var LURE_DURATION:Int = 300;
	private static var LURE_SPEED:Int = 30;
	
	private var grpEnemies:FlxTypedGroup<Enemy>;
	private var duration:Int;

	public function new(X:Float = 0, Y:Float = 0, angle:Float, grpEnemies:FlxTypedGroup<Enemy>) 
	{
		super(X - LURE_WIDTH / 2, Y - LURE_HEIGHT / 2);
		loadGraphic(AssetPaths.lure__png, false, LURE_WIDTH, LURE_HEIGHT);
		this.grpEnemies = grpEnemies;
		this.velocity = FlxVelocity.velocityFromAngle(angle, LURE_SPEED);
		this.drag.x = 10;
		this.drag.y = 10;
		this.duration = LURE_DURATION;
		
		// Grow and shrink repeatedly
		FlxTween.tween(this.scale, { x: 1.2, y: 1.2 }, 0.5, { type: FlxTween.PINGPONG } );
	}
	
	override public function update() {
		super.update();
		
		FlxG.overlap(this, grpEnemies, function(l:Lure, e:Enemy) {
			duration--;
		});
		
		duration--;
		if (duration <= 0) {
			grpEnemies.forEachAlive(function(e:Enemy) {
				e.unlure();
			});
			this.destroy();
		}
		else {
			grpEnemies.forEachAlive(function(e:Enemy) {
				e.lure(this.getMidpoint(), LURE_RANGE);
			});
			
			// Fade out over time
			this.alpha = 0.7 * duration / LURE_DURATION + 0.3;
		}
	}
	
}
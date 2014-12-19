package spells ;
import characters.enemies.Enemy;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxMath;

/**
 * ...
 * @author Peter Shi
 */
class Screech extends FlxSprite
{
	private static var SCREECH_WIDTH:Int = 600;
	private static var SCREECH_HEIGHT:Int = 600;
	private static var SCREECH_STUN_DURATION:Int = 100;
	private static var SCREECH_RANGE:Int = 300;
	private static var SCREECH_GRAPHIC_DURATION:Float = 0.25;	// in seconds
	
	public function new(X:Float = 0, Y:Float = 0, grpEnemies:FlxTypedGroup<Enemy>) 
	{
		super(X - SCREECH_WIDTH / 2, Y - SCREECH_HEIGHT / 2);
		loadGraphic(AssetPaths.screech__png, true, SCREECH_WIDTH, SCREECH_HEIGHT);
		animation.add("screech", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 60, false);
		animation.play("screech");
		/*scale.x = 0;
		scale.y = 0;
		FlxTween.tween(scale, { x: 2 * SCREECH_RANGE / SCREECH_WIDTH, y: 2 * SCREECH_RANGE / SCREECH_HEIGHT }, SCREECH_GRAPHIC_DURATION / 4);*/
		FlxTween.tween(this, { alpha: 0.5 }, SCREECH_GRAPHIC_DURATION,
		{ complete: function (f:FlxTween) {
			this.destroy();
		}});

		grpEnemies.forEachAlive(function(e:Enemy) {
			if (FlxMath.isDistanceToPointWithin(e, this.getMidpoint(), SCREECH_RANGE)) {
				e.stun(SCREECH_STUN_DURATION);
			}
		});
	}
}
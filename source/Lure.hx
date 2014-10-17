package ;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author Peter Shi
 */
class Lure extends FlxSprite
{
	private static var LURE_WIDTH = 16;
	private static var LURE_HEIGHT = 16;
	private static var LURE_RANGE = 100;
	private static var LURE_DURATION:Int = 300;
	
	private var grpEnemies:FlxTypedGroup<Enemy>;
	private var duration:Int;

	public function new(X:Float = 0, Y:Float = 0, grpEnemies:FlxTypedGroup<Enemy>) 
	{
		super(X - LURE_WIDTH / 2, Y - LURE_HEIGHT / 2);
		loadGraphic(AssetPaths.lure__png, false, LURE_WIDTH, LURE_HEIGHT);
		this.grpEnemies = grpEnemies;
		this.duration = LURE_DURATION;
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
				e.lure(this.getMidpoint().x, this.getMidpoint().y, LURE_RANGE);
			});
		}
	}
	
}
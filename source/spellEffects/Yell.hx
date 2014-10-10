package spellEffects;
import flixel.FlxSprite;

/**
 * ...
 * @author Peter Shi
 */
class Yell extends SpellEffect
{
	public static var YELL_DURATION:Int = 30;
	private var duration:Int;

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		duration = YELL_DURATION;
		
		loadGraphic(AssetPaths.Yell__png, false, 64, 64);
		x -= this.width / 2;
		y -= this.height / 2;
	}
	
	override public function touchedBy(E:Enemy)
	{
		E.stopAndStun(1);
	}
	
	override public function update() {
		super.update();
		duration--;
		
		if (duration <= 0)
			this.destroy();
	}
	
}
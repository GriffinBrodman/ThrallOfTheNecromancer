package spellEffects ;
import entities.Entity;

/**
 * ...
 * @author Peter Shi
 */
class Trap extends SpellEffect
{
	public static var TRAP_DURATION:Int = 600;
	private var duration:Int;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		duration = TRAP_DURATION;
		
		loadGraphic(AssetPaths.trap__png, false, 16, 16);
		x -= this.width / 2;
		y -= this.height / 2;
	}
	
	override public function touchedBy(E:Enemy)
	{
		E.stopAndStun(120);
		this.destroy();
	}
	
	override public function update() {
		super.update();
		duration--;
		
		if (duration <= 0)
			this.destroy();
	}
}
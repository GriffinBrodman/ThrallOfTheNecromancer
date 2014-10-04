package spells;
import flixel.FlxSprite;
import spellEffects.SpellEffect;
import spellEffects.Trap;

/**
 * ...
 * @author Peter Shi
 */
class TrapSpell extends Spell
{
	public static var TRAP_COOLDOWN = 120;

	public function new() 
	{
		super();
		cooldownMax = TRAP_COOLDOWN;
		cooldown = 0;
	}
	
	override public function place(X:Float = 0, Y:Float = 0):SpellEffect {
		if (cooldown > 0)
			return null;
			
		cooldown = cooldownMax;
		return new Trap(X, Y);
	}
}
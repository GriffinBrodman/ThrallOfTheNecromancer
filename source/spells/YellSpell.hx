package spells;
import flixel.FlxSprite;
import spellEffects.SpellEffect;
import spellEffects.Yell;

/**
 * ...
 * @author Peter Shi
 */
class YellSpell extends Spell
{
	public static var YELL_COOLDOWN = 60;

	public function new() 
	{
		super();
		cooldownMax = YELL_COOLDOWN;
		cooldown = 0;
	}
	
	override public function place(X:Float = 0, Y:Float = 0):SpellEffect {
		if (cooldown > 0)
			return null;
			
		cooldown = cooldownMax;
		return new Yell(X, Y);
	}
	
}
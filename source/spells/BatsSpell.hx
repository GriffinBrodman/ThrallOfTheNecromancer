package spells;
import flixel.FlxSprite;
import spellEffects.SpellEffect;
import spellEffects.Bats;

/**
 * ...
 * @author Peter Shi
 */
class BatsSpell extends Spell
{
	public static var BATS_COOLDOWN = 300;

	public function new() 
	{
		super();
		cooldownMax = BATS_COOLDOWN;
		cooldown = 0;
		
		twoClickSpell = true;
		firstClicked = false;
	}
	
	override public function place(X:Float = 0, Y:Float = 0):SpellEffect {
		if (cooldown > 0)
			return null;
			
		firstClicked = false;
		cooldown = cooldownMax;
		return new Bats(firstClickPos.x, firstClickPos.y, X, Y);
	}
}
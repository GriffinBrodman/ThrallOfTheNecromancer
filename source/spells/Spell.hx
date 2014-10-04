package spells;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import spellEffects.SpellEffect;

/**
 * ...
 * @author Peter Shi
 */
class Spell
{
	private var cooldownMax:Int;
	private var cooldown:Int;

	private function new()
	{
	}
	
	public function place(X:Float = 0, Y:Float = 0):SpellEffect {
		return null;
	}
	
	public function getCooldown():Int {
		return cooldown;
	}
	
	public function update() {
		if (cooldown > 0)
			cooldown--;
	}
	
}
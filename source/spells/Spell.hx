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
	private var twoClickSpell:Bool;
	private var firstClicked:Bool;
	private var firstClickPos:FlxPoint;

	private function new()
	{
	}
	
	public function place(X:Float = 0, Y:Float = 0):SpellEffect {
		return null;
	}
	
	public function setFirstClickPos(pos:FlxPoint):Void {
		if (cooldown > 0)
			return;
		
		firstClickPos = pos;
		firstClicked = true;
	}
	
	public function getCooldown():Int {
		return cooldown;
	}
	
	public function isTwoClickSpell():Bool {
		return twoClickSpell;
	}
	
	public function isFirstClicked():Bool {
		return firstClicked;
	}
	
	public function update() {
		if (cooldown > 0)
			cooldown--;
	}
	
}
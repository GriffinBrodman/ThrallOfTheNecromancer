package spells;
import flixel.FlxG;
import flixel.FlxSprite;
import spellEffects.SpellEffect;

/**
 * ...
 * @author Peter Shi
 */
class SpellBook
{
	public static var SPELL_INPUT:Array<Array<String>> = [["ONE"], ["TWO"], ["THREE"], ["FOUR"], ["FIVE"]];
	
	private var spells:Array<Spell>;
	private var selectedSpell:Spell;
	private var num_spells:Int;
	private var effectToBeAdded:SpellEffect;

	public function new (spells:Array<Spell>) {
		this.spells = spells;
		num_spells = Std.int(Math.min(SPELL_INPUT.length, spells.length));
	}
	
	private function handleInput() {
		if (selectedSpell != null && FlxG.mouse.justPressed) {
			effectToBeAdded = selectedSpell.place(FlxG.mouse.x, FlxG.mouse.y);
			if (effectToBeAdded != null)
				selectedSpell = null;
		}
		
		for (i in 0...num_spells) {
			if (FlxG.keys.anyJustPressed(SPELL_INPUT[i])) {
				selectedSpell = spells[i];
			}
		}
	}
	
	public function update() {
		for (spell in spells) {
			spell.update();
		}
		
		handleInput();
	}
	
	public function getEffectToBeAdded():SpellEffect {
		return effectToBeAdded;
	}
	
	public function wipeEffectToBeAdded():Void {
		effectToBeAdded = null;
	}
	
}
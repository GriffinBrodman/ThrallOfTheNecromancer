package spells;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import spellEffects.SpellEffect;

/**
 * ...
 * @author Peter Shi
 */
class SpellBook
{
	public static var SPELL_INPUT:Array<Array<String>> = [["ONE"], ["TWO"], ["THREE"], ["FOUR"], ["FIVE"]];
	
	private var scale:Float = 2;
	private var spells:Array<Spell>;
	private var selectedSpell:Spell;
	private var num_spells:Int;
	private var effectToBeAdded:SpellEffect;
	private var mouseOnCooldown:Bool;

	public function new (spells:Array<Spell>) {
		this.spells = spells;
		num_spells = Std.int(Math.min(SPELL_INPUT.length, spells.length));
	}
	
	private function handleInput() {
		if (selectedSpell != null && FlxG.mouse.justPressed) {
			var mx:Float = FlxG.mouse.x * scale;
			var my:Float = FlxG.mouse.y * scale;
			
			if (selectedSpell.isTwoClickSpell()) {
				if (selectedSpell.isFirstClicked()) 
					effectToBeAdded = selectedSpell.place(mx, my);
				else
					selectedSpell.setFirstClickPos(new FlxPoint(mx, my));
			}
			else {
				effectToBeAdded = selectedSpell.place(mx, my);
			}
			
			if (effectToBeAdded != null){
				selectedSpell = null;
				FlxG.mouse.unload();
			}
		}
		
		for (i in 0...num_spells) {
			if (FlxG.keys.anyJustPressed(SPELL_INPUT[i])) {
				selectedSpell = spells[i];
				FlxG.mouse.load(AssetPaths.mouseSpellLoadedOnCooldown__png);
				mouseOnCooldown = true;
			}
		}
		
		if (mouseOnCooldown && selectedSpell != null && selectedSpell.getCooldown() <= 0){
			FlxG.mouse.load(AssetPaths.mouseSpellLoaded__png);
			mouseOnCooldown = false;
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
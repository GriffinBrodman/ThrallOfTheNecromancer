package;

import entities.Entity;
import entities.Exit;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import spellEffects.SpellEffect;
import spells.BatsSpell;
import spells.TrapSpell;
import spells.YellSpell;
import flixel.util.FlxMath;
using flixel.util.FlxSpriteUtil;

import spells.SpellBook;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public static var NUM_SECONDS = 60;
	public static var FRAMES_PER_SECOND = 60;
	public static var ESCAPEE_THRESHOLD = 2;
	public static var ENEMY_SIGHT_RANGE = 100;
	
	private var _player:Player;
	private var _spellbook:SpellBook;
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _mBorders:FlxTilemap;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _grpExits:FlxTypedGroup<Exit>;
	private var _hud:HUD;
	private var _money:Int = 0;
	private var _health:Int = 3;
	private var _inCombat:Bool = false;
	private var _won:Bool = false;
	private var _paused:Bool;
	private var _sndCoin:FlxSound;
	private var _grpSpellEffects:FlxTypedGroup<SpellEffect>;
	private var _timer:Int;
	private var _escapeLimit:Int;			//Limits number of humans we can let escape
	private var _numEscaped = 0;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;

		_map = new FlxOgmoLoader(AssetPaths.room_002__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		_mWalls.setTileProperties(1, FlxObject.NONE);
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		
		_mBorders = _map.loadTilemap(AssetPaths.Outerborder__png, 16, 16, "playerwall");
		_mBorders.setTileProperties(1, FlxObject.ANY);
		_mBorders.setTileProperties(2, FlxObject.ANY);
		add(_mBorders);
		
		_grpExits = new FlxTypedGroup<Exit>();
		add(_grpExits);
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		_player = new Player();
		_spellbook = new SpellBook([new TrapSpell(), new YellSpell(), new BatsSpell()]);
		
		_grpSpellEffects = new FlxTypedGroup<SpellEffect>();
		add(_grpSpellEffects);
		
		_map.loadEntities(placeEntities, "entities");
		
		for (i in 0..._grpEnemies.length)
		{
			_grpEnemies.members[i].setGoal(_grpExits);
		}
		add(_player);
		FlxG.camera.setSize(FlxG.width * 2, FlxG.height * 2);
		FlxG.camera.setScale(1, 1);
		//FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, 1);
	
		_timer = NUM_SECONDS * FRAMES_PER_SECOND;
		_escapeLimit = ESCAPEE_THRESHOLD;
		
		_hud = new HUD(_timer);
		add(_hud);
		
		
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		
		super.create();	
		
	}
	
	private function getSecs(_timer:Int):Int
	{
		return Std.int(_timer / FRAMES_PER_SECOND);
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		switch(entityName)
		{
			case "player":
				_player.x = x;
				_player.y = y;
			case "enemy":
				_grpEnemies.add(new Enemy(x + 4, y, _mWalls));
			case "exit":
				_grpExits.add(new Exit(x, y));
		}
	}
	
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_player = FlxDestroyUtil.destroy(_player);
		_mWalls = FlxDestroyUtil.destroy(_mWalls);
		_grpEnemies = FlxDestroyUtil.destroy(_grpEnemies);
		_hud = FlxDestroyUtil.destroy(_hud);
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		_timer--;
		_hud.updateHUD(getSecs(_timer));
		
		if (_timer <= 0)
		{
			_won = true;
			FlxG.switchState(new GameOverState(_won, _money));
		}
		if (_numEscaped >= _escapeLimit)
		{
			FlxG.switchState(new GameOverState(_won, _money));
		}
		FlxG.collide(_player, _mBorders);
		FlxG.collide(_grpEnemies, _mWalls);
		_grpEnemies.forEachAlive(checkEnemyVision);
		FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		FlxG.overlap(_grpEnemies, _grpSpellEffects, enemyTouchTrap);
		FlxG.overlap(_grpEnemies, _grpExits, humanExit);
		
		_spellbook.update();
		if (_spellbook.getEffectToBeAdded() != null){
			_grpSpellEffects.add(_spellbook.getEffectToBeAdded());
			_spellbook.wipeEffectToBeAdded();
		}
	}
	
	private function doneFadeOut():Void 
	{
		FlxG.switchState(new GameOverState(_won, _money));
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
		
	}
	
	private function enemyTouchTrap(E:Enemy, T:SpellEffect):Void
	{
		T.touchedBy(E);
	}
	
	private function humanExit(human:Enemy, exit:Entity)
	{
		human.kill();
		_numEscaped++;
	}
	
	private function checkEnemyVision(e:Enemy):Void
	{
		if (FlxMath.isDistanceWithin(e, _player, ENEMY_SIGHT_RANGE) && _mWalls.ray(e.getMidpoint(), _player.getMidpoint())
		&& e.canSee(_player))
		{
			e.seesPlayer = true;
			e.playerPos.copyFrom(_player.getMidpoint());
		}
		else
			e.seesPlayer = false;		
	}
}

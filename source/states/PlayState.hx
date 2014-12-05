package states ;

import characters.enemies.Enemy;
import characters.enemies.DFSEnemy;
import characters.Player;
import entities.Exit;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxMath;
import flixel.text.FlxText;
import level.LevelLoader;
//import openfl.utils.ObjectInput;
import characters.SnakeBody;
import ui.HUD;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public static var NUM_SECONDS = 60;
	public static var FRAMES_PER_SECOND = 60;
	public static var ESCAPEE_THRESHOLD = 5;	//TODO
	public static var ENEMY_SIGHT_RANGE = 200;
	public static var ENEMY_DETECTION_RANGE = 40;
	public static var NUM_SNAKE_PARTS = 9;
	
	private var _player:Player;
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _ground:FlxTilemap;
	//private var _mBorders:FlxTilemap;
	private var loader:LevelLoader;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _grpExits:FlxTypedGroup<Exit>;
	private var _grpUI:FlxTypedGroup<FlxSprite>;
	private var _grpSnake:FlxTypedGroup<SnakeBody>;
	private var _hud:HUD;
	private var _won:Bool = false;
	private var _paused:Bool;
	private var _timer:Int;
	private var _escapeLimit:Int;			//Limits number of humans we can let escape
	private var _numEscaped = 0;
	private var _bg:FlxSprite;
	private var debug:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		/*bg = new FlxSprite(0, 0, AssetPaths.room01Big__png);
		add(bg);
		
		_map = new FlxOgmoLoader(AssetPaths.room01Big__oel);
		
		_mWalls = _map.loadTilemap(AssetPaths.invisibletile__png, 128, 128, "walls");
		_ground = _map.loadTilemap(AssetPaths.invisibletile__png, 128, 128, "ground");*/
		
		loader = new LevelLoader();
		
		//_bg = loader.getBackground();
		_map = loader.getMap();
		_mWalls = loader.getWalls();
		_ground = loader.getGround();
		_grpExits = loader.getExits();
		_grpEnemies = loader.getEnemies();
		
		//add(_bg);
		add(_ground);
		add(_mWalls);
		add(_grpExits);
		add(_grpEnemies);
		
		_grpUI = new FlxTypedGroup<FlxSprite>();
		add(_grpUI);
		
		var tempPlayer = loader.getPlayer();
		_player = new Player(tempPlayer.x, tempPlayer.y, _grpEnemies, _mWalls, this.add);
		_grpSnake = new FlxTypedGroup<SnakeBody>();
		var lastPart:SnakeBody = null;
		for (i in 0...NUM_SNAKE_PARTS) {
			lastPart = new SnakeBody(lastPart == null ? _player : lastPart, i);
			_grpSnake.add(lastPart);
			/*
			var subhead:SnakeBody = new SnakeBody(_player, 1);
			var subhead2:SnakeBody = new SnakeBody(subhead, 2);
			var body:SnakeBody = new SnakeBody(subhead2, 3);
			var body2:SnakeBody = new SnakeBody(body, 4);
			var tail:SnakeBody = new SnakeBody(body2, 5);
			var tail2:SnakeBody = new SnakeBody(tail, 6);
			
			_grpSnake.add(tail2);
			_grpSnake.add(tail);
			_grpSnake.add(body2);
			_grpSnake.add(body);
			_grpSnake.add(subhead2);
			_grpSnake.add(subhead);
			*/
		}
		
		add(_grpSnake);
		
		add(_player);
		
		_map.loadEntities(placeEntities, "entities");
		
		for (i in 0..._grpEnemies.length)
		{
			_grpEnemies.members[i].setGoal(_grpExits);
		}
		
		//FlxG.camera.setSize(FlxG.width, FlxG.height);
		//FlxG.camera.setScale(1.5, 1.5);
		//We will use the following line for the bigger scale, don't delete
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, 1);
	
		_timer = NUM_SECONDS * FRAMES_PER_SECOND;
		_escapeLimit = ESCAPEE_THRESHOLD;
		
		_hud = new HUD(_timer, _player, _escapeLimit, _numEscaped, _mWalls);
		add(_hud);
		_hud.minimapInit(_player, _grpSnake, _grpEnemies, _grpExits);		
		
		debug = new FlxText();
		debug.setPosition(0, FlxG.height - 30);
		add(debug);
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		
		super.create();	
	}
	
	/** Function to get number of seconds passed
	 */
	private function getSecs(_timer:Int):Int
	{
		return Std.int(_timer / FRAMES_PER_SECOND);
	}
	
	
	/**
	 * Callback function for placing entities from map file
	 */
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
				_grpEnemies.add(new DFSEnemy(x, y, _mWalls, _ground));
			case "exit":
				var escapable = StringToBool(entityData.get("escapable"));
				_grpExits.add(new Exit(x, y, escapable));
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
		_hud.updateHUD(getSecs(_timer), _escapeLimit, _numEscaped);
				
		if (_timer <= 0)
		{
			_won = true;
			FlxG.switchState(new GameOverState(_won));
		}
		if (_numEscaped >= _escapeLimit)
		{
			FlxG.switchState(new GameOverState(_won));
		}
		
		FlxG.collide(_mWalls, _grpEnemies);
		//FlxG.collide(_playerWalls, _player);	TODO: Add this line when we get player walls
		_grpEnemies.forEachAlive(checkEnemyVision);
		FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		FlxG.overlap(_grpEnemies, _grpExits, humanExit);
		
		//debug.text = Std.string(_player.angle);
	}
	
	private function doneFadeOut():Void 
	{
		FlxG.switchState(new GameOverState(_won));
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
	}
	
	private function humanExit(human:Enemy, exit:Exit):Void
	{
		if (exit.canEscape() && !human.getEscaped())
		{
			human.setEscaped();
			FlxDestroyUtil.destroy(human);
			_numEscaped++;
			
			FlxG.camera.flash(FlxColor.RED, 0.5, null, true, 0.5);
		}
		else
		{
			human.setGoal(_grpExits);
		}
	}

	/**
	 * Function that returns whether an enemy sees the player based on position and raycasting
	 * @param	e
	 */
	private function checkEnemyVision(e:Enemy):Void
	{
		e.scared = false;
		
		var dx = e.getMidpoint().x - _player.getMidpoint().x;
		var dy = e.getMidpoint().y - _player.getMidpoint().y;
		if ( (dx * dx + dy * dy <= ENEMY_SIGHT_RANGE * ENEMY_SIGHT_RANGE && _mWalls.ray(e.getMidpoint(), _player.getMidpoint())
		&& e.inLOS(_player.x, _player.y)) || dx * dx + dy * dy <= ENEMY_DETECTION_RANGE * ENEMY_DETECTION_RANGE)
		{
			e.scared = true;
			e.snakePos.copyFrom(_player.getMidpoint());
			
		}
		else {
			for (i in 0..._grpSnake.length)
			{
				dx = e.getMidpoint().x - _grpSnake.members[i].getMidpoint().x;
				dy = e.getMidpoint().y - _grpSnake.members[i].getMidpoint().y;
				if ( (dx * dx + dy * dy <= ENEMY_SIGHT_RANGE * ENEMY_SIGHT_RANGE && _mWalls.ray(e.getMidpoint(), _grpSnake.members[i].getMidpoint())
				&& e.inLOS(_grpSnake.members[i].x, _grpSnake.members[i].y )) || dx * dx + dy * dy <= ENEMY_DETECTION_RANGE * ENEMY_DETECTION_RANGE)
				{
					e.scared = true;
					e.snakePos.copyFrom(_grpSnake.members[i].getMidpoint());
					break;
				}
			}
		}
	}
	
	/**
	 * Utility function to convert a boolean to a String
	 * @param	a
	 * @return
	 */
	function StringToBool(a:Dynamic):Bool{
		var res:Bool = (cast (a, String).toLowerCase() == "true")?true:false;
		return res;
	}
}

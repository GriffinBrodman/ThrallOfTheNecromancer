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
import ui.Camera;
//import openfl.utils.ObjectInput;
import characters.SnakeBody;
import ui.HUD;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public static var FRAMES_PER_SECOND:Int = 60;
	public static var ENEMY_SIGHT_RANGE:Int = 200;
	public static var ENEMY_DETECTION_RANGE:Int = 40;
	public static var NUM_SNAKE_PARTS:Int = 9;
	private static var START_DELAY_SECONDS:Int = 3;
	
	private var _player:Player;
	private var _humanWalls:FlxTilemap;
	private var _playerWalls:FlxTilemap;
	private var _humanPlayerWalls:FlxTilemap;
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
	private var _currLevel:Int;
	private var _numLevels:Int = 5;
	private var _tutorial:FlxSprite;
	
	private var _state:Int = -1;
	private var _startTimer:Int = 0;
	private var _startDelaySprite:FlxSprite;
	private var _startDelayText:FlxText;
	
	public function new(levelNum:Int) 
	{
		super();
		_currLevel = levelNum;
	}
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		
		loader = new LevelLoader(_currLevel);
		loadLevel();
		
		//add(_bg);
		add(_ground);
		add(_humanWalls);
		add(_playerWalls);
		add(_humanPlayerWalls);
		add(_grpExits);
		add(_grpEnemies);
		
		_grpUI = new FlxTypedGroup<FlxSprite>();
		add(_grpUI);
		
		var tempPlayer = loader.getPlayer();
		_player = new Player(tempPlayer.x, tempPlayer.y, _grpEnemies, _humanWalls, this.add);
		_grpSnake = new FlxTypedGroup<SnakeBody>();
		var lastPart:SnakeBody = null;
		for (i in 0...NUM_SNAKE_PARTS) {
			lastPart = new SnakeBody(lastPart == null ? _player : lastPart, i);
			_grpSnake.add(lastPart);
		}
		
		add(_grpSnake);
		
		add(_player);
				
		for (i in 0..._grpEnemies.length)
		{
			_grpEnemies.members[i].setGoal(_grpExits);
		}
		
		//FlxG.camera.setSize(FlxG.width, FlxG.height);
		//FlxG.camera.setScale(1.5, 1.5);
		//We will use the following line for the bigger scale, don't delete
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, 1);
		
		_hud = new HUD(getSecs(_timer), _player, _escapeLimit, _numEscaped, _humanWalls, _playerWalls, _humanPlayerWalls);
		add(_hud);
		_hud.minimapInit(_player, _grpSnake, _grpEnemies, _grpExits);		
		
		debug = new FlxText();
		debug.setPosition(100, FlxG.height - 30);
		add(debug);
		
		if (_currLevel < 4)
		{
			_tutorial = new FlxSprite(50, 260);
			_tutorial.loadGraphic("assets/images/tutorial" + _currLevel +".png");
			_tutorial.x = 120 - (_tutorial.width / 2);
			_tutorial.scrollFactor.set(0, 0);
			add(_tutorial);
		}
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		
		disableAll();
		_state = 0;
		_startDelaySprite = new FlxSprite(0, 0);
		_startDelaySprite.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_startDelaySprite.alpha = 0.6;
		_startDelaySprite.scrollFactor.x = _startDelaySprite.scrollFactor.y = 0;
		add(_startDelaySprite);
		_startDelayText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "Press Any Key to Start", 32);
		_startDelayText.scrollFactor.x = _startDelayText.scrollFactor.y = 0;
		_startDelayText.screenCenter(true, true);
		add(_startDelayText);
	}
	
	private function loadLevel():Void
	{
		_humanWalls = loader.getWalls();
		_playerWalls = loader.getPlayerWalls();
		_humanPlayerWalls = loader.getHumanPlayerWalls();
		_ground = loader.getGround();
		_grpExits = loader.getExits();
		Enemy.exits = loader.getExitsMap();
		_grpEnemies = loader.getEnemies();
		_escapeLimit = loader.getEscapeeThreshold();
		_timer = loader.getTime() * FRAMES_PER_SECOND;
		//_bg = loader.getBackground();
	}
	
	private function disableAll():Void {
		for (e in _grpEnemies) {
			e.set_active(false);
		}
		for (s in _grpSnake) {
			s.set_active(false);
		}
		_player.set_active(false);
	}
	
	private function enableAll():Void {
		for (e in _grpEnemies) {
			e.set_active(true);
		}
		for (s in _grpSnake) {
			s.set_active(true);
		}
		_player.set_active(true);
	}
	
	/** Function to get number of seconds passed
	 */
	private function getSecs(_timer:Int):Int
	{
		return Math.ceil(_timer / FRAMES_PER_SECOND);
	}
	
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_player = FlxDestroyUtil.destroy(_player);
		_humanWalls = FlxDestroyUtil.destroy(_humanWalls);
		destroyGroup(_grpSnake);
		destroyGroup(_grpEnemies);
		destroyGroup(_hud);
		_startDelaySprite = FlxDestroyUtil.destroy(_startDelaySprite);
		_startDelayText = FlxDestroyUtil.destroy(_startDelayText);
		if (_currLevel < 4)
		{
			_tutorial.destroy();
		}
		super.destroy();
	}
	
	private function destroyGroup(group:FlxTypedGroup<Dynamic>) {
		group.forEachExists(function(obj:FlxSprite) { obj.destroy(); } );
		group.destroy();
		return null;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		if (_state == 0) {
			if (FlxG.keys.firstJustReleased() != "") {
				_startTimer = START_DELAY_SECONDS * FRAMES_PER_SECOND;
				
				_state = 1;
			}
		}
		else if (_state == 1) {
			_startTimer--;
			_startDelayText.text = Std.string(getSecs(_startTimer));
			_startDelayText.screenCenter(true, true);
			if (_startTimer <= 0) {
				remove(_startDelaySprite);
				remove(_startDelayText);
				enableAll();
				
				_state = 2;
			}
		}
		else if (_state == 2){
			_timer--;
			_hud.updateHUD(getSecs(_timer), _escapeLimit, _numEscaped);
					
			if (_timer <= 0)
			{
				add(_startDelaySprite);
				_startDelayText.text = "You win!";
				_startDelayText.screenCenter(true, true);
				add(_startDelayText);
				disableAll();
				_state = 3;
			}
			FlxG.collide(_humanWalls, _grpEnemies);
			FlxG.collide(_playerWalls, _player);
			FlxG.collide(_humanPlayerWalls, _grpEnemies);
			FlxG.collide(_humanPlayerWalls, _player);
			_grpEnemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(_grpEnemies, _grpExits, humanExit);
			
			Camera.update();
			
			if (FlxG.keys.anyJustPressed(["ESCAPE"])) {
				this.openSubState(new PauseState());
			}
		}
		else if (_state == 3) {
			if (FlxG.keys.firstJustPressed() != ""){
				if (loader.getCurrLevel() >= _numLevels)
				{
					_won = true;
					FlxG.switchState(new GameOverState(_won, _currLevel));
				}
				else
					FlxG.switchState(new PlayState(_currLevel + 1));
			}
		}
	}
	
	private function doneFadeOut():Void 
	{
		FlxG.switchState(new GameOverState(_won, _currLevel));
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
	}
	
	private function humanExit(human:Enemy, exit:Exit):Void
	{
		if (exit.canEscape())
		{
			FlxDestroyUtil.destroy(human);
			_numEscaped++;
			
			FlxG.camera.flash(FlxColor.RED, 0.5, null, true, 0.5);
			if (_numEscaped >= _escapeLimit)
			{
				FlxG.switchState(new GameOverState(_won, _currLevel));
			}
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
		var wasScared:Bool = e.scared;
		e.scared = false;
		
		var dx = e.getMidpoint().x - _player.getMidpoint().x;
		var dy = e.getMidpoint().y - _player.getMidpoint().y;
		if ( (dx * dx + dy * dy <= ENEMY_SIGHT_RANGE * ENEMY_SIGHT_RANGE && _humanWalls.ray(e.getMidpoint(), _player.getMidpoint())
		&& e.inLOS(_player.x, _player.y)) || dx * dx + dy * dy <= ENEMY_DETECTION_RANGE * ENEMY_DETECTION_RANGE)
		{
			e.scared = true;
			e.snakePos.copyFrom(_player.getMidpoint());
			
			if (!wasScared)
				Camera.shake(0.01, 20);
			
		}
		else {
			for (i in 0..._grpSnake.length)
			{
				dx = e.getMidpoint().x - _grpSnake.members[i].getMidpoint().x;
				dy = e.getMidpoint().y - _grpSnake.members[i].getMidpoint().y;
				if ( (dx * dx + dy * dy <= ENEMY_SIGHT_RANGE * ENEMY_SIGHT_RANGE && _humanWalls.ray(e.getMidpoint(), _grpSnake.members[i].getMidpoint())
				&& e.inLOS(_grpSnake.members[i].x, _grpSnake.members[i].y)) || dx * dx + dy * dy <= ENEMY_DETECTION_RANGE * ENEMY_DETECTION_RANGE)
				{
					e.scared = true;
					e.snakePos.copyFrom(_grpSnake.members[i].getMidpoint());
					
					if (!wasScared)
						Camera.shake(0.01, 30);
				
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

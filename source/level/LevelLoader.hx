package level;
import characters.enemies.DFSEnemy;
import characters.Player;
import characters.enemies.Enemy;
import entities.Exit;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import haxe.ds.IntMap;

/**
 * ...
 * @author ...
 */
class LevelLoader
{
	private var _map:FlxOgmoLoader;
	private var _humanWalls:FlxTilemap;
	private var _trueHumanWalls:FlxTilemap;
	private var _playerWalls:FlxTilemap;
	private var _humanPlayerWalls:FlxTilemap;
	private var _ground:FlxTilemap;
	private var _player:Player;
	private var _enemies:FlxTypedGroup<Enemy>;
	private var _exits:FlxTypedGroup<Exit>;
	private var _exitsMap:IntMap<Bool>;
	private var _bg:FlxSprite;
	private var _levelnum:Int;
	private var _timeLeft:Int;
	private var levelPathFrag = "assets/data/room";
	private var levelExtension = ".oel";
	private var levelBGFrag = "assets/images/room";
	private var levelBGExtension = ".png";// Big.png";
	private var escapee_threshold:Int;
	private var TILE_LENGTH = 64;
	
	public function new(levelNum:Int)
	{
		_player = new Player(0, 0, null, null, null);
		_enemies = new FlxTypedGroup<Enemy>();
		_exits = new FlxTypedGroup<Exit>();
		_exitsMap = new IntMap<Bool>();
		_levelnum = levelNum;
		loadLevel(_levelnum);
	}
	
	private function loadLevel(levelNum:Int)
	{
		_map = new FlxOgmoLoader(getLevelPath(levelNum));
		_humanWalls = _map.loadTilemap(AssetPaths.wheat_tile_set__png, TILE_LENGTH, TILE_LENGTH, "humanwalls");
		_humanWalls.loadMap(_humanWalls.getData(),AssetPaths.wheat_tile_set__png, TILE_LENGTH, TILE_LENGTH, FlxTilemap.AUTO);
		_ground = _map.loadTilemap(AssetPaths.ground_tile_sheet__png, TILE_LENGTH, TILE_LENGTH, "ground");
		_playerWalls = _map.loadTilemap(AssetPaths.puddleTilesheet__png, TILE_LENGTH, TILE_LENGTH, "playerwalls");
		_playerWalls.loadMap(_playerWalls.getData(), AssetPaths.puddleTilesheet__png, TILE_LENGTH, TILE_LENGTH, FlxTilemap.AUTO);

		createHumanPlayerWalls();
		
		_map.loadEntities(placeEntities, "entities");
		escapee_threshold = Std.parseInt(_map.getProperty("escapeLimit"));
		_timeLeft = Std.parseInt(_map.getProperty("time"));
	}
	
	private function createHumanPlayerWalls():Void {
		var humanPlayerWallsData:Array<Int> = [];
		var trueHumanWallsData:Array<Int> = [];
		for (y in 0..._humanWalls.heightInTiles) {
			for (x in 0..._humanWalls.widthInTiles) {
				var humanWallHasTile = _humanWalls.getTile(x, y) > 0;
				if (humanWallHasTile && _playerWalls.getTile(x, y) > 0){
					humanPlayerWallsData.push(1);	// Fill with tile
					trueHumanWallsData.push(1);
					_humanWalls.setTile(x, y, 0);
					_playerWalls.setTile(x, y, 0);
				}
				else
				{
					humanPlayerWallsData.push(0);	// Don't fill with tile
					if (humanWallHasTile)
						trueHumanWallsData.push(1);
					else
						trueHumanWallsData.push(0);
				}
			}
		}
		
		_humanPlayerWalls = new FlxTilemap();
		_humanPlayerWalls.widthInTiles = _humanWalls.widthInTiles;
		_humanPlayerWalls.heightInTiles = _humanWalls.heightInTiles;
		//_humanPlayerWalls.customTileRemap = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		_humanPlayerWalls.loadMap(humanPlayerWallsData, AssetPaths.humanPlayerWall__png, TILE_LENGTH, TILE_LENGTH);

		_trueHumanWalls = new FlxTilemap();
		_trueHumanWalls.widthInTiles = _humanWalls.widthInTiles;
		_trueHumanWalls.heightInTiles = _humanWalls.heightInTiles;
		//_humanPlayerWalls.customTileRemap = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		_trueHumanWalls.loadMap(trueHumanWallsData, AssetPaths.humanPlayerWall__png, TILE_LENGTH, TILE_LENGTH);
	}
	
	private function getLevelPath(levelNum:Int):String
	{
		return levelPathFrag + convertLevelnum(levelNum) + levelExtension;
	}
	
	private function getBGPath(levelNum:Int):String
	{
		return levelBGFrag + convertLevelnum(levelNum) + levelBGExtension;
	}
	
	private function convertLevelnum(levelNum:Int)
	{
		return levelNum < 10 ? ("0" + levelNum) : ("" + levelNum);
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
				_enemies.add(new DFSEnemy(x, y, _trueHumanWalls));
			case "exit":
				var escapable:Bool = StringToBool(entityData.get("escapable"));
				var orient = Std.string(entityData.get("orientation"));
				_exits.add(new Exit(x, y, escapable, orient));
				_exitsMap.set(Std.int((x / 64) + (y / 64) * _humanWalls.widthInTiles), escapable);
		}
	}
	
	public function getMap():FlxOgmoLoader
	{
		return _map;
	}

	public function getWalls():FlxTilemap
	{
		return _humanWalls;
	}
	
	public function getPlayerWalls():FlxTilemap
	{
		return _playerWalls;
	}
	
	public function getHumanPlayerWalls():FlxTilemap
	{
		return _humanPlayerWalls;
	}
	
	public function getTrueHumanWalls():FlxTilemap
	{
		return _trueHumanWalls;
	}
	
	public function getGround():FlxTilemap
	{
		return _ground;
	}
	
	public function getPlayer():Player
	{
		return _player;
	}
	
	public function getEnemies():FlxTypedGroup<Enemy>
	{
		return _enemies;
	}
	
	public function getExits():FlxTypedGroup<Exit>
	{
		return _exits;
	}
	
	public function getExitsMap():IntMap<Bool>
	{
		return _exitsMap;
	}
	
	public function getBackground():FlxSprite
	{
		return _bg;
	}
	
	public function getEscapeeThreshold():Int
	{
		return escapee_threshold;
	}
	
	public function getTime():Int
	{
		return _timeLeft;
	}
	
	public function getCurrLevel()
	{
		return _levelnum;
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
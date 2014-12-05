package level;
import characters.enemies.DFSEnemy;
import characters.Player;
import characters.enemies.Enemy;
import entities.Exit;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;

/**
 * ...
 * @author ...
 */
class LevelLoader
{
	var _map:FlxOgmoLoader;
	var _walls:FlxTilemap;
	var _ground:FlxTilemap;
	var _player:Player;
	var _enemies:FlxTypedGroup<Enemy>;
	var _exits:FlxTypedGroup<Exit>;
	var _bg:FlxSprite;
	private var _levelnum = 1;
	private var levelPathFrag = "assets/data/room";
	private var levelExtension = ".oel";//"Big.oel";
	private var levelBGFrag = "assets/images/room";
	private var levelBGExtension = ".png";// Big.png";
	
	public function new()
	{
		_player = new Player(0, 0, null, null, null);
		_enemies = new FlxTypedGroup<Enemy>();
		_exits = new FlxTypedGroup<Exit>();
		loadLevel(_levelnum);
	}
	
	private function loadLevel(levelNum:Int)
	{
		_map = new FlxOgmoLoader(getLevelPath(levelNum));
		_walls = _map.loadTilemap(AssetPaths.ground_tile_sheet__png, 32, 32, "walls");
		//_walls = _map.loadTilemap(AssetPaths.invisibletile__png, 128, 128, "walls");
		_ground = _map.loadTilemap(AssetPaths.ground_tile_sheet__png, 32, 32, "ground");
		//_ground = _map.loadTilemap(AssetPaths.invisibletile__png, 128, 128, "ground");
		//_bg = new FlxSprite(0, 0, getBGPath(levelNum));
		_map.loadEntities(placeEntities, "entities");
	}
	
	public function nextLevel()
	{
		_levelnum++;
		loadLevel(_levelnum);
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
				_enemies.add(new DFSEnemy(x, y, _walls, _ground));
			case "exit":
				var escapable = StringToBool(entityData.get("escapable"));
				_exits.add(new Exit(x, y, escapable));
		}
	}
	
	public function getMap():FlxOgmoLoader
	{
		return _map;
	}

	public function getWalls():FlxTilemap
	{
		return _walls;
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
	
	public function getBackground():FlxSprite
	{
		return _bg;
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
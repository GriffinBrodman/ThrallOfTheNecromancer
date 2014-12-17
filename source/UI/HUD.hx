package ui ;

import characters.enemies.Enemy;
import characters.Player;
import characters.SnakeBody;
import entities.Exit;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import ui.FlxMinimap;
using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private static var BAR_X:Int = 0;
	private static var BAR_Y:Int = 5;
	private static var BAR_GAP:Int = 25;
	private static var BAR_WIDTH:Int = 250;
	private static var BAR_HEIGHT:Int = 20;
	
	private static var MINIMAP_X:Int = 20;
	private static var MINIMAP_Y:Int = 80;
	private static var MINIMAP_WIDTH:Int = 175;
	private static var MINIMAP_HEIGHT:Int = 175;
	
	private static var MAPFRAME_WIDTH:Int = 18;
	private static var MAPFRAME_HEIGHT:Int = 18;
	private static var MAPFRAME_X = MINIMAP_X - MAPFRAME_WIDTH;
	private static var MAPFRAME_Y = MINIMAP_Y - MAPFRAME_HEIGHT;
	
	private static var TIMER_HEIGHT = 100;
	private static var TIMER_WIDTH = 100;
	
	private static var SECS_PER_FRAME:Float;
	
	private var _timer:FlxSprite;
	private var totalTime:Int;
	private var _txtEscaped:FlxText;
	private var player:Player;
	private var screechBack:FlxSprite;
	private var screechCooldownBar:FlxSprite;
	private var dashBack:FlxSprite;
	private var dashCooldownBar:FlxSprite;
	private var minimap:FlxMinimap;
	private var mapFrame:FlxSprite;
	
	/** 
	 * Constructor for HUD. Takes in number of seconds passed, number of enemies that can
	 * escape, and number that have escaped.
	 */
	public function new(timer:Int, player:Player, escapeLimit:Int, numEscaped:Int, humanWalls:FlxTilemap, playerWalls:FlxTilemap, humanPlayerWalls:FlxTilemap) 
	{
		super();
		this.player = player;

		// timer text
		totalTime = timer;
		SECS_PER_FRAME = totalTime / 12;
		/*_txtTimer = new FlxText(0, 2, 40, secs, 16);
		_txtTimer.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);

		_txtTimer.alignment = "center";
		_txtTimer.x = FlxG.width / 2;

		this.add(_txtTimer);*/
		
		_timer = new FlxSprite(0, 0);
		_timer.loadGraphic(AssetPaths.time_anim__jpg, true, TIMER_WIDTH, TIMER_HEIGHT);
		_timer.x = (FlxG.width - _timer.width) / 2;
		_timer.scrollFactor.set(0, 0);
		_timer.animation.add("runTime", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 1);
		add(_timer);
		
		
		// screech cooldown bar
		//screechCooldownBar = createBar(BAR_X, BAR_Y, BAR_WIDTH, 20, FlxColor.YELLOW);
		screechBack = new FlxSprite(BAR_X, BAR_Y, AssetPaths.backbar__png);
		screechCooldownBar = new FlxSprite(BAR_X, BAR_Y, AssetPaths.screechbar__png);
		// dash cooldown bar
		
		dashBack = new FlxSprite(BAR_X, BAR_Y + BAR_GAP, AssetPaths.backbar__png);
		dashCooldownBar = new FlxSprite(BAR_X, BAR_Y + BAR_GAP, AssetPaths.dashbar__png);
		add(screechBack);
		add(screechCooldownBar);
		add(dashBack);
		add(dashCooldownBar);
		
		// escapee text
		var escaped = "Game over if " + Std.string(escapeLimit - numEscaped) + " escape!";
		_txtEscaped = new FlxText(FlxG.width - 250, 2, 250, escaped, 16);
		_txtEscaped.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		add(_txtEscaped);
		
		// minimap
		minimap = new FlxMinimap(humanWalls, playerWalls, humanPlayerWalls, this, MINIMAP_X, MINIMAP_Y, MINIMAP_WIDTH, MINIMAP_HEIGHT);
		mapFrame = new FlxSprite(MAPFRAME_X, MAPFRAME_Y, AssetPaths.minimap__png);
		mapFrame.scrollFactor.set(0, 0);
		this.add(mapFrame);
		this.add(minimap);
		
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set(0, 0);
		});
	}

	/**
	 * Create bar for various possible attributes e.g. Health, cooldown
	 * @param	X
	 * @param	Y
	 * @param	width
	 * @param	height
	 * @param	color
	 * @return
	 */
	public function createBar(X:Float=20, Y:Float=20, width:Int=500, height:Int=20, color:Int=0xffff0000):FlxSprite {

		var frame:FlxSprite = new FlxSprite(X-2, Y-2);
		frame.makeGraphic(width+4,height+4); //White frame for the bar
		frame.scrollFactor.x = frame.scrollFactor.y = 0;
		this.add(frame);
 
		var inside:FlxSprite = new FlxSprite(X,Y);
		inside.makeGraphic(width,height,0xff000000); //Black interior, 48 pixels wide
		inside.scrollFactor.x = inside.scrollFactor.y = 0;
		this.add(inside);
 
		var bar:FlxSprite = new FlxSprite(X,Y);
		bar.makeGraphic(1,height,color); //The bar itself
		bar.scrollFactor.x = bar.scrollFactor.y = 0;
		bar.origin.x = bar.origin.y = 0; //Zero out the origin
		bar.scale.x = width;
		this.add(bar);
		
		return bar;
	}

	/**
	 * Update function for bars
	 * @param	bar
	 * @param	val
	 * @param	cap
	 * @param	width
	 * @param	tween
	 */
	public static function updateBar(bar:FlxSprite, val:Int, cap:Int, width:Int, tween:Float=0) {
		val = val > 0 ? val : 0;
		
		bar.x = BAR_X - (bar.width * (1 - (val / cap))) ;
	}
	
	/**
	 * Updates rest of UI, such as timer and number of escapees
	 * @param	timer
	 * @param	escapeLimit
	 * @param	escapees
	 */
	public function updateHUD(timer:Int, escapeLimit:Int, escapees:Int):Void
	{
		/*_txtTimer.text = Std.string(timer);
		_txtTimer.x = FlxG.width / 2;// - 12 - _txtTimer.width - 4;*/
		var index = Std.int(Math.min((totalTime - timer) / SECS_PER_FRAME, 11));
		//trace(index);
		_timer.animation.frameIndex = index;
		
		var escaped = "Game over if " + Std.string(escapeLimit - escapees) + " escape";
		if (escapeLimit - escapees == 1)
			escaped += "s!";
		else
			escaped += "!";
		_txtEscaped.text = escaped;
		
		updateBar(screechCooldownBar, Player.SCREECH_COOLDOWN - player.getScreechCooldown(), Player.SCREECH_COOLDOWN, BAR_WIDTH);
		updateBar(dashCooldownBar, Player.DASH_COOLDOWN - player.getDashCooldown(), Player.DASH_COOLDOWN, BAR_WIDTH);
	}
	
	public function minimapInit(player:Player, snakeBody:FlxTypedGroup<SnakeBody>, enemies:FlxTypedGroup<Enemy>, exits:FlxTypedGroup<Exit>) {
		minimap.init(player, snakeBody, enemies, exits);
	}
	
}
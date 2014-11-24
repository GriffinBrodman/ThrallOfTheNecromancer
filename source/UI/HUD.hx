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
	private static var BAR_X:Int = 20;
	private static var BAR_Y:Int = 5;
	private static var BAR_GAP:Int = 5; // Currently unused; will use as number of pixels between bars
	private static var BAR_WIDTH:Int = 250;
	private static var BAR_HEIGHT:Int = 20;
	
	private static var MINIMAP_X:Int = 20;
	private static var MINIMAP_Y:Int = 20;
	private static var MINIMAP_WIDTH:Int = 200;
	private static var MINIMAP_HEIGHT:Int = 200;
	
	private var _txtTimer:FlxText;
	private var _txtEscaped:FlxText;
	private var player:Player;
	private var screechCooldownBar:FlxSprite;
	private var minimap:FlxMinimap;
	
	/** 
	 * Constructor for HUD. Takes in number of seconds passed, number of enemies that can
	 * escape, and number that have escaped.
	 */
	public function new(timer:Int, player:Player, escapeLimit:Int, numEscaped:Int, tiles:FlxTilemap) 
	{
		super();
		this.player = player;

		// timer text
		var secs:String = Std.string(timer);
		_txtTimer = new FlxText(0, 2, 40, secs, 16);
		_txtTimer.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);

		_txtTimer.alignment = "center";
		_txtTimer.x = FlxG.width / 2;

		this.add(_txtTimer);
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set(0, 0);
		});
		
		// cooldown bar
		screechCooldownBar = createBar(BAR_X, BAR_Y, BAR_WIDTH, 20, FlxColor.YELLOW);
		
		// escapee text
		var escaped = "Game over if " + Std.string(escapeLimit - numEscaped) + " escape!";
		_txtEscaped = new FlxText(FlxG.width - 250, 2, 250, escaped, 16);
		_txtEscaped.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		add(_txtEscaped);
		
		// minimap
		minimap = new FlxMinimap(tiles, this, MINIMAP_X, MINIMAP_Y, MINIMAP_WIDTH, MINIMAP_HEIGHT);
		this.add(minimap);
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
		
		bar.scale.x = val * width / cap;
	}
	
	/**
	 * Updates rest of UI, such as timer and number of escapees
	 * @param	timer
	 * @param	escapeLimit
	 * @param	escapees
	 */
	public function updateHUD(timer:Int, escapeLimit:Int, escapees:Int):Void
	{
		_txtTimer.text = Std.string(timer);
		_txtTimer.x = FlxG.width / 2;// - 12 - _txtTimer.width - 4;
		
		var escaped = "Game over if " + Std.string(escapeLimit - escapees) + " escape";
		if (escapeLimit - escapees == 1)
			escaped += "s!";
		else
			escaped += "!";
		_txtEscaped.text = escaped;
		
		updateBar(screechCooldownBar, Player.SCREECH_COOLDOWN - player.getScreechCooldown(), Player.SCREECH_COOLDOWN, BAR_WIDTH);
	}
	
	public function minimapInit(player:Player, snakeBody:FlxTypedGroup<SnakeBody>, enemies:FlxTypedGroup<Enemy>, exits:FlxTypedGroup<Exit>) {
		minimap.init(player, snakeBody, enemies, exits);
	}
	
}
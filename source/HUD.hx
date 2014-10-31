package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private static var BAR_WIDTH:Int = 250;
	
	private var _txtTimer:FlxText;
	private var player:Player;
	private var screechCooldownBar:FlxSprite;
	private var lureCooldownBar:FlxSprite;
	
	public function new(timer:Int, player:Player) 
	{
		super();
		this.player = player;

		var secs:String = Std.string(timer);
		_txtTimer = new FlxText(0, 2, 0, secs, 8);
		_txtTimer.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);

		_txtTimer.alignment = "center";
		_txtTimer.x = FlxG.width;// / 2; // - 12 - _txtTimer.width - 4;

		this.add(_txtTimer);
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
		});
		
		screechCooldownBar = createBar(20, FlxG.height - 35, BAR_WIDTH, 20, FlxColor.YELLOW);
		lureCooldownBar = createBar(20, FlxG.height - 60, BAR_WIDTH, 20, FlxColor.AZURE);
	}
	
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

	public static function updateBar(bar:FlxSprite, val:Int, cap:Int, width:Int, tween:Float=0) {
		val = val > 0 ? val : 0;
		
		bar.scale.x = val * width / cap;
	}
	
	public function updateHUD(timer:Int):Void
	{
		_txtTimer.text = Std.string(timer);
		_txtTimer.x = FlxG.width;// - 12 - _txtTimer.width - 4;
		
		updateBar(screechCooldownBar, Player.SCREECH_COOLDOWN - player.getScreechCooldown(), Player.SCREECH_COOLDOWN, BAR_WIDTH);
		updateBar(lureCooldownBar, Player.LURE_COOLDOWN - player.getLureCooldown(), Player.LURE_COOLDOWN, BAR_WIDTH);
	}
}
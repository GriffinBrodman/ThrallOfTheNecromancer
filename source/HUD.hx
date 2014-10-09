package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private var _sprBack:FlxSprite;
	private var _txtHealth:FlxText;
	private var _txtTimer:FlxText;
	private var _sprHealth:FlxSprite;
	private var _sprMoney:FlxSprite;
	
	public function new(timer:Int) 
	{
		super();
		//_sprBack = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		//_sprBack.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		//_txtHealth = new FlxText(16, 2, 0, "3 / 3", 8);
		//_txtHealth.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		var secs:String = Std.string(timer);
		_txtTimer = new FlxText(0, 2, 0, secs, 8);
		_txtTimer.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		//_sprHealth = new FlxSprite(4, _txtHealth.y + (_txtHealth.height/2)  - 4, AssetPaths.health__png);
		//_sprMoney = new FlxSprite(FlxG.width - 12, _txtTimer.y + (_txtTimer.height/2)  - 4, AssetPaths.coin__png);
		_txtTimer.alignment = "center";
		_txtTimer.x = FlxG.width;// / 2; // - 12 - _txtTimer.width - 4;
		//add(_sprBack);
		//add(_sprHealth);
		//add(_sprMoney);
		//add(_txtHealth);
		add(_txtTimer);
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
		});
	}
	
	public function updateHUD(timer:Int):Void
	//(Health:Int = 0, timer:Int = 0):Void
	{
		//_txtHealth.text = Std.string(Health) + " / 3";
		_txtTimer.text = Std.string(timer);
		_txtTimer.x = FlxG.width;// - 12 - _txtTimer.width - 4;
	}
}
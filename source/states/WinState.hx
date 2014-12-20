package states;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
import flixel.ui.FlxButton;

import Std;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Daniel W. Zhang
 */
class WinState extends FlxState
{
	private var _winScreen:FlxSprite;
	private var _beatTxt:FlxText;
	private var _text:FlxText;
	private var _nextLevel:Int;
	private var notTransitioning = true;
	private static var textSpacer = 40;

	public function new(nextLevel)
	{
		super();
		_nextLevel = nextLevel;
		_winScreen = new FlxSprite(0, 0, AssetPaths.winScreen__jpg);
		_winScreen.screenCenter(true, true);
		_winScreen.scrollFactor.set(0, 0);
		add(_winScreen);

		_beatTxt = new FlxText(0, 0, 0, "You beat the level!", 32);
		_beatTxt.screenCenter(true, true);
		_beatTxt.scrollFactor.set(0, 0);
		_text = new FlxText(0, 0, 0, "Press any key to continue", 32);
		_text.screenCenter(true, true);
		_text.y += textSpacer;
		_text.scrollFactor.set(0, 0);
		FlxG.sound.pause();
		FlxG.sound.playMusic(AssetPaths.winsound__mp3, 1, false);
		add(_text);
		updateSavedLevel(_nextLevel);
	}

	private function updateSavedLevel(Level:Int):Int
	{
		var _save:FlxSave = new FlxSave();
		var _hi:Int = Level;
		_save.bind("maize");
		if (_save.data.Level != null &&
			_save.data.Level > _hi)
			_hi = _save.data.Level;
		else
			_save.data.Level = _hi;
		_save.flush();
		_save.close();
		return _hi;
	}

	override public function update():Void {
		super.update();
		if (notTransitioning && FlxG.keys.firstJustReleased() != "") {
			notTransitioning = false;
			FlxG.switchState(new PlayState(_nextLevel));
		}
	}

	override public function destroy():Void {
		_winScreen = FlxDestroyUtil.destroy(_winScreen);
		_text = FlxDestroyUtil.destroy(_text);
		_beatTxt = FlxDestroyUtil.destroy(_beatTxt);
		super.destroy();
	}
}
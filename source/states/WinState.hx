package states;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import Std;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Daniel W. Zhang
 */
class WinState extends FlxSubState
{
	private var _winScreen:FlxSprite;
	private var _text:FlxText;
	public function new(BGColor:Int=FlxColor.TRANSPARENT)
	{
		super(BGColor);
		_winScreen = new FlxSprite(0, 0, AssetPaths.winScreen__jpg);
		_winScreen.screenCenter(true, true);
		_winScreen.scrollFactor.set(0, 0);
		add(_winScreen);
		
		_text = new FlxText(0, 0, 0, "Press any key to continue", 32);
		_text.screenCenter(true, true);
		_text.scrollFactor.set(0, 0);
		add(_text);
	}
	
	override public function update():Void {
		super.update();
		if (FlxG.keys.firstJustReleased() != "") {
			close();
		}
	}
	
	override public function destroy():Void {
		_winScreen = FlxDestroyUtil.destroy(_winScreen);
		_text = FlxDestroyUtil.destroy(_text);
		super.destroy();
	}
}
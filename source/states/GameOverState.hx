package states ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;

class GameOverState extends FlxState
{
	private var _currLevel:Int;			// number of coins we've collected
	private var _win:Bool;				// if we won or lost
	private var _txtTitle:FlxText;		// the title text
	private var _btnMainMenu:FlxButton;	// button to go to main menu
	private var _btnRetry:FlxButton;
	
	/**
	 * Called from PlayState, this will set our win and score variables
	 * @param	Win		true if the player beat the boss, false if they died
	 * @param	Score	the number of coins collected
	 */
	public function new(Win:Bool, currLevel:Int) 
	{
		_win = Win;
		_currLevel = currLevel;
		checkHiLevel(_currLevel);
		super();
	}
	
	override public function create():Void 
	{
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
		
		// create and add each of our items
		
		_txtTitle = new FlxText(0, 20, 0, _win ? "You Win!" : "Game Over!", 22);
		_txtTitle.alignment = "center";
		_txtTitle.screenCenter(true, false);
		add(_txtTitle);
		
		_btnRetry = new FlxButton(0, (FlxG.height / 2 - 10), "Retry", retry);
		_btnRetry.screenCenter(true, false);
		add(_btnRetry);
		
		_btnMainMenu = new FlxButton(0, (FlxG.height / 2 + 10), "Main Menu", goMainMenu);
		_btnMainMenu.screenCenter(true, false);
		_btnMainMenu.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_btnMainMenu);
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		super.create();
	}
	
	/**
	 * This function will compare the new score with the saved hi-score. 
	 * If the new score is higher, it will save it as the new hi-score, otherwise, it will return the saved hi-score.
	 * @param	Score	The new score
	 * @return	the hi-score
	 */
	private function checkHiLevel(Level:Int):Int
	{
		var _hi:Int = Level;
		var _save:FlxSave = new FlxSave();
		_save.bind("maize");
		if (_save.data.Level != null &&
			_save.data.Level > _hi)
		{
			_hi = _save.data.Level;
		}
		else
		{
			_save.data.Level = _hi;
		}
		_save.flush();
		_save.close();
		return _hi;
	}
	
	/**
	 * When the user hits the main menu button, it should fade out and then take them back to the MenuState
	 */
	private function goMainMenu():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
			FlxG.switchState(new MenuState());
		});
	}
	
	private function retry():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
			FlxG.switchState(new PlayState(_currLevel));
		});
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		// clean up all our objects!
		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
		_btnRetry = FlxDestroyUtil.destroy(_btnRetry);
	}
}
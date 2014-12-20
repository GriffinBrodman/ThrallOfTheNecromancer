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
	private static var textSpacer = 40;
	private var _currLevel:Int;			// current level
	private var _win:Bool;				// if we won or lost
	private var _btnMainMenu:FlxButton;	// button to go to main menu
	private var _btnRetry:FlxButton;
	private var _background:FlxSprite;
	private var _beatTxt:FlxText;
	private var _pressTxt:FlxText;
	
	/**
	 * Called from PlayState, this will set our win and score variables
	 * @param	Win		true if the player beat the boss, false if they died
	 * @param	Score	the number of coins collected
	 */
	public function new(Win:Bool, currLevel:Int) 
	{
		_win = Win;
		_currLevel = _win ? 1 : currLevel;
		updateSavedLevel(_currLevel);
		super();
	}
	
	override public function create():Void 
	{
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
		
		_background = new FlxSprite(0, 0, _win ? AssetPaths.beatGame__jpg : AssetPaths.loseScreen__jpg);
		_background.screenCenter(true, true);
		add(_background);
		
		// create and add each of our items
		if (_win)
		{
			_beatTxt = new FlxText(0, 0, 0, "Congratulations, you've beat the game!", 32);
			_pressTxt = new FlxText(0, 0, 0, "Press Z to return to the menu", 24);
			_beatTxt.screenCenter(true, true);
			_pressTxt.screenCenter(true, true);
			_pressTxt.y += textSpacer;
			add(_beatTxt);
			add(_pressTxt);
			FlxG.camera.fade(FlxColor.BLACK, .33, true);
			FlxG.sound.pause();
			FlxG.sound.playMusic(AssetPaths.winsound__mp3, 1, false);
		}
		else
		{
			_btnRetry = new FlxButton(0, 0, "", retry);
			_btnRetry.loadGraphic(AssetPaths.retryButton__png, false, 207, 300);
			_btnRetry.x = (FlxG.width / 2) - _btnRetry.width;
			_btnRetry.y = FlxG.height - _btnRetry.height;
			add(_btnRetry);
			
			_btnMainMenu = new FlxButton(0, 0, "", goMainMenu);
			_btnMainMenu.loadGraphic(AssetPaths.retMain__png, false, 207, 300);
			_btnMainMenu.x = _btnRetry.x + _btnRetry.width;
			_btnMainMenu.y = _btnRetry.y;
			add(_btnMainMenu);

			FlxG.camera.fade(FlxColor.BLACK, .33, true);
			FlxG.sound.pause();
			FlxG.sound.playMusic(AssetPaths.losesound__mp3, 1, false);
		}
		super.create();
	}
	
	override public function update():Void
	{
		super.update();
		if (_win)
		{
			if (FlxG.keys.firstJustReleased() == "Z")
				goMainMenu();
		}
		else
		{
			if (FlxG.keys.firstJustReleased() == "Z") 
			{
				retry();
			}
			if (FlxG.keys.firstJustReleased() == "X") 
				goMainMenu();
		}
	}
	
	/**
	 * This function will compare the new score with the saved hi-score. 
	 * If the new score is higher, it will save it as the new hi-score, otherwise, it will return the saved hi-score.
	 * @param	Score	The new score
	 * @return	the hi-score
	 */
	private function updateSavedLevel(Level:Int):Int
	{
		var _hi:Int = Level;
		var _save:FlxSave = new FlxSave();
		_save.bind("maize");
		if (_save.data.Level != null &&
			_save.data.Level > _hi && !_win)
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
		//_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		//_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
		_btnRetry = FlxDestroyUtil.destroy(_btnRetry);
		_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
		_background = FlxDestroyUtil.destroy(_background);
		_beatTxt = FlxDestroyUtil.destroy(_beatTxt);
		_pressTxt = FlxDestroyUtil.destroy(_pressTxt);
	}
}
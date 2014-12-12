package states ;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;


/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var STARTLEVEL:Int = 1;
	private var _background:FlxSprite;
	
	//private var _txtTitle:FlxText;
	private var _btnOptions:FlxButton;
	private var _btnPlay:FlxButton;
	#if desktop
	private var _btnExit:FlxButton;
	#end
	private var _btnContinue:FlxButton;
	private var _btnFullScreen:FlxButton;
	private var levelStart:Int;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		levelStart = STARTLEVEL;
		_background = new FlxSprite(0, 0, AssetPaths.menuBackground__jpg);
		add(_background);
		
		_btnFullScreen = new FlxButton(80, 80, FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED", clickFullscreen);
		_btnFullScreen.x = 10;
		_btnFullScreen.y = 10;
		add(_btnFullScreen);
		
		if (FlxG.sound.music == null) // don't restart the music if it's alredy playing
		{
			#if flash
			FlxG.sound.playMusic(AssetPaths.HaxeFlixel_Tutorial_Game__mp3, 1, true);
			#else
			FlxG.sound.playMusic(AssetPaths.HaxeFlixel_Tutorial_Game__ogg, 1, true);
			#end
		}
		
		_btnPlay = new FlxButton(0, 0, "", clickPlay);
		_btnPlay.loadGraphic(AssetPaths.newGameButton__png, false, 175, 285);
		_btnPlay.x = (FlxG.width / 2) - _btnPlay.width;
		_btnPlay.y = FlxG.height - _btnPlay.height;
		_btnPlay.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_btnPlay);

		var _save:FlxSave = new FlxSave();
		if (_save.bind("maize"))
		{
			if (_save.data.Level != null &&
			    _save.data.Level != STARTLEVEL)
			{
				levelStart = _save.data.Level;
				_btnContinue = new FlxButton(0, 0, "", clickPlay);
				_btnContinue.loadGraphic(AssetPaths.continueButton__png, false, 175, 285);
				_btnContinue.x = (FlxG.width / 2) - 1; // - _btnContinue.width;
				_btnContinue.y = FlxG.height - _btnContinue.height;
				_btnContinue.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
				add(_btnContinue);
			}
		}
		
		//_btnOptions = new FlxButton(0, 0, "Options", clickOptions);
		//_btnOptions.x = (FlxG.width / 2) - _btnOptions.width;
		//_btnOptions.y = FlxG.height - _btnOptions.height - 50;
		//_btnOptions.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		//add(_btnOptions);
		
		#if desktop
		_btnExit = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
		_btnExit.loadGraphic(AssetPaths.button__png, true, 20, 20);
		add(_btnExit);
		#end
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		
		super.create();
	}
	
	private function clickFullscreen():Void
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		_btnFullScreen.text = FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED";
	}
	
	#if desktop
	private function clickExit():Void
	{
		System.exit(0);
	}
	#end
	
	private function clickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false, function() {
			FlxG.switchState(new PlayState(STARTLEVEL));
		});
	}
	
	private function clickOptions():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false, function() {
			FlxG.switchState(new OptionsState());
		});
	}
	
	private function clickContinue():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,.33, false, function() {
			FlxG.switchState(new PlayState(levelStart));
		});
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_background = FlxDestroyUtil.destroy(_background);
		_btnPlay = FlxDestroyUtil.destroy(_btnPlay);
		_btnOptions = FlxDestroyUtil.destroy(_btnOptions);
		#if desktop
		_btnExit = FlxDestroyUtil.destroy(_btnExit);
		#end
		_btnFullScreen = FlxDestroyUtil.destroy(_btnFullScreen);
		_btnContinue = FlxDestroyUtil.destroy(_btnContinue);
	}
}
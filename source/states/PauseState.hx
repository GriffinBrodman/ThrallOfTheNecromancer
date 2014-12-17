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

class PauseState extends FlxSubState {
	private var frame:FlxSprite;
	private var text:FlxText;
	private var pauseButton:FlxButton;

	public function new(BGColor:Int=FlxColor.TRANSPARENT) {
		super(BGColor);
		
		frame = new FlxSprite(0, 0);
		frame.makeGraphic(200, 50);
		frame.color = FlxColor.BLACK;
		frame.alpha = 0.8;
		frame.scrollFactor.set(0, 0);
		frame.screenCenter(true, true);
		add(frame);
		
		text = new FlxText(0, 0, 0, "PAUSED", 30);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set(0, 0);
		//text.alignment = "center";
		text.screenCenter(true, true);
		add(text);
	}
	
	override public function update():Void {
		super.update();
		if (FlxG.keys.anyJustPressed(["ESCAPE"])) {
			close();
		}
	}
	
	override public function destroy():Void {
		frame = FlxDestroyUtil.destroy(frame);
		text = FlxDestroyUtil.destroy(text);
		super.destroy();
	}
	
}
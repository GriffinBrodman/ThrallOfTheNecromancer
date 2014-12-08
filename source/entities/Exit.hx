package entities;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author ...
 */
class Exit extends FlxSprite
{
	var escape = false;
	public function new(X:Float=0, Y:Float=0, escapable:Bool) 
	{
		super(X, Y);		
		escape = escapable;
		if (escape)
			loadGraphic("assets/images/exit.png", false, 64, 64);
		else
			makeGraphic(64, 64, FlxColor.TRANSPARENT);
	}
	
	public function canEscape():Bool
	{
		return escape;
	}
}
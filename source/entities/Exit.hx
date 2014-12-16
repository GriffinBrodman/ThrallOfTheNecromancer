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
	var graphicPath = "assets/images/exit";
	var graphicExt = ".png";
	public function new(X:Float=0, Y:Float=0, escapable:Bool, direction:String) 
	{
		super(X, Y);		
		escape = escapable;
		if (escape)
			loadGraphic(graphicPath + direction + graphicExt, false, 64, 64);
		else
			makeGraphic(64, 64, FlxColor.TRANSPARENT);
	}
	
	public function canEscape():Bool
	{
		return escape;
	}
}
package entities;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author ...
 */
class Exit extends FlxSprite
{
	private static var DENOMINATOR = 1;// 2;
	var escape = false;
	var graphicPath = "assets/images/exit";
	var graphicExt = ".png";
	var dir:String;
	public function new(X:Float=0, Y:Float=0, escapable:Bool, direction:String) 
	{
		super(X, Y);
		var offset = this.offset;
		dir = direction;
		escape = escapable;
		if (escape)
			loadGraphic(graphicPath + dir + graphicExt, false, 64, 64);
		else
			makeGraphic(64, 64, FlxColor.TRANSPARENT);
		switch (dir)
		{
			case "Up":
				this.height /= DENOMINATOR;
			case "Left":
				this.width /= DENOMINATOR;
			case "Right":
				this.width /= DENOMINATOR;
				this.offset.add((this.width / DENOMINATOR) * (DENOMINATOR - 1), 0);
			case "Down":
				this.height /= DENOMINATOR;
				this.offset.add(0, (this.height / DENOMINATOR ) * (DENOMINATOR - 1));
		}
	}
	
	public function canEscape():Bool
	{
		return escape;
	}
	
	public function getDirection():String
	{
		return dir;
	}
}
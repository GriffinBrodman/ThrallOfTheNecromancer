package entities;

/**
 * ...
 * @author ...
 */
class Exit extends Entity
{
	var escape = false;
	public function new(X:Float=0, Y:Float=0, escapable:Bool) 
	{
		super(X, Y);
		
		escape = escapable;
		if (escape)
			loadGraphic("assets/images/exit.png", false, 32, 32);
		else
			loadGraphic(AssetPaths.ground_tile__png, false, 32, 32);
	}
	
	public function canEscape():Bool
	{
		return escape;
	}
}
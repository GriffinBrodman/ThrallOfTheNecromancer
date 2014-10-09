package entities;

/**
 * ...
 * @author ...
 */
class Exit extends Entity
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/exit.png", false, 16, 16);
	}
	
}
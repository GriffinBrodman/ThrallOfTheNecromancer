package characters.enemies;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVelocity;
using flixel.util.FlxSpriteUtil;
import entities.Exit;

class DFSEnemy extends Enemy
{
	private static var NORMAL_SPEED:Int = 200;
	private static var SCARED_SPEED:Int = 300;

	override public function new(X:Float=0, Y:Float=0, walls:FlxTilemap, ground:FlxTilemap) 
	{
		normalSpeed = NORMAL_SPEED;
		scaredSpeed = SCARED_SPEED;
		super(X, Y, walls, ground);
		scared = false;
		pathing= false;
		state = "idle";
		scaredTime = 0;
		
	}
		
	override public function determinePath(tileMap:FlxTilemap):Void
	{	
		//Declare some temp data structures for pathfinding. 
		var path = new Array<FlxPoint>(); 																								//Keeps track of the path to exit	
		var visitedArrayArray:Array<Array<Bool>> = [for (x in 0...tileMap.widthInTiles) [for (y in 0...tileMap.heightInTiles) false]];	//Keeps track of whether each node is visited.	
		var nextTile = new FlxPoint();																									//nextTile to add to path
		var S = new Array<FlxPoint>();																									//For tileMap iteration
				
		S.push(currentTile);
		
		//If you haven't found the exit, keep searching
		while (!isExit(path[path.length - 1])) 
		{
			if (S.length != 0) 
			{
				nextTile = S.pop();
				if (visitedArrayArray[Std.int(nextTile.x)][Std.int(nextTile.y)] == false) 
				{					
					visitedArrayArray[Std.int(nextTile.x)][Std.int(nextTile.y)] = true;
					path.push(nextTile);
					for (n in 0...(getNeighborTiles(tileMap, (Std.int(nextTile.x / 128)), (Std.int(nextTile.y/ 128))).length)) 
					{
						S.push(getNeighborTiles(tileMap, (Std.int(nextTile.x / 128)), (Std.int(nextTile.y/ 128)))[n]);
					}
				}			
			}
			else 
			{
				break;
			}
		}		
		pathArray = path;
	}

	
	override public function update():Void 
	{
		super.update();
	}
	
	override public function idle():Void
	{
		super.idle();
	}
	
	override public function fleeing():Void
	{
		super.fleeing();
	}	
		
	override public function inLOS(x:Float, y:Float):Bool
	{
		return super.inLOS(x,y);
	}
	
	override public function draw():Void 
	{
		super.draw();
	}
	
	override public function stun(duration:Int) 
	{
		super.stun(duration);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
}

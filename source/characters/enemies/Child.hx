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
	


	override public function new(X:Float=0, Y:Float=0, walls:FlxTilemap, ground:FlxTilemap) 
	{
		super(X,Y, walls, ground);
		speed = 65;		
		scared = false;
		pathing= false;
		state = "idle";
		scaredTime = 0;
		
	}
		
	public function determinePath(tileMap:FlxTilemap):Array<FlxPoint>
	{	
		//Declare some temp data structures for pathfinding. 
		var path = new Array<FlxPoint>(); 			//Keeps track of the path to exit	
		var visitedArrayArray:Array<Array<Bool>>;	//Keeps track of whether each node is visited.	
		var nextTile = new FlxPoint();				//nextTile to add to path
		var S = new Array<FlxPoint>();				//For tileMap iteration
				
		S.push(currentTile);
		
		//If you can't see the exit, keep searching
		while (!isExit(path[path.length - 1])) 
		{
			//Check if the tile you are on is an intersection by seeing if it has more than 2 neighbors
			if (getNeighborTiles(tileMap, currentTile.x, currentTile.y).length < 3 )  //If it's not an intersection, dfs until you are at an intersection
			{
				if (S.length != 0) 
				{
					nextTile = S.pop();
					if (visitedArrayArray[nextTile.x][nextTile.y] == false) 
					{					
						visitedArrayArray[nextTile.x][nextTile.y] = true;
						path.push(nextTile);
						for (n in 0...getNeighborTiles(tileMap, (Std.int(nextTile.x / 128)), (Std.int(nextTile / 128))).length) 
						{
							S.push(n);
						}
					}			
				}
			}
			else //If you ARE on an intersection, choose a random direction to path to by adding a random neighbor
			{
				path.push(getObject_getRandom_T(getNeighborTiles(tileMap, currentTile.x, currentTile.y), 0, getNeighborTiles(tileMap, currentTile.x, currentTile.y).length));
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
	
	override public function chase():Void
	{
		super.chase();
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

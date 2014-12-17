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
	private static var NORMAL_SPEED:Int = 150;
	private static var SCARED_SPEED:Int = 250;

	override public function new(X:Float=0, Y:Float=0, walls:FlxTilemap) 
	{
		super(X, Y, walls);	
		normalSpeed = NORMAL_SPEED;
		scaredSpeed = SCARED_SPEED;
		curSpeed = normalSpeed;
		
	}
		
	override public function determinePath(tileMap:FlxTilemap):Void
	{	
		//Declare some temp data structures for pathfinding. 
		var path = new Array<FlxPoint>(); 																								//Keeps track of the path to exit			
		var visitedArrayArray:Array<Array<Bool>> = [for (x in 0...tileMap.widthInTiles) [for (y in 0...tileMap.heightInTiles) false]];	//Keeps track of whether each node is visited.			
		var nextTile:FlxPoint = new FlxPoint();																							//nextTile to add to path
		var S = new Array<FlxPoint>();																									//For tileMap iteration
				
		S.push(currentTile);		
			
		//Keep looping until he paths to an exit
		while (true) 
		{
			//If there are tiles on S
			if (S.length > 0) 
			{
				nextTile = S.pop();
				
				//TODO THIS DOESN'T WORK PROPERLY. walls.ray always returns true. Loops second time and causes null path error
				//Check if an exit is visible from here
				/*canSee(tileToCoords(nextTile), goals);				
				if (exitVisible) 
				{
					trace("exit is visible");
					path.push(nearestVisibleExit);
					break;
				}*/
				
				visitedArrayArray[Std.int(nextTile.x)][Std.int(nextTile.y)] = true;
				//Get neighbors of nextTile
				
				var neighbors = getNeighborTiles(tileMap, Std.int(nextTile.x), Std.int(nextTile.y));
				for (n in 0...neighbors.length) 
				{					
					//If the neighbor is unvisited, adds it to S
					if (visitedArrayArray[Std.int(neighbors[n].x)][Std.int(neighbors[n].y)] == false) 
					{
						S.push(neighbors[n]);
					}
				}
				
				
				if (nextTile != currentTile) 
				{
					//As long as tile isn't 
					path.push(nextTile);
					//Checks if tile is an exit entity
					if (isExit(nextTile)) 
					{
						//Check if tile is escapable
						for (g in goals) 
						{
							var gPos = new FlxPoint(Math.round(g.x/Enemy.TILE_DIMENSION)), Math.round(g.y/Enemy.TILE_DIMENSION));
							if (gPos.x == nextTile.x && gPos.y == nextTile.y) 
							{
								break;							
							}
						}
						break;
					}
					else 
					{
						continue;
					}
				}
				else 
				{
					continue;
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
	
	override public function searching():Void
	{
		super.searching();
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

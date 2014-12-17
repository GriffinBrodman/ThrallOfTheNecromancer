package characters.enemies ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVelocity;
import haxe.ds.IntMap;
import ui.Camera;
using flixel.util.FlxSpriteUtil;
import entities.Exit;

class Enemy extends FlxSprite
{
	public static var TILE_DIMENSION = 64.0; 
	
	private var normalSpeed:Int;
	private var scaredSpeed:Int;
	private var curSpeed:Int;
	
	private var position:FlxPoint;				//Current Position
	private var currentTile:FlxPoint;			//Current Tile
	public var pathing:Bool;					//Is this enemy walking to a tile currently
	private var pathArray:Array<FlxPoint>;		//Stores the enemy path
	private var exitVisible:Bool;				//Can the enemy see an exit. Only set in pathfinding.  
	private var nearestVisibleExit:FlxPoint;	//Closest visible exit
	private var path:FlxPath;					
	private var endPoint:FlxPoint;
	public static var exits:IntMap<Bool>;
	private var goals:FlxTypedGroup<Exit>;		//Group of escapable exits
	private var walls:FlxTilemap;	
	private var ground:FlxTilemap;
	public var state:String;
	
	public var scared:Bool;
	private var stunDuration:Int;
	private var fleeingTime:Int;
	public var snakePos(default, null):FlxPoint;
	
	public var minimapDot:FlxSprite;	// Reference to dot on minimap to blink when necessary; Used by minimap
	public var minimapDotTweening:Bool;
	
	private var oldFacing:Int;
	
	
	
	public function new(X:Float=0, Y:Float=0, map:FlxTilemap)
	{
		super(X, Y);
		position = new FlxPoint(X, Y);						
		pathing = false;					
		pathArray = [];					//Array used to navigate the player through the maze											
		walls = map;				//Tilemap for pathfinding
		state = "searching";		//Searching or scared 

		path = new FlxPath();											//Path 
		pathing = false;												//True if enemy is moving to another tile in a path
		
		scared = false;													//Why is this here?
		fleeingTime = 0;
		stunDuration = 0;
		
		snakePos = FlxPoint.get();		

		var type:Int = FlxRandom.int() % 4;
		if (type == 0) loadGraphic(AssetPaths.walkinganimation1__png, true, 64, 64);
		else if (type == 1) loadGraphic(AssetPaths.walkinganimation2__png, true, 64, 64);
		else if (type == 2) loadGraphic(AssetPaths.walkinganimation3__png, true, 64, 64);
		else if (type == 3) loadGraphic(AssetPaths.walkinganimation4__png, true, 64, 64);
		width = 20;
		height = 30;
		offset.x = 6;
		offset.y = 1;
		animation.add("run", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 8, true);
		animation.add("lr", [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21], 8, true);
		animation.play("run", true);
		
		setFacingFlip(FlxObject.DOWN, false, false);
		setFacingFlip(FlxObject.UP, false, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, true);
		drag.x = drag.y = 10;
		
		snakePos = FlxPoint.get();
		
		walls = map;
		path = new FlxPath();
	}
	
	public function updateCooldowns() 
	{
		if (stunDuration > 0)
			stunDuration--;
		if (fleeingTime > 0)
		{
			fleeingTime--;
			if (fleeingTime == 0){
				curSpeed = normalSpeed;
				path.speed = normalSpeed;
			}
		}			
	}
	
	public function setGoal(goal:FlxTypedGroup<Exit>) {
		goals = goal;
		endPoint = (goals.getRandom()).getMidpoint();
	}
	
	public function stun(duration:Int) {
		this.velocity.x = 0;
		this.velocity.y = 0;
		this.stunDuration = duration;
	}
	
	//Updates the field to represent the tile this enemy is currently standing on
	public function updateCurrentTile():Void 
	{
		currentTile = new FlxPoint(Math.round(this.x/TILE_DIMENSION), Math.round(this.y/TILE_DIMENSION));	
	}
	
	//Takes in a FlxPoint of tile coordinates and returns world coordinates
	public function tileToCoords(tile:FlxPoint):FlxPoint 
	{
		var point = new FlxPoint(tile.x * TILE_DIMENSION, tile.y * TILE_DIMENSION);
		return point;
	}
	
	//Returns the tilemap value of the tile at the given tile (not world) coordinates
	public function tileType(map:FlxTilemap,X:Int, Y:Int):Int 
	{
		return map.getTile(X,Y);
	}
	
	//Takes in a tilemap and tile coordinates; Returns an array of all the pathable neighbor tiles
	public function getNeighborTiles(map:FlxTilemap, X:Int, Y:Int):Array<FlxPoint> 
	{
		var neighbors = new Array<FlxPoint>();
		if (Y + 1 < map.heightInTiles) 
		{
			if (tileType(map, X, Y + 1) == 0) 
			{
			neighbors.push(new FlxPoint(X, Y + 1));
			}
		}
		if (Y - 1 > 0)
		{
			if (tileType(map, X, Y - 1) == 0) 
			{
				neighbors.push(new FlxPoint(X, Y - 1));
			}
		}
		if (X + 1 < map.widthInTiles) 
		{
			if (tileType(map, X + 1, Y) == 0) 
			{
				neighbors.push(new FlxPoint(X + 1, Y));
			}		
		}
		if (X - 1 > 0) 
		{
			if (tileType(map, X - 1, Y) == 0) 
			{
				neighbors.push(new FlxPoint(X - 1, Y));
			}
		}
		return neighbors;
	}
	
	//Checks if there is an exit at this location
	private function isExit(location:FlxPoint):Bool {
		if (exits == null){
			return false;
		}
		else {
			var val:Null<Bool> = exits.get(Std.int(location.x + location.y * walls.widthInTiles));
			return val == true;
		}		
	}
	
	public function canSee(pos:FlxPoint, goals:FlxTypedGroup<Exit>):Void
	{
		var visibleExits = new Array<FlxPoint>();	//Stores all the exits this enemy can see from current position				
		for (g in goals) 
		{
			trace("in loop");
			var gPos = new FlxPoint(g.x, g.y);
			trace("X is: " + pos.x/TILE_DIMENSION +" Y is: " + pos.y/TILE_DIMENSION);
			if (walls.ray(pos, gPos)) 	
			{
				trace("true");
				exitVisible = true;
				visibleExits.push(gPos);	
			}
		}
		
		if (exitVisible == true) 
		{
			nearestVisibleExit = visibleExits[0];
			for (e in 1...visibleExits.length) 
			{
				if (position.distanceTo(nearestVisibleExit) > position.distanceTo(visibleExits[e])) 
				{
					nearestVisibleExit = visibleExits[e];
				}
			}	
		}		
	}
	
	
	/*//Checks if a player can see an exit. Assumes an enemy can look in all four directions
	public function canSee(goals:FlxTypedGroup<Exit>):Bool	
	{
		while (!exitVisible) 
		{
			goals.forEach(canSeeHelper);	//Takes in a function with type Exit -> Void
		}									//Function breaks naturally when an exit is in sight becuase exitVisible becomes true
		return exitVisible;
	}
	
	//Function passed into canSee
	public function canSeeHelper(exit:Exit):Void
	{
		var result:FlxPoint = new FlxPoint();	//Needed as an argument for walls.ray()
		{
			var exitPos = new FlxPoint(exit.x, exit.y);
			walls.ray(position, exitPos, result, 1);	
			if (result == null) 						//Result equals null if no wall is hit, which means that it hit an exit
			{
				exitVisible = true;
				visibleExits.push(new FlxPoint(exit.x, exit.y));
			}
		}
		exitVisible = false;
	}*/
	
	//Checks if a Point is in the line of sight of this enemy
	public function inLOS(X:Float, Y:Float):Bool
	{
		if (this.facing == FlxObject.LEFT)
		{
			return X < this.x;
		}
		if (this.facing == FlxObject.RIGHT)
		{
			return X > this.x;
		}
		if (this.facing == FlxObject.UP)
		{
			return Y < this.y;
		}
		else
		{
			return Y > this.y;
		}
	}
	
	//Determines what path to take to exit
	public function determinePath(tileMap:FlxTilemap):Void { }
	
	//Finds path to target tile
	public function targetedDFS(tileMap:FlxTilemap, target:FlxPoint):Array<FlxPoint>
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
					//Checks if tile is the target
					if (nextTile == target)
					{
						break;							
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
		return path;
	}
	
	public function flee():Void 
	{
		//Define tile that the snake is on
		var snakeTile = new FlxPoint(Math.round(snakePos.x / TILE_DIMENSION), Math.round(snakePos.y / TILE_DIMENSION));
		
		while (true) 
		{		
			var newGoal:FlxPoint = goals.getRandom().getMidpoint();
			var newGoalTile = new FlxPoint(Math.round(newGoal.x / TILE_DIMENSION), Math.round(newGoal.y / TILE_DIMENSION));
			
			//Check path to goal vs path to snake
			var pathToGoal = targetedDFS(walls, newGoalTile);
			var pathToSnake = targetedDFS(walls, snakeTile);
			
			//If the first two steps of the respective paths are the same, recalculate path
			if (newGoal != endPoint) 
			{
				if (pathToGoal[1] != pathToSnake[1]) 
				{
					if (pathToGoal[2] != pathToSnake[2]) 
					{
						endPoint = newGoal;
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
				continue;
			}
		}
			
		var pathPoints:Array<FlxPoint> = walls.findPath(getMidpoint(), endPoint);
		if (pathPoints != null && !pathing) 
		{
			pathing = true;
			path.start(this,pathPoints, curSpeed);
		}
	}
	
	
	
	public function searching():Void
	{
		if (scared)
		{
			path.cancel();
			pathing = false;
			state = "fleeing";
			fleeingTime = 50;
			curSpeed = scaredSpeed;
			path.speed = scaredSpeed;
		}
		else 
		{
			if (stunDuration > 0)
			{
				path.cancel();
				pathing = false;
			}
			
			if (path.finished)
			{
				path.cancel();
				pathing = false;
			}
			
			if (!pathing) 
			{
				if (pathArray.length == 0) 
				{
					determinePath(walls);
				}
				else if (pathArray.length > 0) 
				{					
					var newEnd:FlxPoint = pathArray.shift();
					var pathPoints = walls.findPath(tileToCoords(currentTile), tileToCoords(newEnd));
					path.start(this, pathPoints, curSpeed);
					pathing = true;
				}
				/*var newEnd:FlxPoint = goals.getRandom().getMidpoint();
				while (newEnd == endPoint) newEnd = goals.getRandom().getMidpoint();
				endPoint = newEnd;
				var pathPoints:Array<FlxPoint> = walls.findPath(getMidpoint(), endPoint);
				if (pathPoints != null && !pathing) 
				{
					pathing = true;
					path.start(this,pathPoints, curSpeed);
				}*/
			}
		}
	}
	
	public function fleeing():Void
	{
		//NEW REPEL DOESN'T WORK; DO NOT DELETE THIS BLOCK OF CODE
		/*if (fleeingTime == 0)
		{
			state = "searching";
		}
		else 
		{
			if (stunDuration > 0)
			{
				path.cancel();
				pathing = false;
			}
			if (pathing == false) 
			{
				pathArray = [];
				flee();
			}
		}*/
			
		
		if (fleeingTime == 0)
		{
			state = "searching";
		}
		else 
		{
			if (stunDuration > 0)
			{
				path.cancel();
				pathing = false;
			}
			else if (pathing == false)
			{
				pathArray = [];
				flee();
				var pathPoints:Array<FlxPoint> = walls.findPath(getMidpoint(), endPoint);
				if (pathPoints != null && !pathing) 
				{
					pathing = true;
					path.start(this,pathPoints, curSpeed);
				}
			}
			else /*if (pathing == false)*/ 
			{
				var newEnd:FlxPoint = goals.getRandom().getMidpoint();
				while (newEnd == endPoint) 
				{
					newEnd = goals.getRandom().getMidpoint();
				}
				endPoint = newEnd;
				var pathPoints:Array<FlxPoint> = walls.findPath(getMidpoint(), endPoint);
				if (pathPoints != null && !pathing) 
				{
					pathing = true;
					path.start(this,pathPoints, curSpeed);
				}
			}		
		}
	}
	
	override public function update():Void 
	{
		position.x = this.x;
		position.y = this.y;
		updateCurrentTile();
		if (isFlickering())
		{
			return;
		}
		if (state == "searching") 
		{
			searching();
		}
		if (state == "fleeing") 
		{
			fleeing();
		}
		
		updateCooldowns();
		
		super.update();
		
		if (stunDuration > 0)
			this.setColorTransform(3, 3, 1);
		else if (scared)
			this.setColorTransform(3, 1, 1);
		else
			this.setColorTransform(1, 1, 1);
	}
	
	override public function draw():Void 
	{
		if (Math.abs(velocity.x) > Math.abs(velocity.y))
		{
			if (velocity.x < 0)
				facing = FlxObject.LEFT;
			else
				facing = FlxObject.RIGHT;
		}
		else if (Math.abs(velocity.x) < Math.abs(velocity.y))
		{
			if (velocity.y < 0)
				facing = FlxObject.UP;
			else
				facing = FlxObject.DOWN;
		}
		else {
			facing = FlxObject.NONE;
		}
		
		if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT)
		{
			animation.play("lr");
		} 
		else if (facing == FlxObject.DOWN || facing == FlxObject.UP)
		{
			animation.play("run");
		}
		else
		{
			animation.pause();
		}
			
		super.draw();
	}
	
	override public function destroy():Void 
	{
		if (pathing){
			path.cancel();
			FlxDestroyUtil.destroy(path);
			pathing = false;
		}
		super.destroy();		
	}
	
	/*
	 * 1.) Assign to every node a tentative distance value: set it to 
	 * zero for our initial node and to infinity for all other nodes.
	 * 
	 * 2.) Mark all nodes unvisited. Set the initial node as current. 
	 * Create a set of the unvisited nodes called the unvisited set 
	 * consisting of all the nodes.
	 * 
	 * 3.) For the current node, consider all of its unvisited neighbors 
	 * and calculate their tentative distances. Compare the newly calculated 
	 * tentative distance to the current assigned value and assign the smaller 
	 * one. For example, if the current node A is marked with a distance of 6, 
	 * and the edge connecting it with a neighbor B has length 2, then the 
	 * distance to B (through A) will be 6 + 2 = 8. If B was previously marked 
	 * with a distance greater than 8 then change it to 8. Otherwise, keep the 
	 * current value.
	 * 
	 * 4.) When we are done considering all of the neighbors of the current node, 
	 * mark the current node as visited and remove it from the unvisited set. 
	 * A visited node will never be checked again. 
	 * 
	 * 5.) If the destination node has been marked visited (when planning a route 
	 * between two specific nodes) or if the smallest tentative distance among the 
	 * nodes in the unvisited set is infinity when planning a complete traversal; 
	 * occurs when there is no connection between the initial node and remaining 
	 * unvisited nodes), then stop. The algorithm has finished.
	 * 
	 * 6.)	Select the unvisited node that is marked with the smallest tentative 
	 * distance, and set it as the new "current node" then go back to step 3.*/
	
	public function findTarget(tileMap:FlxTilemap, start:FlxPoint, end:FlxPoint):Array<FlxPoint>
	{
		var current:FlxPoint;				//Current tile being considered
		var previous:FlxPoint;				//Used to reconstruct path
		var Q = new Array<FlxPoint>();		//Array for iteration
		var path = new Array<FlxPoint>();	//Path to target		
		var visitedArrayArray:Array<Array<Bool>> = [for (x in 0...tileMap.widthInTiles) [for (y in 0...tileMap.heightInTiles) false]];	//Keeps track of whether each node is visited.	
		var previousArrayArray:Array<Array<Int>> = [for (x in 0...tileMap.widthInTiles) [for (y in 0...tileMap.heightInTiles) null]];		//Keeps track of previous node
		
		//Start at the given start tile
		current = start;
		Q.push(current);
		
		//Get neighbors of tile
		while (Q.length > 0) 
		{
			current = Q.shift();
			var neighbors = getNeighborTiles(current);
			for(n in 0...neighbors.length) 
			{
				//if neighbor is unvisited, enqueue it
				if (visitedArrayArray[neighbors[n].x][neighbors[n].y] == null) 
				{
					Q.push(neighbors[n]);
					visitedArrayArray[current.x][current.y] = true;
				}
			}
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		return path;
	}
	
	
	
	
}
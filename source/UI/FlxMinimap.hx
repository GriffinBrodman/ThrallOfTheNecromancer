package ui ;
import characters.enemies.Enemy;
import characters.Player;
import characters.SnakeBody;
import entities.Exit;
import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import openfl.geom.Matrix;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Peter Shi
 */
class FlxMinimap extends FlxSprite
{
	private static var MINIMAP_ALPHA:Float = 0.75;
	private static var BLINK_DISTANCE:Int = 200;		//Maximum distance between enemy and exit for which enemy starts to blink

	// bitmapdata used drawing and scaling the image of the level
	private var bmd:BitmapData;
	// all the dots currently visible on the minimap (shame there isn't an Object placeholder we can abuse somewhere, now we split the work over 2 arrays)
	private var dots:FlxTypedGroup<FlxSprite>;
	// an array containing all objects that are followed on the minimap
	private var objects:Array<Array<FlxSprite>> = [];
	// scaling factor for the objects to correctly position them on the minimap
	private var sx:Float;
	private var sy:Float;
	// the tilemap we are representing
	private var tilemap:FlxTilemap;
	// internal placeholders for the empty and solid colors
	private var solidColor:UInt = 0x000000;
	private var emptyColor:UInt = 0xffffff;
	private var dotWidth:Int;
	private var dotHeight:Int;
	
	private var grpEnemies:FlxTypedGroup<Enemy>;
	private var grpExits:FlxTypedGroup<Exit>;
	
	public function new(tilemap:FlxTilemap, dots:FlxTypedGroup<FlxSprite>, X:UInt, Y:UInt, W:UInt, H:UInt) {			
		super(X, Y);
		this.tilemap = tilemap;
		this.dots = dots;
		width = W;
		height = H;
		dotWidth = Std.int(W / tilemap.widthInTiles);
		dotHeight = Std.int(H / tilemap.heightInTiles);
		// don't scroll with the camera
		scrollFactor = new FlxPoint();	
		// read the level data and scale to correct size
		read();
		scaleTo(width, height);			
		// set pixel data
		pixels = bmd;
		
		set_alpha(MINIMAP_ALPHA);
	}
	
	public function init(player:Player, snakeBody:FlxTypedGroup<SnakeBody>, enemies:FlxTypedGroup<Enemy>, exits:FlxTypedGroup<Exit>) {
		objects = [];
		
		grpEnemies = enemies;
		grpExits = exits;
		
		for (exit in grpExits) {
			if (exit.canEscape())
				follow(exit, FlxColor.AZURE);
		}
		for (enemy in grpEnemies)
			enemy.minimapDot = follow(enemy, FlxColor.RED);
		for (snakeBody in snakeBody)
			follow(snakeBody, FlxColor.PURPLE);
		follow(player, FlxColor.PURPLE);
	}
	
	/**
	 * Update position to reflect object accurately
	 */
	override public function update():Void {
		for (obj in objects) {
			if (!obj[0].exists) {
				FlxDestroyUtil.destroy(obj[1]);
				objects.remove(obj);
			} else {
				obj[1].x = x + Std.int(obj[0].x / sx) - offset.x;
				obj[1].y = y + Std.int(obj[0].y / sy) - offset.y;
			}
		}
		
		for (enemy in grpEnemies) {
			if (enemy != null && enemy.exists && enemy.minimapDot != null && !enemy.minimapDotTweening){	
				for (exit in grpExits) {
					if (exit.canEscape() && FlxMath.isDistanceWithin(enemy, exit, BLINK_DISTANCE)) {
						enemy.minimapDotTweening = true;
						FlxTween.tween(enemy.minimapDot.scale, { x:2, y:2 }, 0.25, { complete: function(f:FlxTween) {
							if (enemy != null && enemy.exists && enemy.minimapDot != null){
								FlxTween.tween(enemy.minimapDot.scale, { x: 1, y:1 }, 0.25, { complete: function(f:FlxTween) {
									enemy.minimapDotTweening = false;
								}});
							}
						}} );
						break;
					}
				}
			}
		}
		super.update();
	}
	
	/**
	 * Clean up after ourselves when we get destroyed
	 */
	override public function destroy():Void {
		super.destroy();
	}		
	
	/**
	 * Refresh the minimap from scratch
	 */
	public function refresh():Void {			
		// redo the minimap
		read();
		scaleTo(width, height);
		// set pixel data
		pixels = bmd;		
	}
	
	/**
	 * Add an object to be followed on the minimap
	 * 
	 * @param	Obj the object to follow
	 * @param	Color the 0xAARRGGBB color of the icon representing the object on the minimap
	 */
	public function follow(obj:FlxSprite, color:UInt = 0xFFFF0000):FlxSprite{		
		var dot:FlxSprite = new FlxSprite();
		dot.makeGraphic(dotWidth, dotHeight, color - 0xAA000000);
		dot.drawEllipse(0, 0, dotWidth, dotHeight, color);
		dot.scrollFactor = new FlxPoint();
		//dot.set_alpha(minimapAlpha);
		dots.add(dot);
		objects.push([obj, dot]);
		
		return dot;
	}
	
	/**
	 * Scale bmd to correct size
	 * 
	 * @param	W the width
	 * @param	H the height
	 */
	private function scaleTo(W:Float, H:Float):Void {
		// compute scale
		var s:Int = Math.round(W / tilemap.widthInTiles);
		if (tilemap.heightInTiles > tilemap.widthInTiles) {
			// keep the longest side within the minimap bounds
			s = Math.round(H / tilemap.heightInTiles);
		}
		// construct the scaling matrix
		var matrix:Matrix = new Matrix();
		matrix.scale(s, s);
		var scaled:BitmapData = new BitmapData(bmd.width * s, bmd.height * s, true, 0xff000000);
		scaled.draw(bmd, matrix, null, null, null, true);
		bmd = scaled;
		// scale factor pre compute for objects
		sx = tilemap.width / bmd.width;
		sy = tilemap.height / bmd.height;
		// offset needed to center the minimap
		offset.x = -((W / 2) - (bmd.width / 2));
		offset.y = -((H / 2) - (bmd.height / 2));
	}
	
	
	/**
	 * Read the data from the tilemap and plot as points on a bitmap
	 */
	private function read():Void {
		// draw unscaled
		bmd = new BitmapData(tilemap.widthInTiles, tilemap.heightInTiles, true, 0xff000000);			
		for (y in 0...bmd.height) {
			for (x in 0...bmd.width) {
				if(tilemap.getTile(x, y) > 0) {
					bmd.setPixel(x, y, solidColor);
				} else {
					bmd.setPixel(x, y, emptyColor);
				}
			}
		}
	}
	
}
package ui ;
import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import openfl.geom.Matrix;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Peter Shi
 */
class FlxMinimap extends FlxSprite
{

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
	private var solidColor:UInt = 0xffffff;
	private var emptyColor:UInt = 0x000000;
	private var dotWidth:Int;
	private var dotHeight:Int;
	
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
	}
	
	/**
	 * Update position to reflect object accurately
	 */
	override public function update():Void {
		for (obj in objects) {
			if (!obj[0].exists) {
				FlxDestroyUtil.destroy(obj[1]);
				objects.remove(obj);
			}
			obj[1].x = x + Std.int(obj[0].x / sx) - offset.x;
			obj[1].y = y + Std.int(obj[0].y / sy) - offset.y;
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
	public function follow(obj:FlxSprite, color:UInt = 0xFFFF0000):Void	{
		var dot:FlxSprite = new FlxSprite();
		dot.makeGraphic(dotWidth, dotHeight, color);
		//dot.drawEllipse(dotWidth / 2, dotHeight / 2, dotWidth, dotHeight, color);
		dot.scrollFactor = new FlxPoint();
		dots.add(dot);
		objects.push([obj, dot]);
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
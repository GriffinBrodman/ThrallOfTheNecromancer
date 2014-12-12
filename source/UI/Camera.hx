package ui;

import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * ...
 * @author Peter Shi
 */
class Camera
{
	private static var shakeCooldown:Int;
	private static var flashCooldown:Int;
	
	public static function shake(shakeIntensity:Float, shakeDuration:Int, ?force:Bool = false, ?OnComplete:Void -> Void) {
		if (force || shakeCooldown <= 0) {
			FlxG.camera.shake(shakeIntensity, shakeDuration / 60, OnComplete);
			shakeCooldown = shakeCooldown > shakeDuration ? shakeCooldown : shakeDuration;
		}
	}
	
	public static function flash(color:Int, duration:Int, alpha:Float) {
		FlxG.camera.flash(color, duration / 60, null, true, alpha);
	}
	
	public static function update() {
		if (shakeCooldown > 0)
			shakeCooldown--;
	}
	
}
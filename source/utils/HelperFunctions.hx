package utils;
import flixel.ui.FlxBar;
import flixel.text.FlxText;

class HelperFunctions
{
    public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	public static function setTextBorder(target:FlxText, borderStyle:String) {
		switch (borderStyle) {
			case "NONE": target.borderStyle = NONE;
			case "SHADOW": target.borderStyle = SHADOW;
			case "OUTLINE": target.borderStyle = OUTLINE;
			case "OUTLINE_FAST": target.borderStyle = OUTLINE_FAST;
		}
	}

	public static function setBarFillDirection(target:FlxBar, direction:String) {
		switch (direction) {
			case "LEFT_TO_RIGHT": target.fillDirection = LEFT_TO_RIGHT;
			case "RIGHT_TO_LEFT": target.fillDirection = RIGHT_TO_LEFT;
			case "TOP_TO_BOTTOM": target.fillDirection = TOP_TO_BOTTOM;
			case "BOTTOM_TO_TOP": target.fillDirection = BOTTOM_TO_TOP;
			case "HORIZONTAL_INSIDE_OUT": target.fillDirection = HORIZONTAL_INSIDE_OUT;
			case "HORIZONTAL_OUTSIDE_IN": target.fillDirection = HORIZONTAL_OUTSIDE_IN;
			case "VERTICAL_INSIDE_OUT": target.fillDirection = VERTICAL_INSIDE_OUT;
			case "VERTICAL_OUTSIDE_IN": target.fillDirection = VERTICAL_OUTSIDE_IN;
		}
	}
}
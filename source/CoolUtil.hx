package;

import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CoolUtil
{
	/*public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}*/

	public static function getShaderStuffs(shaderPaths:Array<String>) {
		var rets = [];
		if (FileSystem.exists(shaderPaths[0])) rets.push(File.getContent(shaderPaths[0]));
		else rets.push(null);

		if (FileSystem.exists(shaderPaths[1])) rets.push(File.getContent(shaderPaths[1]));
		else rets.push(null);
		
		return rets;
	}
	
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = File.getContent(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	
	public static function coolStringFile(path:String):Array<String>
		{
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	
	public static function msToTimestamp(ms:Float) {
		var seconds = Math.round(ms) / 1000;
		var minutesLeft = Std.string(seconds / 60).split(".")[0];
		var secondsLeft = Std.string(seconds % 60).split(".")[0];
        return '${minutesLeft}:${(secondsLeft.length == 1 ? "0" : "") + secondsLeft}';
	}
}

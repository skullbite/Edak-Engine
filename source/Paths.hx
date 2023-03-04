package;

import openfl.media.Sound;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.io.File;
import sys.FileSystem;

using StringTools;
       
class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var curModDir:Null<String>;

	static public function getPath(file:String, ?library:Null<String>)
	{
		if (curModDir != null) {
			var daModPath = (library != null ? getLibraryPath(file, library) : getPreloadPath(file)).replace("assets/", curModDir + "/");
			if (FileSystem.exists(daModPath)) return daModPath;
		}

		if (library != null)
			return getLibraryPath(file, library);

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload") return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	inline static function getLibraryPathForce(file:String, library:String) return 'assets/$library/$file';
	inline static function getPreloadPath(file:String) return 'assets/$file';
	inline static public function shader(key:String):Array<String> return [getPath('shaders/$key.frag'), getPath('shaders/$key.vert')];
	inline static public function songDataDir(key:String) return FileSystem.readDirectory(getPath('songs/$key'));
	inline static public function scriptDir() return FileSystem.readDirectory(getPath('scripts'));
	inline static public function yaml(key:String, ?library:String) return getPath('data/$key.yaml', library);
	inline static public function txt(key:String, ?library:String) return getPath('data/$key.txt', library);
	inline static public function xml(key:String, ?library:String) return getPath('data/$key.xml', library);
	inline static public function json(key:String, isSong=false, ?library:String) return getPath('${isSong ? "songs" : "data"}/$key.json', library);
	inline static public function video(key:String, ?library:String) return getPath('videos/$key', library);
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String) return sound(key + FlxG.random.int(min, max), library);
	inline static public function font(key:String) return getPath('fonts/$key');
	inline static public function getBitmap(key:String) return BitmapData.fromFile(key);

	inline static public function sound(key:String, ?library:String) {
		var soundPath:Dynamic = getPath('sounds/$key.$SOUND_EXT', library);
		if (!Assets.exists(soundPath) && FileSystem.exists(soundPath)) soundPath = Sound.fromFile(soundPath);
		return soundPath;
	}

	inline static public function music(key:String, ?library:String)
	{
		var musicPath:Dynamic = getPath('music/$key.$SOUND_EXT', library);
		if (!Assets.exists(musicPath) && FileSystem.exists(musicPath)) musicPath = Sound.fromFile(musicPath);
		return musicPath;
	}

	inline static public function voices(song:String, ?altSong:String="")
	{
		var coolPath:Dynamic = 'songs/${song.toLowerCase()}/Voices';
		if (altSong != "") coolPath += '-$altSong';
		coolPath += '.$SOUND_EXT';
		coolPath = getPath(coolPath);
		if (!Assets.exists(coolPath) && FileSystem.exists(coolPath)) coolPath = Sound.fromFile(coolPath);
		return coolPath;
	}

	inline static public function inst(song:String, ?altSong:String="")
	{
		var coolPath:Dynamic = 'songs/${song.toLowerCase()}/Inst';
		if (altSong != "") coolPath += '-$altSong';
		coolPath += '.$SOUND_EXT';
		coolPath = getPath(coolPath);
		if (!Assets.exists(coolPath) && FileSystem.exists(coolPath)) coolPath = Sound.fromFile(coolPath);
		return coolPath;
	}

	inline static public function image(key:String, ?library:String)
	{
		var imgPath:Dynamic = getPath('images/$key.png', library);
		if (!Assets.exists(imgPath) && FileSystem.exists(imgPath)) imgPath = Paths.getBitmap(imgPath);
		return imgPath;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?forcePath:Bool=false, ?manuallyFetch:Bool=false)
	{
		var img:Dynamic = forcePath ? key+".png" : image(key, library);
		var xml:Dynamic = forcePath ? key+".xml" : getPath('images/$key.xml', library);
		if (!Assets.exists(xml)) xml = File.getContent(xml);

		return FlxAtlasFrames.fromSparrow(img, xml);
	}

	inline static public function getPackerAtlas(key:String, ?library:String, ?forcePath:Bool=false, ?manuallyFetch:Bool=false)
	{
		var img:Dynamic = forcePath ? key+".png" : image(key, library);
		var txt:Dynamic = forcePath ? key+".txt" : getPath('images/$key.txt', library);
		if (!Assets.exists(txt)) txt = File.getContent(txt);

		return FlxAtlasFrames.fromSpriteSheetPacker(img, txt);
	}
}

class CustomPaths {
	var dir:String = "";
	var lib:String = "";
	var useFullDir:Bool = false;
	public function new(dir:String, lib:String) {
		this.dir = dir;
		this.lib = lib;
	}

	public function video(key:String) return Paths.getPath('$dir/${useFullDir ? 'videos/' : ''}$key', lib);
	public function music(key:String) return Paths.getPath('$dir/${useFullDir ? 'music/' : '' }$key.${Paths.SOUND_EXT}', lib);
	public function sound(key:String) return Paths.getPath('$dir/${useFullDir ? 'sounds/' : '' }$key.${Paths.SOUND_EXT}', lib);
	public function soundRandom(key:String, min:Int, max:Int) return sound(key + FlxG.random.int(min, max));
	public function txt(key:String) return Paths.getPath('$dir/${useFullDir ? 'data/' : '' }$key.txt', lib);
	public function json(key:String) return Paths.getPath('$dir/${useFullDir ? 'data/' : '' }$key.json', lib);

	public function image(key:String) {
		var imgPath:Dynamic = Paths.getPath('$dir/${useFullDir ? 'images/' : '' }$key.png', lib);
		if (!Assets.exists(imgPath)) imgPath = Paths.getBitmap(imgPath);
		return imgPath;
	}

    public function getSparrowAtlas(key:String) {
		var img:Dynamic = image(key);
		var xml:Dynamic = Paths.getPath('$dir/${useFullDir ? 'images/' : '' }$key.xml', lib);
		if (!Assets.exists(xml)) xml = File.getContent(xml);
		return FlxAtlasFrames.fromSparrow(img, xml);
	}
	
	public function getPackerAtlas(key:String) {
		var img:Dynamic = image(key);
		var txt:Dynamic = Paths.getPath('$dir/${useFullDir ? 'images/' : '' }$key.txt', lib);
		if (!Assets.exists(txt)) txt = File.getContent(txt);
		return FlxAtlasFrames.fromSpriteSheetPacker(img, txt);
	}
}
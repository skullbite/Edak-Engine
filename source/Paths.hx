package;

import openfl.media.Sound;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import sys.io.File;
import sys.FileSystem;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return 'assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function shader(key:String):Array<String> {
		return ['assets/shaders/$key.frag', 'assets/shaders/$key.vert'];
	}

	inline static public function songDataDir(key:String) {
		return FileSystem.readDirectory('assets/songs/$key');
	}
	
	inline static public function scriptDir() {
		return FileSystem.readDirectory('assets/scripts');
	}
	
	inline static public function difficulty(key:String) {
		return getPath('data/difficulties/$key.yaml', TEXT, null);
	}

	inline static public function weekData(key:String) {
		return getPath('data/weeks/$key.yaml', TEXT, null);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, isSong=false, ?library:String)
	{
		return getPath('${isSong ? "songs" : "data"}/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		var soundPath:Dynamic = getPath('sounds/$key.$SOUND_EXT', SOUND, library);
		return soundPath;
	}

	static public function video(key:String, ?library:String) {
		return getPath('videos/$key', MOVIE_CLIP, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		var musicPath:Dynamic = getPath('music/$key.$SOUND_EXT', MUSIC, library);
		if (!Assets.exists(musicPath) && FileSystem.exists(musicPath)) musicPath = Sound.fromFile(musicPath);
		return musicPath;
	}

	inline static public function voices(song:String, ?altSong:String="")
	{
		var coolPath:Dynamic = 'assets/songs/${song.toLowerCase()}/Voices';
		if (altSong != "") coolPath += '-$altSong';
		coolPath += '.$SOUND_EXT';
		if (!Assets.exists(coolPath) && FileSystem.exists(coolPath)) coolPath = Sound.fromFile(coolPath);
		return coolPath;
	}

	inline static public function inst(song:String, ?altSong:String="")
	{
		var coolPath:Dynamic = 'assets/songs/${song.toLowerCase()}/Inst';
		if (altSong != "") coolPath += '-$altSong';
		coolPath += '.$SOUND_EXT';
		if (!Assets.exists(coolPath) && FileSystem.exists(coolPath)) coolPath = Sound.fromFile(coolPath);
		return coolPath;
	}

	inline static public function image(key:String, ?library:String)
	{
		var imgPath:Dynamic = getPath('images/$key.png', IMAGE, library);
		if (!Assets.exists(imgPath) && FileSystem.exists(imgPath)) imgPath = Paths.getBitmap(imgPath);
		return imgPath;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getBitmap(key:String, ?library:String) {
		return BitmapData.fromFile(key);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?forcePath:Bool=false, ?manuallyFetch:Bool=false)
	{
		var img:Dynamic = forcePath ? key+".png" : image(key, library);
		var xml:Dynamic = forcePath ? key+".xml" : file('images/$key.xml', library);
		if (!Assets.exists(xml)) xml = File.getContent(xml);

		return FlxAtlasFrames.fromSparrow(img, xml);
	}

	inline static public function getPackerAtlas(key:String, ?library:String, ?forcePath:Bool=false, ?manuallyFetch:Bool=false)
	{
		var img:Dynamic = forcePath ? key+".png" : image(key, library);
		var txt:Dynamic = forcePath ? key+".txt" : file('images/$key.txt', library);
		if (!Assets.exists(txt)) txt = File.getContent(txt);

		return FlxAtlasFrames.fromSpriteSheetPacker(img, txt);
	}
}

class CustomPaths {
	var dir:String = "";
	var lib:String = "";
	public function new(dir:String, lib:String) {
		this.dir = dir;
		this.lib = lib;
	}

	public function video(key:String, useFullDir=false) {
		return Paths.getPath('$dir/${useFullDir ? 'videos/' : ''}$key', MOVIE_CLIP, lib);
	}

	public function music(key:String,useFullDir=false) {
		return Paths.getPath('$dir/${useFullDir ? 'music/' : '' }$key.${Paths.SOUND_EXT}', MUSIC, lib);
	}
	
	public function sound(key:String, useFullDir=false) {
		return Paths.getPath('$dir/${useFullDir ? 'sounds/' : '' }$key.${Paths.SOUND_EXT}', SOUND, lib);
	}

	public function soundRandom(key:String, min:Int, max:Int, useFullDir=false) {
		return sound(key + FlxG.random.int(min, max), useFullDir);
	}
	
	public function txt(key:String, useFullDir=false) {
		return Paths.getPath('$dir/${useFullDir ? 'data/' : '' }$key.txt', TEXT, lib);
	}

	public function json(key:String, useFullDir=false) {
		return Paths.getPath('$dir/${useFullDir ? 'data/' : '' }$key.json', TEXT, lib);
	}

	public function image(key:String, useFullDir=false) {
		var imgPath:Dynamic = Paths.getPath('$dir/${useFullDir ? 'images/' : '' }$key.png', IMAGE, lib);
		if (!Assets.exists(imgPath)) imgPath = Paths.getBitmap(imgPath, lib);
		return imgPath;
	}

    public function getSparrowAtlas(key:String, useFullDir=false) {
		var img:Dynamic = image(key, useFullDir);
		var xml:Dynamic = Paths.file('$dir/${useFullDir ? 'images/' : '' }$key.xml', lib);
		if (!Assets.exists(xml)) xml = File.getContent(xml);
		return FlxAtlasFrames.fromSparrow(img, xml);
	}
	
	public function getPackerAtlas(key:String, useFullDir=false) {
		var img:Dynamic = image(key, useFullDir);
		var txt:Dynamic = Paths.file('$dir/${useFullDir ? 'images/' : '' }$key.txt', lib);
		if (!Assets.exists(txt)) txt = File.getContent(txt);
		return FlxAtlasFrames.fromSpriteSheetPacker(img, txt);
	}
}
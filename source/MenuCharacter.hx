package;

import yaml.util.ObjectMap.AnyObjectMap;
import yaml.Yaml;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef CharacterJsonData = {
	?storyAssets:String,
	anims: {
		idle:String,
		?confirm:String
	},
	x: Int,
	y: Int,
	scale: Float,
	flipped: Bool,
	framerate: Int
}
class CharacterSetting
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flipped(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flipped:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flipped = flipped;
	}
}

class MenuCharacter extends FlxSprite
{
	private static var settings:Map<String, CharacterSetting> = [
		'bf' => new CharacterSetting(0, -20, 1.0, true),
		'gf' => new CharacterSetting(50, 80, 1.5, true),
		'dad' => new CharacterSetting(-15, 130),
		'spooky' => new CharacterSetting(20, 30),
		'pico' => new CharacterSetting(0, 0, 1.0, true),
		'mom' => new CharacterSetting(-30, 140, 0.85),
		'parents-christmas' => new CharacterSetting(100, 130, 1.8),
		'senpai' => new CharacterSetting(-40, -45, 1.4)
	];

	private var flipped:Bool = false;
	private var charData:AnyObjectMap;

	public function new(char:String, x:Int, y:Int)
	{
		super(x, y);
		antialiasing = true;
		if (char == null) {
			animation.add("idle", [0]);
			visible = false;
			return;
		}
		else visible = true;
		
		if (FileSystem.exists(Sys.getCwd() + Paths.weekData('characters/$char'))) charData = Yaml.parse(File.getContent(Sys.getCwd() + Paths.weekData('characters/$char')));
		flipped = charData.get("flipped");

		

		frames = Paths.getSparrowAtlas(charData.get("storyAssets") != null ? charData.get("storyAssets") : "campaign_menu_UI_characters");

		animation.addByPrefix("idle", charData.get("anims").get("idle"), charData.get("framerate"));
		if (charData.get("anims").get("confirm") != null) animation.addByPrefix("confirm", charData.get("anims").get("confirm"), charData.get("framerate"), false);
		
		// offset.set(charData.get("x"), charData.get("y"));
		setGraphicSize(Std.int(width * charData.get("scale")));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		if (character == '' || character == null)
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		if (FileSystem.exists(Sys.getCwd() + Paths.weekData('characters/$character'))) charData = Yaml.parse(File.getContent(Sys.getCwd() + Paths.weekData('characters/$character')));
		frames = Paths.getSparrowAtlas(charData.get("storyAssets") != null ? charData.get("storyAssets") : "campaign_menu_UI_characters");

		animation.addByPrefix("idle", charData.get("anims").get("idle"), charData.get("framerate"));
		if (charData.get("anims").get("confirm") != null) animation.addByPrefix("confirm", charData.get("anims").get("confirm"), charData.get("framerate"), false);

		animation.play("idle");

		offset.set(charData.get("x"), charData.get("y"));
		setGraphicSize(Std.int(width * charData.get("scale")));
		flipX = charData.get("flipped");
	}
}

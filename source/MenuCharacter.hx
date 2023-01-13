package;

import yaml.util.ObjectMap.AnyObjectMap;
import yaml.Yaml;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxSprite;

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
		
		if (FileSystem.exists(Paths.weekData('characters/$char'))) charData = Yaml.parse(File.getContent(Paths.weekData('characters/$char')));
		else {
			if (char == null) {
				animation.add("idle", [0]);
				visible = false;
				return;
			}
		}
		flipped = charData.get("flipped");

		

		frames = Paths.getSparrowAtlas(charData.exists("storyAssets") ? charData.get("storyAssets") : "storyMenu/characters/campaign_menu_UI_characters");

		animation.addByPrefix("idle", charData.get("anims").get("idle"), charData.get("framerate"));
		if (charData.get("anims").exists("confirm")) animation.addByPrefix("confirm", charData.get("anims").get("confirm"), charData.get("framerate"), false);
		
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

		if (FileSystem.exists(Paths.weekData('characters/$character'))) charData = Yaml.parse(File.getContent(Paths.weekData('characters/$character')));
		frames = Paths.getSparrowAtlas(charData.exists("storyAssets") ? charData.get("storyAssets") : "storyMenu/characters/campaign_menu_UI_characters");

		animation.addByPrefix("idle", charData.get("anims").get("idle"), charData.get("framerate"));
		if (charData.get("anims").get("confirm") != null) animation.addByPrefix("confirm", charData.get("anims").get("confirm"), charData.get("framerate"), false);

		animation.play("idle");

		offset.set(charData.get("x"), charData.get("y"));
		setGraphicSize(Std.int(width * charData.get("scale")));
		flipX = charData.get("flipped");
	}
}

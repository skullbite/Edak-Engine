package;

import yaml.Parser.ParserOptions;
import yaml.Yaml;
import sys.FileSystem;
import flixel.FlxSprite;

typedef CharacterYamlData = {
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
	private var charData:CharacterYamlData;

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
		
		if (FileSystem.exists(Paths.yaml('weeks/characters/$char'))) charData = Yaml.read(Paths.yaml('weeks/characters/$char'), new ParserOptions().useObjects());
		else {
			if (char == null) {
				animation.add("idle", [0]);
				visible = false;
				return;
			}
		}
		flipped = charData.flipped;

		frames = Paths.getSparrowAtlas(charData.storyAssets != null ? charData.storyAssets : "storyMenu/characters/campaign_menu_UI_characters");

		animation.addByPrefix("idle", charData.anims.idle, charData.framerate);
		if (charData.anims.confirm != null) animation.addByPrefix("confirm", charData.anims.confirm, charData.framerate, false);
		
		// offset.set(charData.get("x"), charData.get("y"));
		offset.set(charData.x, charData.y);
		setGraphicSize(Std.int(width * charData.scale));
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

		if (FileSystem.exists(Paths.yaml('weeks/characters/$character'))) charData = Yaml.read(Paths.yaml('weeks/characters/$character'), new ParserOptions().useObjects());
		frames = Paths.getSparrowAtlas(charData.storyAssets != null ? charData.storyAssets : "storyMenu/characters/campaign_menu_UI_characters");

		animation.addByPrefix("idle", charData.anims.idle, charData.framerate);
		if (charData.anims.confirm != null) animation.addByPrefix("confirm", charData.anims.confirm, charData.framerate, false);

		animation.play("idle");

		offset.set(charData.x, charData.y);
		setGraphicSize(Std.int(width * charData.scale));
		flipX = charData.flipped;
	}
}

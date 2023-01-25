package;

import sys.io.File;
import yaml.Yaml;
import sys.FileSystem;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import PlayState;

using StringTools;

typedef CustomNoteData = {
	dadShouldHit:Bool,
	bfShouldHit:Bool
}

// yeah it's literally just a class with a map in it, shut up
class CustomNoteDataCache {
	static public var data:Map<String, CustomNoteData> = [];

	static public function get(key:String) return data.get(key);
	static public function set(key:String, value:CustomNoteData) data.set(key, value);
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:String;
	public var noteAssetPath:String = "strums/normal/NOTE_assets";
	public var dadShouldHit:Bool = true;
	public var bfShouldHit:Bool = true;

	public var noteScore:Float = 1;
	
	public static var colors:Array<String> = ["purple", "blue", "green", "red"];
	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:String="Normal")
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		
		// i guess your custom notes have to have the same xml anim names as the default one
		this.noteType = noteType;
		var isCustomNote = false;
		var customNoteData:CustomNoteData = null;
		switch (this.noteType) {
			case "Normal": 
				if (PlayState.SONG.noteStyle == "pixel") noteAssetPath = "arrows-pixels";
			default:
				isCustomNote = true;
				noteAssetPath = '$noteType/assets';
				if (CustomNoteDataCache.get(noteType) != null) customNoteData = CustomNoteDataCache.get(noteType);
				else if (FileSystem.exists('assets/customNotes/$noteType')) {
					var noteStuff = Yaml.parse(File.getContent('assets/customNotes/$noteType/info.yaml'));
					customNoteData = {
						dadShouldHit: noteStuff.exists("dadShouldHit") ? noteStuff.get("dadShouldHit") : dadShouldHit,
						bfShouldHit: noteStuff.exists("bfShouldHit") ? noteStuff.get("bfShouldHit") : bfShouldHit
					};
					CustomNoteDataCache.set(noteType, customNoteData);
				}
				dadShouldHit = customNoteData.dadShouldHit;
				bfShouldHit = customNoteData.bfShouldHit;
		}
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (PlayState.SONG.noteStyle)
		{
			case 'pixel':
				var imgPath = isCustomNote ? 'assets/customNotes/$noteAssetPath.png' : Paths.image('strums/pixel/$noteAssetPath');
				loadGraphic(imgPath, true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					var endImgPath = isCustomNote ? 'assets/customNotes/${noteAssetPath}Ends.png' : Paths.image('strums/pixel/arrowEnds');
					loadGraphic(endImgPath, true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			default:
				frames = Paths.getSparrowAtlas(noteAssetPath, isCustomNote ? "customNotes" : null, isCustomNote);

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		x += swagWidth * noteData;
		if (animation.exists('${colors[noteData]}Scroll')) animation.play('${colors[noteData]}Scroll');

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			// animation.play('${colors[noteData]}holdend');

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}
			if (!Settings.get("downscroll") && animation.curAnim.name.contains("holdend")) scale.y += .29;

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${colors[noteData]}hold');
				/*switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}*/

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit) tooLate = true;
			// if (!isOnScreen(PlayState.instance.camHUD) && Settings.get("downscroll") ? y > FlxG.height : y < -60) tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
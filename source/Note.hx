package;

import flixel.FlxG;
import hstuff.CallbackScript;
import flixel.group.FlxGroup.FlxTypedGroup;
import hstuff.HVars;
import yaml.Parser.ParserOptions;
import sys.io.File;
import yaml.Yaml;
import sys.FileSystem;
import flixel.FlxSprite;
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var noteScript:Null<CallbackScript>;
	public var chartingMode:Bool = false;
	public var raw:Array<Dynamic>;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainEnd(get, null):Bool = false;
	function get_isSustainEnd():Bool {
		return animation.curAnim?.name.endsWith("holdend");
	}
	public var noteType:String;
	public var noHit:Bool = false;
	public var strumSyncVariables = ["alpha", "visible", "angle", "color", "x"];

	public var noteScore:Float = 1;
	
	public static var colors:Array<String> = ["purple", "blue", "green", "red"];
	public static var pixelScale:Float = 0.838;
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
		if (noteData != -1) switch (this.noteType) {
			default:
				if (FileSystem.exists(Paths.getPath('custom-notes/$noteType.hxs'))) {
					try {
						noteScript = new CallbackScript(Paths.getPath('custom-notes/$noteType.hxs'), 'Note:$noteType', {
							note: this,
							Paths: Paths
						});

						noteScript.execute();
					}
					catch (e) {
						// i do not want to spam the game into oblivion
						// trace(e.message);
						noteScript = null;
					}
				}
		}
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		setGraphicSize(Std.int(width * 0.7));
		loadSprite();

		x += swagWidth * noteData;
		if (animation.exists('${colors[noteData]}Scroll')) animation.play('${colors[noteData]}Scroll');

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (Settings.get("downscroll") && sustainNote) 
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
			updateHitbox();

			x -= width / 2;

			if (PlayState.curUi == 'pixel') {
				x += 30;
				offset.x = -10;
			}

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${colors[noteData]}hold');
				if (Settings.get("downscroll")) prevNote.angle = 180;
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * ((Settings.get("scrollSpeed") != 1 ? Settings.get("scrollSpeed") : PlayState.SONG.speed));
			    if (PlayState.curUi == 'pixel') prevNote.scale.y *= pixelScale;
				prevNote.updateHitbox();
				if (PlayState.curUi == 'pixel') prevNote.offset.x = -10;
				// prevNote.setGraphicSize();
			}
		}
	}

	function loadSprite() {
		if (noteScript?.exists(CREATE)) {
			noteScript.exec(CREATE, [PlayState.curUi, isSustainNote && prevNote != null]);
			return;
		}

		switch (PlayState.curUi)
		{
			case 'pixel':
				var imgPath = Paths.image('strums/pixel/arrows-pixels');
				loadGraphic(imgPath, true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					var endImgPath = Paths.image('strums/pixel/arrowEnds');
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
				antialiasing = false;
			default:
				frames = Paths.getSparrowAtlas("strums/normal/NOTE_assets");
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
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (noteScript?.exists(UPDATE)) noteScript.exec(UPDATE, [elapsed]);
		if (chartingMode) return;
		
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
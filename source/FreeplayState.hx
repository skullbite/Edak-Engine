package;

import StoryMenuState.WeekData;
import yaml.Parser.ParserOptions;
import StoryMenuState.DifficultyData;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import yaml.util.ObjectMap.AnyObjectMap;
import yaml.Yaml;
import sys.io.File;
import sys.FileSystem;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;


#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var bg:FlxSprite;
	var colorTween:FlxTween;
	var selector:FlxText;
	public static var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	var curDifficultyArray:Array<String> = ["Easy", "Normal", "Hard"];
	var difficultyData:Map<String, DifficultyData> = [];
	#if MODS
	var modDifficulties:Map<String, Map<String, DifficultyData>> = [];
	#end

	var jukeboxInst:FlxSound = new FlxSound();
	var jukeboxVocals:FlxSound = new FlxSound();
	var currentlyPlaying:Null<Int> = null; 

	var scoreText:FlxText;
	var diffText:FlxText;
	var scoreBG:FlxSprite;
	var bottomBG:FlxSprite;
	var rateText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var lerpAcc:Float = 0;
	var intendedAccuracy:Float = 0;
	var curRating:String = "N/A";

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		var weekDataStuff = CoolUtil.coolTextFile(Paths.txt("weeks/order"));
		#if MODS
		var awesomeMods = PolyFrog.getModWeeks();
		#end

		for (week in 0...weekDataStuff.length) addWeek(Paths.yaml("weeks/" + weekDataStuff[week]), week);

		#if MODS
		for (k => v in awesomeMods) {
			for (week in 0...v.length) addWeek(v[week], week, k);
		}
		#end

		
		for (diff in FileSystem.readDirectory(Paths.getPath("data/difficulties"))) {
			var awesomeDifficulty:DifficultyData = Yaml.read(Paths.yaml('difficulties/${diff.split(".").shift()}'), new ParserOptions().useObjects());
			difficultyData.set(diff.split(".").shift().toLowerCase(), awesomeDifficulty);
		}

		#if MODS
		modDifficulties = PolyFrog.getModDifficulties();
		#end

		// todo: play song button because lag
		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('menu/freakyMenu'));
		}
		 

		 #if desktop
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuBGs/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			#if MODS
			Paths.curModDir = songs[i].modPath;
			#end
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			#if MODS
			Paths.curModDir = null;
			#end	

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		var coolBotomInfo = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		coolBotomInfo.alpha = .6;
		add(coolBotomInfo);
		
		// like the psych engine :D
		var infoTxt = new FlxText(2, coolBotomInfo.y + 2, 0, "[SPACE] Play Current Song");
		infoTxt.setFormat(Paths.font("vcr.ttf"), 17);
		add(infoTxt);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		rateText = new FlxText(FlxG.width * 0.7, 33, 0, "");
		rateText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		
		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		bottomBG = new FlxSprite(FlxG.width - 300, FlxG.height - 80).makeGraphic(300, 60, FlxColor.BLACK);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		diffText = new FlxText(0, bottomBG.y + 10, 0, "< TEST >");
		diffText.font = scoreText.font;
		diffText.size = 40;
		diffText.x = bottomBG.x + Std.int(bottomBG.width / 2) - diffText.width + 90;
		add(diffText);

		add(scoreText);
		add(rateText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addWeek(yamlPath:String, weekNum:Int, ?modPath:String)
	{
		var dataStuff:WeekData = Yaml.read(yamlPath, new ParserOptions().useObjects());

		for (x in 0...dataStuff.songs.length) {
			var icon = dataStuff.icons[dataStuff.icons.length == 1 ? 0 : x];
			var color = dataStuff.colors[dataStuff.colors.length == 1 ? 0 : x];
			songs.push(new SongMetadata(dataStuff.songs[x], weekNum, icon, color, dataStuff.difficulties, modPath));
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpAcc = Math.floor(FlxMath.lerp(lerpAcc, intendedAccuracy, 0.4));


		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpAcc - intendedScore) <= 10) lerpAcc = intendedScore;

		scoreText.text = "HIGH SCORE: " + lerpScore;
		rateText.text = 'RATING: ${lerpAcc}% (${curRating != null ? curRating : "N/A"})';
		

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;
		var spaced = FlxG.keys.justPressed.SPACE;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			jukeboxInst.kill();
			jukeboxVocals.kill();
			FlxG.switchState(new MainMenuState());
		}

		if (spaced && (currentlyPlaying == null || currentlyPlaying != curSelected)) {
			if (jukeboxInst.playing) {
				jukeboxInst.pause();
				jukeboxVocals.pause();
			}
			currentlyPlaying = curSelected;
			FlxG.sound.music.pause();
			var songSuffix = difficultyData.get(curDifficultyArray[curDifficulty].toLowerCase()).loadsDifferentSong ? curDifficultyArray[curDifficulty].toLowerCase() : "";

			#if MODS
			Paths.curModDir = songs[curSelected].modPath;
			#end
		    jukeboxInst.loadEmbedded(Paths.inst(songs[curSelected].songName, songSuffix));
			if (FileSystem.exists(Paths.voices(songs[curSelected].songName, songSuffix))) {
				jukeboxVocals.loadEmbedded(Paths.voices(songs[curSelected].songName, songSuffix));
				jukeboxInst.play(true);
			    jukeboxVocals.play(true);
			}
			else jukeboxInst.play(true);
			#if MODS
			Paths.curModDir = null;
			#end
		}

		if (accepted)
		{
			#if MODS
			Paths.curModDir = songs[curSelected].modPath;
			#end
			PlayState.SONG = Song.loadFromJson(curDifficultyArray[curDifficulty], songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficultyArray[curDifficulty].toLowerCase();
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			if (jukeboxInst.playing) {
				jukeboxInst.kill();
				jukeboxVocals.kill();
			}
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = curDifficultyArray.length-1;
		if (curDifficulty >= curDifficultyArray.length)
			curDifficulty = 0;

		#if !switch
		var data = Highscore.getScore(songs[curSelected].songName, curDifficultyArray[curDifficulty]);
		intendedScore = data.score;
		intendedAccuracy = data.accuracy;
		curRating = data.rating;
		#end

		/*switch (curDifficulty)
		{
			case 0:
				diffText.text = "< EASY >";
				diffText2.text = "< EASY >";
			case 1:
				diffText.text = '< NORMAL >';
				diffText2.text = "< NORMAL >";
			case 2:
				diffText.text = "< HARD >";
				diffText2.text = "< HARD >";
		}*/
		// diffText.text = '< ${curDifficultyArray[curDifficulty].toUpperCase()} >';
		var diff = curDifficultyArray[curDifficulty].toLowerCase();
		var diffData = difficultyData[diff];

		#if MODS
		if (modDifficulties.exists(songs[curSelected].modPath) && modDifficulties.get(songs[curSelected].modPath).exists(diff)) diffData = modDifficulties[songs[curSelected].modPath][diff];
		#end
		
		var doTheArrows = curDifficultyArray.length == 1 ? '*${diff.toUpperCase()}*' : '< *${diff.toUpperCase()}* >';
		diffText.applyMarkup(doTheArrows, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(diffData.color), "*")
		]);
		// diffText2.x = scoreBG.x + Std.int(scoreBG.width / 2);
		diffText.x = bottomBG.x + Std.int(bottomBG.width / 2);
		diffText.x -= diffText.width / 2;
	}

	override function onFocus() {
		if (!jukeboxInst.playing && currentlyPlaying != null) {
			jukeboxInst.play();
			jukeboxVocals.play();
		}
		super.onFocus();
	}
	
	override function onFocusLost() {
		if (jukeboxInst.playing) {
			jukeboxInst.pause();
			jukeboxVocals.pause();
		}
		super.onFocusLost();
	}
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		var data = Highscore.getScore(songs[curSelected].songName, curDifficultyArray[curDifficulty]);
		intendedScore = data.score;
		intendedAccuracy = data.accuracy;
		curRating = data.rating;
		// lerpScore = 0;
		#end
		if (curDifficultyArray != songs[curSelected].difficulties) {
			var lastDiff = curDifficulty;
			if (curDifficultyArray.length != songs[curSelected].difficulties.length) {
				if (songs[curSelected].difficulties.length <= 2) curDifficulty = 0;
		        else curDifficulty = 1;
				
			}
			curDifficultyArray = songs[curSelected].difficulties;
		    changeDiff();
		}

		bg.color = songs[curSelected].color;

		// i honestly don't know why this isn't working so i'll come back to it
		/*if (bg.color != songs[curSelected].color) {
			trace(songs[curSelected].color);
			if (colorTween != null) colorTween.cancel();
		    colorTween = FlxTween.color(bg, .5, bg.color, songs[curSelected].color, {
		    	onComplete: t -> colorTween = null
		    });
		}*/
		
		/*#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end*/

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:FlxColor = 0;
	public var difficulties:Array<String> = ["Easy", "Normal", "Hard"];
	public var modPath:Null<String>;

	public function new(song:String, week:Int, songCharacter:String, color:FlxColor, difficulties:Array<String>, ?modPath:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.difficulties = difficulties;
		if (modPath != null) this.modPath = modPath;
	}
}

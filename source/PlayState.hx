package;

import yaml.Parser.ParserOptions;
import StoryMenuState.DifficultyData;
import hstuff.HVars;
import yaml.Yaml;
import EdakDialogueBox.EdakeDialogueBox;
import hstuff.FunkScript;
import openfl.Assets as OpenFLAssets;
import sys.FileSystem;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.utils.AssetType;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
#if (hxCodec >= "2.6.1")
import hxcodec.VideoHandler;
#else
import vlc.MP4Handler;
#end
import flixel.addons.display.FlxRuntimeShader;
/*import OverlayShader;
import BlendModeEffect;*/

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState
{

	public static var instance:PlayState = null;
	public static var HFunk:FunkScript;

	public static var curStage:String = '';
	public static var curUi:String = "normal";
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var saveScore:Bool = true;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:String = "Normal";
	public static var difficultyData:DifficultyData;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public var songInfoTxt:FlxText;
	public var songTimeTxt:FlxText;
	public var bopSpeed:Int = 4;
	public var camBumpZoom:Float = 0.015;
	public var hudBumpZoom:Float = 0.03;

	public var disableInput:Bool = false;
	public static var noteBools:Array<Bool> = CoolUtil.sillyArray(false, 4);

	var songLength:Float = 0;

	public var vocals:FlxSound;

	public static var dad:Character = null;
	public static var gf:Character = null;
	public static var boyfriend:Boyfriend = null;
	public static var dadGroup:FlxTypedGroup<FlxBasic>;
	public static var gfGroup:FlxTypedGroup<FlxBasic>;
	public static var boyfriendGroup:FlxTypedGroup<FlxBasic>;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:Strumline = null;
	public static var cpuStrums:Strumline = null;
	public static var splashes:SplashGroup = null;
	public static var combos:ComboGroup = null;

	public var rating:Null<FlxSprite> = null;
	public var ratingTween:Null<FlxTween> = null;
	public var comboNumGroup:FlxTypedGroup<FlxSprite>;
	public var numTweens:Array<FlxTween> = [];
	public var curMsTxt:Null<FlxText> = null;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	public var health:Float = 1; //making public because sethealth doesnt work without it
	public var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var fc:Bool = true;
	var stage:Stage;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = true;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;

	#if desktop
	// RPC stuff
	var storyDifficultyText:String;
	var detailsText:String;
	#end

	// kooky wacky hscript variables
	var moveHealthIcons = true;
	var bopHealthIcons = true;
	var moveCamera = true;
	var forceCutscene = false;
	/** @deprecated **/
	var splashOffsets = {
		x: 132,
		y: 145
	};
	var popCombos = true;
	var updateScore = true;
	var updateTime = true;


	override public function create()
	{
		instance = this;
		HFunk = new FunkScript();
		dadGroup = new FlxTypedGroup();
		gfGroup = new FlxTypedGroup();
		boyfriendGroup = new FlxTypedGroup();
		comboNumGroup = new FlxTypedGroup();
		defaultCamZoom = 1.05;
		curUi = 'normal';
		if (Settings.get("botplay")) saveScore = false;
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		difficultyData = Yaml.read(Paths.yaml('difficulties/${storyDifficulty.toLowerCase()}'), new ParserOptions().useObjects());
		

		// trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		/*switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}*/

		// iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) detailsText = "Story Mode: Week " + storyWeek;
		else detailsText = "Freeplay";

		// String for when the game is paused
		var detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficulty + ")", Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy));
		#end


		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		var diff = difficultyData.loadsDifferentSong != null && difficultyData.loadsDifferentSong ? storyDifficulty.toLowerCase() : "";

		if (OpenFLAssets.exists(Paths.inst(SONG.song, diff))) OpenFLAssets.getSound(Paths.inst(SONG.song, diff));
		// else if (FileSystem.exists(Paths.inst(SONG.song, diff))) cachedInst = Sound.fromFile(Paths.inst(SONG.song, diff));
		if (SONG.needsVoices && OpenFLAssets.exists(Paths.voices(SONG.song, diff))) OpenFLAssets.getSound(Paths.voices(SONG.song, diff));
		// else if (SONG.needsVoices && FileSystem.exists(Paths.voices(SONG.song, diff))) cachedVocals = Sound.fromFile(Paths.voices(SONG.song, diff));

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);
		var songScripts = [];
		if (FileSystem.exists(Paths.getPath('songs/${SONG.song.toLowerCase()}/scripts'))) songScripts = Paths.songDataDir('${SONG.song.toLowerCase()}/scripts').filter(d -> d.endsWith(".hxs"));
		var scripts:Map<String, String> = [];
		for (x in songScripts) {
			try {
				scripts.set('song_${x.split(".")[0]}', Paths.getPath('songs/${SONG.song.toLowerCase()}/scripts/$x'));
			}
			catch (e) { /* most likely doesn't exist but is still cached in runtime, silently ignored */ }
		}
		var globalScripts = Paths.scriptDir().filter(d -> d.endsWith(".hxs"));
		var loadingModScripts = Paths.getPath("scripts").startsWith("mods/");
		for (x in globalScripts) {
			try { 
				scripts.set('${loadingModScripts ? 'mod_' : ''}global_${x.split(".")[0]}', Paths.getPath('scripts/$x'));
			}
			catch (e) {}
		}
		if (loadingModScripts) {
			var regularGlobals = FileSystem.readDirectory('assets/scripts').filter(d -> d.endsWith(".hxs"));
			for (x in regularGlobals) {
				try {
					scripts.set('global_${x.split(".")[0]}', 'assets/scripts/$x');
				}
				catch (e) {}
			}
		}
		for (k => v in scripts) HFunk.loadScript(k, v);

		HFunk.doDaCallback("onCreate", []);
		

		//dialogue shit
		// considering making a non-week 6 dialogue box
		/*switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}*/

		curStage = SONG.stage;
		if (curStage == '' || curStage == null) {
			trace("stage from song data is null, loading stage");
			curStage = 'stage';
		}

		stage = new Stage();

		add(stage);

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion != null) gf = new Character(400, 130, gfVersion);
		if (gf != null) { 
			gfGroup.add(gf);
			// because somehow gf's null check falls through here
		    if (Reflect.getProperty(gf, "scrollFactor") != null) gf.scrollFactor.set(0.95, 0.95);
		    gf.x += gf.displaceData.x;
		    gf.y += gf.displaceData.y;
		}

		if (SONG.player2 != null) dad = new Character(100, 100, SONG.player2);
		if (dad != null) {
			dadGroup.add(dad);
		    dad.x += dad.displaceData.x;
		    dad.y += dad.displaceData.y;
		}

		// can't even use my null checker 
		var camX = dad != null ? dad.getGraphicMidpoint().x : 0;
		var camY = dad != null ? dad.getGraphicMidpoint().y : 0;

		var camPos:FlxPoint = new FlxPoint(camX, camY);

		if (SONG.player1 != null) boyfriend = new Boyfriend(770, 450, SONG.player1);
		if (boyfriend != null) {
			boyfriendGroup.add(boyfriend);
		    boyfriend.x += boyfriend.displaceData.x;
		    boyfriend.y += boyfriend.displaceData.y;
		}

		add(gfGroup);

		add(stage.infrontOfGf); // i'm tired of limo

		// Shitty layering but whatev it works LOL
		/*if (curStage == 'limo')
			add(limo);*/

		add(dadGroup);
		add(boyfriendGroup);

		add(stage.foreground);

		stage.reposCharacters();

		camPos.x += stage.cameraDisplace.x;
		camPos.y += stage.cameraDisplace.y;


		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new Strumline(false, true, !isStoryMode);
		cpuStrums = new Strumline(true, true, !isStoryMode);
		splashes = new SplashGroup();
		splashes.spawnSplash(0);

		combos = new ComboGroup();
		//combos.pop('sick', 0);

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		var bfColor = boyfriend != null ? FlxColor.fromString(boyfriend.barColor) : 0xFF66FF33;
		var dadColor = dad != null ? FlxColor.fromString(dad.barColor) : 0xFFFF0000;
		healthBar.createFilledBar(dadColor, bfColor);
		// healthBar
		add(healthBar);

		var iconBf = CoolUtil.ezNullCheck(boyfriend, boyfriend.iconName, "face");
		var iconDad = CoolUtil.ezNullCheck(dad, dad.iconName, "face");

		iconP1 = new HealthIcon(iconBf, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(iconDad, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		songInfoTxt = new FlxText(0, FlxG.save.data.downscroll ? 678 : -3, 0);
		songInfoTxt.alpha = 0;
		songInfoTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songInfoTxt.borderSize = 3;
		var difficultyColor = 0;
		/*switch (storyDifficulty) {
			case 0: difficultyColor = FlxColor.LIME;
			case 1: difficultyColor = FlxColor.YELLOW;
			case 2: difficultyColor = FlxColor.RED;
		}*/
		difficultyColor = difficultyData.color;

		songInfoTxt.applyMarkup(SONG.song.replace("-", " ").toUpperCase() + ' - ~~${storyDifficulty.toUpperCase()}~~', [
			new FlxTextFormatMarkerPair(new FlxTextFormat(difficultyColor), "~~")
		]);
		songInfoTxt.screenCenter(X);
		add(songInfoTxt);


		songTimeTxt = new FlxText(0, FlxG.save.data.downscroll ? 653 : (!Settings.get("songPosition") ? 5 : 0) + 27, "-:--/-:--");
		songTimeTxt.alpha = 0;
		songTimeTxt.visible = Settings.get("songPosition");
		updateTime = Settings.get("songPosition");
		songTimeTxt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songTimeTxt.borderSize = 3;
		songTimeTxt.screenCenter(X);
		add(songTimeTxt);

		scoreTxt = new FlxText(0, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Settings.get("botplay") ? 30 : 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;													  
		add(scoreTxt);
		updateScoreTxt();

		strumLineNotes.cameras = [camHUD];
		songInfoTxt.cameras = [camHUD];
		songTimeTxt.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		if (isStoryMode || forceCutscene)
		{
			switch (curSong.toLowerCase())
			{
				/* hard coded cutscenes here i guess */
				default:
					if (HFunk.funcExists("onCutscene")) HFunk.doDaCallback("onCutscene", []);
					else startCountdown();
			}
		}
		else startCountdown();

		super.create();

		HFunk.doDaCallback("onCreatePost", []);
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		cpuStrums.doIntro();
		playerStrums.doIntro();

		for (x in cpuStrums.members.concat(playerStrums.members)) strumLineNotes.add(x);
		add(splashes);

		add(combos);

		var off = 0;
		if (!Settings.get("songPosition")) off = 10;
		if (Settings.get("downscroll")) {
			off *= -1;
			off -= 5;
		}
		FlxTween.tween(songInfoTxt, { y: songInfoTxt.y + 10 + off, alpha: 1 }, 2.2, { ease: FlxEase.circOut });
		if (songTimeTxt.visible) FlxTween.tween(songTimeTxt, { y: songTimeTxt.y + 10, alpha: 1 }, 2.2, { ease: FlxEase.circOut });

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var countTick = HFunk.doDaCallback("onCountdownTick", [swagCounter]);
			if (countTick.contains(HVars.STOP)) return;

			if (dad != null && swagCounter % dad.bopSpeed == 0) dad.dance();
			if (gf != null && swagCounter % gf.bopSpeed == 0) gf.dance();
			if (boyfriend != null && swagCounter % boyfriend.bopSpeed == 0) boyfriend.dance();

			var prefix = 'ui/$curUi/countdown';
			var introAlts:Array<String> = ['$prefix/ready', '$prefix/set', '$prefix/go'];
			var altSuffix:String = "";
			if (curUi == 'pixel') altSuffix = "-pixel";

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('countdown/intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curUi == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curUi == 'pixel')
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curUi == 'pixel')
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	public var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		
		HFunk.doDaCallback("onSongStart", []);

		if (!paused)
		{

				var diff = difficultyData.loadsDifferentSong != null && difficultyData.loadsDifferentSong ? storyDifficulty.toLowerCase() : "";
				FlxG.sound.playMusic(Paths.inst(SONG.song, diff), 1, false);
		}

		FlxG.sound.music.onComplete = HFunk.funcExists("onEndSong") ? () -> HFunk.doDaCallback("onEndSong", []) : endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy));
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		var diff = difficultyData.loadsDifferentSong != null && difficultyData.loadsDifferentSong ? storyDifficulty.toLowerCase() : "";
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song, diff));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		/*#if windows
			var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						trace('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						trace('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end*/
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(16 / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var daNoteType:String = songNotes[3] != null ? songNotes[3] : "Normal";

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daNoteType);
				swagNote.raw = songNotes;
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteType);
					swagNote.raw = songNotes;
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
					HFunk.doDaCallback("onNoteSpawn", [sustainNote, true]);
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) swagNote.x += FlxG.width / 2; // general offset

				HFunk.doDaCallback("onNoteSpawn", [swagNote, false]);
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if desktop
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficulty + ") ", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy));
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficulty + ")", null);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if desktop
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficulty + ") ", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		HFunk.doDaCallback("onUpdate", [elapsed]);
		stage.stageUpdate(elapsed);
		
		//trace(FlxG.sound.music.name);

		if (songStarted && updateTime) { 
			songTimeTxt.text = CoolUtil.msToTimestamp(FlxG.sound.music.time) + "/" + CoolUtil.msToTimestamp(FlxG.sound.music.length);
		    songTimeTxt.screenCenter(X); 
		}

		if (Settings.get("npsDisplay") && nps > 1  && updateScore && !Settings.get("botplay")) updateScoreTxt();

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		/*if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}*/

		super.update(elapsed);
		
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			FlxG.sound.music.pause();
		    vocals.pause();

			var pauseRets = HFunk.doDaCallback("onPause", []);
			if (pauseRets.contains(HVars.STOP)) return;
			var bfX = boyfriend != null ? boyfriend.getScreenPosition().x : 0;
			var bfY = boyfriend != null ? boyfriend.getScreenPosition().y : 0;

			// 1 / 1000 chance for Gitaroo Man easter egg
			// imma be real, this gets annoying when you're trying to test
			#if !debug
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
			#end
				openSubState(new PauseSubState(bfX, bfY));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (bopHealthIcons) {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		    iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

			iconP1.updateHitbox();
		    iconP2.updateHitbox();
		}

		var iconOffset:Int = 26;

		if (moveHealthIcons) {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		    iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			var char = dad != null ? dad.curCharacter : null;
			if (FlxG.keys.pressed.CONTROL) char = boyfriend != null ? boyfriend.curCharacter : null;
			if (FlxG.keys.pressed.SHIFT) char = gf != null ? gf.curCharacter : null;
			if (char != null) FlxG.switchState(new AnimationDebug(char));
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{

			if (dad != null && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var camCall = HFunk.doDaCallback("onCamMove", ["dad"]);
				if (camCall.contains(HVars.STOP)) return;
				if (moveCamera && dad != null) {
					var offsetX = dad.displaceData.camX;
				    var offsetY = dad.displaceData.camY;
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				}
			}

			if (boyfriend != null && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var camCall = HFunk.doDaCallback("onCamMove", ["bf"]);
				if (camCall.contains(HVars.STOP)) return;
				if (moveCamera && boyfriend != null) {
					var offsetX = boyfriend.displaceData.camX;
				    var offsetY = boyfriend.displaceData.camY;
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0)
		{
			if (boyfriend != null) boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null);
			#end

			var gameOverCall = HFunk.doDaCallback("onGameOver", []);
			if (gameOverCall.contains(HVars.STOP)) return;
			
			var bfX = boyfriend != null ? boyfriend.getScreenPosition().x : 0;
			var bfY = boyfriend != null ? boyfriend.getScreenPosition().y : 0;

			openSubState(new GameOverSubstate(bfX, bfY));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
 		if (FlxG.save.data.resetButton)
		{
			if(FlxG.keys.justPressed.R)
				{
					if (boyfriend != null) boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					vocals.stop();
					FlxG.sound.music.stop();

					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ")",Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null);
					#end

					var gameOverCall = HFunk.doDaCallback("onGameOver", []);
			        if (gameOverCall.contains(HVars.STOP)) return;

					var bfX = CoolUtil.ezNullCheck(boyfriend, boyfriend.getScreenPosition().x, 0);
			        var bfY = CoolUtil.ezNullCheck(boyfriend, boyfriend.getScreenPosition().y, 0);
		
					openSubState(new GameOverSubstate(bfX, bfY));
					
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				/*
				    BUG: note sustains get held even if the note is supposed to miss
				*/
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					
							if (FlxG.save.data.downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.isSustainEnd && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height / 2;
	
									// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									if(!FlxG.save.data.botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || !daNote.isSustainEnd ||  daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
											swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.y = daNote.frameHeight - swagRect.height;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
	
										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								if(daNote.isSustainNote && !daNote.noHit)
								{
									daNote.y -= daNote.height / 2;
	
									if(!FlxG.save.data.botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || !daNote.isSustainEnd || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
											swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.height -= swagRect.y;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
	
										daNote.clipRect = swagRect;
									}
								}
						}
		
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						HFunk.doDaCallback("opponentNoteHit", [daNote.noteData, daNote]);

						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}

						if (daNote.noHit) {
							new FlxTimer().start(2, t -> {
								daNote.active = false;
						        daNote.kill();
						        notes.remove(daNote, true);
						        daNote.destroy();
							});
							return;
						}
						
						if (dad != null) switch (daNote.noteData)
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
						
						cpuStrums.lightStrum(daNote.noteData);
						

						if (dad != null) dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;

						
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (daNote.mustPress)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote) 
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha - (daNote.isSustainNote ? 0.4 : 0);
					}
					else if (!daNote.wasGoodHit)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote) 
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha - (daNote.isSustainNote ? 0.4 : 0);
					}

					if (daNote.noteScript != null) daNote.noteScript.exec("propertyOverride", []);

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll) && daNote.mustPress && !daNote.noHit)
					{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else
							{
								health -= 0.075;
								vocals.volume = 0;
								if (theFunne)
									noteMiss(daNote.noteData, daNote);
							}
		
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
					}				
				});
			}

		cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
		});

		if (!inCutscene)
			keyShit();


		/*#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end*/

		HFunk.doDaCallback("onUpdatePost", []);
	}

	public function preExit() {
		#if MODS
		Paths.curModDir = null;
		#end
		saveScore = true;
	}

	function endSong():Void
	{

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.onComplete = null;
		#if !switch
		if (saveScore) Highscore.saveScore(SONG.song, Math.round(songScore), HelperFunctions.truncateFloat(accuracy, 2), Ratings.getRatingType(), storyDifficulty);
		#end

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('menu/freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsState());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('menu/freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					// saveScore = false;

					#if MODS
					Paths.curModDir = null;
					#end
					FlxG.switchState(new StoryMenuState());

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (saveScore) Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					saveScore = true;

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + storyDifficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(storyDifficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.sound.music.kill();
				preExit();
				FlxG.switchState(new FreeplayState());
			}
		}
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			if (rating != null) rating.destroy();
			rating = new FlxSprite();
			var score:Float = 350;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					health -= 0.2;
					ss = false;
					shits++;
					totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					totalNotesHit += 1;
					sicks++;
			}
			updateScoreTxt();

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad' || daRating != 'miss')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(Highscore.convertScore(noteDiff));

			var msTiming = Math.round(HelperFunctions.truncateFloat(noteDiff, 3));

			var comboPopCall = HFunk.doDaCallback("onComboPop", [daRating, combo, msTiming]);
			if (comboPopCall.contains(HVars.STOP)) return;

			combos.pop(daRating, msTiming);
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			/*rating.loadGraphic(Paths.image('ui/$curUi/ratings/' + daRating.replace("miss", "shit")));
			rating.setGraphicSize(Std.int(rating.width * 0.8));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(FlxG.save.data.botplay) msTiming = 0;							   

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if(!FlxG.save.data.botplay) add(currentTimingShown);
			
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/$curUi/combo/combo'));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if(!FlxG.save.data.botplay) add(rating);
	
			if (curUi != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.6));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.6));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/$curUi/combo/' + 'num' + i));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (PlayState.curUi != 'pixel')
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10) {
					add(numScore);
					/*if (daLoop == seperatedScore.length - 1) {
						comboSpr.x += numScore.x - 550;
						comboSpr.y = numScore.y - 40;
						comboSpr.setGraphicSize(Std.int(comboSpr.width * .8));
						add(comboSpr);
					}
				}
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;*/
			return;
			}
			HFunk.doDaCallback("onComboPop", [daRating, combo, null]);
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		private function keyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
		 
				// Prevent player input if botplay is on
				if(FlxG.save.data.botplay || disableInput)
				{
					holdArray = [false, false, false, false];
					pressArray = [false, false, false, false];
					releaseArray = [false, false, false, false];
				} 
				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 
				// PRESSES, check for note hits
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					if (boyfriend != null) boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList.contains(daNote.noteData))
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					});
		 
					for (note in dumbNotes)
					{
						FlxG.log.add("killing dumb ass note at " + note.strumTime);
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
		 
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		 
					var dontCheck = false;

					for (i in 0...pressArray.length)
					{
						if (pressArray[i] && !directionList.contains(i))
							dontCheck = true;
					}

					if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								if (mashViolations != 0)
									mashViolations--;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}

					if(dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay)
					{
						if (mashViolations > 8)
						{
							trace('mash violations ' + mashViolations);
							scoreTxt.color = FlxColor.RED;
							noteMiss(0,null);
						}
						else
							mashViolations++;
					}

				}
				
				notes.forEachAlive(function(daNote:Note)
				{
					if(FlxG.save.data.downscroll && daNote.y > strumLine.y ||
					!FlxG.save.data.downscroll && daNote.y < strumLine.y)
					{
						// Force good note hit regardless if it's too late to hit it or not as a fail safe
						if(FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress ||
						FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress)
						{
								goodNoteHit(daNote);
								if (boyfriend != null) boyfriend.holdTimer = daNote.sustainLength;
						}
					}
				});
				
				if (boyfriend != null && boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if ((!holdArray[spr.ID] && !Settings.get("botplay")) || (Settings.get("botplay") && spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished))
						spr.animation.play('static');

					if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && curUi != "pixel")
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			}

	function noteMiss(direction:Int = 1, daNote:Null<Note>):Void
	{
		if (boyfriend != null && boyfriend.stunned) return;
		// if (daNote != null && !daNote.bfShouldHit && Settings.get("botplay")) return;
		health -= 0.04;
		combo = 0;
		misses++;
		if (daNote != null) {
			var missCall = HFunk.doDaCallback("noteMiss", [direction, daNote]);
			if (missCall.contains(HVars.STOP)) return;
		}
		else {
			var missCall = HFunk.doDaCallback("noteMiss", [direction, null]);
			if (missCall.contains(HVars.STOP)) return;
		}
		
		if (gf != null && combo > 5 && gf.animation.exists('sad')) gf.playAnim('sad');

			//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			//var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('miss/missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			if (boyfriend != null) switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateAccuracy();
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff);

			/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
			} */
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));
				
				/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false);*/

			}
		}

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{
				if (note.noHit) {
					if (!Settings.get("botplay")) {
					    playerStrums.lightStrum(note.noteData);
					    note.kill();
					    notes.remove(note, true);
					    note.destroy();
					}
					else {
						new FlxTimer().start(4, t -> {
						    note.kill();
					        notes.remove(note, true);
					        note.destroy();
					    });
						return;
				    }
					
					noteMiss(note.noteData, note);
					return;
				}

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;

				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;

					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();

					var noteCall = HFunk.doDaCallback("goodNoteHit", [note.noteData, note]);
					if (noteCall.contains(HVars.STOP)) return;

					if (boyfriend != null) switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 0:
							boyfriend.playAnim('singLEFT', true);
					}


					/*if(!loadRep && note.mustPress)
						saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));*/
				
					playerStrums.lightStrum(note.noteData);
					if (note.rating == "sick" && !note.isSustainNote) splashes.spawnSplash(note.noteData);

				}
			}
		

	override function stepHit()
	{
		super.stepHit();
		HFunk.doDaCallback("onStepHit", [curStep]);
		stage.stepHit(curStep);
		if (FlxG.sound.music.time >= Conductor.songPosition + 20 || FlxG.sound.music.time <= Conductor.songPosition - 20)
		{
			resyncVocals();
		}


		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null,true,  songLength - Conductor.songPosition);
		#end

	}

	override function beatHit()
	{
		super.beatHit();
		HFunk.doDaCallback("onBeatHit", [curBeat]);
		stage.beatHit(curBeat);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}


		var nextSect = SONG.notes[Math.floor(curStep / 16)];
		if (nextSect != null)
		{
			if (nextSect.bpm != null && nextSect.bpm != Conductor.bpm && nextSect.bpm > 0 && (nextSect.changeBPM == null || (nextSect.changeBPM != null && nextSect.changeBPM)))
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			/*if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
				dad.dance();*/
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);


		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % bopSpeed == 0)
		{
			FlxG.camera.zoom += camBumpZoom;
			camHUD.zoom += hudBumpZoom;
		}

		if (bopHealthIcons) {
		    iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		    iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		    iconP1.updateHitbox();
		    iconP2.updateHitbox();
		}

		if (gf != null && gf.velocity != null && curBeat % gf.bopSpeed == 0) gf.dance();
		if (boyfriend != null && curBeat % boyfriend.bopSpeed == 0 && !boyfriend.animation.curAnim.name.startsWith("sing")) boyfriend.dance();
		if (dad != null && curBeat % dad.bopSpeed == 0 && !dad.animation.curAnim.name.startsWith("sing")) dad.dance();

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad != null && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				if (boyfriend != null) boyfriend.playAnim('hey', true);
				if (dad != null) dad.playAnim('cheer', true);
			}
	}
	override function onFocusLost() {
		if (health > 0 && !paused && canPause && !inCutscene) {
			persistentUpdate = false;
		    persistentDraw = true;
		    paused = true;
			
			FlxG.sound.music.pause();
		    vocals.pause();
			var pauseRets = HFunk.doDaCallback("onPause", []);
			if (pauseRets.contains(HVars.STOP)) return;

			var bfX = boyfriend != null ? boyfriend.getScreenPosition().x : 0;
			var bfY = boyfriend != null ? boyfriend.getScreenPosition().y : 0;

		    openSubState(new PauseSubState(bfX, bfY));
		}
		
		super.onFocusLost();
	}

	static public function makeShader(path:String) {
		var shaderStuff = CoolUtil.getShaderStuffs(Paths.shader(path));

		return new FlxRuntimeShader(shaderStuff[0], shaderStuff[1]);
	}
	
	public function updateScoreTxt() {
		var scoreChangeCall = HFunk.doDaCallback("onScoreUpdate", []);
		if (scoreChangeCall.contains(HVars.STOP) || !updateScore) return;
		if (Settings.get("botplay")) {
			if (scoreTxt.size != 30) scoreTxt.size = 30;
			if (scoreTxt.text != "BOTPLAY") scoreTxt.text = "BOTPLAY";
		}
		else {
			if (scoreTxt.size != 20) scoreTxt.size = 20;
		    scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		}
		scoreTxt.screenCenter(X);
	}

	function playVideo(videoPath:String, endCallBack:Void -> Void) {
		#if (hxCodec >= "2.6.1")
		var videoHandler = new VideoHandler();
		#else
		var videoHandler = new MP4Handler();
		#end
		videoHandler.finishCallback = endCallBack;
		videoHandler.playVideo(Paths.video(videoPath));
	}

	function openCustomSubState(targetSub:String) {
		openSubState(new CustomSubState(targetSub));
	}

	function openDialogueBox(boxType:String, dialogue:Array<String>, callback:Void -> Void) {
		var dialogueBox = new EdakeDialogueBox(boxType, dialogue);
		dialogueBox.finishCallback = callback;
		dialogueBox.cameras = [camHUD];
		add(dialogueBox);
	}
}

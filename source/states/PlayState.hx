package states;

import sys.io.File;
import haxe.Json;
import hstuff.CallbackScript;
import flixel.util.typeLimit.OneOfTwo;
import yaml.Parser.ParserOptions;
import states.StoryMenuState.DifficultyData;
import hstuff.HVars;
import yaml.Yaml;
import groups.EdakDialogueBox.EdakeDialogueBox;
import hstuff.FunkScript;
import sys.FileSystem;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.utils.Assets;
import openfl.Lib;
import utils.Section.SwagSection;
import utils.Song.SwagSong;
import utils.Conductor;
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
import groups.ComboGroup;
import groups.SplashGroup;
import groups.Strumline;
import groups.Stage;
import sprites.Note;
import sprites.Character;
import sprites.Boyfriend;
import sprites.HealthIcon;
import substates.CustomSubState;
import utils.Ratings;
import utils.HelperFunctions;
import utils.CoolUtil;
import utils.Highscore;
import utils.Song;
import substates.PauseSubState;
import substates.GameOverSubstate;


#if VIDEOS
#if (hxCodec >= "2.6.1")
import hxcodec.VideoHandler;
#else
import vlc.MP4Handler;
#end
#end
import flixel.addons.display.FlxRuntimeShader;

#if desktop
import utils.Discord.DiscordClient;
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
	public static var week:Int = 0;
	public static var saveScore:Bool = true;
	public static var playlist:Array<String> = [];
	public static var difficulty(default, set):String = "normal";
	public static var musicPost:Null<String> = null;
	public static function set_difficulty(val:String) {
		difficultyData = Yaml.read(Paths.yaml('difficulties/${val.toLowerCase()}'), new ParserOptions().useObjects());
        musicPost = difficultyData.loadsDifferentSong ? val.toLowerCase() : null;
        return difficulty = val;
	}
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
	var songLength:Float = 0;

	public var vocals:FlxSound;

	public static var dad:Character = null;
	public static var gf:Character = null;
	public static var bf:Boyfriend = null;
	public static var dadGroup:FlxTypedGroup<FlxBasic>;
	public static var gfGroup:FlxTypedGroup<FlxBasic>;
	public static var bfGroup:FlxTypedGroup<FlxBasic>;

	public var notes:FlxTypedGroup<Note>;
	public var eventsChart:Null<SwagSong>;
	private var unspawnNotes:Array<Note> = [];
	private var events:Array<Dynamic> = [];
	private var eventScripts:Map<String, CallbackScript> = [];

	public var strumLine:FlxSprite;
	// private var curSection:Int = 0;

	private var camFollow:FlxObject;
	public static var startOn:OneOfTwo<Array<Float>, String> = "dad";
	private var camOn:OneOfTwo<Array<Float>, String> = "dad";
	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public var playerStrums:Strumline = null;
	public var cpuStrums:Strumline = null;
	public static var splashes:SplashGroup = null;
	public static var combos:ComboGroup = null;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	public var health(default, set):Float = 1; //making public because sethealth doesnt work without it
	function set_health(val:Float):Float {
		if (val >= 2) val = 2;
        if (val <= 0) {
			val = 0;
            runGameOver();
            return health = val;
        }

		// icons won't move at first if ran through this, dunno why
        // updateHealthBarStuff();
        return health = val;
	}
	public var combo:Int = 0;
	public static var misses(default, set):Int = 0;
	public static function set_misses(val:Int) {
		misses = val;
		if (val != 0) instance.updateScoreTxt();
		return val;
	}
	private var accuracy(default, set):Float = 0.00;
	function set_accuracy(val:Float) {
		accuracy = val;
		updateScoreTxt();
		return val;
	}
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;
	
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camTop:FlxCamera;
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var fc:Bool = true;
	var stage:Stage;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef(default, set):Int = 0;
	function set_songScoreDef(val:Int) {
		songScoreDef = val;
		updateScoreTxt();
		return val;
	}
	var scoreTxt:FlxText;

	public static var weekScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = true;
	
	// because if you die with a state change queued the game softlocks
	private var stateChangeFired:Bool = false;

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
	var popCombos = true;
	var updateScore = true;
	var updateTime = true;
	var doStrumIntro = true;

	override public function create()
	{
		instance = this;
		HFunk = new FunkScript();
		dadGroup = new FlxTypedGroup();
		gfGroup = new FlxTypedGroup();
		bfGroup = new FlxTypedGroup();
		defaultCamZoom = 1.05;
		curUi = 'normal';
		if (Settings.get("botplay")) saveScore = false;
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		doStrumIntro = true;
		startOn = "dad";

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		#if desktop
		// Making difficulty text for Discord Rich Presence.

		// iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) detailsText = "Story Mode: Week " + week;
		else detailsText = "Freeplay";

		// String for when the game is paused
		var detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + difficulty + ")", Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy));
		#end

		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);
		camTop = new FlxCamera();
		camTop.bgColor.alpha = 0;
		FlxG.cameras.add(camTop);
		
		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Paths.inst(SONG.song, musicPost);
		if (SONG.needsVoices && FileSystem.exists(Paths.voices(SONG.song, musicPost, true))) Paths.voices(SONG.song, musicPost);
		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: '  + Conductor.safeFrames + '\nSONG: ${SONG.song}'  + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);
		
		
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

		HFunk.doDaCallback(CREATE, []);
		

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
		if (curStage == '' || curStage == null) curStage = 'stage';
		
		stage = new Stage();
		add(stage);

		playerStrums = new Strumline(false, true, doStrumIntro);
		addToHUD(playerStrums);
		cpuStrums = new Strumline(true, true, doStrumIntro);
		addToHUD(cpuStrums);
		notes = new FlxTypedGroup<Note>();
		addToHUD(notes);

		splashes = new SplashGroup();
		splashes.spawnSplash(0);
		combos = new ComboGroup();
		

		if (SONG.gfVersion != null) gf = new Character(400, 130, SONG.gfVersion);
		if (gf != null && gf.scrollFactor != null) {
			gfGroup.add(gf);
			gf.scrollFactor.set(0.95, 0.95);
		    gf.x += gf.displaceData.x;
		    gf.y += gf.displaceData.y;
		}

		if (SONG.player2 != null) dad = new Character(100, 100, SONG.player2);
		if (dad != null && dad.scrollFactor != null) {
			dadGroup.add(dad);
		    dad.x += dad.displaceData.x;
		    dad.y += dad.displaceData.y;
		}

		if (SONG.player1 != null) bf = new Boyfriend(770, 450, SONG.player1);
		if (bf != null && bf.scrollFactor != null) {
			bfGroup.add(bf);
		    bf.x += bf.displaceData.x;
		    bf.y += bf.displaceData.y;
		}

		add(gfGroup);

		add(stage.infrontOfGf); // i'm tired of limo

		// Shitty layering but whatev it works LOL
		/*if (curStage == 'limo')
			add(limo);*/

		add(dadGroup);
		add(bfGroup);

		add(stage.foreground);

		stage.createPost();

		var camX:Float = 0;
		var camY:Float = 0;

		var camTarget:Character = null;

		if (startOn is Array) {
			camX = startOn[0];
			camY = startOn[1];
		}
		else switch (startOn) {
            case "bf": camTarget = bf;
            case "gf": camTarget = gf;
            case "dad": camTarget = dad;
        }

        if (camTarget != null) {
            var offsetX = camTarget.displaceData.camX;
            var offsetY = camTarget.displaceData.camY;
            var midpoint = camTarget.getMidpoint();
			var xOff = startOn == "dad" ? 150 : -100;

			camX = midpoint.x + xOff + offsetX;
			camY = midpoint.y - 100 + offsetY;
        }

		Conductor.songPosition = -5000;

		// startCountdown();

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(camX, camY, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		// FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		addToHUD(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		var bfColor = bf != null ? bf.barColor : 0xFF66FF33;
		var dadColor = dad != null ? dad.barColor : 0xFFFF0000;
		healthBar.createFilledBar(dadColor, bfColor);
		// healthBar
		addToHUD(healthBar);

		var iconBf = bf.iconName ?? "face";
		var iconDad = dad.iconName ?? "face";


		iconP1 = new HealthIcon(iconBf, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		addToHUD(iconP1);

		iconP2 = new HealthIcon(iconDad, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		addToHUD(iconP2);

		songInfoTxt = new FlxText(0, Settings.get("downscroll") ? FlxG.height - 35 : 15);
		songInfoTxt.antialiasing = false;
		songInfoTxt.alpha = 0;
		songInfoTxt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songInfoTxt.borderSize = 3;

		var difficultyColor = 0;
		/*switch (difficulty) {
			case 0: difficultyColor = FlxColor.LIME;
			case 1: difficultyColor = FlxColor.YELLOW;
			case 2: difficultyColor = FlxColor.RED;
		}*/
		difficultyColor = difficultyData.color;

		songInfoTxt.applyMarkup(SONG.song.replace("-", " ").toUpperCase() + ' - ~~${difficulty.toUpperCase()}~~', [
			new FlxTextFormatMarkerPair(new FlxTextFormat(difficultyColor), "~~")
		]);
		songInfoTxt.screenCenter(X);
		addToHUD(songInfoTxt);

		songTimeTxt = new FlxText(20, healthBarBG.y, 0, "[-:--/-:--]");
		songTimeTxt.visible = Settings.get("songPosition");
		songTimeTxt.antialiasing = false;
		songTimeTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songTimeTxt.borderSize = 2;
		addToHUD(songTimeTxt);

		scoreTxt = new FlxText(0, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.antialiasing = false;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Settings.get("botplay") ? 30 : 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;													  
		addToHUD(scoreTxt);
		updateScoreTxt();

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
					if (HFunk.funcExists(CUTSCENE)) HFunk.doDaCallback(CUTSCENE, []);
					else startCountdown();
			}
		}
		else startCountdown();

		super.create();

		HFunk.doDaCallback(CREATE_POST, []);
	}

	override function sectionHit() {
        super.sectionHit();

		HFunk.doDaCallback(SECTION, [curSection]);
		
        if (SONG.notes[curSection] == null) return;
		
        if (songStarted && moveCamera) {
			var next = SONG.notes[curSection].mustHitSection ? "bf" : "dad";
			var camCall = HFunk.doDaCallback(CAMERA, [next]);
		    if (camCall.contains(HVars.STOP)) return;
			if (next != camOn) moveCam(next);
		}
    }

	function moveCam(target:OneOfTwo<Array<Float>, String>) {
		if (target == camOn) return;
		camOn = target;
        var char:Character = null;
		if (target is Array) camFollow.setPosition(target[0], target[1]);
        else switch (target) {
            case "bf": char = bf;
            case "gf": char = gf;
            case "dad": char = dad;
        }

        if (char != null) {
            var offsetX = char.displaceData.camX;
            var offsetY = char.displaceData.camY;
            var midpoint = char.getMidpoint();
			var xOff = target == "dad" ? 150 : -100;
            camFollow.setPosition(midpoint.x + xOff + offsetX, midpoint.y - 100 + offsetY);
        }
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		cpuStrums.doIntro();
		playerStrums.doIntro();

		addToHUD(splashes);
		addToHUD(combos);

		
		var daThingy = -20;
		if (Settings.get("downscroll")) daThingy *= -1;
		songInfoTxt.y += daThingy;
		FlxTween.tween(songInfoTxt, { y: songInfoTxt.y + (daThingy * -1), alpha: 1 }, 2.2, { ease: FlxEase.circOut });

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var countTick = HFunk.doDaCallback(COUNTDOWN, [tmr.elapsedLoops - 1]);
			if (countTick.contains(HVars.STOP)) return;

			if (dad != null && tmr.elapsedLoops % dad?.bopSpeed == 0) dad?.dance();
			if (gf != null && tmr.elapsedLoops % gf?.bopSpeed == 0) gf?.dance();
			if (bf != null && tmr.elapsedLoops % bf?.bopSpeed == 0) bf?.dance();
			stage.beatHit(curBeat);

			var prefix = 'ui/$curUi/countdown';
			var introAlts:Array<String> = ['$prefix/ready', '$prefix/set', '$prefix/go'];
			var sfx = ['countdown/intro3', 'countdown/intro2', 'countdown/intro1', 'countdown/introGo'];
			var altSuffix:String = "";
			if (curUi == 'pixel') altSuffix = "-pixel";
			
			if (tmr.elapsedLoops != 1) {
				var cdSpr = new FlxSprite().loadGraphic(Paths.image(introAlts[tmr.elapsedLoops - 2]));
			    cdSpr.updateHitbox();
			    if (curUi == 'pixel') {
					cdSpr.setGraphicSize(Std.int(cdSpr.width * daPixelZoom));
					cdSpr.antialiasing = false;
				} 
				cdSpr.screenCenter();
				cdSpr.cameras = [camHUD];
			    add(cdSpr);
				FlxTween.tween(cdSpr, { y: cdSpr.y += 100, alpha: 0 }, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: t -> cdSpr.destroy()
				});
			}
			FlxG.sound.play(Paths.sound(sfx[tmr.elapsedLoops - 1] + altSuffix), 0.6);
			
			// generateSong('fresh');
		}, 4);
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
		
		HFunk.doDaCallback(SONG_START, []);

		if (!paused) FlxG.sound.playMusic(Paths.inst(SONG.song, musicPost), 1, false);
		FlxG.sound.music.onComplete = HFunk.funcExists(SONG_END) ? () -> HFunk.doDaCallback(SONG_END, []) : endSong;
		vocals.time = FlxG.sound.music.time;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		resyncVocals();
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + difficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy));
		#end
	}

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());

		Conductor.changeBPM(SONG.bpm);

		curSong = SONG.song;

		if (SONG.needsVoices && FileSystem.exists(Paths.voices(SONG.song, musicPost, true)))
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song, musicPost));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		var eventPaths:Array<String> = [];
		var songName = SONG.song.toLowerCase().replace(" ", "-");
		if (Paths.songDataDir(songName).contains("events"))
			eventPaths = eventPaths.concat(FileSystem.readDirectory(Paths.getPath('songs/${SONG.song.toLowerCase()}/events')).filter(s -> s.endsWith('.hxs')).map(s -> Paths.curModDir + '/songs/$songName/events/$s'));
		#if MODS
		if (Paths.curModDir != null && FileSystem.exists(Paths.curModDir + '/events')) 
			eventPaths = eventPaths.concat(FileSystem.readDirectory(Paths.curModDir + '/events').filter(d -> d.endsWith('.hxs')).map(d -> Paths.curModDir + '/events/$d'));
		#end
		if (FileSystem.exists('assets/events')) 
			eventPaths = eventPaths.concat(FileSystem.readDirectory('assets/events').filter(d -> d.endsWith('.hxs')).map(d -> 'assets/events/$d'));
		

		for (x in eventPaths) {
			try {
			    var daScript:CallbackScript = new CallbackScript(x, 'Event:$x', {
			    	name: "",
			    	description: "N/A",
			    	game: this,
			    	Paths: Paths
			    });
				daScript.exec(INIT, []);

				var eventName:String = daScript.get("name");
				
			    if (eventName == "") continue;
			    if (eventScripts.exists(eventName)) continue;
			    eventScripts.set(eventName, daScript);
			}
			catch (e) {
				trace('failed to load event $x: ${e.message}');
				continue;
			}
		}

		var inSongEvents = [];
		if (Paths.songDataDir(songName + '/charts').contains("events.json")) {
			var eventDoHickey:SwagSong = Json.parse(File.getContent(Paths.json('${songName}/charts/events', true))).song;
			for (sect in eventDoHickey.notes) {
				for (note in sect.sectionNotes) {
					var daStrumTime:Float = note[0] + FlxG.save.data.offset;
				    if (daStrumTime < 0)
				    	daStrumTime = 0;
					var coolNoteData = note[1] % 4;
					if (coolNoteData == -1) {
						for (x in 0...note[2].length) {
							if (!(note[2] is Array)) continue;
							var eventData = note[2][x];
							var name = eventData[0];
							var val1 = eventData[1];
							var val2 = eventData[2];
							// crashes are bad m'kay
							if ((!(name is String) || name == null) || (!(val1 is String) || val1 == null) || (!(val2 is String) || val2 == null)) continue; 
							var iHateHaxe:Array<Dynamic> = [name, val1, val2, daStrumTime];
							var eventScript = null;
							if (eventScripts.exists(name)) eventScript = eventScripts[name];
							 
							if (!inSongEvents.contains(name) && eventScript != null) eventScript.exec(CREATE_POST, []); 
							else inSongEvents.push(name);
							events.push(iHateHaxe);
							if (eventScript != null) eventScript.exec(PRELOAD, [val1, val2, daStrumTime]);
							HFunk.doDaCallback(EVENT_LOAD, iHateHaxe);
						}
						continue;
					}
				}	
			}
		}

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if (daNoteData == -1) {
					for (x in 0...songNotes[2].length) {
						if (!(songNotes[2] is Array)) continue;
						var eventData = songNotes[2][x];
						var name = eventData[0];
						var val1 = eventData[1];
						var val2 = eventData[2];
						// crashes are bad m'kay
						if ((!(name is String) || name == null) || (!(val1 is String) || val1 == null) || (!(val2 is String) || val2 == null)) continue; 
						var iHateHaxe:Array<Dynamic> = [name, val1, val2, daStrumTime];
						var eventScript = null;
						if (eventScripts.exists(name)) eventScript = eventScripts[name];
 						
						if (!inSongEvents.contains(name)) inSongEvents.push(name);
						events.push(iHateHaxe);
						if (eventScript != null) eventScript.exec(PRELOAD, [val1, val2, daStrumTime]);
						HFunk.doDaCallback(EVENT_LOAD, iHateHaxe);
					}
					continue;
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
					HFunk.doDaCallback(NOTE_SPAWN, [sustainNote]);
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) swagNote.x += FlxG.width / 2; // general offset

				HFunk.doDaCallback(NOTE_SPAWN, [swagNote]);
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
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + difficulty + ") ", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy));
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
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + difficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + difficulty + ")", null);
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
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + difficulty + ") ", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps(default, set):Int = 0;
	function set_nps(val:Int) {
		updateScoreTxt();
		return nps = val; 
	}

	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		HFunk.doDaCallback(UPDATE, [elapsed]);
		stage.stageUpdate(elapsed);
		
		//trace(FlxG.sound.music.name);

		if (songStarted && updateTime && songTimeTxt.visible) 
			songTimeTxt.text = "[" + CoolUtil.msToTimestamp(FlxG.sound.music.time) + "/" + CoolUtil.msToTimestamp(FlxG.sound.music.length) + "]";
		    // songTimeTxt.x = songInfoTxt.width - 20;
		

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (events.length != 0) {
			if (events[0][3] <= Conductor.songPosition) {
				HFunk.doDaCallback(EVENT, events[0]);
				stage.event(events[0][0], events[0][1], events[0][2], events[0][3]);
				if (eventScripts.exists(events[0][0])) eventScripts.get(events[0][0]).exec(CALLBACK, [events[0][1], events[0][2], events[0][3]]);
				events.shift();
			}
		}

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
			if (!Settings.get("botplay")) {
				nps = notesHitArray.length;
			    if (nps > maxNPS) maxNPS = nps;
		    }
		}

		/*if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}*/

		super.update(elapsed);
		
		updateHealthBarStuff();
		
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause) openPause();

		if (FlxG.keys.justPressed.SEVEN && !stateChangeFired)
		{
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			HFunk.doDaCallback(BEFORE_EXIT, []);
			stateChangeFired = true;
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (bopHealthIcons) {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		    iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

			iconP1.updateHitbox();
		    iconP2.updateHitbox();
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */
	
		if (FlxG.keys.justPressed.EIGHT && !stateChangeFired) {
			var isPlayer = false;
			var char = dad?.curCharacter ?? null;
			if (FlxG.keys.pressed.CONTROL) {
				isPlayer = true;
				char = bf?.curCharacter ?? null;
			}
			if (FlxG.keys.pressed.SHIFT) char = gf?.curCharacter ?? null;
			if (char != null) FlxG.switchState(new AnimationDebug(char, isPlayer));
			HFunk.doDaCallback(BEFORE_EXIT, []);
			stateChangeFired = true;
		}

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

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		#if debug
        FlxG.watch.addQuick('songPos', Conductor.songPosition);
        FlxG.watch.addQuick('curStep', curStep);
        FlxG.watch.addQuick('curBeat', curBeat);
        FlxG.watch.addQuick('curSection', curSection);
        #end

		if (FlxG.keys.justPressed.R && Settings.get("resetButton")) health = 0;

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
				for (x in 0...notes.length)
				{	
					var daNote = notes.members[x];
					if (daNote == null || !daNote.alive) {
						notes.remove(daNote, true);
						if (daNote != null) daNote.destroy();
						break;
					}

					// NoteHandler.handleNote(daNote);
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
					
					var curStrum = (daNote.mustPress ? playerStrums : cpuStrums).members[daNote.noteData];
					var strumLineMid = curStrum.height / 2;
					
					if (FlxG.save.data.downscroll)
						{
							daNote.y = (curStrum.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
							if(daNote.isSustainNote)
							{
								// Remember = minus makes notes go up, plus makes them go down
								if(daNote.isSustainEnd && daNote.prevNote != null)
									daNote.y += daNote.prevNote.height;
								else
									daNote.y += daNote.height / 2;

								// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (curStrum.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
							}
						}else
						{
							daNote.y = (curStrum.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
							if(daNote.isSustainNote && !daNote.noHit)
							{
								daNote.y -= daNote.height / 2;

								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (curStrum.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
					}
		
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						HFunk.doDaCallback(OPPONENT, [daNote.noteData, daNote]);


						if (!daNote.noHit) {
							var altAnim:String = "";
	
						    if (SONG.notes[curSection] != null)
						    {
						    	if (SONG.notes[curSection].altAnim)
						    		altAnim = '-alt';
						    }
							dad?.playAnim('sing${Character.directions[daNote.noteData]}' + altAnim, true);
								
							cpuStrums.lightStrum(daNote.noteData);
								
		
							if (dad != null) dad.holdTimer = 0;
			
							if (SONG.needsVoices)
								vocals.volume = 1;
			
							daNote.active = false;
		
								
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}

					var targetSyncStrum = (daNote.mustPress ? playerStrums : cpuStrums).members[daNote.noteData];


					if (daNote.strumSyncVariables.contains("visible")) daNote.visible = targetSyncStrum.visible;
 					if (daNote.strumSyncVariables.contains("alpha")) daNote.alpha = targetSyncStrum.alpha - (daNote.isSustainNote ? 0.4 : 0);
					if (daNote.strumSyncVariables.contains("angle") && !daNote.isSustainNote) daNote.angle = targetSyncStrum.angle;
					if (daNote.strumSyncVariables.contains("color")) daNote.color = targetSyncStrum.color;
					if (daNote.strumSyncVariables.contains("x")) daNote.x = targetSyncStrum.x;


					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * SONG.speed));
	
					if (daNote.tooLate)
					{
							if (daNote.mustPress) {
								health -= 0.075;
								vocals.volume = 0;
								if (!daNote.noHit) noteMiss(daNote.noteData, daNote);
							}
		
							if (!daNote.noHit || (daNote.noHit && daNote.strumTime <= Conductor.songPosition - daNote.strumTime)) {
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
					}
				}
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

		HFunk.doDaCallback(UPDATE_POST, []);
	}

	public function preExit() {
		#if MODS
		Paths.curModDir = null;
		#end
		saveScore = true;

		Assets.cache.removeSound(Paths.inst(SONG.song, musicPost, true));
		if (SONG.needsVoices) Assets.cache.removeSound(Paths.voices(SONG.song, musicPost, true));

		HFunk.doDaCallback(BEFORE_EXIT, []);
		for (k => v in HFunk.scripts) v.active = false;
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
		if (saveScore) Highscore.saveScore(SONG.song, Math.round(songScore), HelperFunctions.truncateFloat(accuracy, 2), Ratings.getRatingType(), difficulty);
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
				weekScore += Math.round(songScore);

				playlist.remove(playlist[0]);

				if (playlist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('menu/freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					// saveScore = false;

					preExit();
					FlxG.switchState(new StoryMenuState());

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(week + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (saveScore) Highscore.saveWeekScore(week, weekScore, difficulty);
					saveScore = true;

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{

					trace('LOADING NEXT SONG');
					trace(playlist[0].toLowerCase() + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					SONG = Song.loadFromJson(difficulty, playlist[0]);
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
			// bf.playAnim('hey');
	
			/*var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];*/
			//
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
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					totalNotesHit += 0.50;
				case 'good':
					score = 200;
					ss = false;
					goods++;
					health += 0.04;
					totalNotesHit += 0.75;
				case 'sick':
					health += 0.1;
					totalNotesHit += 1;
					sicks++;
			}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));
			if (!Settings.get('botplay')) {
				songScore += Math.round(score);
			    songScoreDef += Math.round(Highscore.convertScore(noteDiff));
			}

			var msTiming = Math.round(HelperFunctions.truncateFloat(noteDiff, 3));

			var comboPopCall = HFunk.doDaCallback(COMBO, [daRating, combo, msTiming]);
			if (comboPopCall.contains(HVars.STOP)) return;

			combos.pop(daRating, msTiming);
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
					if (holdArray.contains(true) && /*!bf.stunned && */ generatedMusic)
					{
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
								goodNoteHit(daNote);
						});
					}
			 
					// PRESSES, check for note hits
					if (pressArray.contains(true) && /*!bf.stunned && */ generatedMusic)
					{
						if (bf != null) bf.holdTimer = 0;
			 
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
	
						// will reimplement
						/*if(dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay)
						{
							if (mashViolations > 8)
							{
								trace('mash violations ' + mashViolations);
								scoreTxt.color = FlxColor.RED;
								noteMiss(0,null);
							}
							else
								mashViolations++;
						}*/
	
					}
					
					notes.forEachAlive(function(daNote:Note)
					{
						var strumline = daNote.mustPress ? playerStrums : cpuStrums;
						if(FlxG.save.data.downscroll && daNote.y > strumline.members[daNote.noteData].y ||
						!FlxG.save.data.downscroll && daNote.y < strumline.members[daNote.noteData].y)
						{
							// Force good note hit regardless if it's too late to hit it or not as a fail safe
							if(FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress ||
							FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress)
							{
									goodNoteHit(daNote);
									if (bf != null) bf.holdTimer = daNote.sustainLength;
							}
						}
					});
			 
					if (bf != null && bf.animation != null && bf.animation.curAnim != null && bf.holdTimer > Conductor.stepCrochet * bf.singTime * 0.001) {
						if (
							((!Settings.get("botplay") && !holdArray.contains(true)) || 
							(Settings.get("botplay") && (bf.curAnim.finished || bf.curAnim.looped))) && 
							bf.curAnim.name.startsWith('sing')
						) bf.dance(true);
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
		if (Settings.get("botplay")) return;
		if (bf != null && bf.stunned) return;
		health -= 0.04;
		combo = 0;
		misses++;
		if (gf != null && combo > 5 && gf.animation.exists('sad')) gf.playAnim('sad', true);

			//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			//var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);
			if (daNote.noHit) destroy();

			songScore -= 10;
			updateAccuracy();
			updateScoreTxt();
			var missCall = HFunk.doDaCallback(NOTE_MISS, [direction, daNote]);
			if (missCall.contains(HVars.STOP)) return;

			FlxG.sound.play(Paths.soundRandom('miss/missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			bf?.playAnim('sing${Character.directions[direction]}miss', true);
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
					if (Settings.get("botplay")) return;
					playerStrums.lightStrum(note.noteData);
					notes.remove(note, true); 
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

					var noteCall = HFunk.doDaCallback(NOTE_HIT, [note.noteData, note]);
					if (noteCall.contains(HVars.STOP)) return;

					bf?.playAnim('sing${Character.directions[note.noteData]}', true);
				
					playerStrums.lightStrum(note.noteData);
					if (note.rating == "sick" && !note.isSustainNote) splashes.spawnSplash(note.noteData);
				}
			}
		

	override function stepHit()
	{
		super.stepHit();
		HFunk.doDaCallback(STEP, [curStep]);
		stage.stepHit(curStep);
		if (FlxG.sound.music.time >= Conductor.songPosition + 20 || FlxG.sound.music.time <= Conductor.songPosition - 20)
			resyncVocals();


		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + difficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null,true,  songLength - Conductor.songPosition);
		#end

	}

	override function beatHit()
	{
		super.beatHit();

		stage.beatHit(curBeat);
		HFunk.doDaCallback(BEAT, [curBeat]);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}


		var nextSect = SONG.notes[curSection];
		if (nextSect != null)
		{
			if (nextSect.bpm != null && nextSect.bpm != Conductor.bpm && nextSect.bpm > 0 && (nextSect.changeBPM == null || (nextSect.changeBPM != null && nextSect.changeBPM)))
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			/*if (SONG.notes[curSection].mustHitSection && dad.curCharacter != 'gf')
				dad.dance();*/
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);


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

		// WHY DO THESE KEEP FALLING THROUGH OH MY GOD
		if (gf != null && gf.animation != null && curBeat % gf.bopSpeed == 0 && !gf.animation.curAnim?.name.startsWith("sing")) gf.dance(true);
		if (bf != null && bf.animation != null && curBeat % bf.bopSpeed == 0 && !bf.animation.curAnim?.name.startsWith("sing")) bf.dance(true);
		if (dad != null && dad.animation != null && curBeat % dad.bopSpeed == 0 && !dad.animation.curAnim?.name.startsWith("sing")) dad.dance(true);
	}

	override function onFocus() {
		if (paused) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
	}
	override function onFocusLost() {
		if (health > 0 && !paused && !inCutscene) openPause();
		
		super.onFocusLost();
	}

	static public function makeShader(path:String) {
		var shaderStuff = CoolUtil.getShaderStuffs(Paths.shader(path));

		return new FlxRuntimeShader(shaderStuff[0], shaderStuff[1]);
	}
	
	public function updateScoreTxt() {
		var scoreChangeCall = HFunk.doDaCallback(SCORE_UPDATE, []);
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

	public function preloadEvent(name:String, val1:String="", val2:String="") {
		// crashes are bad m'kay
		var iHateHaxe:Array<Dynamic> = [name, val1, val2, 0];
		var eventScript:Null<CallbackScript> = null;
		if (eventScripts.exists(name)) eventScript = eventScripts[name];
		 
		if (eventScript != null) eventScript.exec(PRELOAD, [val1, val2, 0]);
		HFunk.doDaCallback(EVENT_LOAD, iHateHaxe);
	}

	public function invokeEvent(name:String, val1:String="", val2:String="") events.insert(0, [name, val1, val2, Conductor.songPosition]);

	function runGameOver() {
		if (stateChangeFired) return;
		if (bf != null) bf.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

		#if desktop
		// Game Over doesn't get his own variable because it's only used here
		DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + difficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null);
		#end

		var gameOverCall = HFunk.doDaCallback(GAME_OVER, []);
		if (gameOverCall.contains(HVars.STOP)) return;
			
		var bfX = bf != null ? bf.getScreenPosition().x : 0;
		var bfY = bf != null ? bf.getScreenPosition().y : 0;

		openSubState(new GameOverSubstate(bfX, bfY));
	}

	function openPause() {
		if (!canPause || inCutscene || FlxG.sound.music == null) return;
		persistentUpdate = false;
		paused = true;	

		FlxG.sound.music.pause();
		vocals.pause();

		var pauseRets = HFunk.doDaCallback(PAUSE, []);
		if (pauseRets.contains(HVars.STOP)) return;

		// 1 / 1000 chance for Gitaroo Man easter egg
		// imma be real, this gets annoying when you're trying to test
		if (Settings.get("gitaroo") && FlxG.random.bool(0.1))
		{
			trace('GITAROO MAN EASTER EGG');
			FlxG.switchState(new GitarooPause());
		}
		else
			openSubState(new PauseSubState());
	}

	function updateHealthBarStuff() {
		var iconOffset:Int = 26;

		if (moveHealthIcons) {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		    iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}

	public function addToTop(thing:FlxBasic) {
		thing.cameras = [camTop];
		add(thing);
	}

	public function addToHUD(thing:FlxBasic) {
		thing.cameras = [camHUD];
		add(thing);
	}

	#if VIDEOS
	function playVideo(videoPath:String, endCallBack:Void -> Void) {
		#if (hxCodec >= "2.6.1")
		var videoHandler = new VideoHandler();
		#else
		var videoHandler = new MP4Handler();
		#end
		videoHandler.finishCallback = endCallBack;
		videoHandler.playVideo(Paths.video(videoPath));
	}
	#end

	function openCustomSubState(targetSub:String) openSubState(new CustomSubState(targetSub));

	function openDialogueBox(boxType:String, dialogue:Array<String>, callback:Void -> Void) {
		var dialogueBox = new EdakeDialogueBox(boxType, dialogue);
		dialogueBox.finishCallback = callback;
		addToTop(dialogueBox);
	}
}

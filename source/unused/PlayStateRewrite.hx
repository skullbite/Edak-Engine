package;

import flixel.FlxCamera;
import flixel.math.FlxRect;
import RibbitNote.NoteSprite;
import openfl.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import yaml.Parser.ParserOptions;
import flixel.system.FlxSound;
import hstuff.HVars;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import openfl.Lib;
import flixel.math.FlxPoint;
import sys.FileSystem;
import flixel.FlxG;
import Discord.DiscordClient;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import hstuff.FunkScript;
import yaml.Yaml;
import StoryMenuState.DifficultyData;
import Song.SwagSong;

using StringTools;

class PlayStateRewrite extends PlayBase {
    // hscript stuff
    public static var instance:PlayStateRewrite;
    public static var HFunk:FunkScript;
    var globalVars:Map<String, String> = [];

    var moveHealthIcons:Bool = true;
    var bopHealthIcons:Bool = true;
    var moveCamera:Bool = true;
    var zoomCamera:Bool = false;
    var forceCutscene:Bool = false;
    var popCombos:Bool = true;
    var updateScore:Bool = true;
    var updateTime:Bool = true;


    // actually static variables
    public static var daPixelZoom = 6;

    // week stuff
    public static var isStoryMode:Bool = false;
    public static var weekScore:Int = 0;
    public static var playlist:Array<String> = [];
    // todo: week id 
    public static var week:Int = 0;


    // song + diff stuff
    public static var SONG:SwagSong;
    public static var songSuffix:Null<String>;
    public static var difficultyData:DifficultyData;
    public static var difficulty(default, set):String = "normal";
    public static function set_difficulty(val:String) {
        difficultyData = Yaml.read(Paths.yaml('difficulties/${val.toLowerCase()}'), new ParserOptions().useObjects());
        songSuffix = difficultyData.loadsDifferentSong ? val.toLowerCase() : null;
        return difficulty = val;
    }

    // stage stuff
    public static var curUi:String = "normal";
    public static var curStage:String = "stage";
    public static var defaultCamZoom:Float = 1.05;

    // character things
    public static var dad:Null<Character> = null;
    public static var gf:Null<Character> = null;
    public static var bf:Null<Character> = null;

    public static var dadGroup:FlxTypedGroup<FlxBasic>;
    public static var gfGroup:FlxTypedGroup<FlxBasic>;
    public static var bfGroup:FlxTypedGroup<FlxBasic>;
    

    // voices
    var voices:Null<FlxSound>;

    // camera stuff

    var camFollow:FlxObject;
    static var prevCamFollow:FlxObject;
    var camBumpZoom:Float = 0.015;
	var hudBumpZoom:Float = 0.03;

    // ui stuff
    var healthBarBG:FlxSprite;
    var healthBar:FlxBar;

    var iconP1:HealthIcon;
    var iconP2:HealthIcon;

    var infoTxt:FlxText;
    var timeTxt:FlxText;

    public static var splashes:SplashGroup;
    public static var combos:ComboGroup;

    // timers n tweens
    var startTimer:FlxTimer;

    // notes
    var notes:FlxTypedGroup<NoteSprite>;
    var unspawnNotes:Array<RibbitNote> = [];
    

    // logic objects
    var camOn(default, set):String = "dad";
    function set_camOn(val:String) {
        if (val == camOn) return camOn = val;
        var char:Character = null;
        switch (val) {
            case "bf": char = bf;
            case "gf": char = gf;
            case "dad": char = dad;
        }

        if (char != null) {
            var offsetX = char.displaceData.camX;
            var offsetY = char.displaceData.camY;
            var midpoint = char.getMidpoint();
            var xOff = val == "dad" ? 150 : -100;

            camFollow.setPosition(midpoint.x + xOff + offsetX, midpoint.y - 100 + offsetY);
        }

        return camOn = val;
    }
    var generatedSong:Bool = false;
    var startingSong:Bool = false;
    var endingSong:Bool = false;
    var startedCountdown:Bool = false;
    var inCutscene:Bool = false;
    var songStarted:Bool = false;
    var previousFrameTime:Int = 0;

    var paused:Bool = false;
    var canPause:Bool = false;

    var songLength:Float = 0;

    public static var saveScore:Bool = true;


    // rating + score + more player data things
    var health(default, set):Float = 1;
    function set_health(val:Float):Float {
        if (val <= 0) {
            runGameOver();
            return health = val;
        }

        health = val;
        updateHealthBarStuff();
        return val;
	}
    var score:Int = 0;
    var nps:Int = 0;
    var maxNPS:Int = 0;
    public var combo:Int = 0;
    public var misses:Int = 0;
    public var ratings = {
        sicks: 0,
        goods: 0,
        bads: 0,
        shits: 0
    };

    var accuracy:Float = 0;
    var totalNotesPassed:Int = 0;
    var totalNotesHit:Int = 0;
    function set_totalNotesPassed(val:Int) {
        accuracy = Math.max(0, totalNotesHit / val * 100);
        return totalNotesPassed = val;
    }
    
    override function create() {
        instance = this;
        HFunk = new FunkScript();

        dadGroup = new FlxGroup();
        gfGroup = new FlxGroup();
        bfGroup = new FlxGroup();

        defaultCamZoom = 1.05;
        curUi = 'normal';
        bgType = STAGE;

        if (FlxG.sound.music != null) FlxG.sound.music.stop();

        generateSong();

        #if desktop
        DiscordClient.changePresence('this is a test state', 'say hi if you see this :D');
        #end

        if (SONG == null) {
            FlxG.log.warn('null song, rip');
            SONG = {
                song: "test",
                bpm: 100,
                speed: 1,
                needsVoices: true,
                notes: [],
                stage: "stage",
                gfVersion: "gf",
                player1: "bf",
                player2: "dad"
            };
        }

        if (SONG.stage == '' || curStage == null) {
            curStage = "stage";
        }
        else curStage = SONG.stage;

        super.create();

        notes = new FlxTypedGroup<NoteSprite>();
        add(notes);

        splashes = new SplashGroup();
        splashes.spawnSplash(0);

        combos = new ComboGroup();

        Conductor.mapBPMChanges(SONG);
        Conductor.changeBPM(SONG.bpm);

        Conductor.songPosition = -5000;

        var songPath = Paths.inst(SONG.song, songSuffix, true);
        var voicePath = Paths.voices(SONG.song, songSuffix, true);

        if (FileSystem.exists(songPath)) Paths.getSound(songPath);
        if (SONG.needsVoices && FileSystem.exists(voicePath)) Paths.getSound(voicePath);

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

        if (SONG.gfVersion != null) gf = new Character(400, 130, SONG.gfVersion);
        if (gf != null && gf.scrollFactor != null) {
            gfGroup.add(gf);
            gf.x += gf.displaceData.x;
            gf.y += gf.displaceData.y;
        }

        if (SONG.player2 != null) dad = new Character(100, 100, SONG.player2);
        if (dad != null) {
            dadGroup.add(dad);
            dad.x += dad.displaceData.x;
            dad.y += dad.displaceData.y;
        }

        if (SONG.player1 != null) bf = new Boyfriend(770, 450, SONG.player1);
        if (bf != null) {
            bfGroup.add(bf);
            bf.x += bf.displaceData.x;
            bf.y += bf.displaceData.y;
        }

        // can't even use my null checker 
		var camX = dad != null ? dad.getGraphicMidpoint().x + dad.displaceData.camX + 150 : 0;
		var camY = dad != null ? dad.getGraphicMidpoint().y + dad.displaceData.camY - 100 : 0;
        var camPos:FlxPoint = new FlxPoint(camX, camY);

        camFollow = new FlxObject(camPos.x, camPos.y, 1, 1);
        add(camFollow);

        add(gfGroup);
        add(stage.infrontOfGf);
        add(dadGroup);
        add(bfGroup);
        add(stage.foreground);

        FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
        FlxG.camera.zoom = defaultCamZoom;
        FlxG.camera.focusOn(camFollow.getPosition());
        FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        FlxG.fixedTimestep = false;

        healthBarBG = new FlxSprite(0, Settings.get("downscroll") ? 50 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
        healthBarBG.cameras = [camHUD];
        healthBarBG.screenCenter(X);
        add(healthBarBG);

        healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
        healthBar.cameras = [camHUD];
        var bfColor = bf != null ? FlxColor.fromString(bf.barColor) : 0xFF66FF33;
		var dadColor = dad != null ? FlxColor.fromString(dad.barColor) : 0xFFFF0000;
        healthBar.createFilledBar(dadColor, bfColor);
        add(healthBar);

        var iconBf = bf != null ? bf.iconName : "face";
		var iconDad = dad != null ? dad.iconName : "face";

        iconP1 = new HealthIcon(iconBf, true);
        iconP1.cameras = [camHUD];
        iconP1.y = healthBar.y - (iconP1.height / 2);
        add(iconP1);

        iconP2 = new HealthIcon(iconDad);
        iconP2.cameras = [camHUD];
        iconP2.y = healthBar.y - (iconP2.height / 2);
        add(iconP2);

        updateHealthBarStuff();
        
        infoTxt = new FlxText(0, Settings.get("downscroll") ? 678 : -3);
        infoTxt.cameras = [camHUD];
        infoTxt.alpha = 0;
        infoTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        infoTxt.borderSize = 3;

        var difficultyColor = FlxColor.fromInt(difficultyData.color);

        infoTxt.applyMarkup(SONG.song.replace("-", " ").toUpperCase() + ' - ~~${difficulty.toUpperCase()}~~', [
            new FlxTextFormatMarkerPair(new FlxTextFormat(difficultyColor, true), "~~")
        ]);
        infoTxt.screenCenter(X);
        add(infoTxt);

        timeTxt = new FlxText(0, Settings.get("downscroll") ? 653 : (!Settings.get("songPosition") ? 5 : 0) + 27, "-:--/-:--");
        timeTxt.alpha = 0;
        timeTxt.cameras = [camHUD];
        timeTxt.visible = Settings.get("songPosition");
        timeTxt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        timeTxt.borderSize = 3;
        timeTxt.screenCenter(X);
        add(timeTxt);

        notes.cameras = [camHUD];

        startingSong = true;
        if (isStoryMode || forceCutscene) {
            if (HFunk.funcExists("onCutscene")) HFunk.doDaCallback("onCutscene", []);
            else startCountdown(); // countdown shittttttttt
        }
        else startCountdown(); // 3 2 1 go!

        HFunk.doDaCallback("onCreatePost", []);
        
        // todo: rework where camera starts on stage
    }

	public function preExit() {
        #if MODS
		Paths.curModDir = null;
		#end
		saveScore = true;
		var songPaths = 'songs/${SONG.song.toLowerCase()}';

		// Paths.inst/voices fetches either a string or sound, don't feel like reimplementing 
		Assets.cache.removeSound(Paths.getPath('$songPaths/Inst' + (songSuffix != null ? '-$songSuffix' : '') + Paths.SOUND_EXT));
		if (SONG.needsVoices) Assets.cache.removeSound(Paths.getPath(Paths.getPath('$songPaths/Voices' + (songSuffix != null ? '-$songSuffix' : '') + Paths.SOUND_EXT)));
    }

    function endSong() {
        endingSong = true;
        
    }

	public function updateScoreTxt() {}

    function updateHealthBarStuff() {
        iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(health / 2, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - 26;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(health / 2, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - 26 * 2;
    }

    function runGameOver() {
        persistentUpdate = false;
		persistentDraw = false;
        paused = true;

        voices.stop();
        FlxG.sound.music.stop();

        #if desktop
			// Game Over doesn't get his own variable because it's only used here
			// DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficulty + ")", Settings.get("botplay") ? "BOTPLAY" : Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy), null);
        #end

        var gameOverCall = HFunk.doDaCallback("onGameOver", []);
		if (gameOverCall.contains(HVars.STOP)) return;
		
		var bfX = bf != null ? bf.getScreenPosition().x : 0;
		var bfY = bf != null ? bf.getScreenPosition().y : 0;

		openSubState(new GameOverSubstate(bfX, bfY));
    }

    function openPauseMenu() {
        if (!canPause && !startedCountdown) return;

        persistentUpdate = false;
        // persistentDraw = false;
        paused = true;

        FlxG.sound.music.pause();
        if (voices != null) voices.pause();

        var pauseRets = HFunk.doDaCallback("onPause", []);
		if (pauseRets.contains(HVars.STOP)) return;

        // imma be real, this gets annoying when you're trying to test
        #if !debug
        if (FlxG.random.bool(0.01))
        {
        	trace('GITAROO MAN EASTER EGG');
        	FlxG.switchState(new GitarooPause());
        }
        else
        #end
            openSubState(new PauseSubState());
    }

    override function beatHit() {
        super.beatHit();

        if (zoomCamera && FlxG.camera.zoom < 1.35 && curBeat % bopSpeed == 0)
            {
                FlxG.camera.zoom += camBumpZoom;
                camHUD.zoom += hudBumpZoom;
            }

        if (songStarted) {
            if (dad != null && curBeat % dad.bopSpeed == 0) dad.dance();
            if (gf != null && curBeat % gf.bopSpeed == 0) gf.dance();
            if (bf != null && curBeat % bf.bopSpeed == 0) bf.dance();
        }
        
    }

    function startCountdown() {
        inCutscene = false;

        cpuStrums.doIntro();
        playerStrums.doIntro();

        add(splashes);
        add(combos);

        var off = 0;
        if (!Settings.get("songPosition")) off = 10;
        if (Settings.get("downscroll")) {
			off *= -1;
			off -= 5;
		}
        
		FlxTween.tween(infoTxt, { y: infoTxt.y + 10 + off, alpha: 1 }, 2.2, { ease: FlxEase.circOut });
        if (timeTxt.visible) FlxTween.tween(timeTxt, { y: timeTxt.y + 10, alpha: 1 }, 2.2, { ease: FlxEase.circOut });

        startedCountdown = true;

        Conductor.songPosition = 0;
        Conductor.songPosition -= Conductor.crochet * 5;

        startTimer = new FlxTimer().start(Conductor.crochet / 1000, t -> {
            var countTick = HFunk.doDaCallback("onCountdownTick", [t.elapsedLoops - 2]);
            if (countTick.contains(HVars.STOP)) return;

            if (dad != null && t.elapsedLoops % dad.bopSpeed == 0) dad.dance();
            if (gf != null && t.elapsedLoops % gf.bopSpeed == 0) gf.dance();
            if (bf != null && t.elapsedLoops % bf.bopSpeed == 0) bf.dance();

            var prefix = 'ui/$curUi/countdown';
            var introAssets = ['$prefix/ready', '$prefix/set', '$prefix/go'];
            var sfx = ['countdown/intro3', 'countdown/intro2', 'countdown/intro1', 'countdown/introGo'];
            var altSuffix = curUi == "pixel" ? "-pixel" : "";

            if (t.elapsedLoops != 1) {
                var cdSpr = new FlxSprite().loadGraphic(Paths.image(introAssets[t.elapsedLoops - 2]));
                if (curUi == 'pixel') cdSpr.setGraphicSize(Std.int(cdSpr.width * daPixelZoom));
                cdSpr.screenCenter();
                cdSpr.cameras = [camHUD];
                add(cdSpr);
                FlxTween.tween(cdSpr, { /* y: cdSpr.y - 50, */ alpha: 0 }, Conductor.crochet / 1000, {
                    ease: FlxEase.cubeInOut,
                    onComplete: _ -> cdSpr.destroy()
                });
            }
            FlxG.sound.play(Paths.sound(sfx[t.elapsedLoops - 1] + altSuffix), 0.6);
        }, 4);
    }

    function startSong() {
        previousFrameTime = FlxG.game.ticks;
        startingSong = false;
        songStarted = true;

        HFunk.doDaCallback("onSongStart", []);
        if (!paused) FlxG.sound.playMusic(Paths.inst(SONG.song, songSuffix), 1, false);
        if (voices != null) {
            voices.play();
            // resyncVoices();
        }

        songLength = FlxG.sound.music.length;

        #if desktop
        // DiscordClient.changePresence();
        #end
    }

    function generateSong() {
        voices = SONG.needsVoices ? new FlxSound().loadEmbedded(Paths.voices(SONG.song, songSuffix)) : null;
        if (voices != null) FlxG.sound.list.add(voices);

        for (sect in SONG.notes) {
            var mustHit = sect.mustHitSection;

            for (swagNotes in sect.sectionNotes) {
                var strumTime = swagNotes[0] + Settings.get("offset");
                if (strumTime < 0) strumTime = 0;

                var noteData = Std.int(swagNotes[1] % 4);

                var mustHitNote = mustHit;
                if (noteData > 3) mustHitNote = !mustHitNote;

                var noteType = swagNotes[3] != null ? swagNotes[3] : "Normal";

                var oldNote:RibbitNote = null;
                if (unspawnNotes.length > 0) oldNote = unspawnNotes[unspawnNotes.length - 1];

                var swagNote:RibbitNote = new RibbitNote(strumTime, noteData, mustHitNote, swagNotes[2], noteType);
                unspawnNotes.push(swagNote);
                // if (unspawnNotes.length > 0) oldNote = unspawnNotes                
            }
        }

        unspawnNotes.sort((note1, note2) -> FlxSort.byValues(FlxSort.ASCENDING, note1.strumTime, note2.strumTime));
        generatedSong = true;
    }

    function resyncVocals() {
        if (!songStarted) return;

        FlxG.sound.music.play();
        Conductor.songPosition = FlxG.sound.music.time;

        if (voices != null) {
            voices.pause();
            voices.time = Conductor.songPosition;
            voices.play();
        }
        
    }

    function handleNotes() {
        for (daNote in notes) {
            if (daNote.parent == null || !daNote.active) continue;
            /*daNote.visible = daNote.tooLate;
            daNote.active = daNote.tooLate;*/
            var lastNote = daNote.parent.holds.members[daNote.ID - 1];
            var strum = (daNote.parent.mustPress ? playerStrums : cpuStrums).members[daNote.parent.data];

            daNote.x = strum.x - 20;


            // daNote.y = 50;
            if (!Settings.get('downscroll')) {
                daNote.y = (strum.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
                if (daNote.isSustainNote) {}
            }
            else {
                daNote.y = (strum.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
            }

            if (FlxG.save.data.downscroll)
                {
                    if (daNote.parent.mustPress)
                        daNote.y = (playerStrums.members[daNote.parent.data].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
                    else
                        daNote.y = (cpuStrums.members[daNote.parent.data].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
                    if(daNote.isSustainNote)
                    {
                        // Remember = minus makes notes go up, plus makes them go down
                        if(daNote.animation.curAnim.name.endsWith('end') && daNote.parent.holds.members[daNote.ID - 1] != null)
                            daNote.y += lastNote.height;
                        else
                            daNote.y += daNote.height / 2;

                        // If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
                        if(!FlxG.save.data.botplay)
                        {
                            if(daNote.wasGoodHit && (lastNote.wasGoodHit && !daNote.canBeHit))
                            {
                                // Clip to strumline
                                var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
                                swagRect.height = (cpuStrums.members[daNote.parent.data].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
                                swagRect.y = daNote.frameHeight - swagRect.height;

                                daNote.clipRect = swagRect;
                            }
                        }else {
                            var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
                            swagRect.height = (cpuStrums.members[daNote.parent.data].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
                            swagRect.y = daNote.frameHeight - swagRect.height;

                            daNote.clipRect = swagRect;
                        }
                    }
                }else
                {
                    if(daNote.isSustainNote)
                    {
                        daNote.y -= daNote.height / 2;

                        if(!FlxG.save.data.botplay)
                        {
                            if(daNote.wasGoodHit && (lastNote.wasGoodHit && !daNote.canBeHit))
                            {
                                // Clip to strumline
                                var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
                                swagRect.y = (cpuStrums.members[daNote.parent.data].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
                                swagRect.height -= swagRect.y;

                                daNote.clipRect = swagRect;
                            }
                        }else {
                            var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
                            swagRect.y = (cpuStrums.members[daNote.parent.data].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
                            swagRect.height -= swagRect.y;

                            daNote.clipRect = swagRect;
                        }
                    }
            }

            var targetSyncStrum = (daNote.parent.mustPress ? playerStrums : cpuStrums).members[daNote.parent.data];

			daNote.visible = targetSyncStrum.visible;
 		    daNote.alpha = targetSyncStrum.alpha - (daNote.isSustainNote ? 0.4 : 0);
			if (!daNote.isSustainNote) daNote.angle = targetSyncStrum.angle;
			daNote.color = targetSyncStrum.color;
		    daNote.x = targetSyncStrum.x;

			if (daNote.isSustainNote)
				daNote.x += daNote.width / 2 + 17;


            if (daNote.wasGoodHit && !daNote.parent.mustPress && Conductor.songPosition >= daNote.strumTime + 20) {
                notes.remove(daNote, true);
                daNote.destroy();
                trace('note terminated @ ${daNote.strumTime}, ${daNote.parent.mustPress}');
            }

            // if (daNote.mustPress && !daNote.)
        }
    }

    function goodNoteHit(daNote:NoteSprite) {
        
    }

    override function handleInput() {
        super.handleInput();

        if (inputs.presses.contains(true) && generatedSong) {
            if (bf != null) bf.holdTimer = 0;

            var possibleNotes:Array<NoteSprite> = [];
            var dirList:Array<Int> = [];
            var dumbNotes:Array<NoteSprite> = [];

            
            for (daNote in notes) {
                if (daNote == null || !daNote.active) continue;

                if (daNote.canBeHit && daNote.parent.mustPress && !daNote.tooLate && daNote.parent.mustPress) {
                    if (dirList.contains(daNote.parent.data)) {
                        for (coolNote in possibleNotes) {
                            if (coolNote.parent.data == daNote.parent.data && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
                            { // if it's the same note twice at < 10ms distance, just delete it
                                // EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
                                dumbNotes.push(daNote);
                                break;
                            }
                            else if (coolNote.parent.data == daNote.parent.data && daNote.strumTime < coolNote.strumTime)
                            { // if daNote is earlier than existing note (coolNote), replace
                                possibleNotes.remove(coolNote);
                                possibleNotes.push(daNote);
                                break;
                            }
                        }

                    }
                }
                else {
                    possibleNotes.push(daNote);
                    dirList.push(daNote.parent.data);
                }
            }

            for (x in dumbNotes) {
                trace('note killed @ ${x.strumTime}');
                notes.remove(x, true);
                x.destroy();
            }

            possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

            var dontCheck = false;

			for (i in 0...inputs.presses.length) {
                if (dontCheck) break;
				if (inputs.presses[i] && !dirList.contains(i)) dontCheck = true;
			}

            if (possibleNotes.length > 0 && !dontCheck) {
                if (!Settings.get("ghost")) {
                    for (i in 0...inputs.presses.length) {
                        if (inputs.presses[i] && !dirList.contains(i)) {} // note miss
                    }
                }

                for (swagNote in possibleNotes) {
                    if (inputs.presses[swagNote.parent.data]) {
                        // goodNoteHit
                    }
                }
            }
            else if (!Settings.get("ghost")) {
                for (shit in 0...inputs.presses.length)
                    if (inputs.presses[shit]) {} // noteMiss(shit, null);
            }

            for (daNote in notes) {
                if (daNote == null || !daNote.active) continue;
                if (daNote.strumTime <= Conductor.songPosition - daNote.strumTime) {
                    if (Settings.get("botplay") && (daNote.parent.canBeHit || daNote.tooLate) && daNote.parent.mustPress) {} // good note hit, set bf hold timer 
                }
            }

            if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!inputs.holds.contains(true) || FlxG.save.data.botplay)) {
                if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss')) bf.dance();
			}

        }




    }

    override function closeSubState() {
        if (!paused) {
            super.closeSubState();
            return;
        }

        if (FlxG.sound.music != null && !startingSong) resyncVocals();
        #if desktop
        // discord stuff
        #end

        super.closeSubState();
    }

    override function stepHit() {
        super.stepHit();
        if (!endingSong && FlxG.sound.music.time >= Conductor.songPosition + 20 || FlxG.sound.music.time <= Conductor.songPosition - 20) resyncVocals();
    }

    override function sectionHit() {
        super.sectionHit();
        if (SONG.notes[curSection] == null) return;
        if (moveCamera) camOn = SONG.notes[curSection].mustHitSection ? "bf" : "gf";
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);

        #if debug
        FlxG.watch.addQuick('songPos', Conductor.songPosition);
        FlxG.watch.addQuick('curStep', curStep);
        FlxG.watch.addQuick('curBeat', curBeat);
        FlxG.watch.addQuick('curSection', curSection);
        #end

        if (zoomCamera) {
            FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
            camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
        }

        if (updateTime) timeTxt.text = '${CoolUtil.msToTimestamp(FlxG.sound.music.time)}/${CoolUtil.msToTimestamp(FlxG.sound.music.length)}';

        if (FlxG.keys.justPressed.ENTER) openPauseMenu();

        if (startingSong) {
            if (startedCountdown) {
                Conductor.songPosition += FlxG.elapsed * 1000;
                if (Conductor.songPosition >= 0) startSong();
            }
        }
        else {
            Conductor.songPosition += FlxG.elapsed * 1000;
    
            if (!paused) previousFrameTime = FlxG.game.ticks;
        }

        if (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 350) {
            notes.add(unspawnNotes[0].parent);
            for (hold in unspawnNotes[0].holds) add(hold);
            if (unspawnNotes[0].parent == null) FlxG.log.warn("null note found in data!");
            unspawnNotes.splice(0, 1);
        }

        if (generatedSong) handleNotes();
    }
}
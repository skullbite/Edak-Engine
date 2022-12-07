package;

import flixel.FlxSprite;
import sys.FileSystem;
import sys.io.File;
import hstuff.HStage;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class Stage extends FlxTypedGroup<FlxBasic> {
    public var publicSprites:Map<String, FlxBasic>;
    public var foreground:FlxTypedGroup<FlxBasic>;
    public var infrontOfGf:FlxTypedGroup<FlxBasic>; // limo AUUUUUGH
    public var ScriptStage:Null<HStage> = null;
    public var curStage:String;
    public var defaultCamZoom:Float = 1.05;
    public var cameraDisplace:{x:Float,y:Float} = {
        x: 0.0,
        y: 0.0
    };
    public function new() {
        super();
        publicSprites = new Map();
        foreground = new FlxTypedGroup();
        infrontOfGf = new FlxTypedGroup();
        curStage = PlayState.curStage;
        switch (curStage) {
            // case "xyz": hardcoding auuuugh
            default:
                if (FileSystem.exists('assets/stages/$curStage')) {
                    var stageCode = File.getContent('assets/stages/$curStage/init.hx');
                    try {
                        ScriptStage = new HStage(this, stageCode);
                        ScriptStage.exec("create", []);
                    }
                    catch (e) {
                        trace('Failed to load $curStage from hscript: ${e.message}');
                        ScriptStage = null;
                        loadStageInstead();
                    }
                }
                else loadStageInstead();
        }
    }

    public function reposCharacters() {
        if (ScriptStage != null && ScriptStage.funcExists("reposCharacters")) {
            ScriptStage.exec("reposCharacters", []);
            return;
        }
    }

    public function stepHit(curStep:Int) {
        if (ScriptStage != null && ScriptStage.funcExists("stepHit")) { 
            ScriptStage.exec("stepHit", [curStep]); 
            return;
        }
    } 

    public function beatHit(curBeat:Int) {
        if (ScriptStage != null && ScriptStage.funcExists("beatHit")) {
            ScriptStage.exec("beatHit", [curBeat]);
            return;
        }
    }

    public function stageUpdate(elapsed:Float) {
        super.update(elapsed);
        if (ScriptStage != null && ScriptStage.funcExists("update")) { 
            ScriptStage.exec("update", [elapsed]);
            return;
        }
    }

    function loadStageInstead() {
        // PlayState.defaultCamZoom = 0.9;
		var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
        foreground.add(stageCurtains);
    }

}
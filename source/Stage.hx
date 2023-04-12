package;

import hstuff.HVars;
import hstuff.CallbackScript;
import flixel.FlxSprite;
import sys.FileSystem;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class Stage extends FlxTypedGroup<FlxBasic> {
    public var publicSprites:Map<String, FlxBasic>;
    public var foreground:FlxTypedGroup<FlxBasic>;
    public var infrontOfGf:FlxTypedGroup<FlxBasic>; // limo AUUUUUGH
    public var stageScript:Null<CallbackScript> = null;
    public var cameraDisplace:{x:Float,y:Float} = {
        x: 0.0,
        y: 0.0
    };
    public function new() {
        super();
        publicSprites = new Map();
        foreground = new FlxTypedGroup();
        infrontOfGf = new FlxTypedGroup();
        var curStage = PlayState.curStage;
        switch (curStage) {
            // case "xyz": hardcoding auuuugh
            default:
                if (FileSystem.exists(Paths.getPath('stages/$curStage/init.hxs'))) {
                    try {
                        var pathsThing = new CustomPaths(curStage, "stages");
                        pathsThing.useFullDir = true;
                        stageScript = new CallbackScript(Paths.getPath('stages/$curStage/init.hxs'), 'Stage:$curStage', {
                            add: add,
                            remove: remove,
                            foreground: foreground,
                            stage: this,
                            Paths: pathsThing,
                            _Paths: Paths
                        });
                        stageScript.execute();
                        stageScript.exec(CREATE, []);
                    }
                    catch (e) {
                        trace('Failed to load $curStage from hscript: ${e.message}');
                        stageScript = null;
                        loadStageInstead();
                    }
                }
                else loadStageInstead();
        }
    }

    public function createPost() {
        if (stageScript?.exists(CREATE_POST)) stageScript.exec(CREATE_POST, []);
    }

    public function stepHit(curStep:Int) {
        if (stageScript?.exists(STEP)) stageScript.exec(STEP, [curStep]); 
    } 

    public function beatHit(curBeat:Int) {
        if (stageScript?.exists(BEAT)) stageScript.exec(BEAT, [curBeat]);
    }

    public function stageUpdate(elapsed:Float) {
        super.update(elapsed);
        if (stageScript?.exists(UPDATE)) stageScript.exec(UPDATE, [elapsed]);
    }

    function loadStageInstead() {
        // PlayState.defaultCamZoom = 0.9;
		var bg = new FlxSprite(-600, -200).loadGraphic(Paths.getPath('stage/images/stageback.png', 'stages'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.getPath('stage/images/stagefront.png', 'stages'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.getPath('stage/images/stagecurtains.png', 'stages'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
        foreground.add(stageCurtains);
    }

}
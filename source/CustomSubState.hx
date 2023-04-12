package;

import hstuff.HVars.Callbacks;
import hstuff.CallbackScript;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxCamera;
import flixel.FlxG;

class CustomSubState extends MusicBeatSubstate {
    public var subScript:Null<CallbackScript> = null;
    var customCam:FlxCamera = new FlxCamera();
    public var subName:String;
    public function new(target:String) {
        super();
        customCam.bgColor.alpha = 0;
		FlxG.cameras.add(customCam);
        subName = target;
        if (FileSystem.exists(Paths.getPath('substates/$target/init.hxs'))) {
            try {
                subScript = new CallbackScript(Paths.getPath('substates/$target/init.hxs'), 'CustomSub:$target', {
                    sub: this,
                    add: add,
                    remove: remove,
                    Paths: new CustomPaths(subName, "substates"),
                    _Paths: Paths
                });
                subScript.execute();
                subScript.exec(CREATE, []);
            }
            catch (e) {
                trace('Failed to load $target: ${e.message}');
            }
        }
        else close();
        cameras = [customCam];
    }

    override function sectionHit() {
        super.sectionHit();
        if (subScript?.exists(SECTION)) subScript.exec(SECTION, [curSection]);
    }
    
    override function beatHit() {
        super.beatHit();
        if (subScript?.exists(BEAT)) subScript.exec(BEAT, [curBeat]);
    }
    
    override function stepHit() {
        super.stepHit();
        if (subScript?.exists(BEAT)) subScript.exec(STEP, [curStep]);
    }
    
    override function close() {
        super.close();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (subScript?.exists(BEAT)) subScript.exec(UPDATE, [elapsed]);
    }
}
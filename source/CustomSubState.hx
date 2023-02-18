package;

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
        if (FileSystem.exists('assets/substates/$target/init.hxs')) {
            try {
                subScript = new CallbackScript('assets/substates/$target/init.hxs', 'CustomSub:$target', {
                    sub: this,
                    Paths: new CustomPaths(subName, "substates"),
                    _Paths: Paths
                });
                subScript.execute();
                subScript.exec("create", []);
            }
            catch (e) {
                trace('Failed to load $target: ${e.message}');
            }
        }
        else close();
        cameras = [customCam];
    }
    

    override function close() {
        FlxG.cameras.remove(customCam);
        super.close();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (subScript != null) subScript.exec("update", [elapsed]);
    }
}
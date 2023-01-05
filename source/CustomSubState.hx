package;

import hstuff.HSub;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxCamera;
import flixel.FlxG;

class CustomSubState extends MusicBeatSubstate {
    public var subScript:Null<HSub> = null;
    var customCam:FlxCamera = new FlxCamera();
    public var subName:String;
    public function new(target:String) {
        super();
        customCam.bgColor.alpha = 0;
		FlxG.cameras.add(customCam);
        subName = target;
        if (FileSystem.exists('assets/substates/$target/init.hx')) {
            var code = File.getContent('assets/substates/$target/init.hx');
            subScript = new HSub(code, this);
            subScript.exec("create", []);
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
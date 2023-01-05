package hstuff;

import flixel.FlxSprite;
import Stage;

// todo: background characters bop faster than usual
// temp fix: set flxsprite anim framerates to half their target
class HStage extends CallbackScript {
    var vars:Map<String, Dynamic> = [];
    public function new(stageClass:Stage, path:String) {
        super(path);
        name = "Stage:" + stageClass.curStage;
        set("stage", stageClass);
        set("Paths", new CustomPaths(stageClass.curStage, "stages"));
        set("_Paths", Paths);
        set("FlxSprite", FlxSprite);
        set("vars", vars);
        try {
            execute();
        }
        catch (e) {
            trace('${stageClass.curStage} failed to load: ${e.message}');
        }
    }
}
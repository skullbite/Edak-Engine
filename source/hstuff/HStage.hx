package hstuff;

import flixel.FlxSprite;
import Stage;

// todo: background characters bop faster than usual
// temp fix: set flxsprite anim framerates to half their target
class HStage extends CallbackScript {
    var script:String = "";
    var vars:Map<String, Dynamic> = [];
    public function new(stageClass:Stage, script:String) {
        super(script);
        name = "Stage:" + stageClass.curStage;
        interp.variables.set("stage", stageClass);
        interp.variables.set("Paths", new StagePaths(stageClass.curStage));
        interp.variables.set("_Paths", Paths);
        interp.variables.set("FlxSprite", FlxSprite);
        interp.variables.set("vars", vars);
        try {
            interp.execute(parser.parseString(script));
        }
        catch (e) {
            trace('${stageClass.curStage} failed to load: ${e.message}');
        }
    }
}
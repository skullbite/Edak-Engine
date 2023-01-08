package hstuff;

import Stage;

// todo: background characters bop faster than usual
// temp fix: set flxsprite anim framerates to half their target
class HStage extends CallbackScript {
    public function new(stageClass:Stage, path:String) {
        super(path);
        name = "Stage:" + stageClass.curStage;
        set("stage", stageClass);
        set("Paths", new CustomPaths(stageClass.curStage, "stages"));
        set("_Paths", Paths);
        try {
            execute();
        }
        catch (e) {
            trace('${stageClass.curStage} failed to load: ${e.message}');
        }
    }
}
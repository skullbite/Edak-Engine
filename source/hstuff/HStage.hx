package hstuff;

import flixel.FlxSprite;
import Stage;

// todo: background characters bop faster than usual
// temp fix: set flxsprite anim framerates to half their target
class HStage extends HBase {
    var script:String = "";
    var vars:Map<String, Dynamic> = [];
    public function new(stageClass:Stage, script:String) {
        super();
        interp.variables.set("stage", stageClass);
        interp.variables.set("Paths", new StagePaths(stageClass.curStage));
        interp.variables.set("_Paths", Paths);
        interp.variables.set("FlxSprite", FlxSprite);
        interp.variables.set("vars", vars);
        try {
            interp.execute(parser.parseString(script));
            this.script = script;
        }
        catch (e) {
            trace('${stageClass.curStage} failed to load: ${e.message}');
        }
        
    }

    // normally i would put this in the exec but i need the bool from the return
    public function funcExists(target:String) return StringTools.contains(script, "function " + target);

    public function exec(target:String, args:Array<Dynamic>) {
        try {
            interp.execute(parser.parseString(script + '\n$target(${args.join(", ")});'));
        }
        catch (e) {
            trace('Stage function "$target" failed: ${e.message}');
        }
    }
}
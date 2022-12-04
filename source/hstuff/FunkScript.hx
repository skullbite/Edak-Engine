package hstuff;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;


// Better name than HGame
class FunkScript extends HBase {
    public var scripts:Array<CallbackScript> = [];
    var pre:String = "var game = PlayState.instance;\n";

    public function loadScript(name:String, code:String) {
        // dry run to make sure the code actually works
        try {
            var toRun = pre + code;
            interp.execute(parser.parseString(toRun));
            var script = new CallbackScript(toRun);
            script.interp.variables.set("vars", new Map<String, Dynamic>());
            script.interp.variables.set("FlxTween", FlxTween);
            script.interp.variables.set("FlxTimer", FlxTimer);
            script.interp.variables.set("Paths", Paths);
            scripts.push(script);
            trace('loaded script $name');
        }
        catch (e) {
            trace('hscript:$name failed to load: ${e.message}');
        }
    }

    // long ahh line
    public function doDaCallback(name:String, args:Array<Dynamic>) { 
        for (script in scripts) script.exec(name, args);
    }
}
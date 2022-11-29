package hstuff;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;


// Better name than HGame
class FunkScript extends HBase {
    public var scripts:Map<String, String>;
    var pre:String = "var game = PlayState.instance;\n";
    override public function new() {
        super();
        scripts = new Map();
        interp.variables.set("FlxTween", FlxTween);
        interp.variables.set("FlxTimer", FlxTimer);
        interp.variables.set("Paths", Paths);
    }

   

    public function loadScript(name:String, code:String) {
        // dry run to make sure the code actually works
        try {
            var toRun = pre + code;
            interp.execute(parser.parseString(toRun));
            scripts.set(name, toRun);
            trace('loaded script $name');
        }
        catch (e) {
            trace('hscript:$name failed to load: ${e.message}');
        }
    }

    // long ahh line
    public function doDaCallback(name:String, args:Array<Dynamic>) { 
        for (k => v in scripts) { 
            // don't play with comments ig
            if (StringTools.contains(v, "function " + name)) interp.execute(parser.parseString(v + '\n$name(${args.join(", ")})', k));
        }

    }
}


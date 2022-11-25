package hstuff;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.tweens.FlxTween;


// Better name than HGame
class FunkScript extends HBase {
    public var scripts:Map<String, String>;
    var pre:String = "var game = PlayState.instance;\n";
    override public function new() {
        super();
        scripts = new Map();
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("FlxTween", FlxTween);
        interp.variables.set("FlxTimer", FlxTimer);
        interp.variables.set("Paths", Paths);
        interp.variables.set("importLib", importLib);
    }

    // psych engine??? i might switch to a different lib which will deprecate this
    function importLib(lib:String) {
        var name = lib.split(".").pop();
        var target = Type.resolveClass(lib);
        if (target != null && interp.variables.get(name) == null) interp.variables.set(name, target);
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
            if (StringTools.contains(v, name)) interp.execute(parser.parseString(v + '\n$name(${args.join(", ")})', k));
        }

    }
}


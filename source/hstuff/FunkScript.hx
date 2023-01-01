package hstuff;

import flixel.FlxSprite;
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
            script.interp.variables.set("FlxSprite", FlxSprite);
            script.interp.variables.set("FlxTween", FlxTween);
            script.interp.variables.set("FlxTimer", FlxTimer);
            script.interp.variables.set("Paths", Paths);
            script.interp.variables.set("STOP", HVars.STOP);
            scripts.push(script);
            trace('loaded script $name');
        }
        catch (e) {
            trace('hscript:$name failed to load: ${e.message}');
        }
    }

    public function anyExists(target:String) {
        var allScriptOutputs = [];
        for (_ => v in scripts) allScriptOutputs.push(v.funcExists(target));
        return allScriptOutputs.contains(true);
        
    }
    public function doDaCallback(name:String, args:Array<Dynamic>) { 
        var scriptReturns:Array<Dynamic> = [];
        for (script in scripts) {
            if (script.funcExists(name)) scriptReturns.push(script.exec(name, args));
        }
        return scriptReturns;
    }
}
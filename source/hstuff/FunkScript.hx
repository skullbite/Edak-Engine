package hstuff;

import hstuff.HVars.Callbacks;
import states.PlayState;

// Better name than HGame
class FunkScript extends HBase {
    public var scripts:Map<String, CallbackScript> = [];

    public function loadScript(name:String, path:String) {
        try {
            var script = new CallbackScript(path, name, {
                Paths: Paths,
                STOP: HVars.STOP,
                game: PlayState.instance,
                add: PlayState.instance.add,
                addToHUD: PlayState.instance.addToHUD,
                addToTop: PlayState.instance.addToTop,
                remove: PlayState.instance.remove,
                insert: PlayState.instance.insert
            });
            
            scripts.set(name, script);
            // trace('Loaded script $name');
            Sys.println(path + ': script loaded successfully!');
        }
        catch (e) {
            Sys.println(path + ': script failed to load.\n${e.message}');
        }
    }

    public function funcExists(target:String) {
        var allScriptOutputs = [];
        for (_ => v in scripts) allScriptOutputs.push(v.exists(target));
        return allScriptOutputs.contains(true);
    }
    public function doDaCallback(name:Callbacks, args:Array<Dynamic>) { 
        var scriptReturns:Array<Dynamic> = [];
        for (script in scripts) {
            if (script.exists(name)) scriptReturns.push(script.exec(name, args));
        }
        return scriptReturns;
    }
}
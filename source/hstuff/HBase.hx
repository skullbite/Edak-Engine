package hstuff;

import hscript.Parser;
import hscript.Interp;
import flixel.FlxG;

// @:enum abstract FlxColor(String) to String {}

class HBase {
    public var parser:Parser;
    public var interp:Interp;
    public var variables(get, never):Map<String, Dynamic>;
    public function new() {
        parser = new Parser();
        interp = new Interp();
        interp.variables.set("PlayState", PlayState);
        // interp.variables.set("GameOverSubstate", GameOverSubstate);
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("importLib", importLib);
        interp.variables.set("Std", Std);
        interp.variables.set("Reflect", Reflect);
        interp.variables.set("Type", Type);
        interp.variables.set("Conductor", Conductor);
        parser.line = 1;
        parser.allowTypes = true;
    }

    // psych engine??? i might switch to a different lib which will deprecate this
    function importLib(lib:String, alias="") {
        var name = alias != "" ? alias : lib.split(".").pop();
        var target = Type.resolveClass(lib);
        if (target != null && interp.variables.get(name) == null) interp.variables.set(name, target);
    }

    function get_variables() {
        return interp.variables;
    }
}
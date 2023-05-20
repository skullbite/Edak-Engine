package hstuff;

import tea.TeaScript;

// @:enum abstract FlxColor(String) to String {}

class HBase extends TeaScript {
    public function new(?path:String) {
        super(path);
        set("this", this);
        set("set", set);
        set("PlayState", PlayState);
        set("GameOverSubstate", GameOverSubstate);
        set("importLib", importLib);
        set("Reflect", Reflect);
        set("Type", Type);
        set("Conductor", Conductor);
        set("Settings", Settings);
        set("HelperFunctions", HelperFunctions);
        set("onDesktop", #if desktop true #else false #end);

        var platform:String;
        #if windows
        platform = "windows";
        #elseif mac
        platform = "mac";
        #elseif linux
        platform = "linux";
        #elseif html5
        platform = "html5";
        #elseif android
        platform = "android";
        #elseif ios
        platform = "ios";
        #else 
        platform = "other";
        #end

        set("platform", platform);

        parser.line = 1;
        parser.allowTypes = true;
        parser.allowJSON = true;
    }
    
    // psych engine??? i might switch to a different lib which will deprecate this
    function importLib(lib:String, alias="") {
        var name = alias != "" ? alias : lib.split(".").pop();
        var target = Type.resolveClass(lib);
        if (target != null && get(name) == null) set(name, target);
    }
}
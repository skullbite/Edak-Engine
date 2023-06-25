package utils;

import states.StoryMenuState;
import openfl.Lib;
import flixel.FlxG;

typedef SettingsData = {
    displayName:String,
    value:Dynamic,
    ?description:String,
    type:String,
    ?min:Float,
    ?max:Float,
    ?options:Array<String>
}; 
// todon't
class Settings {
    public static var categories:Map<String, Map<String, SettingsData>> = [
        "Gameplay" => [
            "downscroll" => {
                displayName: "Downscroll",
                type: "bool",
                value: false
            },
            "middlescroll" => {
                displayName: "Middlescroll",
                type: "bool",
                value: false
            },
            "scrollSpeed" => {
                displayName: "Scroll Speed",
                type: "float",
                value: 1,
                min: 0.9,
                max: 4
            },
            "offset" => {
                displayName: "Audio Offset",
                type: "float",
                value: 0,
                min: -999,
                max: 999
            },
            "ghost" => {
                displayName: "Ghost Tapping",
                type: "bool",
                value: true
            },
            "frames" => {
                displayName: "Safe Frames",
                type: "int",
                min: 1,
                max: 20,
                value: 10
            },
            "fpsCap" => {
                displayName: "FPS Cap",
                type: "int",
                min: 60,
                max: 290,
                value: 120
            },
            "resetButton" => {
                displayName: "Allow Reset",
                type: "bool",
                value: false
            },
            "controls" => {
                displayName: "Set Controls",
                type: "substate",
                value: null
            },
            "customize" => {
                displayName: "Customize Gameplay",
                type: "state",
                value: null
            }
        ],
        "Appearance" => [
            "distractions" => {
                displayName: "Distractions",
                type: "bool",
                value: true
            },
            "accuracyDisplay" => {
                displayName: "Show Accuracy",
                type: "bool",
                value: true
            },
            "npsDisplay" => {
                displayName: "Show NPS",
                type: "bool",
                value: false
            },
            "songPosition" => {
                displayName: "Song Position",
                type: "bool",
                value: true
            }
        ],
        "Misc" => [
            "fps" => {
                displayName: "Show FPS",
                type: "bool",
                value: false
            },
            "debug" => {
                displayName: "Debugging Mode",
                type: "bool",
                value: false
            },
            "flashing" => {
                displayName: "Use Flashing Lights",
                type: "bool",
                value: true
            },
            "botplay" => {
                displayName: "Use Botplay",
                type: "bool",
                value: false
            },
            "gitaroo" => {
                displayName: "Easter Egg Pause",
                type: "bool",
                value: false
            },
            "darkBg" => {
                displayName: "Use Black Menu BG",
                type: "bool",
                value: false
            }
        ]
    ];

    // if you intend on editing a variable via the state/substate, instead of the settings menu, you can init those variables here
    public static var extInits:Map<String, Dynamic> = [
        "changedHit" => false,
        "changedHitX" => -1,
        "changedHitY" => -1,
    ];

    public static function init() {
        FlxG.save.bind('edak', 'skullbite');
        for (cat in categories) {
            for (k => v in cat) {
                if (v.value != null) {
                    if (!Reflect.hasField(FlxG.save.data, k)) set(k, v.value);
                }
            } 
        }
        for (k => v in extInits) {
            if (!Reflect.hasField(FlxG.save.data, k)) set(k, v);
        }

        if (FlxG.save.data.weekUnlocked != null) {
            // FIX LATER!!!
            // WEEK UNLOCK PROGRESSION!!
            // StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

            if (StoryMenuState.weekUnlocked.length < 4)
                StoryMenuState.weekUnlocked.insert(0, true);

            // QUICK PATCH OOPS!
            if (!StoryMenuState.weekUnlocked[0])
                StoryMenuState.weekUnlocked[0] = true;
        }
        FlxG.save.flush();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
        if (!FlxG.save.data.debug) FlxG.debugger.toggleKeys = null;
    }

    public static function get(settingKey:String):Dynamic return Reflect.getProperty(FlxG.save.data, settingKey);

    public static function set(settingKey:String, value:Dynamic) Reflect.setProperty(FlxG.save.data, settingKey, value);
}
import flixel.FlxG;

typedef SettingsData = {
    displayName:String,
    value:Dynamic,
    ?description:String,
    type:String,
    ?min:Int,
    ?max:Int,
    ?options:Array<String>
}; 
// todo
class Settings {
    public static var categories:Map<String, Map<String, SettingsData>> = [
        "Gameplay" => [
            "downscroll" => {
                displayName: "Downscroll",
                type: "bool",
                value: true
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
            "flashing" => {
                displayName: "Use Flashing Lights",
                type: "bool",
                value: true
            },
            "botplay" => {
                displayName: "Use Botplay",
                type: "bool",
                value: false
            }
        ]
    ];

    public static function init() {
        for (cat in categories) {
            for (k => v in cat) {
                if (!Reflect.hasField(FlxG.save.data, k)) Reflect.setProperty(FlxG.save.data, k, v.value);
            } 
        } 
    }

    public static function get(settingKey:String):Dynamic return Reflect.getProperty(FlxG.save.data, settingKey);

    public static function set(settingKey:String, value:Dynamic) Reflect.setProperty(FlxG.save.data, settingKey, value);
}
import flixel.FlxG;

// todo
class Settings {
    public static var categories = [
        "General" => [
            "fakeSetting" => {
                displayName: "Fake Setting",
                type: "bool",
                value: true
            },
            "real" => {
                displayName: "Real",
                type: "bool",
                value: true
            }
        ],
        "Not General" => [
            "test" => {
                displayName: "Test",
                type: "bool",
                value: true
            }
        ]
    ];
    /*public static function initSettingsIfNull() {
        for (k => v in categories) {
            for (_k => _v in v) {
                FlxG.save.data.
            } 
        } 
    }*/
}
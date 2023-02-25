package;

import sys.FileSystem;
import StoryMenuState.DifficultyData;
import yaml.Yaml;
import yaml.Parser.ParserOptions;

// PolyFrog! get it? because polymod and kades a frog- uh
// its a mod helper woo
// if this turns out to be all static functions i'll just move it back to Paths
class PolyFrog {
    public static function getModWeeks() {
        var coolMods = FileSystem.readDirectory("mods");
        var weekDirs:Map<String, Array<String>> = [];
        for (x in coolMods) {
            if (!FileSystem.isDirectory('mods/$x') || !FileSystem.exists('mods/$x/data/weeks') || !FileSystem.exists('mods/$x/data/weeks/order.txt') || !FileSystem.isDirectory('mods/$x/data/weeks')) continue;
            var orderThingy = CoolUtil.coolTextFile('mods/$x/data/weeks/order.txt');
            weekDirs.set('mods/$x', orderThingy.map(week -> 'mods/$x/data/weeks/$week.yaml'));
        }
        return weekDirs;
    }

    public static function getModDifficulties():Map<String, Map<String, DifficultyData>> {
        var modsThatAreCool = FileSystem.readDirectory("mods");
        var diffMap:Map<String, Map<String, DifficultyData>> = [];
        for (x in modsThatAreCool) {
            if (!FileSystem.exists('mods/$x/data/difficulties') || !FileSystem.isDirectory('mods/$x/data/difficulties')) continue;
            var miniDiffMap:Map<String, DifficultyData> = [];
            for (y in FileSystem.readDirectory('mods/$x/data/difficulties')) miniDiffMap.set(y.split(".").shift(), Yaml.read('mods/$x/data/difficulties/$y', new ParserOptions().useObjects()));
            diffMap.set('mods/$x', miniDiffMap);
        }
        return diffMap;
    }
}
package;

import sys.FileSystem;

// awesome mod manager woo
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
}
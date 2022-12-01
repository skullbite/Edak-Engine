package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxG;
import sys.io.File;
import hstuff.HBase;
import flixel.util.FlxColor;
import flixel.FlxSprite;

// incomplete replacement state for the options state
// inspired by the v1.8 options menu
class OptionsTestState extends MusicBeatState {
    var baseBox:FlxSprite;
    var topBox:FlxSprite;
    var settingCatText:FlxText;
    var categories:Array<String> = [];
    var curSettings:Array<String> = [];
    var curCategory:Int = 0;
    var categorySelected:Bool = false;
    var curSetting:Int = 0;
    var settingsGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup();
    var optionTicks:FlxTypedGroup<FlxText> = new FlxTypedGroup();
    var highlightChar:FlxText;
    var darkThing:FlxSprite;
    override function create() {
        super.create();
        for (k => _ in Settings.categories) categories.push(k);

        var bg = new FlxSprite(Paths.image('menuDesat'));
        bg.color = FlxColor.BLUE;
        add(bg);

        baseBox = new FlxSprite().makeGraphic(1000, 600);
        baseBox.color = 0x000000;
        baseBox.alpha = .6;
        baseBox.screenCenter();
        add(baseBox);


        add(settingsGroup);
        add(optionTicks);
        
        topBox = new FlxSprite(baseBox.x, baseBox.y).makeGraphic(1000, 100);
        topBox.color = 0x000000;
        topBox.alpha = .3;
        add(topBox);


        highlightChar = new FlxText(baseBox.x + 10, topBox.height + 60, 0, ">", 35);
        highlightChar.font = Paths.font("vcr.ttf");
        highlightChar.borderStyle = OUTLINE;
        highlightChar.borderSize = 2;
        highlightChar.visible = categorySelected;
        add(highlightChar);

        var stuff = 0;
        for (v in Settings.categories.get(categories[curCategory])) {
            for (k in Settings.categories.get(categories[curCategory]).keys()) curSettings.push(k);
            
            var mod = 40;
            var option = new FlxText(baseBox.x + 40, (topBox.height + 60) + (stuff * mod), 0, v.displayName, 35);
            var tick = new FlxText(baseBox.width - 60, (topBox.height + 60) + (stuff * mod), 0, "VALUE_HERE OWO", 35);
            for (item in [option, tick]) {
                item.font = Paths.font("vcr.ttf");
                item.borderStyle = OUTLINE;
                item.borderSize = 2;
            }
            tick.x = baseBox.width - tick.width;
            settingsGroup.add(option);
            optionTicks.add(tick);
            stuff++;
        }
        
        settingCatText = new FlxText(0, topBox.y + 20, 0, "< " + categories[curCategory] + " >", 40);
        settingCatText.font = Paths.font("vcr.ttf");
        settingCatText.borderStyle = OUTLINE;
        settingCatText.borderSize = 2;
        settingCatText.screenCenter(X);
        add(settingCatText);

        darkThing = new FlxSprite(baseBox.x, baseBox.y + 100).makeGraphic(1000, 500);
        darkThing.color = 0x000000;
        darkThing.alpha = .3;
        darkThing.visible = !categorySelected;
        add(darkThing);
    }

    override function update(elapsed) {
        super.update(elapsed);
        highlightChar.visible = categorySelected;
        darkThing.visible = !categorySelected;
        if (FlxG.keys.justPressed.ESCAPE) { 
            if (!categorySelected) FlxG.switchState(new MainMenuState());
            else {
                categorySelected = false;
                curSetting = 0;
                // this might cause a crash, but if you have an empty settings category that's a skill issue on your part tbh
                highlightChar.visible = false;
                highlightChar.visible = categorySelected;
                highlightChar.y = settingsGroup.members[0].y;
            }
        }
        if (controls.LEFT_P) {
            if (!categorySelected) switchCategory(-1);
        }
        if (controls.RIGHT_P) if (!categorySelected) switchCategory(1);
        if (controls.UP_P && categorySelected) switchSetting(-1);
        if (controls.DOWN_P && categorySelected) switchSetting(1);
        if (FlxG.keys.justPressed.ENTER) if (!categorySelected) categorySelected = true;
    }

    function switchSetting(set=0) {
        if (settingsGroup.length == 1) return;
        else if (curSetting + set == settingsGroup.length) curSetting = 0
        else if (curSetting + set == -1) curSetting = settingsGroup.length - 1;
        else curSetting += set;

        FlxTween.tween(highlightChar, { y: settingsGroup.members[curSetting].y }, 0.07, { ease: FlxEase.circInOut });
    }

    function switchCategory(cat=0) {
        if (categories.length == 1) return;
        else if (curCategory + cat == categories.length) curCategory = 0;
        else if (curCategory + cat == -1) curCategory = categories.length - 1;
        else curCategory += cat;
        curSetting = 0;

        settingCatText.text = "< " + categories[curCategory] + " >";
        settingCatText.screenCenter(X);
        Settings.categories.get(categories[curCategory]);
        settingsGroup.forEach(d -> d.destroy());
        optionTicks.forEach(d -> d.destroy());
        settingsGroup.clear();
        var stuff = 0;
        for (v in Settings.categories.get(categories[curCategory])) {
            var mod = 40;
            var option = new FlxText(baseBox.x + 40, (topBox.height + 60) + (stuff * mod), 0, v.displayName, 35);
            var tick = new FlxText(baseBox.width - 60, (topBox.height + 60) + (stuff * mod), 0, "VALUE_HERE", 35);
            for (item in [option, tick]) {
                item.font = Paths.font("vcr.ttf");
                item.borderStyle = OUTLINE;
                item.borderSize = 2;
            }
            tick.x = baseBox.width - tick.width;
            settingsGroup.add(option);
            optionTicks.add(tick);
            stuff++;
        }

        function editSetting(change=0) {
            Settings.categories.get(categories[curCategory]).get("");

        }
    }
}
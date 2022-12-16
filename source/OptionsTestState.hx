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

class TickText extends FlxText {
    public var key:String;
    public var firstTick:Bool = true;
    override function new(x:Int, y:Int, settingsKey:String) {
        super(x, y, 0, "", 35);
        key = settingsKey;
        font = Paths.font("vcr.ttf");
        borderStyle = OUTLINE;
        borderSize = 2;
    }

    public function tick(change=0) {}
}
class BoolValueText extends TickText {
    var value:Bool;
    var markupRules:Array<FlxTextFormatMarkerPair>;
    override public function new(x:Int, y:Int, key:String) {
        super(x, y, key);
        this.value = Settings.get(key);
        markupRules = [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.LIME), "!"), new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), ".")];

        tick();
    }
    override public function tick(_=0) {
        if (!firstTick) {
            value = !value;
            Settings.set(key, value);
        }

        applyMarkup('< ${value ? "!ON!" : ".OFF."} >', markupRules);
        if (firstTick) firstTick = false;
    }
}

class StringValueText extends TickText {
    var values:Array<String> = [];
    var curValue:Int;
    override public function new(x:Int, y:Int, key:String, values:Array<String>) {
        super(x, y, key);
        this.values = values;
        curValue = values.indexOf(Settings.get(key));

        tick(); 
    }
    override public function tick(change=0) {
        if (curValue + change == values.length) curValue = 0;
        else if (curValue + change == -1) curValue = values.length - 1;
        else curValue += change;
        if (!firstTick) Settings.set(key, values[curValue]);

        text = '< ${values[curValue]} >';
        if (firstTick) firstTick = false;
    }
}

class IntValueText extends TickText {
    var min:Int;
    var max:Int;
    public var curValue:Int;
    override public function new(x:Int, y:Int, key:String, min:Int, max:Int) {
        super(x, y, key);
        curValue = Settings.get(key);
        this.min = min;
        this.max = max;
        // trace(curValue);

        tick();
    }

    override public function tick(change=0) {
        if (curValue + change < min) return;
        else if (curValue + change > max) return;
        else curValue += change;
        if (!firstTick) Settings.set(key, curValue);
        
        text = '< $curValue >';
        if (firstTick) firstTick = false;
    }
}

// incomplete replacement state for the options state
// inspired by the v1.8 options menu
class OptionsTestState extends MusicBeatState {
    var baseBox:FlxSprite;
    var topBox:FlxSprite;
    var settingCatText:FlxText;
    var categories:Array<String> = [];
    var curCategory:Int = 0;
    var categorySelected:Bool = false;
    var curSetting:Int = 0;
    var settingsGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup();
    var optionTicks:FlxTypedGroup<TickText> = new FlxTypedGroup();
    var highlightChar:FlxText;
    var bgHighlight:FlxSprite;
    var darkThing:FlxSprite;
    override function create() {
        super.create();
        for (k => _ in Settings.categories) categories.push(k);
        categories.reverse();

        var bg = new FlxSprite(Paths.image('menuDesat'));
        bg.color = 0xFFea71fd;
        add(bg);

        baseBox = new FlxSprite().makeGraphic(1000, 600);
        baseBox.color = 0x000000;
        baseBox.alpha = .6;
        baseBox.screenCenter();
        add(baseBox);

        /*bgHighlight = new FlxSprite(baseBox.x, baseBox.y + 60).makeGraphic(Std.int(baseBox.width), 10, 0xffffff);
        bgHighlight.alpha = .2;
        bgHighlight.visible = categorySelected;
        add(bgHighlight);*/

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

        
        settingCatText = new FlxText(0, topBox.y + 30, 0, "< " + categories[curCategory] + " >", 40);
        settingCatText.font = Paths.font("vcr.ttf");
        settingCatText.borderStyle = OUTLINE;
        settingCatText.borderSize = 2;
        settingCatText.screenCenter(X);
        add(settingCatText);

        switchCategory();

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
            FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
            if (!categorySelected) switchCategory(-1);
            else changeSetting(-1);
        }
        if (controls.RIGHT_P) {
            FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
            if (!categorySelected) switchCategory(1);
            else changeSetting(1);
        }
        if (controls.UP_P && categorySelected) {
            FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
            switchSetting(-1);
        }
        if (controls.DOWN_P && categorySelected) {
            FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
            switchSetting(1);
        }
        if (FlxG.keys.justPressed.ENTER) {
            
            if (!categorySelected) {
                FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
                categorySelected = true;
            }
        }
    }

    function changeSetting(change=0) {
        var targetTick = optionTicks.members[curSetting];
        targetTick.tick(change);
        targetTick.x = baseBox.width - targetTick.width + 60;
    }

    function switchSetting(set=0) {
        if (settingsGroup.length == 1) return;
        else if (curSetting + set == settingsGroup.length) curSetting = 0
        else if (curSetting + set == -1) curSetting = settingsGroup.length - 1;
        else curSetting += set;

        // FlxTween.tween(highlightChar, { y: settingsGroup.members[curSetting].y }, 0.07, { ease: FlxEase.circInOut });
        highlightChar.y = settingsGroup.members[curSetting].y;
        // bgHighlight.y = settingsGroup.members[curSetting].y;
    }

    function switchCategory(cat=0) {
        if (categories.length == 1) return;
        else if (curCategory + cat == categories.length) curCategory = 0;
        else if (curCategory + cat == -1) curCategory = categories.length - 1;
        else curCategory += cat;
        curSetting = 0;

        settingCatText.text = "< " + categories[curCategory] + " >";
        settingCatText.screenCenter(X);
        // Settings.categories.get(categories[curCategory]);
        settingsGroup.forEach(d -> d.destroy());
        optionTicks.forEach(d -> d.destroy());
        settingsGroup.clear();
        optionTicks.clear();
        var stuff = 0;
        for (k => v in Settings.categories.get(categories[curCategory])) {
            var mod = 40;
            var option = new FlxText(baseBox.x + 40, (topBox.height + 60) + (stuff * mod), 0, v.displayName, 35);
            option.font = Paths.font("vcr.ttf");
            option.borderStyle = OUTLINE;
            option.borderSize = 2;
            /*var tick = new TickText(Std.int(baseBox.width - 60), Std.int((topBox.height + 60) + (stuff * mod)));*/
            var tick:TickText = null;
            switch (v.type) {
                case "string": tick = new StringValueText(Std.int(baseBox.width - 20), Std.int((topBox.height + 60) + (stuff * mod)), k, v.options);
                case "int": tick = new IntValueText(Std.int(baseBox.width - 20), Std.int((topBox.height + 60) + (stuff * mod)), k, v.min, v.max);
                case "bool": tick = new BoolValueText(Std.int(baseBox.width - 20), Std.int((topBox.height + 60) + (stuff * mod)), k);
            }
            tick.x = baseBox.width - tick.width + 60;
            settingsGroup.add(option);
            optionTicks.add(tick);
            stuff++;
        }
    }
}
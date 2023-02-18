package;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import PlayState;

function create() {
    var coolAssBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
    coolAssBG.color = 0x000000; 
    coolAssBG.alpha = .2;
    sub.add(coolAssBG);
    var fuckingMoney = new FlxText();
    fuckingMoney.size = 40;
    fuckingMoney.text = "THIS IS A PAUSE SCREEN\nPRESS ESC TO RESUME\nPRESS B TO TOGGLE BOTPLAY\nPRESS Q TO QUIT";
    fuckingMoney.screenCenter();
    sub.add(fuckingMoney);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.ESCAPE) sub.close();
    if (FlxG.keys.justPressed.B) Settings.set("botplay", !Settings.get("botplay"));
    if (FlxG.keys.justPressed.Q) FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
}
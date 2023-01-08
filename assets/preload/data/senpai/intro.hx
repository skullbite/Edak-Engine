package;

import flixel.util.FlxTimer;
import CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;

function onCutscene() {
    var lunchbox = FlxG.sound.play(Paths.music('Lunchbox'), 0);
	lunchbox.fadeIn(1, 0, 0.8);
    var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
    blackScreen.color = 0x000000;
	blackScreen.scrollFactor.set();
	game.add(blackScreen);
    new FlxTimer().start(0.3, t -> {
		blackScreen.alpha -= 0.15;
		if (blackScreen.alpha > 0) t.reset(0.3);
        else {
            game.openDialogueBox("senpai", CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue')), () -> {
                lunchbox.fadeOut(2.2, 0);
                // game.camHUD.visible = true;
                game.startCountdown();
            });
        }
        
    });
}
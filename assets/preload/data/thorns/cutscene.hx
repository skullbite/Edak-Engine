package;

import flixel.util.FlxTimer;
import CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;

function onCutscene() {
    var lunchboxScary = FlxG.sound.play(Paths.music('LunchboxScary'), 0, true);
	lunchboxScary.fadeIn(1, 0, 0.8);
    var blue = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
	blue.color = 0x0077ff;
    blue.screenCenter();
    game.add(blue);
    

    var senpaiEvil:FlxSprite = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
    senpaiEvil.alpha = 0;
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();
    game.add(senpaiEvil);

    new FlxTimer().start(0.3, t -> {
        senpaiEvil.alpha += 0.15;
        if (senpaiEvil.alpha < 1) {
            t.reset();
            return;
        }
        senpaiEvil.animation.play("idle");
		FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, () -> {
            FlxG.camera.stopFX();
            game.remove(blue);
            game.remove(senpaiEvil);
            game.openDialogueBox("thorns", CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue')), () -> {
                lunchboxScary.fadeOut(2.2, 0);
                // game.camHUD.visible = true;
                game.startCountdown();
            });
        }, true);
        new FlxTimer().start(3.2, t -> FlxG.camera.fade(0xffffff, 1.6, false));
    });
}
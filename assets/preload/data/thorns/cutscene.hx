function onCreate() {
    if (PlayState.isStoryMode) game.camHUD.visible = false;
}
function onCutscene() {
    var blue = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
	blue.height = Std.int(FlxG.height * 2);
	blue.width = Std.int(FlxG.width * 2);
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
            game.camHUD.visible = true;
            game.remove(blue);
            game.remove(senpaiEvil);
            game.startCountdown();
        }, true);
        new FlxTimer().start(3.2, t -> FlxG.camera.fade(0xffffff, 1.6, false));
    });
}
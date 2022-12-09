function onCutscene() {
    FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
	FlxG.sound.music.fadeIn(1, 0, 0.8);
    var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
	blackScreen.height = Std.int(FlxG.height * 2);
	blackScreen.width = Std.int(FlxG.width * 2);
	blackScreen.color = 0x000000;
	blackScreen.scrollFactor.set();
	game.add(blackScreen);
    new FlxTimer().start(0.3, t -> {
		blackScreen.alpha -= 0.15;
		if (blackScreen.alpha > 0) t.reset(0.3);
        else {
            FlxG.sound.music.fadeOut(2.2, 0, t -> { 
                FlxG.sound.music = null;
                game.startCountdown();
            });
        }
        
    });
}
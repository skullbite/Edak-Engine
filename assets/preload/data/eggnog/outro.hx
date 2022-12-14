function onStepHit(step) {
    if (step == 938) {
        vars["lightSound"] = FlxG.sound.play(Paths.sound("Lights_Shut_off"));
        var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
	    blackScreen.height = Std.int(FlxG.height * 2);
	    blackScreen.width = Std.int(FlxG.width * 2);
	    blackScreen.color = 0x000000;
        blackScreen.cameras = [game.camHUD];
        game.add(blackScreen);
    }
}

function onEndSong() {
    vars["lightSound"].onComplete = game.endSong;
    FlxG.sound.music.volume = 0;
    game.vocals.volume = 0;
}
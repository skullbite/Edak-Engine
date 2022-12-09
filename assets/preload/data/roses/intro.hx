function onCutscene() {
    FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
    new FlxTimer().start(1.3, game.startCountdown, 1);
}
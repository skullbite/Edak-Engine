function onCreate() {
    // if (PlayState.isStoryMode) game.camHUD.visible = false;
}
function onCutscene() {
    importLib("CoolUtil");
    FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
    new FlxTimer().start(1.3, () -> game.openDialogueBox("roses", CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue')), () -> { 
        // game.camHUD.visible = true;
        game.startCountdown();
    }));
}
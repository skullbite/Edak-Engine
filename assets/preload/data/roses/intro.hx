package;

import flixel.util.FlxTimer;
import CoolUtil;
import flixel.FlxG;

function onCutscene() {
    FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
    new FlxTimer().start(1.3, t -> game.openDialogueBox("roses", CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue')), () -> { 
        // game.camHUD.visible = true;
        game.startCountdown();
    }));
}
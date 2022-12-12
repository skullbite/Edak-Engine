package hstuff;

import flixel.tweens.FlxTween;
import haxe.ds.Map;
import EdakDialogueBox;
import flixel.FlxSprite;

class HDialogue extends CallbackScript {
    var vars:Map<String, Dynamic> = [];
    override public function new(dialogueClass:EdakeDialogueBox, script:String) {
        super(script);
        name = "Dialogue:" + dialogueClass.boxType;
        interp.variables.set("dia", dialogueClass);
        interp.variables.set("FlxSprite", FlxSprite);
        interp.variables.set("FlxTween", FlxTween);
        interp.variables.set("Paths", new DialoguePaths(dialogueClass.boxType));
        interp.variables.set("_Paths", Paths);
        interp.variables.set("vars", new Map<String, Dynamic>());
    }
}
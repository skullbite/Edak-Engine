package hstuff;

import EdakDialogueBox;

class HDialogue extends CallbackScript {
    override public function new(dialogueClass:EdakeDialogueBox, script:String) {
        super(script);
        name = "Dialogue:" + dialogueClass.boxType;
        set("dia", dialogueClass);
        set("Paths", new CustomPaths(dialogueClass.boxType, "dialogue"));
        set("_Paths", Paths);
    }
}
package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxTimer;
import sys.io.File;
import sys.FileSystem;
import hstuff.CallbackScript;
import flixel.addons.text.FlxTypeText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

// because the og one was so hardcoded it was actually killing me
class EdakeDialogueBox extends FlxTypedGroup<FlxBasic> {
    // var background:FlxSprite;
    public var boxType:String;
    var dialogueScript:Null<CallbackScript>;
    var portraits:Map<String, FlxSprite> = [];
    var box:FlxSprite;
    var speakTxt:FlxTypeText;
    var groupTxt:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
    var textStarted:Bool = false;
    var currentlyTyping:Bool = false;
    var initText:Bool = true;
    var alreadyEnding:Bool = false;
    var dialogueText:Array<String>;
    var curPortrait:String;
    public var finishCallback:Void -> Void;
    override public function new(boxType:String, dialogueText:Array<String>) {
        super();
        this.boxType = boxType;
        this.dialogueText = dialogueText;
        switch (boxType) {
            // case "hardcoded box here":
            default:
                if (FileSystem.exists(Paths.getPath('dialogue/$boxType/init.hxs'))) {
                    try {
                        dialogueScript = new CallbackScript(Paths.getPath('dialogue/$boxType/init.hxs'), 'Dialogue:$boxType', {
                            dia: this,
                            Paths: new CustomPaths(boxType, "dialogue"),
                            _Paths: Paths
                        });
                        dialogueScript.execute();
                        dialogueScript.exec("create", []);
                    }
                    catch (e) {
                        trace('Failed to load $boxType: ${e.message}');
                        if (finishCallback != null) { 
                            finishCallback();
                            kill();
                        }
                        // else idk the game just hangs, git gud
                    }
                }
        }
        if (box == null) {
            trace("No box set, that's half the point of dialogue lol. Skipping dialogue...");
            if (finishCallback != null) doEnd();
            else kill();
            return;
        }
        else if (dialogueText.length == 0) {
            trace("No dialogue?? :( skipping...");
            if (finishCallback != null) doEnd();
            else kill();
        }
        for (_ => v in portraits) {
            v.visible = false;
            add(v);
        }
        add(box);

        speakTxt = new FlxTypeText(box.x + 20, box.y + 20, Std.int(FlxG.width * 0.6), "", 8);
        groupTxt.add(speakTxt);
        add(groupTxt);
        if (box.animation.exists("open")) {
            box.animation.play("open");
            box.animation.finishCallback = (n) -> {
                if (box.animation.exists("idle")) box.animation.play("idle");
                textStarted = true;
            }
        }     
        else {
            if (box.animation.exists("idle")) box.animation.play("idle");
            textStarted = true;
        }
        if (dialogueScript.exists("createPost")) dialogueScript.exec("createPost", []);
        
        // new FlxTimer().start(10, (t) -> finishCallback());
    }

    function startDialogue() {
        cleanDialog();
        if (dialogueScript.exists("preLine")) dialogueScript.exec("preLine", [curPortrait, dialogueText[0]]);
        for (k => v in portraits) {
            if (k == curPortrait) {
                v.visible = true;
                if (v.animation.exists("enter")) v.animation.play("enter");
            }
            else v.visible = false;
        }
        speakTxt.resetText(dialogueText[0]);
        var targetPortrait = portraits[curPortrait];
        if (targetPortrait != null && targetPortrait.animation.exists("pre")) {
            targetPortrait.animation.play("pre");
            targetPortrait.animation.finishCallback = t -> {
                currentlyTyping = true;
                speakTxt.start(0.04, true, false, [SPACE], () -> currentlyTyping = false);
            }
        } 
        else {
            currentlyTyping = true;
            speakTxt.start(0.04, true, false, [SPACE], () -> currentlyTyping = false);
        }
        dialogueText.splice(0, 1);
        if (initText) initText = false;
    }

    function cleanDialog() {
        var splitName:Array<String> = dialogueText[0].split(":");
        curPortrait = splitName[1];
        dialogueText[0] = StringTools.trim(dialogueText[0].substr(splitName[1].length + 2));
    }

    function doEnd() {
        if (!alreadyEnding) {
            alreadyEnding = true;
            if (dialogueScript.exists("finish")) new FlxTimer().start(.5, t -> dialogueScript.exec("finish", []));
            else {
                for (x in 0...length) members[x].visible = false;
                new FlxTimer().start(.5, t -> finishCallback());
                kill();
            }
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (dialogueScript != null && dialogueScript.exists("update")) dialogueScript.exec("update", [elapsed]);
        var targetPortrait = portraits[curPortrait];
        if (targetPortrait != null && targetPortrait.animation.exists("talk") && currentlyTyping) targetPortrait.animation.play("talk");
        if (FlxG.keys.justPressed.ESCAPE) doEnd();
        if (FlxG.keys.justPressed.ENTER || initText) {
            if (dialogueText.length != 0) {
                if (textStarted) {
                    if (currentlyTyping) {
                        speakTxt.skip();
                        currentlyTyping = false;
                    }
                    else startDialogue();
                }
            }
            else doEnd();
        }
    }
}
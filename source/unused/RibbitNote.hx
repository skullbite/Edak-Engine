package;

import flixel.FlxG;
import hstuff.CallbackScript;
import sys.FileSystem;
import flixel.group.FlxGroup;

using StringTools;

class RibbitNote {
    public var parent:NoteSprite;
    public var holds:FlxTypedGroup<NoteSprite>;

    public var strumTime:Float = 0;
    public var data:Int = 0;
    public var sustainLength:Float = 0;

    public var canBeHit:Bool = false;
    public var mustPress:Bool = false;

    public var noHit:Bool = false;
    public var rating:String = "shit";
    // todo
    // public var healthOff
    // public var score

    public var script:Null<CallbackScript>;
    public var raw:Array<Dynamic>;
    public var type:String;
    public var strumSyncVariables = ["alpha", "visible", "angle", "color", "x"];

    public static var colors:Array<String> = ["purple", "blue", "green", "red"];
    public static var directions:Array<String> = ["left", "down", "up", "right"];
    public static var swagWidth:Float = 160 * 0.7;
    
    public function new(strumTime:Float, noteData:Int, mustHit:Bool, sustainLength:Float, ?noteType:String = "Normal") {
        this.strumTime = strumTime;
        data = noteData;
        mustPress = mustHit;
        if (sustainLength > 0) this.sustainLength = sustainLength;
        type = noteType;

        switch (type) {
            default:
                if (FileSystem.exists(Paths.getPath('custom-notes/$type.hxs'))) {
                    try {
                        script = new CallbackScript(Paths.getPath('custom-notes/$type.hxs'), 'Note:$noteType', {
                            note: parent,
                            holds: holds
                        });
                        
                        script.execute();
                    }
                    catch (e) {
                        script = null;
                    }
                }
        }

        holds = new FlxTypedGroup();

        parent = new NoteSprite(this, false);
        parent.strumTime = strumTime;


        for (sus in 0...Math.floor(this.sustainLength / Conductor.stepCrochet)) {
            var sussyNote:NoteSprite = new NoteSprite(this, true);
            sussyNote.ID = sus;
            sussyNote.strumTime += strumTime + Conductor.stepCrochet * sus;
            sussyNote.scrollFactor.set();
            if (mustPress) sussyNote.x += FlxG.width / 2;
            holds.add(sussyNote);
        }

    }
}

class NoteSprite extends FrogSprite {
    public var tooLate:Bool = false;
    public var wasGoodHit:Bool = false;

    public var isSustainNote:Bool = false;
    public var isSustainEnd(get, null):Bool;
    public var strumTime:Float = 0;
    public var canBeHit:Bool = false;
    public var parent:RibbitNote;

    function get_isSustainEnd():Bool return animation.curAnim != null && animation.curAnim.name.endsWith("holdend");

    public function new(og:RibbitNote, isSustainNote:Bool) {
        super();
        parent = og;
        this.isSustainNote = isSustainNote;


        x += 50;
        y -= 2000;

        generateSprite();

        x += RibbitNote.swagWidth * parent.data;
        if (!isSustainNote) playAnim('${RibbitNote.colors[parent.data]}Scroll');

        if (Settings.get("downscroll") && isSustainNote) flipY = true;

        if (isSustainNote) {
            alpha = 0.6;

            x += width / 2;

            playAnim('${RibbitNote.colors[parent.data]}holdend');
            x -= width / 2;

            if (PlayState.curUi == 'pixel') {
                x += 30;
                offset.x = -10;
            }

            if (!isSustainEnd) {
                var pixelUi = PlayState.curUi == 'pixel';
                playAnim('${RibbitNote.colors[parent.data]hold}hold');
                if (Settings.get('downscroll')) angle = 180;
                scale.y *= Conductor.stepCrochet / 100 * 1.5 * ((Settings.get("scrollSpeed") != 1 ? Settings.get("scrollSpeed") : PlayState.SONG.speed));
                if (pixelUi) scale.y *= 0.838; // anti clip scaling
                updateHitbox();
                if (pixelUi) offset.x = -10;
            }
        }

    }

    // todo: only load one types of holds anims
    function generateSprite() {
        if (parent.script != null && parent.script.exists("loadSprite")) {
            parent.script.exec("loadSprite", [PlayState.curUi]);
            return;
        }

        switch (PlayState.curUi) {
            case "pixel":
                if (!isSustainNote) {
                    loadGraphic(Paths.image('strums/pixel/arrows-pixels'), true, 17, 17);
                    animation.add('greenScroll', [6]);
                    animation.add('redScroll', [7]);
                    animation.add('blueScroll', [5]);
                    animation.add('purpleScroll', [4]);
                }
                else {
                    loadGraphic(Paths.image('strums/pixel/arrowEnds'), true, 7, 6);

                    animation.add('purpleholdend', [4]);
                    animation.add('greenholdend', [6]);
                    animation.add('redholdend', [7]);
                    animation.add('blueholdend', [5]);
                    animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
                    
                }

                setGraphicSize(Std.int(width * PlayState.daPixelZoom));
                updateHitbox();
            default:
                frames = Paths.getSparrowAtlas('strums/normal/NOTE_assets');
                for (x in RibbitNote.colors) {
                    addAnim(x + 'hold', x + ' hold piece');
                    addAnim(x + 'holdend', x + ' hold end');
                    addAnim(x + 'Scroll', x + '0');
                }
                setGraphicSize(Std.int(width * 0.7));
        }

    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (parent.script != null && parent.script.exists("update")) parent.script.exec("update", [elapsed]);
        // todo: new with must press
        if (!parent.mustPress) {
            parent.canBeHit = false;
            // do NOT use parent.strumTime, replace with strumtime that's safe for sustains
            if (strumTime <= Conductor.songPosition) wasGoodHit = true;
        }
        else {
            if (isSustainNote) {
                    if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
                        && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
                        canBeHit = true;
                    else
                        canBeHit = false;
                }
                else
                {
                    if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
                        && strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
                        canBeHit = true;
                    else
                        canBeHit = false;
                }

                if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit) tooLate = true;
        }
        
    }
}
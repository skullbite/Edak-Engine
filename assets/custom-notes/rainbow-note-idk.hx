import flixel.FlxG;
import shaders.ColorSwap;
import Note;

var colorThing:ColorSwap = new ColorSwap();
var holdNames = Note.colors.map(t -> t + "hold");

function create() {}

function loadSprite(noteStyle:String, isSusEnd:Bool) {
    note.frames = Paths.getSparrowAtlas("strums/normal/RGB_NOTE");
    note.setGraphicSize(Std.int(note.width * 0.7));
    note.shader = colorThing.shader;
    note.dadShouldHit = false;
    note.bfShouldHit = false;
    for (x in 0...3) {
        note.animation.addByPrefix(holdNames[x] + "end", "blue hold end", 0, false);
        note.animation.addByPrefix(holdNames[x], "blue hold piece", 0, false);
    }


    if (!note.isSustainNote) {
        note.animation.addByPrefix("daNote", "blue", 0, false);
        note.offset.x += 20;

        switch (note.noteData) {
            case 0: note.angle += 90;
            case 2: note.angle -= 180;
            case 3: note.angle -= 90;
        }
        note.animation.play("daNote");
    }
}

function propertyOverride() {
    if (!note.isSustainNote) switch (note.noteData) {
        case 0: note.angle += 90;
        case 2: note.angle -= 180;
        case 3: note.angle -= 90;
    }
}

function update(elapsed) {
    colorThing.update(elapsed * 0.4);
}
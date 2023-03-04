package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class SplashGroup extends FlxTypedGroup<FlxSprite> {
    public var splashAssets = "strums/noteSplashes";
    public var targetStrumGroup = PlayState.playerStrums;
    public var offsets = {
        x: 132, 
        y: 145 
    };
    public var perStrumOffsets = [{x: 0, y: 0}, {x: 40, y: 0}, {x: 0, y: 0}, {x: 0, y: 0}];
    var firstSplash = true;
    
	public var color:Int = 0xffffff;
	public var scale:Float = 1;
	public var defaultFramerate:Int = 24;

    public function spawnSplash(noteData:Int, ?customAnim:String) {
        var strumTarget = PlayState.playerStrums.members[noteData];
        // recycle(Splash);
       
        var splash = new Splash(Std.int(strumTarget.getMidpoint().x), Std.int(strumTarget.getMidpoint().y), offsets.x + perStrumOffsets[noteData].x, offsets.y + perStrumOffsets[noteData].y, noteData, splashAssets, defaultFramerate, customAnim);
        splash.cameras = [PlayState.instance.camHUD];
        if (firstSplash) {
            splash.alpha = 0.005;
            firstSplash = false;
        }
        else splash.alpha = strumTarget.alpha - .4;
        splash.color = color;
        splash.animation.play("splash");
        splash.setGraphicSize(Std.int(splash.width * scale));
        splash.animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        splash.animation.finishCallback = n -> {
            splash.alpha = 0;
            splash.kill();
        }
        add(splash);
    }
}

class Splash extends FlxSprite {
    public function new(x:Int, y:Int, offX:Int, offY:Int, noteData:Int, splashAssets:String, framerate:Int, ?customAnim:String) {
        super(x, y);
        frames = Paths.getSparrowAtlas(splashAssets);
        offset.x = offX;
        offset.y = offY;
        var rando = FlxG.random.int(1, 2);
        
        if (customAnim != null) animation.addByPrefix("splash", customAnim, framerate, false);
        else switch (noteData) {
            case 0: animation.addByPrefix("splash", 'note splash purple $rando', framerate, false);
            case 1: animation.addByPrefix("splash", 'note splash blue $rando', framerate, false);
            case 2: animation.addByPrefix("splash", 'note splash green $rando', framerate, false);
            case 3: animation.addByPrefix("splash", 'note splash red $rando', framerate, false);
        }
    }
}
package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class SplashGroup extends FlxTypedGroup<FlxSprite> {
    public var splashAssets = "strums/noteSplashes";
    var firstSplash = true;

    public function spawnSplash(noteData:Int, offX:Int=0, offY:Int=0) {
        var strumTarget = PlayState.playerStrums.members[noteData];
        // recycle(Splash);
       
        var splash = new Splash(Std.int(strumTarget.getMidpoint().x), Std.int(strumTarget.getMidpoint().y), offX, offY, noteData, splashAssets);
        splash.cameras = [PlayState.instance.camHUD];
        if (firstSplash) {
            splash.alpha = 0.005;
            firstSplash = false;
        }
        splash.animation.play("splash");
        splash.animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        splash.animation.finishCallback = n -> {
            splash.alpha = 0;
            splash.kill();
        }
        add(splash);
    }
}

class Splash extends FlxSprite {
    public function new(x:Int, y:Int, offX:Int, offY:Int, noteData:Int, splashAssets:String) {
        super(x, y);
        if (splashAssets == null) splashAssets = "strums/noteSplashes";
        frames = Paths.getSparrowAtlas(splashAssets);
        alpha = .6;
        offset.x = offX;
        offset.y = offY;
        var rando = FlxG.random.int(1, 2);
        
        switch (noteData) {
            case 0: animation.addByPrefix("splash", 'note splash purple $rando', 24, false);
            case 1: animation.addByPrefix("splash", 'note splash blue $rando', 24, false);
            case 2: animation.addByPrefix("splash", 'note splash green $rando', 24, false);
            case 3: animation.addByPrefix("splash", 'note splash red $rando', 24, false);
        }
    }
}
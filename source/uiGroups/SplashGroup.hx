package uiGroups;

import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class SplashGroup extends FlxTypedGroup<FlxSprite> {
    public var targetStrumGroup = PlayState.instance.playerStrums;
    // i'm gonna knock this offset system down soon
    public var offsets = {
        x: 132, 
        y: 145 
    };
    public var perStrumOffsets = [{x: -80, y: -85}, {x: -80, y: -85}, {x: -80, y: -85}, {x: -80, y: -85}];
    var firstSplash = true;
    
	public var color:FlxColor = 0xffffff;
	public var scale:Float = 1.5;
	public var defaultFramerate:Int = 24;

    public function spawnSplash(noteData:Int, ?customSprite:FlxSprite) {
        var strumTarget = targetStrumGroup.members[noteData];
        // recycle(Splash);

        if (customSprite != null) {
            customSprite.animation.play("splash");
            customSprite.animation.finishCallback = n -> {
                customSprite.alpha = 0;
                customSprite.kill();
                if (firstSplash) {
                    customSprite.alpha = 0.005;
                    firstSplash = false;
                }
            }
            add(customSprite);
            return;
        }
       
        var splash = new Splash(Std.int(strumTarget.getMidpoint().x), Std.int(strumTarget.getMidpoint().y), offsets.x + perStrumOffsets[noteData].x, offsets.y + perStrumOffsets[noteData].y, noteData, defaultFramerate);
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

// default splashes by ✨Skellz#5046 
class Splash extends FlxSprite {
    public function new(x:Int, y:Int, offX:Int, offY:Int, noteData:Int, framerate:Int, ?customAnim:String) {
        super(x, y);
        frames = Paths.getSparrowAtlas("strums/splashes");
        offset.x = offX;
        offset.y = offY;
        
        if (customAnim != null) animation.addByPrefix("splash", customAnim, framerate, false);
        else switch (noteData) {
            case 0: animation.addByPrefix("splash", 'SplashPurble', framerate, false);
            case 1: animation.addByPrefix("splash", 'SplashBlub', framerate, false);
            case 2: animation.addByPrefix("splash", 'SplashGreb', framerate, false);
            case 3: animation.addByPrefix("splash", 'SplashReb', framerate, false);
        }
    }
}
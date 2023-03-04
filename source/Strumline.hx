package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class Strumline extends FlxTypedGroup<FlxSprite> {
    var forDad:Bool;
    var doIntroTween:Bool;
    public function new(forDad:Bool=true, followMiddlescroll:Bool=true, doIntroTween:Bool=false) {
        super();

        this.doIntroTween = doIntroTween;
        this.forDad = forDad;

        for (i in 0...4)
            {
                // FlxG.log.add(i);
                var middleScrollOffset = Settings.get("middlescroll") && !Settings.get("downscroll") && followMiddlescroll ? 20 : 0;
                var babyArrow:FlxSprite = new FlxSprite(0, (Settings.get("downscroll") ? FlxG.height - 165 : 50) + middleScrollOffset);
    
                switch (PlayState.curUi)
                {
                    case 'pixel':
                        babyArrow.loadGraphic(Paths.image('strums/pixel/arrows-pixels', null), true, 17, 17);
                        babyArrow.animation.add('green', [6]);
                        babyArrow.animation.add('red', [7]);
                        babyArrow.animation.add('blue', [5]);
                        babyArrow.animation.add('purplel', [4]);
    
                        babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.daPixelZoom));
                        babyArrow.updateHitbox();
                        babyArrow.antialiasing = false;
    
                        switch (Math.abs(i))
                        {
                            case 0:
                                babyArrow.x += Note.swagWidth * 0;
                                babyArrow.animation.add('static', [0]);
                                babyArrow.animation.add('pressed', [4, 8], 12, false);
                                babyArrow.animation.add('confirm', [12, 16], 24, false);
                            case 1:
                                babyArrow.x += Note.swagWidth * 1;
                                babyArrow.animation.add('static', [1]);
                                babyArrow.animation.add('pressed', [5, 9], 12, false);
                                babyArrow.animation.add('confirm', [13, 17], 24, false);
                            case 2:
                                babyArrow.x += Note.swagWidth * 2;
                                babyArrow.animation.add('static', [2]);
                                babyArrow.animation.add('pressed', [6, 10], 12, false);
                                babyArrow.animation.add('confirm', [14, 18], 12, false);
                            case 3:
                                babyArrow.x += Note.swagWidth * 3;
                                babyArrow.animation.add('static', [3]);
                                babyArrow.animation.add('pressed', [7, 11], 12, false);
                                babyArrow.animation.add('confirm', [15, 19], 24, false);
                        }
                    default:
                        babyArrow.frames = Paths.getSparrowAtlas('strums/normal/NOTE_assets');
                        babyArrow.animation.addByPrefix('green', 'arrowUP');
                        babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
    
                        babyArrow.antialiasing = true;
                        babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
    
                        switch (Math.abs(i))
                        {
                            case 0:
                                babyArrow.x += Note.swagWidth * 0;
                                babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                                babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                                babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                            case 1:
                                babyArrow.x += Note.swagWidth * 1;
                                babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                                babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                                babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                            case 2:
                                babyArrow.x += Note.swagWidth * 2;
                                babyArrow.animation.addByPrefix('static', 'arrowUP');
                                babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                                babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                            case 3:
                                babyArrow.x += Note.swagWidth * 3;
                                babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                                babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                                babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                        }
                }
    
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();

    
                // psych engine!!!!!
                if (Settings.get("middlescroll") && followMiddlescroll) {
                    if (Settings.get("downscroll")) babyArrow.y -= 10;
                    if (forDad) {
                        babyArrow.alpha = .5;
                        babyArrow.x += 320;
                        if (i > 1) babyArrow.x += 350;
                        else babyArrow.x -= 350;
                    }
                    else babyArrow.x -= 320;
                }
    
                babyArrow.ID = i;
    
                add(babyArrow);
                
                babyArrow.animation.play('static');
                babyArrow.x += 100;
                babyArrow.x += Std.int((FlxG.width / 2) * (forDad ? 0 : 1));
                babyArrow.alpha = 0;
            }             
    }

    public function lightStrum(targetStrum:Int=0) {
        members[targetStrum].animation.play("confirm", true);
        if (forDad && members[targetStrum].animation.curAnim.name == 'confirm' && PlayState.curUi != "pixel") {
            members[targetStrum].centerOffsets();
            members[targetStrum].offset.x -= 13;
            members[targetStrum].offset.y -= 13;
        }
        else members[targetStrum].centerOffsets();
    }

    public function doIntro() {
        if (doIntroTween) {
            for (i in 0...members.length) {
                members[i].y -= 10;
                FlxTween.tween(members[i], {y: members[i].y + 10, alpha: Settings.get("middlescroll") && forDad ? .5 : 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            }
        }
        else for (i in 0...members.length) FlxTween.tween(members[i], {y: members[i].y + 10, alpha: Settings.get("middlescroll") && forDad ? .5 : 1}, 1, { ease: FlxEase.circOut });
    }
}
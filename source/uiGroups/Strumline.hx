package uiGroups;

import PlayState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class Strumline extends FlxTypedGroup<FrogSprite> {
    var forDad:Bool;
    var doIntroTween:Bool;
    public function new(forDad:Bool=true, followMiddlescroll:Bool=true, doIntroTween:Bool=false) {
        super();

        this.doIntroTween = doIntroTween;
        this.forDad = forDad;

        for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow = new FrogSprite(0, (Settings.get("downscroll") ? FlxG.height - 150 : 50));
    
                switch (PlayState.curUi)
                {
                    case 'pixel':
                        babyArrow.loadGraphic(Paths.image('strums/pixel/arrows-pixels', null), true, 17, 17);
    
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
    
                        babyArrow.antialiasing = true;
                        babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                        babyArrow.x += Note.swagWidth * i;
    
                        switch (i)
                        {
                            case 0:
                                babyArrow.addAnim('static', 'arrowLEFT', null, null, 0);
                                babyArrow.addAnim('pressed', 'left press');
                                babyArrow.addAnim('confirm', 'left confirm', [13, 13]);
                            case 1:
                                babyArrow.addAnim('static', 'arrowDOWN', null, null, 0);
                                babyArrow.addAnim('pressed', 'down press');
                                babyArrow.addAnim('confirm', 'down confirm', [13, 13]);
                            case 2:
                                babyArrow.addAnim('static', 'arrowUP', null, null, 0);
                                babyArrow.addAnim('pressed', 'up press');
                                babyArrow.addAnim('confirm', 'up confirm', [13, 13]);
                            case 3:
                                babyArrow.addAnim('static', 'arrowRIGHT', null, null, 0);
                                babyArrow.addAnim('pressed', 'right press');
                                babyArrow.addAnim('confirm', 'right confirm', [13, 13]);
                        }
                }
    
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();

    
                // psych engine!!!!!
                if (Settings.get("middlescroll") && followMiddlescroll) {
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
                if (doIntroTween) babyArrow.alpha = 0;
            }
            /*if (!doIntroTween) for (i in 0...members.length) {
                trace('a');
                members[i].alpha = Settings.get("middlescroll") && forDad ? .5 : 1;
            }*/
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
        if (!doIntroTween) return;
        
        for (i in 0...members.length) {
            members[i].y -= 10;
            FlxTween.tween(members[i], {y: members[i].y + 10, alpha: Settings.get("middlescroll") && forDad ? .5 : 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
        }
    }
}
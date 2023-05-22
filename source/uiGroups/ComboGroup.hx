package uiGroups;

import PlayState;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

typedef ComboTweens = {
    rating:Null<FlxTween>,
    text:Null<FlxTween>,
    numbers:Array<FlxTween>
}

class ComboGroup extends FlxTypedGroup<FlxBasic> {
    public var rating:FlxSprite;
    public var numbers:FlxTypedGroup<FlxSprite>;
    public var ms:FlxText;
    public var tweens:ComboTweens = {
        rating: null,
        text: null,
        numbers: [],
    };
    public var basePos:{?x:Int,?y:Int} = {};

    public function new() {
        super();

        if (Settings.get("changedHit")) basePos = { x: Settings.get("changedHitX"), y: Settings.get("changedHitY") };
        else basePos = { x: Std.int(FlxG.width / 2) - 175, y: Std.int(FlxG.height / 2) };

        rating = new FlxSprite();
        rating.alpha = 0;

        add(rating);
        
        numbers = new FlxTypedGroup<FlxSprite>();
        add(numbers);

        ms = new FlxText();
        ms.text = "0ms";
        ms.alpha = 0;
        ms.font = Paths.font("vcr.ttf");
        ms.size = 35;
        ms.borderStyle = OUTLINE;
        ms.borderSize = 2;
        ms.velocity.y = 550;
        add(ms);
    }

    public function pop(ratingStr:String, msVal:Float) {
        if (tweens.rating != null) {
            tweens.rating.cancel();
            rating.alpha = 0;
            rating.reset(basePos.x, basePos.y);
        }
        for (x in tweens.numbers) if (x != null) {
            tweens.numbers.remove(x);
            x.cancel();
        }
        if (numbers.length != 0) numbers.forEach(d -> {
            numbers.remove(d);
            d.destroy();
        });

        if (tweens.text != null) tweens.text.cancel();
        ms.alpha = 0;
        ms.velocity.y = 0;
		ms.velocity.x = 0; 
        var isPixelUi = PlayState.curUi == 'pixel';
        var scaleStuff = 0.6;
        if (isPixelUi) scaleStuff = PlayState.daPixelZoom * 0.7;
        
        rating.loadGraphic(Paths.image('ui/${PlayState.curUi}/ratings/' + ratingStr.replace("miss", "shit")));
        if (isPixelUi) rating.antialiasing = false;
        rating.setGraphicSize(Std.int(rating.width * scaleStuff));
        rating.x = basePos.x - 70;
        rating.screenCenter(Y);
        rating.y = basePos.y - 65;
        if (!isPixelUi) rating.y -= 70;
        rating.acceleration.x = 0;
        rating.acceleration.y = 550;
        rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
        if (isPixelUi) {
            rating.x += 160;
            rating.y -= 10;
        }
        rating.alpha = 1;

        ms.text = Std.string(Math.round(msVal)) + "ms";
        ms.x = basePos.x + 140;
        ms.y = basePos.y - 30;
        ms.velocity.y -= FlxG.random.int(140, 175);
		ms.velocity.x -= FlxG.random.int(0, 10);
        ms.alpha = 1;

        var combo = PlayState.instance.combo;

        if (combo >= 10) {
            var comboThing = Std.string(combo).split("");
            while (comboThing.length < 3) comboThing.insert(0, "0");
    
            var spacing = 43;
            if (isPixelUi) {
                spacing += 10;
                ms.x += 10;
            }
            for (num in 0...comboThing.length) {

                var numSpr = new ComboSprite((basePos.x - 20) + (spacing * num), basePos.y - 30, comboThing[num]);
                numbers.add(numSpr);
    
                tweens.numbers.push(FlxTween.tween(numSpr, { alpha: 0 }, 0.5, {  
                    startDelay: Conductor.crochet * 0.001,
                    onComplete: t -> if (numSpr != null) numSpr.destroy() 
                }));
            }
        }
       

        tweens.rating = FlxTween.tween(rating, { alpha: 0 }, 0.5, { 
            startDelay: Conductor.crochet * 0.001
        });

        tweens.text = FlxTween.tween(ms, { alpha: 0, y: ms.y - FlxG.random.int(20, 30) }, 0.7, { onUpdate: t -> ms.velocity.y += FlxG.elapsed });
    }
}

class ComboSprite extends FlxSprite {
    public function new(x:Float, y:Float, num:String) {
        super(x, y);
        loadGraphic(Paths.image('ui/${PlayState.curUi}/combo/num$num'));

        if (PlayState.curUi == 'pixel') {
            antialiasing = false;
            setGraphicSize(Std.int(width * PlayState.daPixelZoom));
        }
        else setGraphicSize(Std.int(width * 0.5));

        updateHitbox();
        acceleration.y = FlxG.random.int(200, 300);
        velocity.y -= FlxG.random.int(140, 160);
        velocity.x = FlxG.random.float(-5, 5);
    }
}
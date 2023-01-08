package;

import flixel.FlxSprite;
import flixel.FlxG;

var lightningStrikeBeat = 0;
var lightingOffset = 8;
var halloweenBG:FlxSprite;

function create() {
	var hallowTex = Paths.getSparrowAtlas('halloween_bg');
	halloweenBG = new FlxSprite(-200, -100);
	halloweenBG.frames = hallowTex;
	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	halloweenBG.animation.play('idle');
	halloweenBG.antialiasing = true;
    // stage.publicSprites["halloweenBG"] = halloweenBG;
	stage.add(halloweenBG);
}

function reposCharacters() {
	PlayState.dad.y += 200;
}

function beatHit(beat) {
    if (FlxG.random.bool(10) && beat > lightningStrikeBeat + lightingOffset) lightningStrikeShit(beat);
}

function lightningStrikeShit(beat) {
	FlxG.sound.play(_Paths.soundRandom('thunder_', 1, 2));
	halloweenBG.animation.play('lightning');

	lightningStrikeBeat = beat;
	lightingOffset = FlxG.random.int(8, 24);

	PlayState.boyfriend.animation.play('scared', true);
	PlayState.gf.playAnim('scared', true);
}
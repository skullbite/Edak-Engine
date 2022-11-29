function create() {
	var hallowTex = Paths.getSparrowAtlas('halloween_bg');
	var halloweenBG = new FlxSprite(-200, -100);
	halloweenBG.frames = hallowTex;
	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	halloweenBG.animation.play('idle');
	halloweenBG.antialiasing = true;
    stage.publicSprites["halloweenBG"] = halloweenBG;
	stage.add(halloweenBG);
    vars["lightningStrikeBeat"] = 0;
    vars["lightingOffset"] = 8;
}

function reposCharacters() {
	PlayState.dad.y += 200;
}

function beatHit(beat) {
    if (FlxG.random.bool(10) && beat > vars["lightningStrikeBeat"] + vars["lightingOffset"]) lightningStrikeShit(beat);
}

function lightningStrikeShit(beat) {
	FlxG.sound.play(_Paths.soundRandom('thunder_', 1, 2));
	stage.publicSprites["halloweenBG"].animation.play('lightning');

	vars["lightningStrikeBeat"] = beat;
	vars["lightingOffset"] = FlxG.random.int(8, 24);

	PlayState.boyfriend.animation.finishCallback = n -> {
		if (n == 'scared') { 
			PlayState.boyfriend.shouldDance = true;
			PlayState.boyfriend.animation.finishCallback = null;
		}
	};
	PlayState.boyfriend.shouldDance = false;
	PlayState.boyfriend.animation.play('scared', true);

	PlayState.gf.animation.finishCallback = n -> {
		if (n == 'scared') { 
			PlayState.gf.shouldDance = true;
			PlayState.gf.animation.finishCallback = null;
		}
	};
	PlayState.gf.shouldDance = false;
	PlayState.gf.playAnim('scared', true);
}
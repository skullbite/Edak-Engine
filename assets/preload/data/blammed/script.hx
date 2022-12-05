function onCreatePost() {
    PlayState.gf.bopSpeed = 2;
}

function onCountdownTick(tick) {
    if (tick == 3) { 
        PlayState.boyfriend.playAnim("hey");
        FlxTween.tween(game.camHUD, { alpha: 0 }, 0.5);
        importLib("flixel.tweens.FlxEase");
    }
} 

function onBeatHit(beat) {
    switch (beat) {
        case 30: FlxTween.tween(game.camHUD, { alpha: 1 }, 0.5);
        case 32: PlayState.gf.bopSpeed = 1;
        case 96, 192: FlxTween.tween(game, { defaultCamZoom: 1.2 }, 0.3, { ease: FlxEase.quadOut });
        case 128, 224: FlxTween.tween(game, { defaultCamZoom: 1.05 }, 0.3, { ease: FlxEase.quadOut });
    }
}
function onBeatHit(beat:Int) {
    switch (beat) {
        case 16, 80: PlayState.gf.bopSpeed = 2;
        case 48, 112: PlayState.gf.bopSpeed = 1;
    }
}
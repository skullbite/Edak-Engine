function onCreatePost() {
    PlayState.gf.bopSpeed = 2;
}

function onBeatHit(beat) {
    switch (beat) {
        case 32: game.bopSpeed = 1;
        case 64,192: 
            game.bopSpeed = 4;
            PlayState.gf.bopSpeed = 1;
        case 160:
            game.bopSpeed = 8;
            PlayState.gf.bopSpeed = 2;
        case 224:
            game.bopSpeed = 2;
            game.camBumpZoom = 0.02;
            game.hudBumpZoom = 0.04;
            PlayState.gf.bopSpeed = 2;
        case 256:
            game.bopSpeed = 1;
            game.camBumpZoom = 0.03;
            game.hudBumpZoom = 0.05;
            PlayState.gf.bopSpeed = 1;
        case 288:
            game.camBumpZoom = 0.015;
            game.hudBumpZoom = 0.03;
            game.bopSpeed = 4;
            PlayState.gf.bopSpeed = 2;

    }
    
}
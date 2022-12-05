function create() {
    char.frames = Paths.getSparrowAtlas('bfPixelsDEAD');
    char.animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
    char.animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
    char.animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
    char.animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
    
    char.addOffset('firstDeath');
    char.addOffset('deathLoop', -37);
    char.addOffset('deathConfirm', -37);
    char.playAnim('firstDeath');
    				// pixel bullshit
    char.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
    char.updateHitbox();
    char.antialiasing = false;
    char.flipX = true;
}
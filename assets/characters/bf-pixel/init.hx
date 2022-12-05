function create() {
    char.barColor = "0xf368f0";
    char.frames = Paths.getSparrowAtlas('bfPixel');
    char.animation.addByPrefix('idle', 'BF IDLE', 24, false);
    char.animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
    char.animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
    char.animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
    char.animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
    char.animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
    char.animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
    char.animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
    char.animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
    
    char.addOffset('idle');
    char.addOffset("singUP");
    char.addOffset("singRIGHT");
    char.addOffset("singLEFT");
    char.addOffset("singDOWN");
    char.addOffset("singUPmiss");
    char.addOffset("singRIGHTmiss");
    char.addOffset("singLEFTmiss");
    char.addOffset("singDOWNmiss");
    
    char.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
    char.updateHitbox();
    
    char.playAnim('idle');
    
    char.width -= 100;
    char.height -= 100;
    
    char.antialiasing = false;
    
    char.flipX = true;
}
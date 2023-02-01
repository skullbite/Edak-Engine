function create() {
    char.frames = Paths.getSparrowAtlas("bfCar");
    char.animation.addByPrefix('idle', 'BF idle dance', 24, false);
    char.animation.addByIndices('idleLoop', 'BF idle dance', [8, 9, 10, 11, 12, 13], "", 24, true);
    char.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
    char.animation.addByIndices('singUPLoop', 'BF NOTE UP0', [18, 19, 20, 21, 22, 13], "", 24, true);
    char.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
    char.animation.addByIndices('singLEFTLoop', 'BF NOTE LEFT0', [10, 11, 12, 13, 14, 15], "", 24, true);
    char.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
    char.animation.addByIndices('singRIGHTLoop', 'BF NOTE RIGHT0', [34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46], "", 24, true);
    char.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
    char.animation.addByIndices('singDOWNLoop', 'BF NOTE DOWN0', [20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, true);
    char.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
    char.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
    char.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
    char.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
    
    char.addOffset('idle', -5);
    char.addOffset('idleLoop', -5);
    char.addOffset("singUP", -29, 27);
    char.addOffset("singUPLoop", -29, 27);
    char.addOffset("singRIGHT", -38, -7);
    char.addOffset("singRIGHTLoop", -38, -7);
    char.addOffset("singLEFT", 12, -6);
    char.addOffset("singLEFTLoop", 12, -6);
    char.addOffset("singDOWN", -10, -50);
    char.addOffset("singDOWNLoop", -10, -50);
    char.addOffset("singUPmiss", -29, 27);
    char.addOffset("singRIGHTmiss", -30, 21);
    char.addOffset("singLEFTmiss", 12, 24);
    char.addOffset("singDOWNmiss", -11, -19);
    char.playAnim('idle');
    
    char.flipX = true;
}
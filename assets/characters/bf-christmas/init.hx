char.frames = Paths.getSparrowAtlas('bfChristmas');
char.animation.addByPrefix('idle', 'BF idle dance', 24, false);
char.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
char.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
char.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
char.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
char.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
char.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
char.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
char.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
char.animation.addByPrefix('hey', 'BF HEY', 24, false);

char.addOffset('idle', -5);
char.addOffset("singUP", -29, 27);
char.addOffset("singRIGHT", -38, -7);
char.addOffset("singLEFT", 12, -6);
char.addOffset("singDOWN", -10, -50);
char.addOffset("singUPmiss", -29, 27);
char.addOffset("singRIGHTmiss", -30, 21);
char.addOffset("singLEFTmiss", 12, 24);
char.addOffset("singDOWNmiss", -11, -19);
char.addOffset("hey", 7, 4);

char.playAnim('idle');

char.flipX = true;
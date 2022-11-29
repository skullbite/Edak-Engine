char.barColor = "0x8978cc";
char.frames = Paths.getSparrowAtlas('Pico_FNF_assetss');
char.animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
char.animation.addByPrefix('singUP', 'pico Up note0', 24, false);
char.animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
char.animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
char.animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);
char.animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
char.animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
char.animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
char.animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);

char.addOffset('idle');
char.addOffset("singUP", -29, 27);
char.addOffset("singRIGHT", -68, -7);
char.addOffset("singLEFT", 65, 9);
char.addOffset("singDOWN", 200, -70);
char.addOffset("singUPmiss", -19, 67);
char.addOffset("singRIGHTmiss", -60, 41);
char.addOffset("singLEFTmiss", 62, 64);
char.addOffset("singDOWNmiss", 210, -28);

char.playAnim('idle');

char.flipX = true;
char.displaceData.camX = -20;
char.displaceData.camY = 40;
char.displaceData.y = 300;
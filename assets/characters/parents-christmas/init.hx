char.barColor = "0xf191ba";
char.frames = Paths.getSparrowAtlas('mom_dad_christmas_assets');
char.animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
char.animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
char.animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
char.animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
char.animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

char.animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

char.animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
char.animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
char.animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

char.addOffset('idle');
char.addOffset("singUP", -47, 24);
char.addOffset("singRIGHT", -1, -23);
char.addOffset("singLEFT", -30, 16);
char.addOffset("singDOWN", -31, -29);
char.addOffset("singUP-alt", -47, 24);
char.addOffset("singRIGHT-alt", -1, -24);
char.addOffset("singLEFT-alt", -30, 15);
char.addOffset("singDOWN-alt", -30, -27);

char.playAnim('idle');
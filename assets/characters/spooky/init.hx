char.barColor = "0xb2b2b2";
char.frames = Paths.getSparrowAtlas('spooky_kids_assets');
char.animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
char.animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
char.animation.addByPrefix('singLEFT', 'note sing left', 24, false);
char.animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
char.animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
char.animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

char.addOffset('danceLeft');
char.addOffset('danceRight');

char.addOffset("singUP", -20, 26);
char.addOffset("singRIGHT", -130, -14);
char.addOffset("singLEFT", 130, -10);
char.addOffset("singDOWN", -50, -130);

char.playAnim('danceRight');
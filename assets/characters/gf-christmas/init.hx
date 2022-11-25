char.frames = Paths.getSparrowAtlas('gfChristmas');
char.animation.addByPrefix('cheer', 'GF Cheer', 24, false);
char.animation.addByPrefix('singLEFT', 'GF left note', 24, false);
char.animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
char.animation.addByPrefix('singUP', 'GF Up Note', 24, false);
char.animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
char.animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
char.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
char.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
char.animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
char.animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
char.animation.addByPrefix('scared', 'GF FEAR', 24);

char.addOffset('cheer');
char.addOffset('sad', -2, -2);
char.addOffset('danceLeft', 0, -9);
char.addOffset('danceRight', 0, -9);

char.addOffset("singUP", 0, 4);
char.addOffset("singRIGHT", 0, -20);
char.addOffset("singLEFT", 0, -19);
char.addOffset("singDOWN", 0, -20);
char.addOffset('hairBlow', 45, -8);
char.addOffset('hairFall', 0, -9);

char.addOffset('scared', -2, -17);

char.playAnim('danceRight');
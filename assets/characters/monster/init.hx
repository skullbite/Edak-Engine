char.barColor = "0x78ff71";
char.frames = Paths.getSparrowAtlas('Monster_Assets');
char.animation.addByPrefix('idle', 'monster idle', 24, false);
char.animation.addByPrefix('singUP', 'monster up note', 24, false);
char.animation.addByPrefix('singDOWN', 'monster down', 24, false);
char.animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
char.animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

char.addOffset('idle');
char.addOffset("singUP", -20, 50);
char.addOffset("singRIGHT", -51);
char.addOffset("singLEFT", -30);
char.addOffset("singDOWN", -30, -40);
char.playAnim('idle');
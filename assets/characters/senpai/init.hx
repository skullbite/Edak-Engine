char.barColor = "0xd5d5d3";
char.frames = _Paths.getSparrowAtlas('reused/senpai', 'characters');
char.animation.addByPrefix('idle', 'Senpai Idle', 24, false);
char.animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
char.animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
char.animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
char.animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

char.addOffset('idle');
char.addOffset("singUP", 5, 37);
char.addOffset("singRIGHT");
char.addOffset("singLEFT", 40);
char.addOffset("singDOWN", 14);

char.playAnim('idle');

char.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
char.updateHitbox();

char.antialiasing = false;
char.displaceData.x += 150;
char.displaceData.y += 360;
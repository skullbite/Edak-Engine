char.barColor = "0xf191ba";
char.frames = Paths.getSparrowAtlas("DADDY_DEAREST");
char.animation.addByPrefix('idle', 'Dad idle dance', 24, false);
char.animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
char.animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
char.animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
char.animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

char.addOffset('idle');
char.addOffset("singUP", -6, 50);
char.addOffset("singRIGHT", 0, 27);
char.addOffset("singLEFT", -10, 10);
char.addOffset("singDOWN", 0, -30);

char.playAnim('idle');
char.barColor = "0xf191ba";
char.frames = Paths.getSparrowAtlas('Mom_Assets');

char.animation.addByPrefix('idle', "Mom Idle", 24, false);
char.animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
char.animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
char.animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
// CUZ DAVE IS DUMB!
char.animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

char.addOffset('idle');
char.addOffset("singUP", 14, 71);
char.addOffset("singRIGHT", 10, -60);
char.addOffset("singLEFT", 250, -23);
char.addOffset("singDOWN", 20, -160);

char.playAnim('idle');
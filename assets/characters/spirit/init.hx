char.barColor = "0x59b4ff";
char.frames = Paths.getPackerAtlas('spirit');
char.animation.addByPrefix('idle', "idle spirit_", 24, false);
char.animation.addByPrefix('singUP', "up_", 24, false);
char.animation.addByPrefix('singRIGHT', "right_", 24, false);
char.animation.addByPrefix('singLEFT', "left_", 24, false);
char.animation.addByPrefix('singDOWN', "spirit down_", 24, false);

char.addOffset('idle', -220, -280);
char.addOffset('singUP', -220, -240);
char.addOffset("singRIGHT", -220, -280);
char.addOffset("singLEFT", -200, -280);
char.addOffset("singDOWN", 170, 110);

char.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
char.updateHitbox();

char.playAnim('idle');

char.antialiasing = false;

char.displaceData.x -= 150;
char.displaceData.y += 100;
char.bopSpeed = 1;
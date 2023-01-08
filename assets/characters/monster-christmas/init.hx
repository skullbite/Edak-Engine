function create() {
    char.iconName = "monster";
    char.barColor = "0x78ff71";
    char.frames = Paths.getSparrowAtlas('monsterChristmas');
    char.animation.addByPrefix('idle', 'monster idle', 24, false);
    char.animation.addByPrefix('singUP', 'monster up note', 24, false);
    char.animation.addByPrefix('singDOWN', 'monster down', 24, false);
    // bruh
    char.animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);
    char.animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);
    
    char.addOffset('idle');
    char.addOffset("singUP", -20, 50);
    char.addOffset("singLEFT", -51);
    char.addOffset("singRIGHT", -30);
    char.addOffset("singDOWN", -40, -94);
    char.playAnim('idle');
    
    char.displaceData.y = 130;
}
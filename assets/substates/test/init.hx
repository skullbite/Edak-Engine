function create() {
    importLib("flixel.text.FlxText");
    importLib("flixel.FlxSprite");
    trace("THIS IS A TEST");
    var coolAssBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height);
    coolAssBG.width = FlxG.width;
    coolAssBG.height = FlxG.height;
    coolAssBG.color = 0x000000;
    coolAssBG.alpha = .2;
    trace("FUCK");
    sub.add(coolAssBG);
    var fuckingMoney = new FlxText();
    fuckingMoney.size = 40;
    fuckingMoney.text = "THIS IS A PAUSE SCREEN\nPRESS ESC TO RESUME";
    fuckingMoney.screenCenter();
    sub.add(fuckingMoney);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.ESCAPE) sub.close();
}
function create() {
    importLib("flixel.util.FlxTimer");
    importLib("flixel.text.FlxText");
    var bg = new FlxSprite().makeGraphic(FlxG.width * 1.2, FlxG.height * 1.2, 0xFFE293A8);
    bg.width = FlxG.width * 1.2;
    bg.height = FlxG.height * 1.2;
    bg.color = 0xFFB3DFd8;
    bg.alpha = 0;

    dia.add(bg);

    new FlxTimer().start(0.83, t -> {
		bg.alpha += (1 / 5) * 0.7;
		if (bg.alpha > 0.7)
			bg.alpha = 0.7;
	}, 5);
    
    dia.box = new FlxSprite(-20, 45);
    dia.box.frames = Paths.getSparrowAtlas("dialogueBox-pixel");
    dia.box.animation.addByPrefix('open', 'Text Box Appear', 12, false);
	dia.box.animation.addByIndices('idle', 'Text Box Appear', [4], "", 12);
    dia.box.setGraphicSize(Std.int(dia.box.width * PlayState.daPixelZoom * 0.9));
    dia.box.screenCenter();
    dia.box.y = 350;
    dia.portraits["dad"] = new FlxSprite(425, 350);
    dia.portraits["dad"].frames = Paths.getSparrowAtlas("portraits/senpaiPortrait");
    dia.portraits["dad"].animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
    dia.portraits["dad"].setGraphicSize(Std.int(dia.portraits["dad"].width * PlayState.daPixelZoom * 0.9));

    dia.portraits["bf"] = new FlxSprite(500, 350);
    dia.portraits["bf"].frames = _Paths.getSparrowAtlas('portraits/bfPortrait', 'dialogue');
	dia.portraits["bf"].animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
	dia.portraits["bf"].setGraphicSize(Std.int(dia.portraits["bf"].width * PlayState.daPixelZoom * 0.9));
}

function createPost() {
    dia.speakTxt.size = 32;
    dia.speakTxt.font = 'Pixel Arial 11 Bold';
    dia.speakTxt.x -= 350;
    dia.speakTxt.y += 100;
    dia.speakTxt.color = 0xFF3F2021;
    dia.speakTxt.sounds = [FlxG.sound.load(_Paths.sound('pixelText'), 0.6)];
    var dropTxt = new FlxText(dia.speakTxt.x + 2, dia.speakTxt.y + 2, Std.int(FlxG.width * 0.6));
    dia.groupTxt.insert(0, dropTxt);
    dropTxt.size = 32;
    dropTxt.font = 'Pixel Arial 11 Bold';
    dropTxt.color = 0xFFD89494;
    vars["dropTxt"] = dropTxt;
}

function update(elapsed) {
    vars["dropTxt"].text = dia.speakTxt.text;
    if (FlxG.keys.justPressed.ENTER) FlxG.sound.play(_Paths.sound('clickText'), 0.8);
}

function finish() {
    /* TODO: random cut off before actual finish events */
    dia.forEach(s -> {
        if (s.alpha != null) FlxTween.tween(s, { alpha: 0 }, 3);
        else s.visible = false;
    });
    dia.finishCallback();
    dia.kill();
}
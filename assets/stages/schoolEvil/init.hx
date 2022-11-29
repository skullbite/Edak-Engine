function create() {
	importLib("flixel.addons.effects.FlxTrail");
    var bg:FlxSprite = new FlxSprite(400, 200);
	bg.frames = Paths.getSparrowAtlas('animatedEvilSchool');
	bg.animation.addByPrefix('idle', 'background 2', 24);
	bg.animation.play('idle');
	bg.scrollFactor.set(0.8, 0.9);
	bg.scale.set(6, 6);
	stage.add(bg);
}

function reposCharacters() {
	PlayState.boyfriend.x += 200;
	PlayState.boyfriend.y += 220;
	PlayState.boyfriend.displaceData.camY = -70;
	PlayState.gf.x += 180;
	PlayState.gf.y += 300;
	var trail = new FlxTrail(PlayState.dad, null, 4, 24, 0.3, 0.069);
	PlayState.dadGroup.insert(0, trail);
}
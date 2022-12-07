function create() {
	stage.cameraDisplace.x = 300;
    var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('evilBG'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.2, 0.2);
	bg.active = false;
	bg.scale.set(0.8, 0.8);
	bg.updateHitbox();
	stage.add(bg);

	var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('evilTree'));
	evilTree.antialiasing = true;
	evilTree.scrollFactor.set(0.2, 0.2);
	stage.add(evilTree);

	var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("evilSnow"));
	evilSnow.antialiasing = true;
	stage.add(evilSnow);
}

function reposCharacters() {
	PlayState.dad.y -= 90;
}
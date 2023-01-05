package;

import flixel.FlxSprite;

function create() {
    var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.9, 0.9);
    bg.active = false;
    stage.add(bg);

    var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
    stageFront.scale.set(1.1, 1.1);
    stageFront.updateHitbox();
    stageFront.antialiasing = true;
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.active = false;
    stage.add(stageFront);

    var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
    stageCurtains.scale.set(0.9, 0.9);
    stageCurtains.updateHitbox();
    stageCurtains.antialiasing = true;
    stageCurtains.scrollFactor.set(1.3, 1.3);
    stageCurtains.active = false;
    stage.foreground.add(stageCurtains);
}

function reposCharacters() {
    if (PlayState.SONG.song.toLowerCase() == 'tutorial') { 
        PlayState.dad.x = PlayState.gf.x;
        PlayState.dad.y = PlayState.gf.y;
        PlayState.gf.visible = false;
    }
}
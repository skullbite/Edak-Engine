package;

import BackgroundGirls;
import CoolUtil;
import flixel.FlxSprite;

function create() {
	stage.cameraDisplace.x = 200;
    var bgSky = new FlxSprite().loadGraphic(Paths.image('weebSky'));
	bgSky.scrollFactor.set(0.1, 0.1);
	stage.add(bgSky);

	var repositionShit = -200;

	var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weebSchool'));
	bgSchool.scrollFactor.set(0.6, 0.90);
	stage.add(bgSchool);

	var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weebStreet'));
	bgStreet.scrollFactor.set(0.95, 0.95);
	stage.add(bgStreet);

	var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weebTreesBack'));
	fgTrees.scrollFactor.set(0.9, 0.9);
	stage.add(fgTrees);

	var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
	var treetex = Paths.getPackerAtlas('weebTrees');
	bgTrees.frames = treetex;
	bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
	bgTrees.animation.play('treeLoop');
	bgTrees.scrollFactor.set(0.85, 0.85);
	stage.add(bgTrees);

	var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
	treeLeaves.frames = Paths.getSparrowAtlas('petals');
	treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
	treeLeaves.animation.play('leaves');
	treeLeaves.scrollFactor.set(0.85, 0.85);
	stage.add(treeLeaves);

	/*bgSky.scale.set(6, 6);
	bgSchool.scale.set(6, 6);
	bgStreet.scale.set(6, 6);
	bgTrees.scale.set(1.4, 1.4);
	fgTrees.scale.set(0.8, 0.8);
	treeLeaves.scale.set(6, 6);*/

    var widShit = Std.int(bgSky.width * 6);

	bgSky.setGraphicSize(widShit);
	bgSchool.setGraphicSize(widShit);
	bgStreet.setGraphicSize(widShit);
	bgTrees.setGraphicSize(Std.int(widShit * 1.4));
	fgTrees.setGraphicSize(Std.int(widShit * 0.8));
	treeLeaves.setGraphicSize(widShit);
	

	fgTrees.updateHitbox();
	bgSky.updateHitbox();
	bgSchool.updateHitbox();
	bgStreet.updateHitbox();
	bgTrees.updateHitbox();
	treeLeaves.updateHitbox();

    var bgGirls = new BackgroundGirls(-100, 190);
    bgGirls.animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 12, false);
	bgGirls.animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 12, false);
	bgGirls.scrollFactor.set(0.9, 0.9);

	if (PlayState.SONG.song.toLowerCase() == 'roses' && Settings.get("distractions")) { 
        bgGirls.getScared();
        bgGirls.animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 12, false);
	    bgGirls.animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 12, false);
    }

	bgGirls.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
	bgGirls.updateHitbox();
	if (Settings.get("distractions")) stage.add(bgGirls);
    stage.publicSprites["bgGirls"] = bgGirls;
}

function reposCharacters() {
	PlayState.boyfriend.x += 200;
	PlayState.boyfriend.y += 220;
	PlayState.gf.x += 180;
	PlayState.gf.y += 300;
	PlayState.boyfriend.displaceData.camX = -200;
	PlayState.boyfriend.displaceData.camY = -200;
}

function beatHit(beat) {
    if (Settings.get("distractions")) stage.publicSprites["bgGirls"].dance();
}
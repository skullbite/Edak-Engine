package states;

import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import sprites.Character;

class AnimationDebug extends MusicBeatState {
	var target:String;
	var char:Character;
	var camDot:FlxSprite;
	var anims:FlxTypedGroup<FlxText>;
	var buttons:FlxTypedGroup<FlxSpriteButton>;
	var cameraDisplaceButton:FlxSpriteButton;
	var camDis:FlxText;
	var resetButton:FlxSpriteButton;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isPlayer:Bool;
	var camFocused:Bool = false;
	public function new(awesomeChar:String, isPlayer:Bool) {
		super();
		target = awesomeChar;
		this.isPlayer = isPlayer;
	}

	override public function create() {
		FlxG.sound.music.stop();
		FlxG.mouse.visible = true;
		var bg = new FlxSprite().loadGraphic(Paths.image('menuBGs/menuDesat'));
		bg.color = 0x5C5C5C;
		add(bg);

		char = new Character(0, 0, target, isPlayer);
		char.x += char.displaceData.x;
		char.y += char.displaceData.y;
		char.debugMode = true;
		char.screenCenter();
		add(char);

		var midpoint = char.getGraphicMidpoint();
		var xOff = !isPlayer ? 150 : -100;
		camDot = new FlxSprite().makeGraphic(10, 10);
		camDot.screenCenter();
		camDot.setPosition(midpoint.x + xOff + char.displaceData.camX, midpoint.y - 100 + char.displaceData.camY);
		add(camDot);

		anims = new FlxTypedGroup();
		add(anims);
		buttons = new FlxTypedGroup();
		add(buttons);


		var iHateMapLoops = 0;
		for (k => v in char.animOffsets) {
			// if (!char.animation.exists(k)) continue;
			animList.push(k);
			var swagTxt = new FlxText(110, 20 + (iHateMapLoops * 25));
			swagTxt.text = Std.string(v);
			swagTxt.size = 20;
			swagTxt.borderStyle = OUTLINE;
			swagTxt.borderSize = 2;
			swagTxt.ID = iHateMapLoops;
			anims.add(swagTxt);

			var button = new FlxSpriteButton(20, 25 + (iHateMapLoops * 25), null, () -> switchAnims(swagTxt.ID, true));
			button.ID = iHateMapLoops;
			button.createTextLabel(k);
			buttons.add(button);

			/*var squareButton = new FlxSprite(20, 20 + (iHateMapLoops * 25)).makeGraphic(10, 10);
			mouseManager.add(squareButton, f -> switchAnims(swagTxt.ID, true));*/
			
			iHateMapLoops++;
		}

		cameraDisplaceButton = new FlxSpriteButton(1075, 25, null, () -> {
			camFocused = true;
			switchAnims(cameraDisplaceButton.ID, true);
		});
		cameraDisplaceButton.createTextLabel("Camera Displace");
		cameraDisplaceButton.ID = buttons.length;
		buttons.add(cameraDisplaceButton);

		camDis = new FlxText(FlxG.width - 115, 20);
		camDis.ID = anims.length;
		camDis.text = '[${char.displaceData.camX},${char.displaceData.camY}]';
		camDis.size = 20;
		camDis.borderStyle = OUTLINE;
		camDis.borderSize = 2;
		anims.add(camDis);

		switchAnims();
		super.create();
	}

	function switchAnims(change:Int=0, ?jump:Bool=false) {
		if (jump) {
			if (change == curAnim) return;
			curAnim = change;
		}
		else {
			curAnim += change;

		    if (curAnim >= animList.length)
		    	curAnim = 0;
		    if (curAnim < 0)
		    	curAnim = animList.length - 1;
		}

		if (curAnim != cameraDisplaceButton.ID) camFocused = false;
		if (camFocused) {
			camDot.color = FlxColor.CYAN;
		}
		else {
			camDot.color = FlxColor.WHITE;
			char.playAnim(animList[curAnim], true);
		}

		for (x in buttons) {
			if (x.ID == curAnim) {
				x.color = FlxColor.CYAN;
			}
			else x.color = FlxColor.WHITE;
		}

		for (x in anims) {
			if (x.ID == curAnim) {
				x.color = FlxColor.CYAN;
			}
			else x.color = FlxColor.WHITE;
		}
		
	}

	function editCam(changeVal:Int=0, onX:Bool=true) {
		changeVal *= -1;
		if (FlxG.keys.pressed.SHIFT) changeVal *= 10;
		if (onX) char.displaceData.camX += changeVal;
		else char.displaceData.camY += changeVal;
		var midpoint = char.getGraphicMidpoint();
		var xOff = !isPlayer ? 150 : -100;
		camDot.screenCenter();
		camDot.setPosition(midpoint.x + xOff + char.displaceData.camX, midpoint.y - 100 + char.displaceData.camY);
		camDis.text = '[${char.displaceData.camX},${char.displaceData.camY}]';
	}

	function changeText(changeVal:Int=0, onX:Bool=true) {
		if (camFocused) return;
		if (FlxG.keys.pressed.SHIFT) changeVal *= 10;
		char.animOffsets[animList[curAnim]][onX ? 0 : 1] += changeVal;
		char.playAnim(animList[curAnim], true);
		anims.members[curAnim].text = '${char.animOffsets[animList[curAnim]]}';
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.DOWN) (camFocused ? editCam : changeText)(-1, false);
		if (FlxG.keys.justPressed.RIGHT) (camFocused ? editCam : changeText)(-1);
		if (FlxG.keys.justPressed.UP) (camFocused ? editCam : changeText)(1, false);
		if (FlxG.keys.justPressed.LEFT) (camFocused ? editCam : changeText)(1);
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.mouse.visible = false;
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.SPACE) char.playAnim(animList[curAnim], true);	
		
		if (FlxG.keys.justPressed.W) switchAnims(-1);
		if (FlxG.keys.justPressed.S) switchAnims(1);
		if (FlxG.keys.justPressed.A) FlxG.camera.zoom -= .1;
		if (FlxG.keys.justPressed.D) FlxG.camera.zoom += .1;
	}

}
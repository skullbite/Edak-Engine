package;

import hstuff.HVars;
import hstuff.CallbackScript;
import sys.FileSystem;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

typedef SwagConfig = {
	?barColor:Int,
	?iconName:String,
	?deadData: {
		?char:String,
		?sound:String,
		?music:String,
		?end:String,
		?bpm:Int
	}
}

class Character extends FrogSprite
{
	public static var directions = ["LEFT", "DOWN", "UP", "RIGHT"];
	public var debugMode:Bool = false;
	public var barColor:String = "0xe76aca";
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var iconName(get, default):String;
	public var singTime:Float = 4;
	function get_iconName() {
		if (charScript != null && charScript.exists(ICON)) return charScript.exec(ICON, []);
		return curCharacter;
	}
	
	// thx gabi
	public var deadData:{char:String, sound:String, music:String, end:String, bpm:Int} = {
		char: "bf",
		sound: "gameover/normal/fnf_loss_sfx",
		music: "ingame/normal/gameOver",
		end: "ingame/normal/gameOverEnd",
		bpm: 100
	};

	public var holdTimer:Float = 0;
	// -1 so if it's not set to anything else, the bop speed gets automatically set
	public var bopSpeed:Int = -1;
	public var stopAnims = false;
	public var stopSinging = false;
	public var stopDancing = false;
	var charScript:Null<CallbackScript> = null;
	public var displaceData = {
		x: 0,
		y: 0,
		camX: 0,
		camY: 0
	};

	public static function fetchIcon(name:String) {
		if (FileSystem.exists(Paths.getPath('characters/$name/init.hxs'))) {
			var script:CallbackScript = new CallbackScript(Paths.getPath('characters/$name/init.hxs'), '', {});
			if (script.exists(ICON)) return script.exec(ICON, []);
			return name;
		}
		return name;
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);
		curCharacter = character;
		this.isPlayer = isPlayer;
		
		switch (curCharacter)
		{
			default:
				if (FileSystem.exists(Paths.getPath('characters/$curCharacter/init.hxs'))) {
					try {
						charScript = new CallbackScript(Paths.getPath('characters/$curCharacter/init.hxs'), 'Character:$curCharacter', {
							animation: animation,
							addOffset: addOffset,
							addAnim: this.addAnim,
							setGraphicSize: setGraphicSize,
							scale: scale,
							updateHitbox: updateHitbox,
							playAnim: playAnim,
							char: this,
							Paths: new CustomPaths(curCharacter, "characters"),
							_Paths: Paths
						});
						charScript.exec(CREATE, []);
					}
					catch (e) {
						charScript = null;
					    trace('Failed to load $curCharacter from hscript: ${e.message}');
						loadBfInstead();
					}
				}
				else loadBfInstead();
		}

		dance();

		if (bopSpeed == -1) {
			if (animation.exists("danceLeft") && animation.exists("danceRight")) bopSpeed = 1;
			else bopSpeed = 2;
		}

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}

		if (charScript != null && charScript.exists(CREATE_POST)) charScript.exec(CREATE_POST, []);
	}

	override function update(elapsed:Float)
	{
		if (!active) destroy();
		if (!curCharacter.startsWith('bf'))
		{
			if (curAnim == null) return;
			if (curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (holdTimer >= Conductor.stepCrochet * singTime * 0.0011)
			{
				dance(true);
				holdTimer = 0;
			}
		}

		super.update(elapsed);

		if (charScript != null && charScript.exists(UPDATE)) {
			charScript.exec(UPDATE, [elapsed]);
			return;
		}

		if (curAnim == null) return;

		if (curAnim.finished && animation.exists('${curAnim.name}Loop')) playAnim('${curAnim.name}Loop', true);

		switch (curCharacter)
		{
			case 'gf':
				if (curAnim?.name == 'hairFall' && curAnim?.finished)
					playAnim('danceRight');
		}
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(force = false)
	{
		if (debugMode) return;
		if (animation.curAnim?.name.contains("sing") && !curAnim?.finished && !force) return;
		if (charScript != null && charScript.exists(DANCE)) {
			charScript.exec(DANCE, []);
			return;
		}
		
		if (animation.exists('danceLeft') && animation.exists('danceRight')) {
			danced = !danced;
			playAnim(danced ? "danceRight" : "danceLeft", force);
		}
		else playAnim("idle", force);
	}

	// skibbidy beep po
	// (in case there's an issue with hscript)
	function loadBfInstead() {
		curCharacter = "bf";
		frames = FlxAtlasFrames.fromSparrow(Paths.getPath('bf/BOYFRIEND.png', 'characters'), Paths.getPath('bf/BOYFRIEND.xml', 'characters'));
		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		animation.addByPrefix('hey', 'BF HEY', 24, false);

		animation.addByPrefix('firstDeath', "BF dies", 24, false);
		animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
		animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

		animation.addByPrefix('scared', 'BF idle shaking', 24);

		addOffset('idle', -5);
		addOffset("singUP", -29, 27);
		addOffset("singRIGHT", -38, -7);
		addOffset("singLEFT", 12, -6);
		addOffset("singDOWN", -10, -50);
		addOffset("singUPmiss", -29, 27);
		addOffset("singRIGHTmiss", -30, 21);
		addOffset("singLEFTmiss", 12, 24);
		addOffset("singDOWNmiss", -11, -19);
		addOffset("hey", 7, 4);
		addOffset('firstDeath', 37, 11);
		addOffset('deathLoop', 37, 5);
		addOffset('deathConfirm', 37, 69);
		addOffset('scared', -4);

		playAnim('idle');

	    flipX = true;
	}

	override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (stopAnims) return;
		if (stopDancing && (AnimName.contains("dance") || AnimName == "idle")) return;
		if (stopSinging && AnimName.contains("sing")) return;
	
		super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}
}
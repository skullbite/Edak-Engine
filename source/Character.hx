package;

import hstuff.HCharacter;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var barColor:String = "0xe76aca";

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var bopSpeed:Int = 2;
	public var stopAnims = false;
	public var stopSinging = false;
	public var stopDancing = false;
	var CharScript:Null<HCharacter> = null;
	public var displaceData = {
		x: 0.0,
		y: 0.0,
		camX: 0.0,
		camY: 0.0
	};

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		
		antialiasing = true;

		switch (curCharacter)
		{
			default:
				if (FileSystem.exists('assets/characters/$curCharacter/init.hx')) {
					// var charCode = File.getContent('assets/characters/$curCharacter/init.hx');
					try {
						CharScript = new HCharacter(this, 'assets/characters/$curCharacter/init.hx');
						CharScript.exec("create", []);
					}
					catch (e) {
						CharScript = null;
						trace('Failed to load $curCharacter from hscript: ${e.message}');
						loadBfInstead();
					}
				}
				else loadBfInstead();

		}

		dance();

		if (animation.exists("danceLeft") && animation.exists("danceRight")) bopSpeed = 1;

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
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		super.update(elapsed);

		if (CharScript != null && CharScript.exists("update")) {
			CharScript.exec("update", [elapsed]);
			return;
		}

		if (animation.curAnim.finished && animation.getByName('${animation.curAnim.name}Loop') != null) playAnim('${animation.curAnim.name}Loop', true);

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (CharScript != null && CharScript.exists("dance")) {
			CharScript.exec("dance", []);
			return;
		}
		if (!debugMode)
		{
			if (!animation.curAnim.name.startsWith('hair')) {
				if (animation.exists('danceLeft') && animation.exists('danceRight')) {
					danced = !danced;
					playAnim(danced ? "danceRight" : "danceLeft");
				}
				else playAnim("idle", true);
			}
			/*switch (curCharacter)
			{
				case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle', true);

			}*/
		}
	}

	// skibbidy beep po
	// (in case there's an issue with hscript)
	function loadBfInstead() {
		curCharacter = "bf";
		frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
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

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (stopAnims) return;
		if (stopDancing && (AnimName.contains("dance") || AnimName == "idle")) return;
		if (stopSinging && AnimName.contains("sing")) return;
	
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

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

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

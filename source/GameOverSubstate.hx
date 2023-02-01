package;

import hstuff.HVars;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	public static var instance:GameOverSubstate;
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var deathSound:String;
	var deathMusic:String;
	var endSound:String;

	public function new(x:Float, y:Float)
	{
		instance = this;
		var daBf:String = PlayState.boyfriend.deadData.char;
		var daBpm:Int = PlayState.boyfriend.deadData.bpm;
		deathSound = PlayState.boyfriend.deadData.sound;
		deathMusic = PlayState.boyfriend.deadData.music;
		endSound = PlayState.boyfriend.deadData.end;

		super();

		Conductor.songPosition = 0;

		var gameOverRets = PlayState.HFunk.doDaCallback("onGameOverStart", []);
		if (gameOverRets.contains(HVars.STOP)) return;

		// PlayState.HFunk.doDaCallback("onGameOver", []);

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound(deathSound));
		Conductor.changeBPM(daBpm);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gameOverRets = PlayState.HFunk.doDaCallback("onGameOverUpdate", [elapsed]);
		if (gameOverRets.contains(HVars.STOP)) return;

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music(deathMusic));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			var gameOverRets = PlayState.HFunk.doDaCallback("onGameOverEnd", []);
		    if (gameOverRets.contains(HVars.STOP)) return;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSound));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}

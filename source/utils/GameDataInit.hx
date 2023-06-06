package utils;

import flixel.system.debug.log.LogStyle;
import states.PlayState;
import flixel.FlxG;
import lime.app.Application;
import utils.Discord.DiscordClient;
import states.MainMenuState;

class GameDataInit {
	public static var cachedSongs = [
		'menu/freaky', 
		'ingame/breakfast', 
		'ingame/normal/gameOver', 
		'ingame/normal/gameOverEnd',
		'ingame/weeb/gameOver-pixel', 
		'ingame/weeb/gameOverEnd-pixel'
	];

    public static function lol() {
        trace('EDAK ENGINE v${MainMenuState.engineVer}');
        for (x in cachedSongs) Paths.music(x);

		Settings.init();
        PlayerSettings.init();
        Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		#if desktop
		DiscordClient.initialize();
		Application.current.onExit.add(_ -> DiscordClient.shutdown());
		#end

		FlxG.debugger.setLayout(MICRO);
		FlxG.console.registerClass(Paths);
		FlxG.console.registerClass(PlayState);
		FlxG.console.autoPause = false;

		LogStyle.WARNING.openConsole = false;
		LogStyle.WARNING.errorSound = null;
    }
}
package states;

import flixel.util.FlxColor;
import groups.Strumline;
import groups.Stage;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import utils.CoolUtil;

enum BackgroundTypes {
    NONE;
    MENU_BG;
    STAGE;
}

typedef InputTypes = {
    holds: Array<Bool>,
    presses: Array<Bool>
}

// guhhhhhh this essentially the bare minimum for the playstate
// that's just the basic ui
// so if i need to recreate the playstate for a different state, i just extend this
class PlayBase extends MusicBeatState {
    // UI
    public var cpuStrums:Strumline;
    public var playerStrums:Strumline;
    public var scoreTxt:FlxText;

    // CAMERAS
    public var bopSpeed:Int = 4;
    public var camGame:FlxCamera;
    public var camHUD:FlxCamera;
    public var camTop:FlxCamera;

    // INPUTS
    public var inputs:InputTypes = {
        holds: CoolUtil.sillyArray(false, 4),
        presses: CoolUtil.sillyArray(false, 4)
    };
    public var disableInput:Bool = false;

    // BG
    public var bgType:BackgroundTypes = MENU_BG;
    public var stage:Null<Stage>;

    override function create() {
        super.create();

        camGame = new FlxCamera();
        FlxG.cameras.reset(camGame);
        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);
        camTop = new FlxCamera();
        camTop.bgColor.alpha = 0;
        FlxG.cameras.add(camTop);

        FlxCamera.defaultCameras = [camGame];

        switch (bgType) {
            case NONE: null;
            case MENU_BG:
                var bg = new FlxSprite().loadGraphic(Paths.image('menuBGs/${Settings.get("darkBg") ?  "menuBlack" : "menuDesat"}'));
                bg.color = FlxG.random.color(FlxColor.GRAY);
                add(bg);
            case STAGE:
                stage = new Stage();
                add(stage);
        }


        cpuStrums = new Strumline();
        cpuStrums.cameras = [camHUD];
        cpuStrums.doIntro();
        add(cpuStrums);

        playerStrums = new Strumline(false);
        playerStrums.cameras = [camHUD];
        playerStrums.doIntro();
        add(playerStrums);
        
        scoreTxt = new FlxText(0, FlxG.height - 40);
        scoreTxt.cameras = [camHUD];
        scoreTxt.font = Paths.font("vcr.ttf");
        scoreTxt.size = 20;
        scoreTxt.borderStyle = OUTLINE;
        scoreTxt.borderSize = 2;
        scoreTxt.text = "~ PlayBase ~";
        scoreTxt.screenCenter(X);
        add(scoreTxt);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        handleInput();
    }

    function handleInput() {
        var botplay = Settings.get("botplay");
        if (botplay || disableInput) inputs = {
            holds: CoolUtil.sillyArray(false, 4),
            presses: CoolUtil.sillyArray(false, 4)
        };
        else inputs = {
            holds: [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT],
            presses: [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P]
        };

        for (i in 0...playerStrums.length) {
            var strum = playerStrums.members[i];
            if (inputs.presses[i] && strum.animation.curAnim.name != 'confirm') strum.playAnim("pressed");
            else if (!inputs.holds[i]) strum.playAnim("static");
        }
    }
}
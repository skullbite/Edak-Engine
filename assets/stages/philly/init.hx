package;
// i had multiple aneurysms porting this
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;

var trainMoving = false;
var trainCooldown = 0;
var curLight = 0;
var trainFrameTiming = 0.0;
var startedMoving = false;
var trainFinishing = false;
var trainCars = 8;
var trainSound:FlxSound;

function create() {
	stage.cameraDisplace.x = 400;
	stage.cameraDisplace.y = -50;
    importLib("flixel.group.FlxTypedGroup");
    var bg = new FlxSprite(-100).loadGraphic(Paths.image('sky'));
	bg.scrollFactor.set(0.1, 0.1);
	stage.add(bg);

	var city = new FlxSprite(-10).loadGraphic(Paths.image('city'));
	city.scrollFactor.set(0.3, 0.3);
	city.scale.set(0.85, 0.85);
	city.updateHitbox();
	stage.add(city);


	var phillyCityLights = new FlxTypedGroup();
	if (Settings.get("distractions")) stage.add(phillyCityLights);
    stage.publicSprites["phillyCityLights"] = phillyCityLights;


	for (i in 0...5)
	{
			var light = new FlxSprite(city.x).loadGraphic(Paths.image('win' + i));
			light.scrollFactor.set(0.3, 0.3);
			light.visible = false;
			light.scale.set(0.85, 0.85);
			light.updateHitbox();
			light.antialiasing = true;
			stage.publicSprites["phillyCityLights"].add(light);

	}

    var streetBehind = new FlxSprite(-40, 50).loadGraphic(Paths.image('behindTrain'));
    stage.add(streetBehind);

	var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('train'));
	if (Settings.get("distractions")) stage.add(phillyTrain);
    stage.publicSprites["phillyTrain"] = phillyTrain;


	trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', true));
	FlxG.sound.list.add(trainSound);

	// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

	var street = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('street'));
    
	stage.add(street);
}

function update(elapsed) {
    if (trainMoving) {
		trainFrameTiming += elapsed;

		if (trainFrameTiming >= 1 / 24)
		{
			updateTrainPos();
		    trainFrameTiming = 0;
		}
	}
    
}

function beatHit(beat) {
    if (Settings.get("distractions")) {
        if (!trainMoving)
            trainCooldown += 1;

        if (beat % 4 == 0)
        {
            stage.publicSprites["phillyCityLights"].forEach(light -> light.visible = false);
			
			var lastLight = curLight;

            while (curLight == lastLight) curLight = FlxG.random.int(0, stage.publicSprites["phillyCityLights"].length - 1);

            stage.publicSprites["phillyCityLights"].members[curLight].visible = true;
        }
            // phillyCityLights.members[curLight].alpha = 1;
        if (beat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
        {
            trainCooldown = FlxG.random.int(-4, 0);
            trainStart();
        }
    }
}

function trainStart() {
	trainMoving = true;
	if (!trainSound.playing) trainSound.play(true);
}

function updateTrainPos() {
	if(Settings.get("distractions")){
		if (trainSound.time >= 4700 && trainSound.time <= 4900)
			{
				startedMoving = true;
				PlayState.gf.playAnim('hairBlow');
			}
            var phillyTrain = stage.publicSprites["phillyTrain"];

			if (startedMoving)
			{
				phillyTrain.x -= 400;
	
				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;
	
					if (trainCars <= 0)
                        trainFinishing = true;
				}
	
				if (phillyTrain.x < -4000 && trainFinishing) trainReset();
					
			}
	}
}

function trainReset() {
	PlayState.gf.playAnim('hairFall');
    var phillyTrain = stage.publicSprites["phillyTrain"];
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	// trainSound.stop();
	// trainSound.time = 0;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

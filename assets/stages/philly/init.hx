// i had multiple aneurysms porting this
function create() {
	stage.cameraDisplace.x = 400;
	stage.cameraDisplace.y = -50;
    importLib("flixel.system.FlxSound");
    importLib("flixel.group.FlxTypedGroup");
    vars["trainMoving"] = false;
    vars["trainCooldown"] = 0;
    vars["curLight"] = 0;
    vars["trainFrameTiming"] = 0.0;
    vars["startedMoving"] = false;
    vars["trainFinishing"] = false;
    vars["trainCars"] = 8;
    var bg = new FlxSprite(-100).loadGraphic(Paths.image('sky'));
	bg.scrollFactor.set(0.1, 0.1);
	stage.add(bg);

	var city = new FlxSprite(-10).loadGraphic(Paths.image('city'));
	city.scrollFactor.set(0.3, 0.3);
	city.scale.set(0.85, 0.85);
	city.updateHitbox();
	stage.add(city);
   

	var phillyCityLights = new FlxTypedGroup();
	if(FlxG.save.data.distractions) stage.add(phillyCityLights);
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

	phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('train'));
	if (FlxG.save.data.distractions) stage.add(phillyTrain);
    stage.publicSprites["phillyTrain"] = phillyTrain;


	var trainSound = new FlxSound().loadEmbedded(_Paths.sound('train_passes','week3'));
	FlxG.sound.list.add(trainSound);
    vars["trainSound"] = trainSound;

	// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

	var street = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('street'));
    
	stage.add(street);
}

function update(elapsed) {
    if (vars["trainMoving"]) {
		vars["trainFrameTiming"] += elapsed;

		if (vars["trainFrameTiming"] >= 1 / 24)
		{
			updateTrainPos();
			vars["trainFrameTiming"] = 0;
		}
	}
    
}

function beatHit(beat) {
    if(FlxG.save.data.distractions){
        if (!vars["trainMoving"])
            vars["trainCooldown"] += 1;

        if (beat % 4 == 0)
        {
            stage.publicSprites["phillyCityLights"].forEach(function(light:FlxSprite)
            {
                light.visible = false;
            });
			
			var lastLight = vars["curLight"];

            while (vars["curLight"] == lastLight) vars["curLight"] = FlxG.random.int(0, stage.publicSprites["phillyCityLights"].length - 1);

            stage.publicSprites["phillyCityLights"].members[vars["curLight"]].visible = true;
        }
            // phillyCityLights.members[curLight].alpha = 1;
        if (beat % 8 == 4 && FlxG.random.bool(30) && !vars["trainMoving"] && vars["trainCooldown"] > 8)
        {
            trainCooldown = FlxG.random.int(-4, 0);
            trainStart();
        }
    }
}

function trainStart() {
	vars["trainMoving"] = true;
	if (!vars["trainSound"].playing) vars["trainSound"].play(true);
}

function updateTrainPos() {
	if(FlxG.save.data.distractions){
		if (vars["trainSound"].time >= 4700)
			{
				vars["startedMoving"] = true;
				PlayState.gf.playAnim('hairBlow');
			}
            var phillyTrain = stage.publicSprites["phillyTrain"];

			if (vars["startedMoving"])
			{
				phillyTrain.x -= 400;
	
				if (phillyTrain.x < -2000 && !vars["trainFinishing"])
				{
					phillyTrain.x = -1150;
					vars["trainCars"] -= 1;
	
					if (vars["trainCars"] <= 0)
                        vars["trainFinishing"] = true;
				}
	
				if (phillyTrain.x < -4000 && vars["trainFinishing"]) trainReset();
					
			}
	}
}

function trainReset() {
	PlayState.gf.playAnim('hairFall');
    var phillyTrain = stage.publicSprites["phillyTrain"];
	phillyTrain.x = FlxG.width + 200;
	vars["trainMoving"] = false;
	// trainSound.stop();
	// trainSound.time = 0;
	vars["trainCars"] = 8;
	vars["trainFinishing"] = false;
	vars["startedMoving"] = false;
}

package;

import yaml.Parser.ParserOptions;
import yaml.util.ObjectMap.AnyObjectMap;
import sys.io.File;
import yaml.Yaml;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

typedef WeekData = {
	name:String,
	songs:Array<String>,
	icons:Array<String>,
	colors:Array<Int>,
	?hiddenInStory:Bool,
	difficulties:Array<String>,
	?storyDad:String,
	?storyBf:String,
	?storyGf:String
}


typedef DifficultyData = {
	?animName:String,
	?offsets:Array<Int>,
	color:Int,
	?loadsDifferentSong:Bool
}

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<WeekData> = [];
	var difficultyData:Map<String, DifficultyData> = [];
	var curDifficulty:Int = 1;
	var curDifficultyArray = ["Easy", "Normal", "Hard"];

	public static var weekUnlocked:Array<Bool> = [];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var weekDataStuff = CoolUtil.coolTextFile(Paths.txt("weeks/order"));

		for (week in 0...weekDataStuff.length) {
			var coolWeekData:WeekData = Yaml.read(Paths.weekData(weekDataStuff[week]), new ParserOptions().useObjects());
			if (coolWeekData.hiddenInStory != null && coolWeekData.hiddenInStory) continue;
			weekData.push(coolWeekData);
			// to do: reimplement week lock
			weekUnlocked.push(true);
		}

		for (x in FileSystem.readDirectory("assets/data/difficulties").filter(d -> d.endsWith(".yaml"))) {
			var awesomeDifficultyStuff:DifficultyData = Yaml.read(Paths.difficulty(x.split(".").shift()), new ParserOptions().useObjects());
			difficultyData.set(x.split(".").shift(), awesomeDifficultyStuff);
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('menu/freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('storyMenu/campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(weekData[curWeek].storyDad, 0, 100));
		grpWeekCharacters.add(new MenuCharacter(weekData[curWeek].storyBf, 450, 25));
		grpWeekCharacters.add(new MenuCharacter(weekData[curWeek].storyGf, 850, 100));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		/*sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');*/
		for (k => v in difficultyData) sprDifficulty.animation.addByPrefix(k.toLowerCase(), v.animName);

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		changeDifficulty();

		trace("Line 150");

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekData[curWeek].name.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('menu/confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				// grpWeekCharacters.members[1].animation.play('bfConfirm');
				grpWeekCharacters.forEach(d -> {
					if (d.animation.exists("confirm")) d.animation.play("confirm");
				});
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek].songs;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			PlayState.SONG = Song.loadFromJson(curDifficultyArray[curDifficulty].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyDifficulty = curDifficultyArray[curDifficulty].toLowerCase();
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = curDifficultyArray.length-1;
		if (curDifficulty >= curDifficultyArray.length)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		if (weekData[curWeek].difficulties != curDifficultyArray) {
			curDifficultyArray = weekData[curWeek].difficulties;
			if (curDifficultyArray.length <= 2) curDifficulty = 0;
		}
		

		leftArrow.visible = curDifficultyArray.length != 1;
		rightArrow.visible = curDifficultyArray.length != 1;

		var fuck = difficultyData[curDifficultyArray[curDifficulty].toLowerCase()];
		sprDifficulty.animation.play(fuck.animName.toLowerCase());
		sprDifficulty.offset.x = fuck.offsets[0];
		sprDifficulty.offset.y = fuck.offsets[1];

		if (curDifficultyArray.length == 1) return;

		/*switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}*/

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficultyArray[curDifficulty]).score;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficultyArray[curDifficulty]).score;
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		
		if (curDifficultyArray != weekData[curWeek].difficulties) {
			curDifficultyArray = weekData[curWeek].difficulties;
			var lastDiff = curDifficulty;
			if (curDifficultyArray.length <= 2) curDifficulty = 0;
		    else curDifficulty = 1;
		    if (lastDiff != curDifficulty) changeDifficulty();
		}

		var bullShit:Int = 0;
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('menu/scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekData[curWeek].storyDad);
		grpWeekCharacters.members[1].setCharacter(weekData[curWeek].storyBf);
		grpWeekCharacters.members[2].setCharacter(weekData[curWeek].storyGf);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData[curWeek].songs;

		for (i in stringThing)
			txtTracklist.text += "\n" + i.replace("-", " ");

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficultyArray[curDifficulty]).score;
		#end
	}
}
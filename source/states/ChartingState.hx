package states;

import flixel.math.FlxRect;
import hstuff.CallbackScript;
import flixel.addons.ui.FlxUIButton;
import sprites.Character.SwagConfig;
import yaml.Parser.ParserOptions;
import yaml.Yaml;
import sys.FileSystem;
import openfl.filesystem.File;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import utils.Conductor.BPMChangeEvent;
import utils.Section.SwagSection;
import utils.Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import utils.HelperFunctions;
import utils.CoolUtil;
import utils.Conductor;
import sprites.Note;
import sprites.Character;
import sprites.Boyfriend;
import sprites.HealthIcon;
import utils.Song;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	public var playClaps:Bool = false;
	var playBfHits:Bool = false;
	var playDadHits:Bool = false;

	public var snap:Int = 1;

	var UI_box:FlxUITabMenu;
	var otherUI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	// var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var bg:FlxSprite;
	var strumLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var writingNotesText:FlxText;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedEvents:FlxTypedGroup<EventText>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	var diffStuff:FlxInputText;
	var currentDiff:String;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;
	var curNoteType:String = "Normal";
	var noteTypes:Array<String> = ["Normal"];

	var curEventType:String = "";
	var curEventsIndex:Int = 0;
	var curNote:Null<Note> = null;
	// var selectedNoteTween:FlxTween;

	var tempBpm:Float = 0;
	public var gridBlackLine:FlxSprite;
	public var anotherGridLine:FlxSprite;
	public var wowAnotherGridLine:FlxSprite;
	public var amazingAnotherGridLine:FlxSprite;
	var playingMusic:Bool = false;
	var vocals:FlxSound;

	var inputFields:Array<FlxUIInputText> = [];
	var anyFieldsFocused(get, null):Bool;
	function get_anyFieldsFocused() return inputFields.map(d -> d.hasFocus).contains(true);

	var player2:Character = new Character(0,0, "dad");
	var player1:Boyfriend = new Boyfriend(0,0, "bf");

	var iconP1:String;
	var iconP2:String;
	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	private var lastNote:Note;
	// var claps:Array<Note> = [];
	var bfHits:Array<Note> = [];
	var dadHits:Array<Note> = [];

	public var snapText:FlxText;

	override function create()
	{
		chartingMode = true;
		Paths.getSound('charting/SNAP');
		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				// events: [],
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				stage: 'stage',
				speed: 1
			};
		}
		currentDiff = PlayState.difficulty;

		bg = new FlxSprite(-100).loadGraphic(Paths.image('menuBGs/menuBlack'));
		bg.alpha = .8;
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 16);
		add(gridBG);

		var blackBorder:FlxSprite = new FlxSprite(60,10).makeGraphic(120,100,FlxColor.BLACK);
		blackBorder.scrollFactor.set();
		blackBorder.alpha = 0.3;

		snapText = new FlxText(60,10,0,"Snap: 1/" + snap + " (Press Control to unsnap the cursor)\nAdd Notes: 1-8 (or click)\n", 14);
		snapText.scrollFactor.set();

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 1.8).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		anotherGridLine = new FlxSprite(gridBG.x + gridBG.width / 8.9).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(anotherGridLine);

		wowAnotherGridLine = new FlxSprite(gridBG.x).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		wowAnotherGridLine.x -= wowAnotherGridLine.width;
		add(wowAnotherGridLine);

		amazingAnotherGridLine = new FlxSprite(gridBG.x + gridBG.width).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(amazingAnotherGridLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedEvents = new FlxTypedGroup<EventText>();

		FlxG.mouse.visible = true;
		FlxG.save.bind('edak', 'skullbite');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		iconP1 = Character.fetchIcon(_song.player1);
		iconP2 = Character.fetchIcon(_song.player2);

		leftIcon = new HealthIcon(iconP1);
		rightIcon = new HealthIcon(iconP2);

		leftIcon.setGraphicSize(0, 70);
		rightIcon.setGraphicSize(0, 70);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(45, -115);
		rightIcon.setPosition((gridBG.width / 2) + 25, -115);

		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		bpmTxt = new FlxText(1025, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);

		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'},
			{name: "Events", label: 'Events'},
			{name: "Assets", label: 'Assets'}
		];
		

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = (FlxG.width / 2) + 80;
		UI_box.y = 20;

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);

		add(blackBorder);
		add(snapText);

		var utilTabs = [
			{name: "utils", label: "Charting Utils"}
		];
		

		otherUI_box = new FlxUITabMenu(null, utilTabs, true);

		otherUI_box.resize(300, 200);
		otherUI_box.x = (FlxG.width / 2) + 80;
		otherUI_box.y = UI_box.width + 160;
		otherUI_box.scrollFactor.set();

		add(otherUI_box);
		add(UI_box);

		addUtilUI();

		super.create();
	}

	var check_bfHits:FlxUICheckBox;
	var check_dadHits:FlxUICheckBox;
	var check_muteInst:FlxUICheckBox;
	var check_muteVocals:FlxUICheckBox;
	function addUtilUI() {
		check_bfHits = new FlxUICheckBox(10, 10, null, null, "Play BF Hitsounds");
		check_bfHits.checked = playBfHits;
		check_bfHits.callback = () -> playBfHits = check_bfHits.checked;

		check_dadHits = new FlxUICheckBox(10, 30, null, null, "Play Dad Hitsounds");
		check_dadHits.checked = playDadHits;
		check_dadHits.callback = () -> playDadHits = check_dadHits.checked;

		/*check_muteInst = new FlxUICheckBox(10, 50, null, null, "Mute Instrumental");
		check_muteInst.checked = FlxG.sound.music.volume == 0;
		check_muteInst.callback = () -> FlxG.sound.music.volume = 0;*/

		var tab_group_util = new FlxUI(null, UI_box);
		tab_group_util.name = "utils";
		tab_group_util.add(check_bfHits);
		tab_group_util.add(check_dadHits);

		otherUI_box.addGroup(tab_group_util);
	}

	var evDrop:FlxUIDropDownMenu;
	var val1Box:FlxUIInputText;
	var val2Box:FlxUIInputText;
	var val1Title:FlxUIText;
	var val2Title:FlxUIText;
	var evPage:FlxUIText;
	var evDesc:FlxUIText;
	var back:FlxButton;
	var forward:FlxButton;
	var addB:FlxSpriteButton;
	var removeB:FlxSpriteButton;
	var eventData:Array<Array<String>> = [];
	
	function addEventUI() {
		var eventScripts:Array<String> = [];

		var songName = _song.song.toLowerCase().replace(" ", "-");
		if (Paths.songDataDir(songName).contains("events"))
			eventScripts = eventScripts.concat(FileSystem.readDirectory(Paths.getPath('songs/$songName/events')).filter(s -> s.endsWith('.hxs')).map(s -> Paths.curModDir + '/songs/$songName/events/$s'));
		#if MODS
		if (Paths.curModDir != null && FileSystem.exists(Paths.curModDir + '/events')) 
			eventScripts = eventScripts.concat(FileSystem.readDirectory(Paths.curModDir + '/events').filter(s -> s.endsWith(".hxs")).map(s -> Paths.curModDir + '/events/$s'));
		#end
		if (FileSystem.exists('assets/events')) 
			eventScripts = eventScripts.concat(FileSystem.readDirectory('assets/events').filter(s -> s.endsWith(".hxs")).map(s -> 'assets/events/$s'));


		for (x in eventScripts) {
			try {
			    var daScript = new CallbackScript(x, 'Event:$x', {
			    	name: "INVALID__",
			    	description: "N/A"
			    });
				daScript.exec(INIT, []);

				if (daScript.get("name") == "INVALID__") continue;
			    if (eventData.map(d -> d[0]).contains(daScript.get("name"))) continue;
			    eventData.push([daScript.get("name"), daScript.get("description")]);
				daScript.active = false;
			}
			catch (e) {
				trace(e.message);
				continue;
			}
		}

		var eventNames = eventData.map(d -> d[0]);
		evDrop = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(eventNames, true), data -> {
			curEventType = eventNames[Std.parseInt(data)];
			evDesc.text = eventData.filter(d -> d[0] == curEventType)[0][1];
			if (curSelectedNote == null || curSelectedNote[1] != -1) return;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == curSelectedNote[0] && i[1] % 4 == -1) {
					trace(i);
					i[2][curEventsIndex][0] = curEventType;
					trace(i);
				}
			}
	

			updateGrid();
			// if (target != null) _song.notes[curSection].sectionNotes[curEventsIndex][0] = curEventType;
		});

		val1Box = new FlxUIInputText(220, 10, 70, "");
		val1Box.callback = (s, t) -> {
			if (curSelectedNote == null || curSelectedNote[1] != -1) return;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == curSelectedNote[0] && i[1] % 4 == -1) i[2][curEventsIndex][1] = s;
			}
			updateGrid();
		}
		val1Box.visible = false;
		inputFields.push(val1Box);

		val1Title = new FlxUIText(val1Box.x - 50, val1Box.y, 0, 'Value 1: ');

		val2Box = new FlxUIInputText(220, 30, 70, "");
		val2Box.callback = (s, t) -> {
			if (curSelectedNote == null || curSelectedNote[1] != -1) return;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == curSelectedNote[0] && i[1] % 4 == -1) i[2][curEventsIndex][2] = s;
			}
			updateGrid();
		}
		val2Box.visible = false;
		inputFields.push(val2Box);

		val2Title = new FlxUIText(val1Box.x - 50, val2Box.y, 0, 'Value 2: ');

		back = new FlxButton(20, evDrop.y + 80, "<", () -> {
			if (curEventsIndex - 1 == -1) return;
			else curEventsIndex--;
			updateEventUI();
		});
		back.visible = false;

		forward = new FlxButton(back.width + 110, evDrop.y + 80, ">", () -> {
			if (curSelectedNote == null || curSelectedNote[1] != -1) return;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == curSelectedNote[0] && i[1] % 4 == -1) {
					if (curEventsIndex + 1 == i[2].length) return;
			        else curEventsIndex++;
				};
			}
			updateEventUI();
		});
		forward.visible = false;
		
		addB = new FlxSpriteButton(back.width + 110, evDrop.y + 100, null, () -> {
			if (curSelectedNote == null || curSelectedNote[1] != -1) return;
			for (i in _song.notes[curSection].sectionNotes) 
			{
				if (i[0] == curSelectedNote[0] && i[1] % 4 == -1) i[2].push([evDrop.selectedLabel, "", ""]);
			}
			updateEventUI();
			updateGrid();
		});
		addB.createTextLabel("+", null, 8, 0xFFFFFF);
		addB.color = FlxColor.GREEN;
		addB.visible = false;

		removeB = new FlxSpriteButton(back.x, evDrop.y + 100, null, () -> {
			if (curSelectedNote == null || curSelectedNote[1] != -1) return;
			for (i in _song.notes[curSection].sectionNotes) 
			{
				if (i[0] == curSelectedNote[0] && i[1] % 4 == -1) if (i[2].length > 1) i[2].splice(curEventsIndex, 1);
			}
			curEventsIndex = 0;
			updateEventUI();
			updateGrid();
		});
		removeB.createTextLabel("-", null, 8, 0xFFFFFF);
		removeB.color = FlxColor.RED;
		removeB.visible = false;

		evPage = new FlxUIText(UI_box.width / 2 - 20, addB.y - 10, 0, 'N/A');
		evPage.size = 15;

		evDesc = new FlxUIText(10, 200, 0, eventData.filter(d -> d[0] == evDrop.selectedLabel)[0][1] ?? 'N/A');
		evDesc.size = 10;

		var tab_group_events = new FlxUI(null, UI_box);
		tab_group_events.name = "Events";
		tab_group_events.add(val1Box);
		tab_group_events.add(val2Box);
		tab_group_events.add(val1Title);
		tab_group_events.add(val2Title);
		tab_group_events.add(back);
		tab_group_events.add(forward);
		tab_group_events.add(addB);
		tab_group_events.add(removeB);
		tab_group_events.add(evDrop);
		tab_group_events.add(evPage);
		tab_group_events.add(evDesc);

		UI_box.addGroup(tab_group_events);

		updateEventUI();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;
		inputFields.push(UI_songTitle);
		var UI_difficultyTitle = new FlxUIInputText(10, 25, 70, PlayState.difficulty);
		diffStuff = UI_difficultyTitle;
		inputFields.push(UI_difficultyTitle);

		var check_voices = new FlxUICheckBox(10, 40, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		/*var saveEventsButton:FlxButton = new FlxButton(saveButton.x, saveButton.y + 20, "Save Events", () -> {
			saveLevel(true);
		});*/

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		
		var restart = new FlxButton(10,140,"Reset Chart", function()
            {
                for (ii in 0..._song.notes.length)
                {
                    for (i in 0..._song.notes[ii].sectionNotes.length)
                        {
                            _song.notes[ii].sectionNotes = [];
                        }
                }
                resetSection(true);
            });
		
		var restartEvents = new FlxButton(restart.x + 70, 140, "Reset Events", () -> {
			for (i in 0..._song.notes.length) {
				for (xyz in 0..._song.notes[i].sectionNotes.length) {
					if (_song.notes[i].sectionNotes[xyz][1] == -1) _song.notes[i].sectionNotes.remove(_song.notes[i].sectionNotes[xyz]);
				}
			}
			updateGrid();
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74,65,'BPM');
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74,80,'Scroll Speed');
		
		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 95, 'Vocal Volume');
		
		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';



		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		
		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note FWD by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftNoteButton:FlxButton = new FlxButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value));
		});

		var characters:Array<String> = [];
		var gfVersions:Array<String> = [];
		var stages:Array<String> = [];

		#if MODS
		if (Paths.curModDir != null) {
			var charPath = Paths.curModDir + '/characters';
			var gfVerPath = Paths.curModDir + '/data/gfVersionList.txt';
			var stagePath = Paths.curModDir + '/stages';
			// because concat hates me
			if (FileSystem.exists(charPath)) characters = characters.concat(FileSystem.readDirectory(charPath).filter(d -> FileSystem.exists(charPath + '/$d/init.hxs')));
			if (FileSystem.exists(gfVerPath)) gfVersions = gfVersions.concat(CoolUtil.coolTextFile(gfVerPath));
			if (FileSystem.exists(stagePath)) stages = stages.concat(FileSystem.readDirectory(stagePath).filter(d -> FileSystem.exists(stagePath + '/$d/init.hxs')));
		}
		#end

		characters = characters.concat(FileSystem.readDirectory("assets/characters").filter(d -> !characters.contains(d) && FileSystem.exists('assets/characters/$d/init.hxs')));
		gfVersions = gfVersions.concat(CoolUtil.coolTextFile("assets/data/gfVersionList.txt").filter(d -> !gfVersions.contains(d)));
		stages = stages.concat(FileSystem.readDirectory("assets/stages").filter(d -> !stages.contains(d) && FileSystem.exists('assets/stages/$d/init.hxs')));
		var extChars:Array<String> = CoolUtil.coolTextFile("assets/data/characterList.txt");
		var extStages:Array<String> = CoolUtil.coolTextFile("assets/data/stageList.txt");
		if (extChars != [""]) characters = characters.concat(extChars);
		if (stages != [""]) stages = stages.concat(extStages);

		characters = characters.filter(d -> d != "");
		gfVersions = gfVersions.filter(d -> d != "");
		stages = stages.filter(d -> d != "");

		var p1In = characters.contains(_song.player1);
		var p2In = characters.contains(_song.player2);
		var gfIn = gfVersions.contains(_song.gfVersion);
		var stageIn = stages.contains(_song.stage);

		if (!p1In) characters.insert(0, '${_song.player1} (invalid)');
		if (!p2In && !characters.contains('${_song.player2} (invalid)')) characters.insert(0, '${_song.player2} (invalid)');
		if (!gfIn) gfVersions.insert(0, '${_song.gfVersion} (invalid)');
		if (!stageIn) stages.insert(0, '${_song.stage} (invalid)');




		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			if (characters[Std.parseInt(character)].contains("(invalid)")) return;
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads(true, "bf");
		});
		player1DropDown.selectedLabel = p1In ? _song.player1 : characters[characters.indexOf('${_song.player1} (invalid)')];
		player1DropDown.dropDirection = Down;

		var player1Label = new FlxText(10,80,64,'Player 1');

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			if (characters[Std.parseInt(character)].contains("(invalid)")) return;
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads(true, "dad");
		});
		player2DropDown.selectedLabel = p2In ? _song.player2 : characters[characters.indexOf('${_song.player2} (invalid)')];
		player2DropDown.dropDirection = Down;

		var player2Label = new FlxText(140,80,64,'Player 2');

		var gfVersionDropDown = new FlxUIDropDownMenu(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
			{
				if (gfVersions[Std.parseInt(gfVersion)].contains("(invalid)")) return;
				_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
			});
		gfVersionDropDown.selectedLabel = gfIn ? _song.gfVersion : gfVersions[gfVersions.indexOf('${_song.gfVersion} (invalid)')];

		var gfVersionLabel = new FlxText(10,180,64,'Girlfriend');

		var stageDropDown = new FlxUIDropDownMenu(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
			{
				if (stages[Std.parseInt(stage)].contains("(invalid)")) return;
				_song.stage = stages[Std.parseInt(stage)];
			});
		stageDropDown.selectedLabel = stageIn ? _song.stage : stages[stages.indexOf('${_song.stage} (invalid)')];
		
		var stageLabel = new FlxText(140,180,64,'Stage');

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(UI_difficultyTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		// tab_group_song.add(saveEventsButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);
        tab_group_song.add(shiftNoteDialLabel);
        tab_group_song.add(stepperShiftNoteDial);
        tab_group_song.add(shiftNoteDialLabel2);
        tab_group_song.add(stepperShiftNoteDialstep);
        tab_group_song.add(shiftNoteDialLabel3);
        tab_group_song.add(stepperShiftNoteDialms);
        tab_group_song.add(shiftNoteButton);

		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";
		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(gfVersionLabel);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(stageLabel);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);

		UI_box.addGroup(tab_group_song);
		UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174,132,'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			// trace(_song.notes[curSection].sectionNotes);
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];

				if (note[1] == -1) continue;
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
			}
			updateGrid();
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Camera Points to P1?", 100, [], () -> updateHeads());
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperNoteType:FlxUIDropDownMenu;

	var tab_group_note:FlxUI;
	
	function addNoteUI():Void
	{
		tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		writingNotesText = new FlxUIText(20,100, 0, "");
		writingNotesText.setFormat("Arial",20,FlxColor.WHITE,FlxTextAlign.LEFT,FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16 * 4);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var stepperSusLengthLabel = new FlxText(74,10,'Note Sustain Length');

		var stepperNoteTypeLabel = new FlxText(10, 50, "Note Type");
		
		try {
			noteTypes = noteTypes.concat(FileSystem.readDirectory("assets/custom-notes").filter(d -> d.endsWith(".hxs") && !noteTypes.contains(d.replace(".hxs", ""))).map(d -> d.split(".").shift()));
			#if MODS
			if (Paths.curModDir != null && FileSystem.exists(Paths.curModDir + "/custom-notes")) noteTypes = noteTypes.concat(FileSystem.readDirectory(Paths.curModDir + "/custom-notes").filter(d -> d.endsWith(".hxs")).map(d -> d.split(".").shift()));
			#end
		}
		catch (e) {}
		

		stepperNoteType = new FlxUIDropDownMenu(10, 70, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes, true), function(noteType:String):Void {
			curNoteType = noteTypes[Std.parseInt(noteType)];
		});
		stepperNoteType.name = 'note_type';

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(stepperNoteTypeLabel);
		tab_group_note.add(stepperNoteType);

		UI_box.addGroup(tab_group_note);

		/*player2 = new Character(0,gridBG.y, _song.player2);
		player1 = new Boyfriend(player2.width * 0.2,gridBG.y + player2.height, _song.player1);

		player1.y = player1.y - player1.height;

		player2.setGraphicSize(Std.int(player2.width * 0.2));
		player1.setGraphicSize(Std.int(player1.width * 0.2));

		UI_box.add(player1);
		UI_box.add(player2);*/

	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.music = FlxG.sound.load(Paths.inst(daSong, PlayState.musicPost), 0.6);


		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong, PlayState.musicPost));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		vocals.time = FlxG.sound.music.time;

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Camera Points to P1?':
					_song.notes[curSection].mustHitSection = check.checked;
				/*case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');*/
				case "Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			// FlxG.log.add(wname);
			/*if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}*/
			if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null || curSelectedNote[1] == -1)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}else if (wname == 'song_instvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				FlxG.sound.music.volume = nums.value;
			}
		}
		else if (id == FlxUIDropDownMenu.CLICK_EVENT) {
			var targetDrop:FlxUIDropDownMenu = cast sender;
			switch (targetDrop.name) {
				case "note_type":
					if (curSelectedNote == null) return;
					if (curSelectedNote[1] == -1) return;

					if (targetDrop.selectedLabel != "Normal") curSelectedNote[3] = targetDrop.selectedLabel;
					else if (curSelectedNote.length == 4) curSelectedNote.pop();

					updateGrid();
			}
		}
		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].bpm != null && _song.notes[i].bpm != daBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	override function update(elapsed:Float)
	{

		snapText.text = "Snap: 1/" + snap + " (" + (doSnapShit ? "Control to disable" : "Snap Disabled, Control to renable") + ")\nAdd Notes: 1-8 (or click)\n";

		curStep = recalculateSteps();

		if (!playingMusic && (vocals.playing || FlxG.sound.music.playing)) {
			FlxG.sound.music.pause();
			vocals.pause();
		}

		/*if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.RIGHT)
			snap = snap * 2;
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.LEFT)
			snap = Math.round(snap / 2);
		if (snap >= 192)
			snap = 192;
		if (snap <= 1)
			snap = 1;*/

		if (FlxG.keys.justPressed.CONTROL)
			doSnapShit = !doSnapShit;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;
		currentDiff = diffStuff.text;
		

		var left = FlxG.keys.justPressed.ONE;
		var down = FlxG.keys.justPressed.TWO;
		var up = FlxG.keys.justPressed.THREE;
		var right = FlxG.keys.justPressed.FOUR;
		var leftO = FlxG.keys.justPressed.FIVE;
		var downO = FlxG.keys.justPressed.SIX;
		var upO = FlxG.keys.justPressed.SEVEN;
		var rightO = FlxG.keys.justPressed.EIGHT;

		var pressArray = [left, down, up, right, leftO, downO, upO, rightO].map(t -> t && !anyFieldsFocused);
		var delete = false;
		curRenderedNotes.forEach(function(note:Note)
			{
				if (strumLine.overlaps(note) && pressArray[note.noteData])
				{
					deleteNote(note);
					delete = true;
					trace('deelte note');
				}
			});
		for (p in 0...pressArray.length)
		{
			var i = pressArray[p];
			if (i && !delete)
			{
				addNote(new Note(Conductor.songPosition,p, null, false, curNoteType));
			}
		}

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * 16));
		


		if (playBfHits || playDadHits)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.overlap(strumLine, note, function(_, _)
					{
						if (note.noteData == -1) return;
						var doBfHit = note.mustPress && playBfHits && !bfHits.contains(note);
						var doDadHit = !note.mustPress && playDadHits && !dadHits.contains(note);
						if (doDadHit || doBfHit)
						{
							if (doBfHit) bfHits.push(note);
							if (doDadHit) dadHits.push(note);
							FlxG.sound.play(Paths.sound('charting/SNAP'));
						}
					});
				}
			});
		}
		/*curRenderedNotes.forEach(function(note:Note) {
			if (strumLine.overlaps(note) && strumLine.y == note.y) // yandere dev type shit
			{
				if (_song.notes[curSection].mustHitSection)
					{
						trace('must hit ' + Math.abs(note.noteData));
						if (note.noteData < 4)
						{
							switch (Math.abs(note.noteData))
							{
								case 2:
									player1.playAnim('singUP', true);
								case 3:
									player1.playAnim('singRIGHT', true);
								case 1:
									player1.playAnim('singDOWN', true);
								case 0:
									player1.playAnim('singLEFT', true);
							}
						}
						if (note.noteData >= 4)
						{
							switch (note.noteData)
							{
								case 6:
									player2.playAnim('singUP', true);
								case 7:
									player2.playAnim('singRIGHT', true);
								case 5:
									player2.playAnim('singDOWN', true);
								case 4:
									player2.playAnim('singLEFT', true);
							}
						}
					}
					else
					{
						trace('hit ' + Math.abs(note.noteData));
						if (note.noteData < 4)
						{
							switch (Math.abs(note.noteData))
							{
								case 2:
									player2.playAnim('singUP', true);
								case 3:
									player2.playAnim('singRIGHT', true);
								case 1:
									player2.playAnim('singDOWN', true);
								case 0:
									player2.playAnim('singLEFT', true);
							}
						}
						if (note.noteData >= 4)
						{
							switch (note.noteData)
							{
								case 6:
									player1.playAnim('singUP', true);
								case 7:
									player1.playAnim('singRIGHT', true);
								case 5:
									player1.playAnim('singDOWN', true);
								case 4:
									player1.playAnim('singLEFT', true);
							}
						}
					}
			}
		});*/

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			/*trace(curStep);
			trace(16 * (curSection + 1));
			trace('DUMBSHIT');*/

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 16))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 16))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER && !anyFieldsFocused)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			PlayState.saveScore = false;
			
			FlxG.sound.music.stop();
			vocals.stop();
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E && !anyFieldsFocused)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q && !anyFieldsFocused)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB && !anyFieldsFocused)
		{
			if (FlxG.keys.pressed.SHIFT && !anyFieldsFocused)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!anyFieldsFocused)
		{

			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					trace(curRenderedNotes.members.contains(lastNote) ? "delete note" : "add note");
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else 
						addNote(lastNote);
				}
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.CONTROL && !anyFieldsFocused)
			{
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing);
			}	
			if (FlxG.keys.justPressed.SPACE)
			{
				if (playingMusic)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					// claps.splice(0, claps.length);
					bfHits.splice(0, bfHits.length);
					dadHits.splice(0, dadHits.length);
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
				playingMusic = !playingMusic;
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			
			if (FlxG.sound.music.time < 0 || curStep < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				// claps.splice(0, claps.length);
				bfHits.splice(0, bfHits.length);
				dadHits.splice(0, dadHits.length);
				

				var stepMs = curStep * Conductor.stepCrochet;


				trace(Conductor.stepCrochet / snap);

				if (doSnapShit)
					FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * Conductor.stepCrochet / snap);
				else
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				trace(stepMs + " + " + Conductor.stepCrochet / snap + " -> " + FlxG.sound.music.time);

				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection 
			+ "\nCurStep: " 
			+ curStep;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[1] == -1) return;
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	override function beatHit() 
	{
		trace('beat');

		super.beatHit();
		if (!player2.animation.curAnim.name.startsWith("sing"))
		{
			player2.playAnim('idle');
		}
		player1.dance();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			trace('naw im not null');
			curSection = sec;
			if (sec != 0) {
				bfHits = [];
				dadHits = [];
			}


			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			trace('bro wtf I AM NULL');
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (16 * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			if (note[3] != null) copiedNote.push(note[3]);
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];
		if (check_mustHitSection == null) return;

		// stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		// check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateHeads(switchIconOut:Bool=false, ?target:String):Void
	{
		if (switchIconOut) switch (target) {
			case "bf": iconP1 = Character.fetchIcon(_song.player1);
			case "dad": iconP2 = Character.fetchIcon(_song.player2);
		}
		if (check_mustHitSection == null) return;

		if (check_mustHitSection.checked)
		{
			leftIcon.swapIcon(iconP1);
			rightIcon.swapIcon(iconP2);
		}
		else
		{
			leftIcon.swapIcon(iconP2);
			rightIcon.swapIcon(iconP1);
		}
	}

	function updateEventUI() {
		var curEvents = (curSelectedNote ?? [])[2];
		if (curEvents == null) {
			evPage.text = 'N/A';
			return;
		}
		var target:Array<Dynamic> = curEvents[curEventsIndex];
		var daDesc = eventData.filter(d -> d[0] == target[0])[0][1];
		evPage.text = '${curEventsIndex+1}/${curEvents.length}';
		evDesc.text = daDesc;
		if (target != null) {
			evDrop.selectedLabel = target[0];
			val1Box.text = target[1];
			val2Box.text = target[2];
		}
		else {
			evDrop.selectedLabel = evDrop.selectedLabel;
			val1Box.text = "";
			val2Box.text = "";
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null) { 
			if (curSelectedNote[1] == -1) return updateEventUI();
			stepperSusLength.value = curSelectedNote[2];
			stepperNoteType.selectedLabel = curSelectedNote[3] != null ? curSelectedNote[3] : "Normal";
		}
	}

	function updateGrid():Void
	{
		remove(gridBG);
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 16);
        add(gridBG);

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 1.8).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		remove(anotherGridLine);
		anotherGridLine = new FlxSprite(gridBG.x + gridBG.width / 8.9).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(anotherGridLine);

		remove(wowAnotherGridLine);
		wowAnotherGridLine = new FlxSprite(gridBG.x).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		wowAnotherGridLine.x -= wowAnotherGridLine.width;
		add(wowAnotherGridLine);

		remove(amazingAnotherGridLine);
		amazingAnotherGridLine = new FlxSprite(gridBG.x + gridBG.width).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(amazingAnotherGridLine);
		
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedEvents.members.length > 0) curRenderedEvents.remove(curRenderedEvents.members[0], true);

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].bpm != null && _song.notes[curSection].bpm > 0 && _song.notes[curSection].bpm != Conductor.bpm)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].bpm != null && Conductor.bpm != _song.notes[i].bpm && (_song.notes[i].changeBPM != null == _song.notes[i].changeBPM || _song.notes[i].changeBPM == null))
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		updateSectionUI();
		updateHeads();
		for (i in sectionInfo)
		{
			var daStrumTime = i[0];
			var daNoteInfo = i[1];
			var daSus = i[2];
			var daType = i[3] ?? "Normal";

			var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, false, daType);
			note.chartingMode = true;
			note.mustPress = _song.notes[curSection].mustHitSection;
			if (daNoteInfo > 3) note.mustPress = !note.mustPress;

			note.x = Math.floor((daNoteInfo + 1) * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * 16)));
			if (daNoteInfo % 4 == -1) {
				note.frames = null;
				note.loadGraphic(Paths.image('icons/face'), true, 150, 150);
				note.animation.add("test", [0, 1], 0, false, false);
				note.animation.play("test");
				
				var correlatingTxt = new EventText(gridBG.x, note.y, i);
				curRenderedEvents.add(correlatingTxt);
			}
			else note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();

			if (curSelectedNote != null)
				if (curSelectedNote[0] == note.strumTime)
					lastNote = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var color:FlxColor = switch (daNoteInfo % 4) {
				    case 0: 0xffc14a99;
				    case 1: 0xff28ffff;
				    case 2: 0xff25fa04;
				    case 3: 0xfff6373f;
				    default: 0xFFFFFFFF;
			    };
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 5,
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)), color);
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			bpm: _song.bpm,	
			mustHitSection: true,
			sectionNotes: [],
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;
		/*if (curNote != null) {
			selectedNoteTween.cancel();
			curNote.alpha = 1;
		}*/

		// curNote = note;
		// selectedNoteTween = FlxTween.tween(curNote, { alpha: 0 }, 3, { type: PINGPONG });
		for (i in _song.notes[curSection].sectionNotes)
		{
			var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;

			if (i[1] > 3)
			{
				gottaHitNote = !_song.notes[curSection].mustHitSection;
			}

			if (i[0] == note.strumTime && i[1] % 4 == note.noteData && note.mustPress == gottaHitNote)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
				stepperNoteType.selectedLabel = curSelectedNote[3] != null ? curSelectedNote[3] : "Normal";
				curNoteType = curSelectedNote[3] != null ? curSelectedNote[3] : "Normal";
			}
			// else trace(i[0], note.strumTime, i[1] % 4, note.noteData);

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}


	function deleteNote(note:Note):Void
		{
			lastNote = note;
			for (i in _song.notes[curSection].sectionNotes)
			{
				var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;

				if (i[1] > 3)
				{
					gottaHitNote = !_song.notes[curSection].mustHitSection;
				}

				if (i[0] == note.strumTime && i[1] % 4 == note.noteData && note.mustPress == gottaHitNote)
				{
					if (note.noteData == -1) curSelectedNote = null;
					_song.notes[curSection].sectionNotes.remove(i);
				}
			}

			updateEventUI();
			updateGrid();
		}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16,mustHitSection:Bool = false,altAnim:Bool = true):SwagSection
		{
			var sec:SwagSection = {
				bpm: _song.bpm,
				mustHitSection: mustHitSection,
				sectionNotes: [],
				altAnim: altAnim
			};

			return sec;
		}

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0):Void
		{
			var newSong = [];
			
			var millisecadd = (((measure*4)+step/4)*(60000/_song.bpm))+ms;
			var totaladdsection = Std.int((millisecadd/(60000/_song.bpm)/4));
			trace(millisecadd,totaladdsection);
			if(millisecadd > 0)
				{
					for(i in 0...totaladdsection)
						{
							newSong.unshift(newSection());
						}
				}
			for (daSection1 in 0..._song.notes.length)
				{
					newSong.push(newSection(16,_song.notes[daSection1].mustHitSection,_song.notes[daSection1].altAnim));
				}
	
			for (daSection in 0...(_song.notes.length))
			{
				var aimtosetsection = daSection+Std.int((totaladdsection));
				if(aimtosetsection<0) aimtosetsection = 0;
				newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
				newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
				//trace("section "+daSection);
				for(daNote in 0...(_song.notes[daSection].sectionNotes.length))
					{	
						var newtiming = _song.notes[daSection].sectionNotes[daNote][0]+millisecadd;
						if(newtiming<0)
						{
							newtiming = 0;
						}
						var futureSection = Math.floor(newtiming/4/(60000/_song.bpm));
						_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
						newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);
	
						//newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
					}
	
			}
			//trace("DONE BITCH");
			_song.notes = newSong;
			updateGrid();
			updateSectionUI();
			updateNoteUI();
		}
	private function addNote(?n:Note):Void
	{
		var noteStrum:Float;
		var noteData:Int;
		var noteSus:Float;
		var noteType:String;

		if (n != null) { 
			noteStrum = n.strumTime;
			noteData = n.noteData;
			noteSus = n.sustainLength;
			noteType = n.noteType;
		}
		else {
			noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
			noteData = Math.floor(FlxG.mouse.x / GRID_SIZE) - 1;
			noteSus = 0;
			noteType = curNoteType;
		}

		var allNoteData:Array<Dynamic> = [noteStrum, noteData];
		switch (noteData) {
			case -1:
				allNoteData.push([[evDrop.selectedLabel, val1Box.text, val2Box.text]]);
				curEventsIndex = 0;
			default:
				allNoteData.push(noteSus);
				if (noteType != "Normal") allNoteData.push(noteType);
		}

		_song.notes[curSection].sectionNotes.push(allNoteData);

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(currentDiff, song.toLowerCase());
		PlayState.difficulty = currentDiff.toLowerCase();
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		var extraData:{diff:String,?modPath:String} = Settings.get("autosave_ext");
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		#if MODS
		if (extraData.modPath != null) Paths.curModDir = extraData.modPath; 
		#end
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		Settings.set("autosave_ext", {
			diff: currentDiff,
			#if MODS
			modPath: Paths.curModDir
			#end
		});
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	// section clean up, tired of every section having bpm for a section even when there isn't a freaking change
	function cleanUpBeforeSave(eventsOnly=false) { 
		var copyThing = _song;
		var mainBpm = Conductor.bpm;
		if (eventsOnly) {
			Reflect.deleteField(copyThing, "bpm");
			Reflect.deleteField(copyThing, "gfVersion");
			Reflect.deleteField(copyThing, "player1");
			Reflect.deleteField(copyThing, "player2");
			Reflect.deleteField(copyThing, "speed");
			Reflect.deleteField(copyThing, "stage");
		}

		for (x in 0..._song.notes.length) {
			var section = copyThing.notes[x];
			if (eventsOnly) {
				var eventNotes = [];
				for (note in copyThing.notes[x].sectionNotes) 
					if (note[1] == -1) 
						eventNotes.push(note);
				copyThing.notes[x].sectionNotes = eventNotes;
				Reflect.deleteField(copyThing.notes[x], "altAnim");
				Reflect.deleteField(copyThing.notes[x], "mustHitSection");
			} 
			Reflect.deleteField(copyThing.notes[x], "typeOfSection");
			Reflect.deleteField(copyThing.notes[x], "changeBPM");
			
			if (section.bpm != null) {
				if (section.bpm == mainBpm) Reflect.deleteField(copyThing.notes[x], "bpm");
				else mainBpm = section.bpm;
			}
		}
		return copyThing;
	}

	private function saveLevel(eventsOnly=false)
	{
		var data:String = Json.stringify({ "song": cleanUpBeforeSave(eventsOnly) });

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			var saveWhere = 'assets';
			#if MODS
			saveWhere = Paths.curModDir ?? 'assets';
			#end
			_file.save(data.trim(), saveWhere + '/songs/${_song.song.toLowerCase()}/charts/${(eventsOnly ? 'events' : currentDiff).toLowerCase()}.json');
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}

class EventText extends FlxText {
	public function new(x:Float, y:Float, data:Array<Dynamic>) {
		super(x, y);
		size = 20;
		font = Paths.font("vcr.ttf");
		borderStyle = OUTLINE;
		borderSize = 2;
		var events = data[2];
		text = '@ ${HelperFunctions.truncateFloat(data[0], 3)}\n';
		try {
			switch (events.length) {
				case 1: 
					text += events[0][0];
				default: text += '${events.length} Events';
			}
		}
		catch (e) {
			trace(e.message, events);
			text += '${e.message}';
			color = FlxColor.RED;
		}
		
		updateHitbox();
		var split = text.split("\n");
		split.sort((a, b) -> b.length-a.length);
		var longerText:Int = split[0].length;
		offset.x += longerText * 13;
		
	}
}
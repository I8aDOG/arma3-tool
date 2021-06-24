package;

import flixel.group.FlxSpriteGroup;
import lime.app.Application;
import openfl.media.Video;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var staticVar:PlayState;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	// tricky lines
	public var TrickyLinesSing:Array<String> = ["SUFFER","INCORRECT", "INCOMPLETE", "INSUFFICIENT", "INVALID", "CORRECTION", "MISTAKE", "REDUCE", "ERROR", "ADJUSTING", "IMPROBABLE", "IMPLAUSIBLE", "MISJUDGED"];
	public var ExTrickyLinesSing:Array<String> = ["YOU AREN'T HANK", "WHERE IS HANK", "HANK???", "WHO ARE YOU", "WHERE AM I", "THIS ISN'T RIGHT", "MIDGET", "SYSTEM UNRESPONSIVE", "WHY CAN'T I KILL?????"];
	public var TrickyLinesMiss:Array<String> = ["TERRIBLE", "WASTE", "MISS CALCULTED", "PREDICTED", "FAILURE", "DISGUSTING", "ABHORRENT", "FORESEEN", "CONTEMPTIBLE", "PROGNOSTICATE", "DISPICABLE", "REPREHENSIBLE"];

	//cutscene text unhardcoding
	public var cutsceneText:Array<String> = ["OMFG CLOWN!!!!", "YOU DO NOT KILL CLOWN", "CLOWN KILLS YOU!!!!!!"];

	public static var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	var MAINLIGHT:FlxSprite;
	
	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	var tstatic:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('TrickyStatic','clown'), true, 320, 180);

	var tStaticSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound("staticSound","preload"));

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public static var instance:PlayState;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public static var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	var notesHitArray:Array<Date> = [];
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var fc:Bool = true;


	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var gfDance:Bool = false;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public var hank:FlxSprite;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	public static var trans:FlxSprite;

	override public function create()
	{
		KeyBinds.keyCheck();

		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));

		generatedMusic = false;
		theFunne = FlxG.save.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		instance = this;

		if (storyWeek == 7)
			transIn = null;

		var cover:FlxSprite = new FlxSprite(-180,755).loadGraphic(Paths.image('fourth/cover','clown'));
		var hole:FlxSprite = new FlxSprite(50,530).loadGraphic(Paths.image('fourth/Spawnhole_Ground_BACK','clown'));
		var converHole:FlxSprite = new FlxSprite(7,578).loadGraphic(Paths.image('fourth/Spawnhole_Ground_COVER','clown'));

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		resetSpookyText = true;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		staticVar = this;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		
		//unhardcode tricky sing strings lmao
		TrickyLinesSing = CoolUtil.coolTextFile(Paths.txt('trickySingStrings'));
		TrickyLinesMiss = CoolUtil.coolTextFile(Paths.txt('trickyMissStrings'));
		ExTrickyLinesSing = CoolUtil.coolTextFile(Paths.txt('trickyExSingStrings'));

		//load cutscene text
		cutsceneText = CoolUtil.coolTextFile(Paths.txt('cutMyBalls'));
		//yes i called it "cut my balls" fuck you i can name my txts whatever i want

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		if (SONG.song.toLowerCase() == 'improbable-outset' || SONG.song.toLowerCase() == 'madness')
		{
			//trace("line 538");
			defaultCamZoom = 0.75;
			curStage = 'nevada';

			tstatic.antialiasing = true;
			tstatic.scrollFactor.set(0,0);
			tstatic.setGraphicSize(Std.int(tstatic.width * 8.3));
			tstatic.animation.add('static', [0, 1, 2], 24, true);
			tstatic.animation.play('static');

			tstatic.alpha = 0;

			var bg:FlxSprite = new FlxSprite(-350, -300).loadGraphic(Paths.image('red','clown'));
			// bg.setGraphicSize(Std.int(bg.width * 2.5));
			// bg.updateHitbox();
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			var stageFront:FlxSprite;
			if (SONG.song.toLowerCase() != 'madness')
			{
				add(bg);
				stageFront = new FlxSprite(-1100, -460).loadGraphic(Paths.image('island_but_dumb','clown'));
			}
			else
				stageFront = new FlxSprite(-1100, -460).loadGraphic(Paths.image('island_but_rocks_float','clown'));

			stageFront.setGraphicSize(Std.int(stageFront.width * 1.4));
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);
			
			MAINLIGHT = new FlxSprite(-470, -150).loadGraphic(Paths.image('hue','clown'));
			MAINLIGHT.alpha - 0.3;
			MAINLIGHT.setGraphicSize(Std.int(MAINLIGHT.width * 0.9));
			MAINLIGHT.blend = "screen";
			MAINLIGHT.updateHitbox();
			MAINLIGHT.antialiasing = true;
			MAINLIGHT.scrollFactor.set(1.2, 1.2);
		}
		else if (SONG.song.toLowerCase() == 'hellclown')
		{
			//trace("line 538");
			defaultCamZoom = 1;
			curStage = 'nevadaSpook';

			tstatic.antialiasing = true;
			tstatic.scrollFactor.set(0,0);
			tstatic.setGraphicSize(Std.int(tstatic.width * 3));
			tstatic.screenCenter(Y);
			tstatic.animation.add('static', [0, 1, 2], 24, true);
			tstatic.animation.play('static');

			tstatic.alpha = 0;


			var bg:FlxSprite = new FlxSprite(-1540, -845).loadGraphic(Paths.image('fourth/bg','clown'));
			bg.scrollFactor.set(0.9, 0.9);
			bg.setGraphicSize(Std.int(bg.width * 1.75));
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-1840, -750).loadGraphic(Paths.image('hellclwn/island_but_red','clown'));
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);
			
			hank = new FlxSprite(-25, -250);
			hank.frames = Paths.getSparrowAtlas('hellclwn/Hank','clown');
			hank.animation.addByPrefix('dance','Hank',24);
			hank.animation.play('dance');
			hank.scrollFactor.set(0.9, 0.9);
			

			add(hank);
		}
		else if (SONG.song.toLowerCase() == 'expurgation')
		{
			//trace("line 538");
			defaultCamZoom = 0.55;
			curStage = 'auditorHell';

			tstatic.antialiasing = true;
			tstatic.scrollFactor.set(0,0);
			tstatic.setGraphicSize(Std.int(tstatic.width * 8.3));
			tstatic.animation.add('static', [0, 1, 2], 24, true);
			tstatic.animation.play('static');

			tstatic.alpha = 0;

			var bg:FlxSprite = new FlxSprite(-10, -10).loadGraphic(Paths.image('fourth/bg','clown'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 4));
			add(bg);

			hole.antialiasing = true;
			hole.scrollFactor.set(0.9, 0.9);
					
			converHole.antialiasing = true;
			converHole.scrollFactor.set(0.9, 0.9);
			converHole.setGraphicSize(Std.int(converHole.width * 1.3));
			hole.setGraphicSize(Std.int(hole.width * 1.55));

			cover.antialiasing = true;
			cover.scrollFactor.set(0.9, 0.9);
			cover.setGraphicSize(Std.int(cover.width * 1.55));

			var energyWall:FlxSprite = new FlxSprite(1350,-690).loadGraphic(Paths.image("fourth/Energywall","clown"));
			energyWall.antialiasing = true;
			energyWall.scrollFactor.set(0.9, 0.9);
			add(energyWall);
			
			var stageFront:FlxSprite = new FlxSprite(-350, -355).loadGraphic(Paths.image('fourth/daBackground','clown'));
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.55));
			add(stageFront);
		}
		else
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}


		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'nevadaSpook':
				gfVersion = 'gf-hell';
			case 'auditorHell':
				gfVersion = 'gf-tied';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);


		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
			case 'tricky':
				camPos.x += 400;
				camPos.y += 600;
			case 'trickyMask':
				camPos.x += 400;
			case 'trickyH':
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y + 175);
				dad.x -= 650;
				dad.y -= 965;
				gf.x -= 370;
				gf.y -= 220;
			case 'exTricky':
				dad.x -= 250;
				dad.y -= 365;
				gf.x += 345;
				gf.y -= 25;
				dad.visible = false;
		}


		var bfVersion = SONG.player1;

		switch(curStage)
		{
			case 'nevadaSpook':
				bfVersion = 'bf-hell';
		}


		boyfriend = new Boyfriend(770, 450, bfVersion);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'nevada':
				boyfriend.x += 260;
			case 'auditorHell':
				boyfriend.y -= 160;
				boyfriend.x += 350;
		}

		add(gf);

		if (curStage == 'auditorHell')
			add(hole);

		if (dad.curCharacter == 'trickyH')
			dad.addOtherFrames();
		
		add(dad);

		if (curStage == 'auditorHell')
		{
			// Clown init
			cloneOne = new FlxSprite(0,0);
			cloneTwo = new FlxSprite(0,0);
			cloneOne.frames = CachedFrames.cachedInstance.fromSparrow('cln','fourth/Clone');
			cloneTwo.frames = CachedFrames.cachedInstance.fromSparrow('cln','fourth/Clone');
			cloneOne.alpha = 0;
			cloneTwo.alpha = 0;
			cloneOne.animation.addByPrefix('clone','Clone',24,false);
			cloneTwo.animation.addByPrefix('clone','Clone',24,false);

			// cover crap

			add(cloneOne);
			add(cloneTwo);
			add(cover);
			add(converHole);
			add(dad.exSpikes);
		}
		
		add(boyfriend);

		trace('hello');

		if (dad.curCharacter == 'trickyH')
		{
			boyfriend.x -= 620;
			boyfriend.y -= 480;
		}

		if (curStage == 'nevada')
		{	
			add(MAINLIGHT);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;


		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (dad.curCharacter == 'trickyH')
		{
			camFollow.setPosition(dad.getMidpoint().x + 50, dad.getMidpoint().y + 90);
		
		}
		
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.008);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;


		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		// what's your fuckin' deal???????????? -roze
		// what roze bud??? -kade
		// no 
		// ░░░░░▄▄▄▄▀▀▀▀▀▀▀▀▄▄▄▄▄▄░░░░░░░
		// ░░░░░█░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░▀▀▄░░░░
		// ░░░░█░░░▒▒▒▒▒▒░░░░░░░░▒▒▒░░█░░░
		// ░░░█░░░░░░▄██▀▄▄░░░░░▄▄▄░░░░█░░
		// ░▄▀▒▄▄▄▒░█▀▀▀▀▄▄█░░░██▄▄█░░░░█░
		// █░▒█▒▄░▀▄▄▄▀░░░░░░░░█░░░▒▒▒▒▒░█
		// █░▒█░█▀▄▄░░░░░█▀░░░░▀▄░░▄▀▀▀▄▒█
		// ░█░▀▄░█▄░█▀▄▄░▀░▀▀░▄▄▀░░░░█░░█░
		// ░░█░░░▀▄▀█▄▄░█▀▀▀▄▄▄▄▀▀█▀██░█░░
		// ░░░█░░░░██░░▀█▄▄▄█▄▄█▄████░█░░░
		// ░░░░█░░░░▀▀▄░█░░░█░█▀██████░█░░
		// ░░░░░▀▄░░░░░▀▀▄▄▄█▄█▄█▄█▄▀░░█░░
		// ░░░░░░░▀▄▄░▒▒▒▒░░░░░░░░░░▒░░░█░
		// ░░░░░░░░░░▀▀▄▄░▒▒▒▒▒▒▒▒▒▒░░░░█░
		// ░░░░░░░░░░░░░░▀▄▄▄▄▄░░░░░░░░█░░
		// trolling

		/*var kadeEngineWatermark = new FlxText(4,FlxG.height - 4,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + " - KE " + MainMenuState.kadeEngineVer, 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);*/

		scoreTxt = new FlxText(0,0 , 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.screenCenter();
		scoreTxt.x -= 200;
		if (!theFunne)
			scoreTxt.x -= 75;
		scoreTxt.y = healthBarBG.y + 50;
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
			{
				add(replayTxt);
			}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (curStage == "nevada" || curStage == "nevadaSpook" || curStage == 'auditorHell')
			add(tstatic);

		if (curStage == 'auditorHell')
			tstatic.alpha = 0.1;

		if (curStage == 'nevadaSpook' || curStage == 'auditorHell')
		{
			tstatic.setGraphicSize(Std.int(tstatic.width * 12));
			tstatic.x += 600;
		}


		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case 'improbable-outset':
					camFollow.setPosition(boyfriend.getMidpoint().x + 70, boyfriend.getMidpoint().y - 50);
					if (playCutscene)
					{
						trickyCutscene();
						playCutscene = false;
					}
					else
						startCountdown();
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'expurgation':
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					var spawnAnim = new FlxSprite(-150,-380);
					spawnAnim.frames = Paths.getSparrowAtlas('fourth/EXENTER','clown');

					spawnAnim.animation.addByPrefix('start','Entrance',24,false);

					add(spawnAnim);

					spawnAnim.animation.play('start');
					var p = new FlxSound().loadEmbedded(Paths.sound("fourth/Trickyspawn","clown"));
					var pp = new FlxSound().loadEmbedded(Paths.sound("fourth/TrickyGlitch","clown"));
					p.play();
					spawnAnim.animation.finishCallback = function(pog:String)
						{
							pp.fadeOut();
							dad.visible = true;
							remove(spawnAnim);
							startCountdown();
						}
					new FlxTimer().start(0.001, function(tmr:FlxTimer)
						{
							if (spawnAnim.animation.frameIndex == 24)
							{
								pp.play();
							}
							else
								tmr.reset(0.001);
						});
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function doStopSign(sign:Int = 0, fuck:Bool = false)
	{
		trace('sign ' + sign);
		var daSign:FlxSprite = new FlxSprite(0,0);
		// CachedFrames.cachedInstance.get('sign')

		daSign.frames = CachedFrames.cachedInstance.fromSparrow('sign','fourth/mech/Sign_Post_Mechanic');

		daSign.setGraphicSize(Std.int(daSign.width * 0.67));

		daSign.cameras = [camHUD];

		switch(sign)
		{
			case 0:
				daSign.animation.addByPrefix('sign','Signature Stop Sign 1',24, false);
				daSign.x = FlxG.width - 650;
				daSign.angle = -90;
				daSign.y = -300;
			case 1:
				/*daSign.animation.addByPrefix('sign','Signature Stop Sign 2',20, false);
				daSign.x = FlxG.width - 670;
				daSign.angle = -90;*/ // this one just doesn't work???
			case 2:
				daSign.animation.addByPrefix('sign','Signature Stop Sign 3',24, false);
				daSign.x = FlxG.width - 780;
				daSign.angle = -90;
				if (FlxG.save.data.downscroll)
					daSign.y = -395;
				else
					daSign.y = -980;
			case 3:
				daSign.animation.addByPrefix('sign','Signature Stop Sign 4',24, false);
				daSign.x = FlxG.width - 1070;
				daSign.angle = -90;
				daSign.y = -145;
		}
		add(daSign);
		daSign.flipX = fuck;
		daSign.animation.play('sign');
		daSign.animation.finishCallback = function(pog:String)
			{
				trace('ended sign');
				remove(daSign);
			}
	}

	var totalDamageTaken:Float = 0;

	var shouldBeDead:Bool = false;

	var interupt = false;

	// basic explanation of this is:
	// get the health to go to
	// tween the gremlin to the icon
	// play the grab animation and do some funny maths,
	// to figure out where to tween to.
	// lerp the health with the tween progress
	// if you loose any health, cancel the tween.
	// and fall off.
	// Once it finishes, fall off.

	function doGremlin(hpToTake:Int, duration:Int,persist:Bool = false)
	{
		interupt = false;

		grabbed = true;
		
		totalDamageTaken = 0;

		var gramlan:FlxSprite = new FlxSprite(0,0);

		gramlan.frames = CachedFrames.cachedInstance.fromSparrow('grem','fourth/mech/HP GREMLIN');

		gramlan.setGraphicSize(Std.int(gramlan.width * 0.76));

		gramlan.cameras = [camHUD];

		gramlan.x = iconP1.x;
		gramlan.y = healthBarBG.y - 325;

		gramlan.animation.addByIndices('come','HP Gremlin ANIMATION',[0,1], "", 24, false);
		gramlan.animation.addByIndices('grab','HP Gremlin ANIMATION',[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24], "", 24, false);
		gramlan.animation.addByIndices('hold','HP Gremlin ANIMATION',[25,26,27,28],"",24);
		gramlan.animation.addByIndices('release','HP Gremlin ANIMATION',[29,30,31,32,33],"",24,false);

		gramlan.antialiasing = true;

		add(gramlan);

		if(FlxG.save.data.downscroll){
			gramlan.flipY = true;
			gramlan.y -= 150;
		}
		
		// over use of flxtween :)

		var startHealth = health;
		var toHealth = (hpToTake / 100) * startHealth; // simple math, convert it to a percentage then get the percentage of the health

		var perct = toHealth / 2 * 100;

		trace('start: $startHealth\nto: $toHealth\nwhich is prect: $perct');

		var onc:Bool = false;

		FlxG.sound.play(Paths.sound('fourth/GremlinWoosh','clown'));

		gramlan.animation.play('come');
		new FlxTimer().start(0.14, function(tmr:FlxTimer) {
			gramlan.animation.play('grab');
			FlxTween.tween(gramlan,{x: iconP1.x - 140},1,{ease: FlxEase.elasticIn, onComplete: function(tween:FlxTween) {
				trace('I got em');
				gramlan.animation.play('hold');
				FlxTween.tween(gramlan,{
					x: (healthBar.x + 
					(healthBar.width * (FlxMath.remapToRange(perct, 0, 100, 100, 0) * 0.01) 
					- 26)) - 75}, duration,
				{
					onUpdate: function(tween:FlxTween) { 
						// lerp the health so it looks pog
						if (interupt && !onc && !persist)
						{
							onc = true;
							trace('oh shit');
							gramlan.animation.play('release');
							gramlan.animation.finishCallback = function(pog:String) { gramlan.alpha = 0;}
						}
						else if (!interupt || persist)
						{
							var pp = FlxMath.lerp(startHealth,toHealth, tween.percent);
							if (pp <= 0)
								pp = 0.1;
							health = pp;
						}

						if (shouldBeDead)
							health = 0;
					},
					onComplete: function(tween:FlxTween)
					{
						if (interupt && !persist)
						{
							remove(gramlan);
							grabbed = false;
						}
						else
						{
							trace('oh shit');
							gramlan.animation.play('release');
							if (persist && totalDamageTaken >= 0.7)
								health -= totalDamageTaken; // just a simple if you take a lot of damage wtih this, you'll loose probably.
							gramlan.animation.finishCallback = function(pog:String) { remove(gramlan);}
							grabbed = false;
						}
					}
				});
			}});
		});
	}

	var cloneOne:FlxSprite;
	var cloneTwo:FlxSprite;

	function doClone(side:Int)
	{
		switch(side)
		{
			case 0:
				if (cloneOne.alpha == 1)
					return;
				cloneOne.x = dad.x - 20;
				cloneOne.y = dad.y + 140;
				cloneOne.alpha = 1;

				cloneOne.animation.play('clone');
				cloneOne.animation.finishCallback = function(pog:String) {cloneOne.alpha = 0;}
			case 1:
				if (cloneTwo.alpha == 1)
					return;
				cloneTwo.x = dad.x + 390;
				cloneTwo.y = dad.y + 140;
				cloneTwo.alpha = 1;

				cloneTwo.animation.play('clone');
				cloneTwo.animation.finishCallback = function(pog:String) {cloneTwo.alpha = 0;}
		}

	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

		var startTimer:FlxTimer;
		var perfectMode:Bool = false;
		var bfScared:Bool = false;

		function trickySecondCutscene():Void // why is this a second method? idk cry about it loL!!!!
		{
			var done:Bool = false;

			trace('starting cutscene');

			var black:FlxSprite = new FlxSprite(-300, -120).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
			black.scrollFactor.set();
			black.alpha = 0;
			
			var animation:FlxSprite = new FlxSprite(200,300); // create the fuckin thing

			animation.frames = Paths.getSparrowAtlas('trickman','clown'); // add animation from sparrow
			animation.antialiasing = true;
			animation.animation.addByPrefix('cut1','Cutscene 1', 24, false);
			animation.animation.addByPrefix('cut2','Cutscene 2', 24, false);
			animation.animation.addByPrefix('cut3','Cutscene 3', 24, false);
			animation.animation.addByPrefix('cut4','Cutscene 4', 24, false);
			animation.animation.addByPrefix('pillar','Pillar Beam Tricky', 24, false);
			
			animation.setGraphicSize(Std.int(animation.width * 1.5));

			animation.alpha = 0;

			camFollow.setPosition(dad.getMidpoint().x + 300, boyfriend.getMidpoint().y - 200);

			inCutscene = true;
			startedCountdown = false;
			generatedMusic = false;
			canPause = false;

			FlxG.sound.music.volume = 0;
			vocals.volume = 0;

			var sounders:FlxSound = new FlxSound().loadEmbedded(Paths.sound('honkers','clown'));
			var energy:FlxSound = new FlxSound().loadEmbedded(Paths.sound('energy shot','clown'));
			var roar:FlxSound = new FlxSound().loadEmbedded(Paths.sound('sound_clown_roar','clown'));
			var pillar:FlxSound = new FlxSound().loadEmbedded(Paths.sound('firepillar','clown'));

			var fade:FlxSprite = new FlxSprite(-300, -120).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(19, 0, 0));
			fade.scrollFactor.set();
			fade.alpha = 0;

			var textFadeOut:FlxText = new FlxText(300,FlxG.height * 0.5,0,"TO BE CONTINUED");
			textFadeOut.setFormat("Impact", 128, FlxColor.RED);

			textFadeOut.alpha = 0;

			add(animation);

			add(black);

			add(textFadeOut);

			add(fade);

			var startFading:Bool = false;
			var varNumbaTwo:Bool = false;
			var fadeDone:Bool = false;

			sounders.fadeIn(30);

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if (fade.alpha != 1 && !varNumbaTwo)
					{
						camHUD.alpha -= 0.1;
						fade.alpha += 0.1;
						if (fade.alpha == 1)
						{
							// THIS IS WHERE WE LOAD SHIT UN-NOTICED
							varNumbaTwo = true;

							animation.alpha = 1;
							
							dad.alpha = 0;
						}
						tmr.reset(0.1);
					}
					else
					{
						fade.alpha -= 0.1;
						if (fade.alpha <= 0.5)
							fadeDone = true;
						tmr.reset(0.1);
					}
				});

			var roarPlayed:Bool = false;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (!fadeDone)
					tmr.reset(0.1)
				else
				{
					if (animation.animation == null || animation.animation.name == null)
					{
						trace('playin cut cuz its funny lol!!!');
						animation.animation.play("cut1");
						resetSpookyText = false;
						createSpookyText(cutsceneText[1], 260, FlxG.height * 0.9);
					}

					if (!animation.animation.finished)
					{
						tmr.reset(0.1);
						trace(animation.animation.name + ' - FI ' + animation.animation.frameIndex);

						switch(animation.animation.frameIndex)
						{
							case 104:
								if (animation.animation.name == 'cut1')
									resetSpookyTextManual();
						}

						if (animation.animation.name == 'pillar')
						{
							if (animation.animation.frameIndex >= 85) // why is this not in the switch case above? idk cry about it
								startFading = true;
							FlxG.camera.shake(0.05);
						}
					}
					else
					{
						trace('completed ' + animation.animation.name);
						resetSpookyTextManual();
						switch(animation.animation.name)
						{
							case 'cut1':
								animation.animation.play('cut2');
							case 'cut2':
								animation.animation.play('cut3');
								energy.play();
							case 'cut3':
								animation.animation.play('cut4');
								resetSpookyText = false;
								createSpookyText(cutsceneText[2], 260, FlxG.height * 0.9);
								animation.x -= 100;
							case 'cut4':
								resetSpookyTextManual();
								sounders.fadeOut();
								pillar.fadeIn(4);
								animation.animation.play('pillar');
								animation.y -= 670;
								animation.x -= 100;
						}
						tmr.reset(0.1);
					}

					if (startFading)
					{
						sounders.fadeOut();
						trace('do the fade out and the text');
						if (black.alpha != 1)
						{
							tmr.reset(0.1);
							black.alpha += 0.02;

							if (black.alpha >= 0.7 && !roarPlayed)
							{
								roar.play();
								roarPlayed = true;
							}
						}
						else if (done)
						{
							endSong();
							FlxG.camera.stopFX();
						}
						else
						{
							done = true;
							tmr.reset(5);
						}
					}
				}
			});
		}


		public static var playCutscene:Bool = true;

		function trickyCutscene():Void // god this function is terrible
		{
			trace('starting cutscene');

			var playonce:Bool = false;

			
			trans = new FlxSprite(-270, -745);
			trans.frames = Paths.getSparrowAtlas('Jaws','clown');
			trans.antialiasing = true;

			trans.animation.addByPrefix("Close","Jaws smol", 24, false);
			
			trace(trans.animation.frames);

			trans.setGraphicSize(Std.int(trans.width * 1.85));

			trans.scrollFactor.set();

			trace('added trancacscas ' + trans);

	

			var faded:Bool = false;
			var wat:Bool = false;
			var black:FlxSprite = new FlxSprite(-300, -120).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(19, 0, 0));
			black.scrollFactor.set();
			black.alpha = 0;
			var black3:FlxSprite = new FlxSprite(-300, -120).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(19, 0, 0));
			black3.scrollFactor.set();
			black3.alpha = 0;
			var red:FlxSprite = new FlxSprite(-300, -120).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(19, 0, 0));
			red.scrollFactor.set();
			red.alpha = 1;
			inCutscene = true;
			//camFollow.setPosition(bf.getMidpoint().x + 80, bf.getMidpoint().y + 200);
			dad.alpha = 0;
			gf.alpha = 0;
			remove(boyfriend);
			var nevada:FlxSprite = new FlxSprite(260,FlxG.height * 0.7);
			nevada.frames = Paths.getSparrowAtlas('somewhere','clown'); // add animation from sparrow
			nevada.antialiasing = true;
			nevada.animation.addByPrefix('nevada', 'somewhere idfk', 24, false);
			var animation:FlxSprite = new FlxSprite(-50,200); // create the fuckin thing
			animation.frames = Paths.getSparrowAtlas('intro','clown'); // add animation from sparrow
			animation.antialiasing = true;
			animation.animation.addByPrefix('fuckyou','Symbol', 24, false);
			animation.setGraphicSize(Std.int(animation.width * 1.2));
			nevada.setGraphicSize(Std.int(nevada.width * 0.5));
			add(animation); // add it to the scene
			
			// sounds

			var ground:FlxSound = new FlxSound().loadEmbedded(Paths.sound('ground','clown'));
			var wind:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wind','clown'));
			var cloth:FlxSound = new FlxSound().loadEmbedded(Paths.sound('cloth','clown'));
			var metal:FlxSound = new FlxSound().loadEmbedded(Paths.sound('metal','clown'));
			var buildUp:FlxSound = new FlxSound().loadEmbedded(Paths.sound('trickyIsTriggered','clown'));

			camHUD.visible = false;
			
			add(boyfriend);

			add(red);
			add(black);
			add(black3);

			add(nevada);

			add(trans);

			trans.animation.play("Close",false,false,18);
			trans.animation.pause();

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
				if (!wat)
					{
						tmr.reset(1.5);
						wat = true;
					}
					else
					{
					if (wat && trans.animation.frameIndex == 18)
					{
						trans.animation.resume();
						trace('playing animation...');
					}
				if (trans.animation.finished)
				{
				trace('animation done lol');
				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{

						if (boyfriend.animation.finished && !bfScared)
							boyfriend.animation.play('idle');
						else if (boyfriend.animation.finished)
							boyfriend.animation.play('scared');
						if (nevada.animation.curAnim == null)
						{
							trace('NEVADA | ' + nevada);
							nevada.animation.play('nevada');
						}
						if (!nevada.animation.finished && nevada.animation.curAnim.name == 'nevada')
						{
							if (nevada.animation.frameIndex >= 41 && red.alpha != 0)
							{
								trace(red.alpha);
								red.alpha -= 0.1;
							}
							if (nevada.animation.frameIndex == 34)
								wind.fadeIn();
							tmr.reset(0.1);
						}
						if (animation.animation.curAnim == null && red.alpha == 0)
						{
							remove(red);
							trace('play tricky');
							animation.animation.play('fuckyou', false, false, 40);
						}
						if (!animation.animation.finished && animation.animation.curAnim.name == 'fuckyou' && red.alpha == 0 && !faded)
						{
							trace("animation loop");
							tmr.reset(0.01);

							// animation code is bad I hate this
							// :(

							
							switch(animation.animation.frameIndex) // THESE ARE THE SOUNDS NOT THE ACTUAL CAMERA MOVEMENT!!!!
							{
								case 73:
									ground.play();
								case 84:
									metal.play();
								case 170:
									if (!playonce)
									{
										resetSpookyText = false;
										createSpookyText(cutsceneText[0], 260, FlxG.height * 0.9);
										playonce = true;
									}
									cloth.play();
								case 192:
									resetSpookyTextManual();
									if (tstatic.alpha != 0)
										manuallymanuallyresetspookytextmanual();
									buildUp.fadeIn();
								case 219:
									trace('reset thingy');
									buildUp.fadeOut();
							}

						
							// im sorry for making this code.
							// TODO: CLEAN THIS FUCKING UP (switch case it or smth)

							if (animation.animation.frameIndex == 190)
								bfScared = true;

							if (animation.animation.frameIndex >= 115 && animation.animation.frameIndex < 200)
							{
								camFollow.setPosition(dad.getMidpoint().x + 150, boyfriend.getMidpoint().y + 50);
								if (FlxG.camera.zoom < 1.1)
									FlxG.camera.zoom += 0.01;
								else
									FlxG.camera.zoom = 1.1;
							}
							else if (animation.animation.frameIndex > 200 && FlxG.camera.zoom != defaultCamZoom)
							{
								FlxG.camera.shake(0.01, 3);
								if (FlxG.camera.zoom < defaultCamZoom || camFollow.y < boyfriend.getMidpoint().y - 50)
									{
										FlxG.camera.zoom = defaultCamZoom;
										camFollow.y = boyfriend.getMidpoint().y - 50;
									}
								else
									{
										FlxG.camera.zoom -= 0.008;
										camFollow.y = dad.getMidpoint().y -= 1;
									}
							}
							if (animation.animation.frameIndex >= 235)
								faded = true;
						}
						else if (red.alpha == 0 && faded)
						{
							trace('red gay');
							// animation finished, start a dialog or start the countdown (should also probably fade into this, aka black fade in when the animation gets done and black fade out. Or just make the last frame tranisiton into the idle animation)
							if (black.alpha != 1)
							{
								if (tstatic.alpha != 0)
									manuallymanuallyresetspookytextmanual();
								black.alpha += 0.4;
								tmr.reset(0.1);
								trace('increase blackness lmao!!!');
							}
							else
							{
								if (black.alpha == 1 && black.visible)
								{
									black.visible = false;
									black3.alpha = 1;
									trace('transision ' + black.visible + ' ' + black3.alpha);
									remove(animation);
									dad.alpha = 1;
									// why did I write this comment? I'm so confused
									// shitty layering but ninja muffin can suck my dick like mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
									remove(red);
									remove(black);
									remove(black3);
									dad.alpha = 1;
									gf.alpha = 1;
									add(black);
									add(black3);
									remove(tstatic);
									add(tstatic);
									tmr.reset(0.3);
									FlxG.camera.stopFX();
									camHUD.visible = true;
								}
								else if (black3.alpha != 0)
								{
									black3.alpha -= 0.1;
									tmr.reset(0.3);
									trace('decrease blackness lmao!!!');
								}
								else 
								{
									wind.fadeOut();
									startCountdown();
								}
							}
					}
				});
				}
				else
				{
					trace(trans.animation.frameIndex);
					if (trans.animation.frameIndex == 30)
						trans.alpha = 0;
					tmr.reset(0.1);
				}
				}
			});
		}


	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter < 4)
			{
				trace('dance moment');
				dad.dance();
				gf.dance();
				boyfriend.playAnim('idle');
			}
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);

		if (SONG.song.toLowerCase() == 'expurgation') // start the grem time
		{
			new FlxTimer().start(25, function(tmr:FlxTimer) {
				if (curStep < 2400)
				{
					if (canPause && !paused && health >= 1.5 && !grabbed)
						doGremlin(40,3);
					trace('checka ' + health);
					tmr.reset(25);
				}
			});
		}
	}

	var grabbed = false;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		trace('starting song :D');
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		if (SONG.song.toLowerCase().contains('madness') && isStoryMode)
			FlxG.sound.music.onComplete = trickySecondCutscene;
		else
			FlxG.sound.music.onComplete = endSong;
		vocals.play();

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if(!paused)
			resyncVocals();
		});
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			var playerNotes:Array<Int> = [0, 1, 2, 3, 8, 9, 10, 11];

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (!playerNotes.contains(songNotes[1]))
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}
	var spookyText:FlxText;
	var spookyRendered:Bool = false;
	var spookySteps:Int = 0;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		var balls = notesHitArray.length-1;
		while (balls >= 0)
		{
			var cock:Date = notesHitArray[balls];
			if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
				notesHitArray.remove(cock);
			else
				balls = 0;
			balls--;
		}
		nps = notesHitArray.length;
		if (nps > maxNPS)
			maxNPS = nps;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore,0,nps,accuracy);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT){
            if(FlxG.keys.pressed.SHIFT){
                FlxG.switchState(new AnimationDebug(SONG.player1));
            }
            else if(FlxG.keys.pressed.CONTROL){
                FlxG.switchState(new AnimationDebug(gf.curCharacter));
            }
            else{
                FlxG.switchState(new AnimationDebug(SONG.player2));
            }
        }
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'trickyMask':
						camFollow.y = dad.getMidpoint().y + 25;
					case 'trickyH':
						camFollow.x = dad.getMidpoint().x - 50;
						camFollow.y = dad.getMidpoint().y + 130;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 300);

				switch (curStage)
				{
					case 'nevadaSpook':
						camFollow.x = boyfriend.getMidpoint().x - 35;
						camFollow.y = boyfriend.getMidpoint().y - 105;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (loadRep) // rep debug
			{
				FlxG.watch.addQuick('rep rpesses',repPresses);
				FlxG.watch.addQuick('rep releases',repReleases);
				// FlxG.watch.addQuick('Queued',inputsQueued);
			}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
		// this is where I overuse FlxG.Random :)
		if (spookyRendered) // move shit around all spooky like
			{
				spookyText.angle = FlxG.random.int(-5,5); // change its angle between -5 and 5 so it starts shaking violently.
				//tstatic.x = tstatic.x + FlxG.random.int(-2,2); // move it back and fourth to repersent shaking.
				if (tstatic.alpha != 0)
					tstatic.alpha = FlxG.random.float(0.1,0.5); // change le alpha too :)
			}

		
			if (generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.y > FlxG.height)
						{
							daNote.active = false;
							daNote.visible = false;
						}
						else
						{
							daNote.visible = true;
							daNote.active = true;
						}
		
						if (!daNote.mustPress && daNote.wasGoodHit)
						{
							if (SONG.song != 'Tutorial')
								camZooming = true;
		
							var altAnim:String = "";
		
							if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									altAnim = '-alt';
							}
		
							//trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);
		
							if (!(curBeat >= 532 && curBeat <= 536  && curSong.toLowerCase() == "expurgation")){
							switch (Math.abs(daNote.noteData))
							{
								case 2:
									dad.playAnim('singUP' + altAnim, true);
								case 3:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 1:
									dad.playAnim('singDOWN' + altAnim, true);
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
							}
							}
		
							switch(dad.curCharacter)
							{
								case 'trickyMask': // 1% chance
									if (FlxG.random.bool(1) && !spookyRendered && !daNote.isSustainNote) // create spooky text :flushed:
										{
											createSpookyText(TrickyLinesSing[FlxG.random.int(0,TrickyLinesSing.length)]);
										}
								case 'tricky': // 20% chance
									if (FlxG.random.bool(20) && !spookyRendered && !daNote.isSustainNote) // create spooky text :flushed:
										{
											createSpookyText(TrickyLinesSing[FlxG.random.int(0,TrickyLinesSing.length)]);
										}
								case 'trickyH': // 45% chance
									if (FlxG.random.bool(45) && !spookyRendered && !daNote.isSustainNote) // create spooky text :flushed:
										{
											createSpookyText(TrickyLinesSing[FlxG.random.int(0,TrickyLinesSing.length)]);
										}
									FlxG.camera.shake(0.01, 0.2);
								case 'exTricky': // 60% chance
									if (FlxG.random.bool(60) && !spookyRendered && !daNote.isSustainNote) // create spooky text :flushed:
										{
											createSpookyText(ExTrickyLinesSing[FlxG.random.int(0,ExTrickyLinesSing.length)]);
										}
							}
		
		
							dad.holdTimer = 0;
		
							if (SONG.needsVoices)
								vocals.volume = 1;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
		

						if (FlxG.save.data.downscroll)
							daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));	
						else
							daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));
						
						daNote.y -= (daNote.burning ? ((curStage != 'auditorHell' && FlxG.save.data.downscroll) ? 185 : 65 ) : 0);
		
						// WIP interpolation shit? Need to fix the pause issue
						// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
		
						if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
							{
								if (daNote.isSustainNote && daNote.wasGoodHit)
								{
									daNote.kill();
									notes.remove(daNote, true);
									daNote.destroy();
								}
								else
								{
									
									if (!daNote.burning && daNote.mustPress)
									{
										if (!daNote.isSustainNote || curStage != 'nevedaSpook')
										{
											health -= 0.075;
											totalDamageTaken += 0.075;
											interupt = true;
											noteMiss(daNote.noteData);
										}
										else if (daNote.isSustainNote && curStage == 'nevedaSpook') // nerf long notes on hellclown cuz they're too op
										{
											interupt = true;
											health -= 0.035;
											totalDamageTaken += 0.005;
										}
										vocals.volume = 0;
									}
								}		
							daNote.active = false;
							daNote.visible = false;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}

		if (!inCutscene)
			keyShit();

		/*
			if (FlxG.keys.justPressed.ONE)
				trickySecondCutscene();
		*/
	}

	function createSpookyText(text:String, x:Float = -1111111111111, y:Float = -1111111111111):Void
	{
		spookySteps = curStep;
		spookyRendered = true;
		tstatic.alpha = 0.5;
		FlxG.sound.play(Paths.sound('staticSound','clown'));
		spookyText = new FlxText((x == -1111111111111 ? FlxG.random.float(dad.x + 40,dad.x + 120) : x), (y == -1111111111111 ? FlxG.random.float(dad.y + 200, dad.y + 300) : y));
		spookyText.setFormat("Impact", 128, FlxColor.RED);
		if (curStage == 'nevadaSpook')
		{
			//spookyText.size = 200;
			spookyText.y -= 450;
		}
		spookyText.bold = true;
		spookyText.text = text;
		add(spookyText);
	}

	public function endSong():Void
	{
		var song = SONG.song;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		

		if (isStoryMode)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				MainMenuState.reRoll = true;

				LoadingState.loadAndSwitchState(new VideoState("assets/videos/TricksterMan.webm",new MainMenuState()));

				if (storyDifficulty == 2)
					FlxG.save.data.beatenHard = true;
				if (storyDifficulty >= 1)
					FlxG.save.data.beaten = true;

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				switch(song.toLowerCase())
				{
					case 'improbable-outset':
						LoadingState.loadAndSwitchState(new VideoState("assets/videos/HankFuckingShootsTricky.webm", new PlayState()));
					case 'madness':
						LoadingState.loadAndSwitchState(new VideoState("assets/videos/HELLCLOWN_ENGADGED.webm",new PlayState()));
					default:
						LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			if (song.toLowerCase() == "expurgation")
				FlxG.save.data.beatEx = true;
			MainMenuState.reRoll = true;
			FlxG.switchState(new MainMenuState());
		}
	}

	
	function toPlay() {FlxG.switchState(new PlayState());}
	function toMenu() {FlxG.switchState(new MainMenuState());}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			var healthDrain:Float = 0;

			if (SONG.song.toLowerCase() == 'hellclown')
				healthDrain = 0.04;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					health -= 0.2;
					totalDamageTaken += 0.2;
					interupt = true;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					totalDamageTaken += 0.06;
					interupt = true;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2 && !grabbed)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2 && !grabbed)
						health += 0.1 - healthDrain;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);


			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			add(rating);
	
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
		}



	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}


	// anti mash functions :D (soon TM)

	public function canHit(controlArray:Array<Bool>, noteArray:Array<Note>):Bool
	{
		var hit:Bool = true;

		if (noteArray == null)
			return true;

		var baseStrum:Float = noteArray[0].strumTime;

		for(i in 0...noteArray.length)
		{
			var n:Note = noteArray[i];
			if (!controlArray[n.noteData])
				hit = false;
		}
		return hit;
	}




	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;	

	var noteHit:Int = 0;
	private function keyShit():Void // I've invested in emma stocks
		{
			var control = PlayerSettings.player1.controls;

			// control arrays, order L D R U
			var holdArray:Array<Bool> = [control.LEFT, control.DOWN, control.UP, control.RIGHT];
			var pressArray:Array<Bool> = [
				control.LEFT_P,
				control.DOWN_P,
				control.UP_P,
				control.RIGHT_P
			];
			var releaseArray:Array<Bool> = [
				control.LEFT_R,
				control.DOWN_R,
				control.UP_R,
				control.RIGHT_R
			];
	 
	 
			// HOLDS, check for sustain notes
			if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.alpha != 0.1)
						goodNoteHit(daNote);
				});
			}
	 
			// PRESSES, check for note hits
			if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
			{
				boyfriend.holdTimer = 0;
	 
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
	 
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (directionList.contains(daNote.noteData))
						{
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});
	 
				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
	 
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	 
				var dontCheck = false;

				for (i in 0...pressArray.length)
				{
					if (pressArray[i] && !directionList.contains(i))
						dontCheck = true;
				}

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0 && !dontCheck)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
							{ // if a direction is hit that shouldn't be
								if (pressArray[shit] && !directionList.contains(shit))
									noteMiss(shit);
							}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							scoreTxt.color = FlxColor.WHITE;
							if (coolNote.burning)
							{
								if (curStage == 'auditorHell')
								{
									// lol death
									health = 0;
									shouldBeDead = true;
									FlxG.sound.play(Paths.sound('death','clown'));
								}
								else
								{
									health -= 0.45;
									totalDamageTaken += 0.45;
									interupt = true;
									coolNote.wasGoodHit = true;
									coolNote.canBeHit = false;
									coolNote.kill();
									notes.remove(coolNote, true);
									coolNote.destroy();
									FlxG.sound.play(Paths.sound('burnSound','clown'));
									playerStrums.forEach(function(spr:FlxSprite)
									{
										if (pressArray[spr.ID] && spr.ID == coolNote.noteData)
										{
											var smoke:FlxSprite = new FlxSprite(spr.x - spr.width + 15, spr.y - spr.height);
											smoke.frames = Paths.getSparrowAtlas('Smoke','clown');
											smoke.animation.addByPrefix('boom','smoke',24,false);
											smoke.animation.play('boom');
											smoke.setGraphicSize(Std.int(smoke.width * 0.6));
											smoke.cameras = [camHUD];
											add(smoke);
											smoke.animation.finishCallback = function(name:String) {
												remove(smoke);	
											}
										}
									});
								}
							}
							else
								goodNoteHit(coolNote);
						}
					}
				}
				else if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
							if (pressArray[shit])
								noteMiss(shit);
					}

				if(dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost)
				{
					if (mashViolations > 4)
					{
						trace('mash violations ' + mashViolations);
						scoreTxt.color = FlxColor.RED;
						noteMiss(0);
					}
					else
						mashViolations++;
				}

			}
			
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true)))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.playAnim('idle');
			}
	 
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				if (!holdArray[spr.ID])
					spr.animation.play('static');
	 
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}


	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			totalDamageTaken += 0.04;
			interupt = true;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');


			if (dad.curCharacter.toLowerCase().contains("tricky") && FlxG.random.bool(dad.curCharacter == "tricky" ? 10 : 4) && !spookyRendered && curStage == "nevada") // create spooky text :flushed:
				createSpookyText(TrickyLinesMiss[FlxG.random.int(0,TrickyLinesMiss.length)]);
				

			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');


			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateAccuracy();
		}
	}

	function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}

	function updateAccuracy()
		{
			if (misses > 0 || accuracy < 96)
				fc = false;
			else
				fc = true;
			totalPlayed += 1;
			accuracy = totalNotesHit / totalPlayed * 100;
		}


	
		function getKeyPresses(note:Note):Int
			{
				var possibleNotes:Array<Note> = []; // copypasted but you already know that
		
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					}
				});
				return possibleNotes.length;
			}
			
			var mashing:Int = 0;
			var mashViolations:Int = 0;
		
			function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
				{
					var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		
					note.rating = Ratings.CalculateRating(noteDiff);
		
					/* if (loadRep)
					{
						if (controlArray[note.noteData])
							goodNoteHit(note, false);
						else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
						{
							if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
							{
								goodNoteHit(note, false);
							}
						}
					} */
					
					if (controlArray[note.noteData])
					{
						goodNoteHit(note, (mashing > getKeyPresses(note)));
						
						/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
						{
							mashViolations++;
							goodNoteHit(note, (mashing > getKeyPresses(note)));
						}
						else if (mashViolations > 2)
						{
							// this is bad but fuck you
							playerStrums.members[0].animation.play('static');
							playerStrums.members[1].animation.play('static');
							playerStrums.members[2].animation.play('static');
							playerStrums.members[3].animation.play('static');
							health -= 0.4;
							trace('mash ' + mashing);
							if (mashing != 0)
								mashing = 0;
						}
						else
							goodNoteHit(note, false);*/
		
					}
				}
		

				function goodNoteHit(note:Note, resetMashViolation = true):Void
					{

						if (mashing != 0)
							mashing = 0;
		
						var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		
						note.rating = Ratings.CalculateRating(noteDiff);
		
						// add newest note to front of notesHitArray
						// the oldest notes are at the end and are removed first
						if (!note.isSustainNote)
							notesHitArray.unshift(Date.now());
		
						if (!resetMashViolation && mashViolations >= 1)
							mashViolations--;
		
						if (mashViolations < 0)
							mashViolations = 0;
		
						if (!note.wasGoodHit)
						{
							if (!note.isSustainNote)
							{
								popUpScore(note);
								combo += 1;
							}
							else
								totalNotesHit += 1;
			
		
							switch (note.noteData)
							{
								case 2:
									boyfriend.playAnim('singUP', true);
								case 3:
									boyfriend.playAnim('singRIGHT', true);
								case 1:
									boyfriend.playAnim('singDOWN', true);
								case 0:
									boyfriend.playAnim('singLEFT', true);
							}

							playerStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(note.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
								});
							
							note.wasGoodHit = true;
							vocals.volume = 1;
				
							note.kill();
							notes.remove(note, true);
							note.destroy();
							
							updateAccuracy();
						}
					}

	var resetSpookyText:Bool = true;

	function resetSpookyTextManual():Void
	{
		trace('reset spooky');
		spookySteps = curStep;
		spookyRendered = true;
		tstatic.alpha = 0.5;
		FlxG.sound.play(Paths.sound('staticSound','clown'));
		resetSpookyText = true;
	}

	function manuallymanuallyresetspookytextmanual()
	{
		remove(spookyText);
		spookyRendered = false;
		tstatic.alpha = 0;
	}

	var stepOfLast = 0;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		// EX TRICKY HARD CODED EVENTS

		if (curStage == 'auditorHell' && curStep != stepOfLast)
		{
			switch(curStep)
			{
				case 384:
					doStopSign(0);
				case 511:
					doStopSign(2);
					doStopSign(0);
				case 610:
					doStopSign(3);
				case 720:
					doStopSign(2);
				case 991:
					doStopSign(3);
				case 1184:
					doStopSign(2);
				case 1218:
					doStopSign(0);
				case 1235:
					doStopSign(0, true);
				case 1200:
					doStopSign(3);
				case 1328:
					doStopSign(0, true);
					doStopSign(2);
				case 1439:
					doStopSign(3, true);
				case 1567:
					doStopSign(0);
				case 1584:
					doStopSign(0, true);
				case 1600:
					doStopSign(2);
				case 1706:
					doStopSign(3);
				case 1917:
					doStopSign(0);
				case 1923:
					doStopSign(0, true);
				case 1927:
					doStopSign(0);
				case 1932:
					doStopSign(0, true);
				case 2032:
					doStopSign(2);
					doStopSign(0);
				case 2036:
					doStopSign(0, true);
				case 2162:
					doStopSign(2);
					doStopSign(3);
				case 2193:
					doStopSign(0);
				case 2202:
					doStopSign(0,true);
				case 2239:
					doStopSign(2,true);
				case 2258:
					doStopSign(0, true);
				case 2304:
					doStopSign(0, true);
					doStopSign(0);	
				case 2326:
					doStopSign(0, true);
				case 2336:
					doStopSign(3);
				case 2447:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);	
				case 2480:
					doStopSign(0, true);
					doStopSign(0);	
				case 2512:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);
				case 2544:
					doStopSign(0, true);
					doStopSign(0);	
				case 2575:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);
				case 2608:
					doStopSign(0, true);
					doStopSign(0);	
				case 2604:
					doStopSign(0, true);
				case 2655:
					doGremlin(20,13,true);
			}
			stepOfLast = curStep;
		}



		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}

		if (spookyRendered && spookySteps + 3 < curStep)
		{
			if (resetSpookyText)
			{
				remove(spookyText);
				spookyRendered = false;
			}
			tstatic.alpha = 0;
			if (curStage == 'auditorHell')
				tstatic.alpha = 0.1;
		}

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatT:Int = 0;
	var lastBeatDadT:Int = 0;
	var beatOfFuck:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (curStage == 'nevedaSpook')
			hank.animation.play('dance');

		if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				{
					Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
					FlxG.log.add('CHANGED BPM!');
				}
				// else
				// Conductor.changeBPM(SONG.bpm);
	
				// Dad doesnt interupt his own notes
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				{
					dad.dance();
				}
			}
			
		if (curStage == 'auditorHell')
		{
			if (curBeat % 8 == 4 && beatOfFuck != curBeat)
			{
				beatOfFuck = curBeat;
				doClone(FlxG.random.int(0,1));
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && curBeat != lastBeatT)
		{
			lastBeatT = curBeat;
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat == 532 && curSong.toLowerCase() == "expurgation")
		{
			dad.playAnim('Hank', true);
		}

		if (curBeat == 536 && curSong.toLowerCase() == "expurgation")
		{
			dad.playAnim('idle', true);
		}

	}

	var curLight:Int = 0;
}
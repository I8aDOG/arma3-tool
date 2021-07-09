package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var instaKilled:Bool = false;

	public function new(x:Float, y:Float, shouldBeDead:Bool)
	{
		var daStage = PlayState.curStage;
		var daBf:String = 'signDeath';

		instaKilled = shouldBeDead;

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		if (daStage == 'nevadaSpook')
		{
			//I mean, if it ain't broke, don't fix it.
			bf = new Boyfriend(-FlxG.width + (x * 3), -FlxG.height + (y * 3), daBf);
			//bf.setGraphicSize(Std.int(bf.width * 0.3));
			FlxG.camera.zoom = 0.3;
			bf.antialiasing = true;
		}
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('BF_Deathsound','clown'));
		//FlxG.sound.play(Paths.sound('Micdrop','clown'));
		Conductor.changeBPM(200);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		
		bf.playAnim('firstDeath');
		bf.animation.resume();
	}

	var playedMic:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			MainMenuState.reRoll = true;
			FlxG.switchState(new MainMenuState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			trace(bf.animation.frameIndex);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver','clown'));
			bf.playAnim('deathLoop', true);
		}

		else if (bf.animation.curAnim.finished && bf.animation.curAnim.name != 'deathConfirm')
		{
			bf.playAnim('deathLoop', true);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && !instaKilled && bf.animation.frameIndex >= 90 && !playedMic)
		{
			playedMic = true;
			FlxG.sound.play(Paths.sound('Micdrop','clown'));
		}
		else if (bf.animation.curAnim.name == 'firstDeath' && instaKilled && bf.animation.frameIndex >= 74 && !playedMic)
		{
				playedMic = true;
				FlxG.sound.play(Paths.sound('death','clown'));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd','clown'));
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

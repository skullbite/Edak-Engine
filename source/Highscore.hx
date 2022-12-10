package;

import flixel.FlxG;

typedef ScoreData = {
	score:Int,
	accuracy:Float,
	rating:String
};

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, ScoreData> = new Map();
	#else
	public static var songScores:Map<String, ScoreData> = new Map<String, ScoreData>();
	#end


	public static function saveScore(song:String, score:Int = 0, accuracy:Float = 0, rating:String = "N/A", ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if(!FlxG.save.data.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong).score < score)
					setScore(daSong, score, accuracy, rating);
			}
			else
				setScore(daSong, score, accuracy, rating);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{

		if(!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek).score < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int, accuracy:Float = 0, rating:String = "N/A"):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, { score: score, accuracy: accuracy, rating: rating });
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):ScoreData
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):ScoreData
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
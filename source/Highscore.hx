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


	public static function convertScore(noteDiff:Float):Int
    {
        var daRating:String = Ratings.CalculateRating(noteDiff, 166);

        switch(daRating)
			{
				case 'shit':
					return -300;
				case 'bad':
					return 0;
				case 'good':
					return 200;
				case 'sick':
					return 350;
            }
        return 0;
    }

	public static function saveScore(song:String, score:Int = 0, accuracy:Float = 0, rating:String = "N/A", ?diff:String):Void
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

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:String):Void
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

	public static function formatSong(song:String, diff:String):String
	{
		var daSong:String = song;

		return diff.toLowerCase() != "normal" ? daSong + '-${diff.toLowerCase()}' : daSong;
	}

	public static function getScore(song:String, diff:String):ScoreData
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:String):ScoreData
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
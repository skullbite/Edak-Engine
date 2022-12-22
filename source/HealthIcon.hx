package;

import sys.FileSystem;
import openfl.Assets;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	var isPlayer:Bool;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		var target:String = char;
		this.isPlayer = isPlayer;
		swapIcon(target);
	}

	public function swapIcon(target:String) {
		switch (target) {
			case 'bf-car' | 'bf-christmas': target = 'bf';
			case 'mom-car': target = 'mom';
			case 'monster-christmas': target = 'monster';
			case 'senpai-angry': target = 'senpai';
		}

		if (FileSystem.exists(Paths.image('icons/$target'))) loadGraphic(Paths.image('icons/$target'), true, 150, 150);
		else loadGraphic(Paths.image('icons/face'), true, 150, 150);

		antialiasing = true;
		animation.add('icon', [0, 1], 0, false, isPlayer);
		animation.play('icon');

		switch(target)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
		}

		// scrollFactor.set();
	}


	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}

package;

import flixel.animation.FlxAnimation;
import flixel.FlxSprite;

// better flxsprite for handling animation in fnf
// wanted to override the original but flx updates :(
class FrogSprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Float>> = [];
	public var curAnim(get, null):Null<FlxAnimation>;
	public function get_curAnim() return animation.curAnim;
	
    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
        animation.play(AnimName, Force, Reversed, Frame);

		
		if (animOffsets.exists(AnimName))
		{
			var daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		else
			offset.set(0, 0);
    }

    public function addOffset(name:String, x:Float=0, y:Float=0) animOffsets[name] = [x, y];
    
    public function addAnim(name:String, prefix:String, ?offsets:Array<Float>, ?indices:Array<Int>, framerate:Int=24, looped:Bool=false) {
		if (indices != null) animation.addByIndices(name, prefix, indices, "", framerate, looped);
		else animation.addByPrefix(name, prefix, framerate, looped);

		if (offsets != null) addOffset(name, offsets[0], offsets[1]);
		else addOffset(name);

		return { 
			addLoop: (i:Array<Int>, framer:Int=24, loop:Bool=true) -> {
				var loopName = name + "Loop";
			    animation.addByIndices(loopName, prefix, i, "", framer, loop);
				if (offsets != null) addOffset(loopName, offsets[0], offsets[1]);
		        else addOffset(loopName);
		    }
		}
	}
}
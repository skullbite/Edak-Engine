package openfl.display;

import openfl.text.StyleSheet;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	public var borderSize:Int = 2;

	// border code isn't mine
	// https://github.com/Raltyro/FNF-PsikeEngine/blob/main/source/openfl/display/FPS.hx
	@:noCompletion private final borders:Array<TextField> = new Array<TextField>();

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		var border:TextField;
		for (i in 0...8) {
			borders.push(border = new TextField());
			border.selectable = false;
			border.mouseEnabled = false;
			border.autoSize = LEFT;
			border.multiline = true;
			border.width = 800;
			border.height = 70;
		}

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
        
		defaultTextFormat = new TextFormat("VCR OSD Mono", 17, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
		addEventListener(Event.REMOVED, function(_) {
			for (border in borders) this.parent.removeChild(border);
		});
		addEventListener(Event.ADDED, function(_) {
			for (border in borders) this.parent.addChildAt(border, this.parent.getChildIndex(this));
		});
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
		}

		cacheCount = currentCount;
	}

	@:noCompletion override function set_visible(value:Bool):Bool {
		for (border in borders) border.visible = value;
		return super.set_visible(value);
	}

	@:noCompletion override function set_defaultTextFormat(value:TextFormat):TextFormat {
		for (border in borders) {
			border.defaultTextFormat = value;
			border.textColor = 0xFF000000;
		}
		return super.set_defaultTextFormat(value);
	}

	@:noCompletion override function set_x(x:Float):Float {
		for (i in 0...8) borders[i].x = x + ([0, 3, 5].contains(i) ? borderSize : [2, 4, 7].contains(i) ? -borderSize : 0);
		return super.set_x(x);
	}

	@:noCompletion override function set_y(y:Float):Float {
		for (i in 0...8) borders[i].y = y + ([0, 1, 2].contains(i) ? borderSize : [5, 6, 7].contains(i) ? -borderSize : 0);
		return super.set_y(y);
	}

	@:noCompletion override function set_text(text:String):String {
		for (border in borders) border.text = text;
		return super.set_text(text);
	}
}

package hstuff;

class CallbackScript extends HBase {
    var name:String = "h";
    var code:String;
    override public function new(code:String) {
        super();
        this.code = code;
    }

    public function funcExists(target:String) return StringTools.contains(code, "function " + target);

    public function exec(target:String, args:Array<Dynamic>) {
        try {
            var safeArgs = args.map(d -> {
                if (d is String && Math.isNaN(Std.parseFloat(d))) return '"$d"';
                else return d;
            });
            interp.execute(parser.parseString(code + '\n$target(${safeArgs.join(", ")});', name));
        }
        catch (e) {
            trace('Callback:$name function "$target" failed: ${e.message}');
        }
    }
}
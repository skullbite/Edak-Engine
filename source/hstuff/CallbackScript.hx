package hstuff;

class CallbackScript extends HBase {
    var name:String;
    var code:String;
    override public function new(code:String) {
        super();
        this.code = code;
    }

    public function funcExists(target:String) return StringTools.contains(code, "function " + target);

    public function exec(target:String, args:Array<Dynamic>) {
        try {
            interp.execute(parser.parseString(code + '\n$target(${args.join(", ")});'));
        }
        catch (e) {
            trace('Callback:$name function "$target" failed: ${e.message}');
        }
    }
}
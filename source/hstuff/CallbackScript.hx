package hstuff;

class CallbackScript extends HBase {
    var name:String = "h";
    public function new(path:String, printName:String, variables:Dynamic) {
        super(path);
        name = printName;
        var scriptVars = Reflect.fields(variables);
        for (x in 0...scriptVars.length) set(scriptVars[x], Reflect.getProperty(variables, scriptVars[x]));
    }

    public function exec(target:String, args:Array<Dynamic>):Dynamic {
        try {
            return call(target, args);
        }
        catch (e) {
            trace('$name function "$target" failed: ${e.message}');
            return null;
        }
    }
}
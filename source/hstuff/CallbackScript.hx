package hstuff;

class CallbackScript extends HBase {
    var name:String = "h";
    public function new(path:String, printName:String, variables:Dynamic) {
        super(path);
        name = printName;
        var scriptVars = Reflect.fields(variables);
        for (x in 0...scriptVars.length) {
            /*probably gonna remain unused but this is supposed to bind all of a class/objects properties to a script's variables
            if (scriptVars[x] == "bind") {
                var bigProperties = Reflect.fields(Reflect.getProperty(variables, scriptVars[x]));
                // for (y in 0...bigProperties.length) set(bigProperties[y], Reflect.getProperty(scriptVars[x], bigProperties[y]));
            }*/
            set(scriptVars[x], Reflect.getProperty(variables, scriptVars[x]));
        }
    }

    public function exec(target:String, args:Array<Dynamic>):Dynamic {
        try {
            return call(target, args);
        }
        catch (e) {
            trace('$name function "$target" failed: ${e.message}');
            #if debug
            trace(e.stack);
            #end
            return null;
        }
    }
}
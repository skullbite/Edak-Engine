package hstuff;

class CallbackScript extends HBase {
    var name:String = "h";
    public function exec(target:String, args:Array<Dynamic>):Dynamic {
        try {
            return call(target, args);
        }
        catch (e) {
            trace('Callback:$name function "$target" failed: ${e.message}');
            return null;
        }
    }
}
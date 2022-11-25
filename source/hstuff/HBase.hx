package hstuff;

import hscript.Parser;
import hscript.Interp;

class HBase {
    public var parser:Parser;
    public var interp:Interp;
    public var variables(get, never):Map<String, Dynamic>;
    public function new() {
        parser = new Parser();
        interp = new Interp();
        interp.variables.set("PlayState", PlayState);
        parser.line = 1;
        parser.allowTypes = true;
    }

    function get_variables() {
        return interp.variables;
    }
}
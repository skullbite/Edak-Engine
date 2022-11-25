package hstuff;

class HCharacter extends HBase {
    override public function new(charClass:Character, code:String) {
        super();
        interp.variables.set("char", charClass);
        interp.variables.set("Paths", new CharacterPaths(charClass.curCharacter));
        interp.variables.set("_Paths", Paths);
        interp.execute(parser.parseString(code));
    }
}
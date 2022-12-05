package hstuff;

class HCharacter extends CallbackScript {
    override public function new(charClass:Character, code:String) {
        super(code);
        name = "Character:" + charClass.curCharacter;
        interp.variables.set("char", charClass);
        interp.variables.set("Paths", new CharacterPaths(charClass.curCharacter));
        interp.variables.set("_Paths", Paths);
    }
}
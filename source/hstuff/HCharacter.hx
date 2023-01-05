package hstuff;

class HCharacter extends CallbackScript {
    override public function new(charClass:Character, path:String) {
        super(path);
        name = "Character:" + charClass.curCharacter;
        set("this", charClass);
        set("char", charClass);
        set("Paths", new CustomPaths(charClass.curCharacter, "characters"));
        set("_Paths", Paths);
    }
}
package hstuff;

class HSub extends CallbackScript {
    public function new(path:String, substate:CustomSubState) {
        super(path);
        set("sub", substate);
        set("Paths", new CustomPaths(substate.subName, "substates"));
        set("_Paths", Paths);
    }
}
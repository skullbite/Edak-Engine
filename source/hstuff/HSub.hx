package hstuff;

class HSub extends CallbackScript {
    public function new(code:String, substate:CustomSubState) {
        super(code);
        interp.variables.set("sub", substate); 
    }
}
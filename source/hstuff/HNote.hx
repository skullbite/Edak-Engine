package hstuff;

class HNote extends CallbackScript {
    public function new(noteClass:Note, path:String) {
        super(path);
        set("Paths", Paths);
        set("note", noteClass);
    }
}
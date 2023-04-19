package hstuff;

enum abstract Callbacks(String) to String {
    var INIT = "init";
    var PRELOAD = "preload";
    var CALLBACK = "callback";
    var CREATE = "create";
    var CREATE_POST = "createPost";
    var UPDATE = "update";
    var UPDATE_POST = "updatePost";
    var STEP = "stepHit";
    var BEAT = "beatHit";
    var SECTION = "sectionHit";
    var EVENT_LOAD = "eventLoad";
    var EVENT = "event";
    var CUTSCENE = "cutscene";
    var OPPONENT = "opponentNoteHit";
    var SONG_START = "songStart";
    var SONG_END = "songEnd";
    var NOTE_SPAWN = "noteSpawn";
    var PAUSE = "pause";
    var COUNTDOWN = "countdownTick";
    var COMBO = "comboPop";
    var NOTE_MISS = "noteMiss";
    var NOTE_HIT = "noteHit";
    var SCORE_UPDATE = "scoreUpdate";
    var GAME_OVER = "gameOver";
    var GAME_OVER_CREATE = "gameOverCreate";
    var GAME_OVER_UPDATE = "gameOverUpdate";
    var GAME_OVER_END = "gameOverEnd";
    var CAMERA = "camMove";
    var BEFORE_EXIT = "preExit";

    var ICON = "getIcon";
    var DANCE = "dance";
    
    var BEFORE_LINE = "preLine";
    var FINISH = "finish";
}

class HVars {
    static public var STOP:String = "THISISASTRINGTHATSTOPSFUNCTIONSLOL";
}
package arena.stage;

abstract ArenaListener(ArenaEvent -> Void) from ArenaEvent -> Void {
    inline public function call(event: ArenaEvent) {
        this(event);
    }
}

class Arena {

    static public function Empty(listener: ArenaListener): Arena {
        return new Arena(
            {
                identity: 0,
                size: 8,
                cells: arena.stage.Cells.CellsExt.Empty(8)
            },
            listener
        );
    }

    var _stage: ArenaStage;
    var _listener: ArenaListener;

    public function new(stage: ArenaStage, listener: ArenaListener) {
        _stage = stage;
        _listener = listener;

        _listener.call(Resize(_stage.size));
    }

    public function getId<T>(): Identity<T> {
        return cast ++_stage.identity;
    }

    public function update(dt: Float) {
        handleEmptyCells();
    }

    function handleEmptyCells() {
        
    }
}
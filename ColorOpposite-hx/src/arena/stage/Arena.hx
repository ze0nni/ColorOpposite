package arena.stage;

abstract ArenaListener(ArenaEvent -> Void) from ArenaEvent -> Void {
    inline public function call(event: ArenaEvent) {
        this(event);
    }
}

typedef CellContext = {
    var lock: Int;
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
    var _cells: Array<Array<CellContext>>;
    var _listener: ArenaListener;

    public function new(stage: ArenaStage, listener: ArenaListener) {
        _stage = stage;
        _listener = listener;

        var size = _stage.size;
        _cells = new Array();
        for (y in 0...size) {
            var row = new Array();
            _cells.push(row);
            for (x in 0...size) {
                row.push({
                    lock: 0,
                });
            }
        }

        _listener.call(Resize(_stage.size));
        for (i in 0..._stage.size) {
            spawnBlock(i, 6, Color1);
            spawnBlock(i, i, Color1);
        }
    }

    public function getId<T>(): Identity<T> {
        return cast ++_stage.identity;
    }

    public function update(dt: Float) {
        handleEmptyCells();
    }

    function spawnBlock(x: Int, y: Int, kind: BlockKind) {
        if (_stage.cells[y][x].block != null) {
            _listener.call(BlockDespawned(_stage.cells[y][x].block.id));
        }
        _stage.cells[y][x].block = {
            id: getId(),
            x: x,
            y: y,
            kind: kind
        }
        _listener.call(BlockSpawned(_stage.cells[y][x].block));
    }

    public function lockCell(x: Int, y: Int) {
        _cells[y][x].lock++;
    }

    public function unlockCell(x: Int, y: Int) {
        _cells[y][x].lock--;
    }

    inline function IsFree(x: Int, y: Int): Bool {
        return _cells[y][x].lock == 0;
    }

    function handleEmptyCells() {
        var size = _stage.size;
        var cells = _stage.cells;
        for (y in 1...size) {
            for (x in 0...size) {
                if (!IsFree(x, y)) {
                    continue;
                }
                if (cells[y][x].block == null || cells[y-1][x].block != null) {
                    continue;
                }
                var block = cells[y][x].block;
                block.x = x;
                block.y = y-1;
                cells[y-1][x].block = block;
                cells[y][x].block = null;
                _listener.call(BlockMoved(block.id, x, y - 1));
            }
        }
    }
}
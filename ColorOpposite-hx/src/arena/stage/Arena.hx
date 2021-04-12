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
    
    var _cellsLocks: Int = 0;
    var _cells: Array<Array<CellContext>>;

    var _listener: ArenaListener;

    private static var Colors: Array<BlockKind> = [Color1, Color2, Color3, Color4, Color5, Color6];

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
    }

    public function getId<T>(): Identity<T> {
        return cast ++_stage.identity;
    }

    public function randomIntRange(min: Int, max: Int): Int {
        return Std.int(Math.random(min, max));
    }

    public function peekRandom<T>(array: Array<T>): T {
        if (array.length == 0) {
            throw "Empty array";
        }
        return array[randomIntRange(0, array.length-1)];
    }

    public function update(dt: Float) {
        handleGenerateBlocks();
        handleEmptyCells();
    }

    function spawnBlock(x: Int, y: Int, kind: BlockKind, reason: BlockSpawnReason) {
        if (_stage.cells[y][x].block != null) {
            _listener.call(BlockDespawned(_stage.cells[y][x].block.id));
        }
        _stage.cells[y][x].block = {
            id: getId(),
            x: x,
            y: y,
            kind: kind
        }
        _listener.call(BlockSpawned(_stage.cells[y][x].block, reason));
    }

    public function lockCell(x: Int, y: Int) {
        _cells[y][x].lock++;
        _cellsLocks++;
    }

    public function unlockCell(x: Int, y: Int) {
        _cells[y][x].lock--;
        _cellsLocks--;
    }

    inline function IsFree(x: Int, y: Int): Bool {
        return _cells[y][x].lock == 0;
    }

    public function touchCell(x: Int, y: Int) {
        if (_cellsLocks > 0) {
            return;
        }
        var size = _stage.size;
        var cells = _stage.cells;
        if (x < 0 || y < 0 || x >= size || y >= size) {
            return;
        }
        if (_stage.cells[y][x].block == null) {
            return;
        }

        var xStack = [x];
        var yStack = [y];

        var score = 0;
        while (xStack.length > 0) {
            var sx = xStack.pop();
            var sy = yStack.pop();
            var block = cells[sy][sx].block;
            if (block == null)
                continue;
            
            cells[sy][sx].block = null;
            _listener.call(BlockDespawned(block.id));

            score++;

            neighbors(sx, sy, true, function name(bx, by, cell) {
                if (cell.block.kind == block.kind) {
                    xStack.push(bx);
                    yStack.push(by);
                }
            });
        }
        trace(score);
    }

    inline function neighbors(x: Int, y: Int, blocks: Bool, consumer: Int -> Int -> Cell -> Void) {
        var cells = _stage.cells;
        var last = _stage.size - 1;
        if (x > 0) {
            var cell = cells[y][x-1];
            if (!blocks || cell.block != null) {
                consumer(x-1, y, cell);
            }
        }
        if (y > 0) {
            var cell = cells[y-1][x];
            if (!blocks || cell.block != null) {
                consumer(x, y-1, cell);
            }
        }
        if (x < last) {
            var cell = cells[y][x+1];
            if (!blocks || cell.block != null) {
                consumer(x+1, y, cell);
            }
        }
        if (y < last) {
            var cell = cells[y+1][x];
            if (!blocks || cell.block != null) {
                consumer(x, y+1, cell);
            }
        }
    }

    function handleGenerateBlocks() {
        var size = _stage.size;
        var top = size - 1;
        for (x in 0...size) {
            if (!IsFree(x, top)) {
                continue;
            }
            if (_stage.cells[top][x].block != null) {
                continue;
            }
            var color = peekRandom(Colors);
            spawnBlock(x, top, color, Generate);
        }
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
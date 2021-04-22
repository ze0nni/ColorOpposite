package arena.stage;

import arena.stage.Cells.CellsExt;
import haxe.macro.Expr.Case;

typedef CellContext = {
    var lock: Int;
}

class Arena<TSelf> {

    static public function Empty<TSelf>(self: TSelf, listener: ArenaListener<TSelf>, controller: ArenaController): Arena<TSelf> {
        return new Arena<TSelf>(
            {
                identity: 0,
                size: 8,
                cells: arena.stage.Cells.CellsExt.Empty(8),
                player1: {
                    score: 0,
                },
                player2: {
                    score: 0,
                }
            },
            self,
            listener,
            controller
        );
    }

    var _stage: ArenaStage;
    
    var _cellsLocks: Int = 0;
    var _lockForUpdate: Bool = false;
    var _cells: Array<Array<CellContext>>;
    var _cellsToClean: Array<Cell> = [];
    var _cellsContextToClean: Array<CellContext> = [];
    
    var _state: Int = 0;
    var _requestForUpdateState: Bool = true;

    var _self: TSelf;
    var _listener: ArenaListener<TSelf>;
    var _controller: ArenaController;

    var _random: Random;

    var _timeoutHappened: Bool;
    var _roundTime: Int;
    var _roundStart: Float;
    var _lastTimeLeft: Null<Int>;

    private static var Colors: Array<BlockKind> = [Color1, Color2, Color3, Color4, /*Color5, Color6*/];
    private static var Rockets: Array<BlockKind> = [RocketHor, RocketVert];

    public function new(stage: ArenaStage, self: TSelf, listener: ArenaListener<TSelf>, controller: ArenaController) {
        _stage = stage;
        _self = self;
        _listener = listener;
        _controller = controller;

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

        _listener.onResize(_self, _stage.size);
    }

    public function getId<T>(): Identity<T> {
        return cast ++_stage.identity;
    }

    public function randomIntRange(min: Int, max: Int): Int {
        return _random.next(min, max);
    }

    public function peekRandom<T>(array: Array<T>): T {
        if (array.length == 0) {
            throw "Empty array";
        }
        return array[randomIntRange(0, array.length-1)];
    }

    public function update(dt: Float) {
        if (!_controller.inGame()) {
            handleInput();
            return;
        }


        if (!_lockForUpdate && _cellsLocks == 0) {
            handleInput();
        }

        handleTimeLeft();
        handleCleanCells();
        handleGenerateBlocks();
        handleEmptyCells();

        if (_requestForUpdateState && !_lockForUpdate && _cellsLocks == 0) {
            _requestForUpdateState = false;
            _state++;
            _controller.sendHash(_state, _state);
        }

        _lockForUpdate = false;
    }

    public function handleInput() {
        switch (_controller.readInput()) {
            case None:

            case Connected:
                _listener.onConnected(_self);

            case Disconnected:
                _listener.onDisconnected(_self);

            case InGame(seed, rounds, turnsInRount):
                _random = new Random(seed);
                _listener.onInGame(_self, rounds, turnsInRount);

            case Touch(x, y):
                touchCellInternal(x, y);

            case CurrentRound(teamId, roundTime):
                _roundTime = roundTime;
                _roundStart = Os.clock();
                _lastTimeLeft = roundTime;
                _timeoutHappened = false;
                _listener.onCurrentRound(_self, teamId);
                _listener.onCurrentTurn(_self, teamId);
                _listener.onTurnTimeLeft(_self, roundTime, roundTime);

            case CurrentTurn(teamId):
                _listener.onCurrentTurn(_self, teamId);

            case RoomResult(winnder, result):
                _listener.onRoomResult(_self, winnder, result);
        }
    }

    public function player(index: Int): Player {
        switch (index) {
            case 1: 
                return _stage.player1;
            case 2: 
                return _stage.player2;
        }
        throw "Wrong index";
    }

    public function me(): Player {
        if (_controller.teamId() == 1)
            return _stage.player1;
        return _stage.player2;
    }

    public function oponent(): Player {
        if (_controller.teamId() == 1)
            return _stage.player2;
        return _stage.player1;
    }

    function spawnBlock(x: Int, y: Int, kind: BlockKind, reason: BlockSpawnReason) {
        if (_stage.cells[y][x].block != null) {
            _listener.onBlockDespawned(_self, _stage.cells[y][x].block.id);
        }
        _stage.cells[y][x].block = {
            id: getId(),
            x: x,
            y: y,
            kind: kind
        }
        _listener.onBlockSpawned(_self, _stage.cells[y][x].block, reason);
    }

    public function lockCell(x: Int, y: Int) {
        _cells[y][x].lock++;
        _cellsLocks++;
    }

    public function unlockCell(x: Int, y: Int) {
        _cells[y][x].lock--;
        _cellsLocks--;
    }

    inline function isValidCell(x: Int, y: Int) {
        return x > 0 && y > 0 && x < _stage.size && y < _stage.size;
    }

    inline function IsFree(x: Int, y: Int): Bool {
        return _cells[y][x].lock == 0;
    }

    public function touchCell(x: Int, y: Int) {
        if (!_controller.myTurn())
            return;
        if (!isValidCell(x, y)) {
            return;
        }

        _controller.touch(x, y);
        touchCellInternal(x, y);
    }

    function touchCellInternal(x: Int, y: Int) {
        if (_cellsLocks > 0) {
            return;
        }
        var size = _stage.size;
        var cells = _stage.cells;
        if (x < 0 || y < 0 || x >= size || y >= size) {
            return;
        }
        var cell = _stage.cells[y][x];
        if (cell.block == null) {
            return;
        }
        _requestForUpdateState = true;
        _lockForUpdate = true;

        if (cell.block.kind == RocketVert || cell.block.kind == RocketHor) {
            activateRocket(x, y, cell);
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
            _listener.onBlockDespawned(_self, block.id);

            score++;

            neighbors(sx, sy, true, function name(bx, by, cell) {
                if (cell.block.kind == block.kind) {
                    xStack.push(bx);
                    yStack.push(by);
                }
            });
        }
        _listener.onMatched(_self, x, y, score);
        handleMatch(x, y, score);
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

    function activateRocket(x: Int, y: Int, rocketCell: Cell) {
        var rocketBlock = rocketCell.block;
        rocketCell.block = null;
        _listener.onPowerupActivated(_self, x, y, rocketBlock.id);
        _listener.onBlockDespawned(_self, rocketBlock.id);

        if (rocketBlock.kind == RocketHor) {
            for (i in 0..._stage.size) {
                if (i == x) 
                    continue;
                _cellsToClean.push(_stage.cells[y][i]);
                _cellsContextToClean.push(_cells[y][i]);
            }
        } else if (rocketBlock.kind == RocketVert) {
            for (i in 0..._stage.size) {
                if (i == y) 
                    continue;
                _cellsToClean.push(_stage.cells[i][x]);
                _cellsContextToClean.push(_cells[i][x]);
            }
        }

        _requestForUpdateState = true;
        _lockForUpdate = true;
    }

    function handleMatch(x: Int, y: Int, score: Int) {
        var p = player(_controller.currentTeamId());

        p.score += score;
        _listener.onAppendScore(_self, p.score, _controller.currentTeamId() == _controller.teamId());
        
        if (_controller.currentTeamId() == _controller.teamId()) {
            _controller.setScore(_controller.currentTeamId(), p.score);
        }

        if (score == 5) {
            spawnBlock(x, y, peekRandom(Rockets), Swap);
        }
    }

    function handleTimeLeft() {
        if (_lastTimeLeft == null) {
            return;
        }

        var timeLeft = _roundTime - Std.int(Os.clock() - _roundStart);
        if (timeLeft >= 0) {
            if (timeLeft != _lastTimeLeft) {
                _lastTimeLeft = timeLeft;
                _listener.onTurnTimeLeft(_self, timeLeft, _roundTime);
            }
        } else {
            if (!_timeoutHappened) {
                _timeoutHappened = true;
                _controller.timeOut();
            }
        }
    }

    function handleCleanCells() {
        if (_cellsToClean.length == 0)
            return;

        var hasLocked = false;

        var score = 0;

        for (i in 0..._cellsToClean.length) {
            var cell = _cellsToClean[i];
            var context = _cellsContextToClean[i];
            if (cell == null || cell.block == null)
                continue;
            if (context.lock > 0) {
                hasLocked = true;
                continue;
            }
            var block = cell.block;
            cell.block = null;
            _cellsToClean[i] = null;
            _cellsContextToClean[i] = null;
            _listener.onBlockDespawned(_self, block.id);

            score += 1;
        }

        if (!hasLocked) {
            _cellsToClean.resize(0);
            _cellsContextToClean.resize(0);
        }
        if (score > 0) {
            var p = player(_controller.currentTeamId());
            p.score += score;
            _listener.onAppendScore(_self, p.score, _controller.currentTeamId() == _controller.teamId());
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
            _lockForUpdate = true;

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
                _lockForUpdate = true;

                var block = cells[y][x].block;
                block.x = x;
                block.y = y-1;
                cells[y-1][x].block = block;
                cells[y][x].block = null;
                _listener.onBlockMoved(_self, block.id, x, y - 1);
            }
        }
    }
}
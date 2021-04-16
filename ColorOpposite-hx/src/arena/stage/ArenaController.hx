package arena.stage;

enum Input {
    None;
    Connected;
    Disconnected;
    InGame(seed: Int, rounds: Int, turnsInRount: Int);
    Touch(x: Int, y: Int);
    CurrentRound(teamId: Int, turnTime: Int);
    CurrentTurn(teamId: Int);
    RoomResult(result: RoomResult);
}

interface ArenaController {
    function connected(): Bool;
    function inGame(): Bool;
    function teamId(): Int;
    function currentTeamId(): Int;
    function myTurn(): Bool;
    function touch(x: Int, y: Int): Void;
    function timeOut(): Void;
    function readInput(): Input;
    function sendHash(turn: Int, hash: Int): Void;

    function disconnect(): Void;
}

class Common implements ArenaController {
    
    var _inputQueue = new Array<Input>();
    var _inGame: Bool = false;

    public function new() {
        _inputQueue.push(Connected);
        _inputQueue.push(InGame(0, 0, 0));
        _inputQueue.push(CurrentRound(1, 15));
    }

	public function connected():Bool {
		return true;
	}

    public function inGame(): Bool {
        return _inGame;
    }

    public function teamId(): Int {
        return 1;
    }

    public  function currentTeamId(): Int {
        return 1;
    }

	public function myTurn():Bool {
		return true;
	}

	public function touch(x:Int, y:Int) {
        _inputQueue.push(CurrentTurn(1));
    }

    public function timeOut() {
        _inputQueue.push(CurrentRound(1, 15));
    }

	public function readInput():Input {
		if (_inputQueue.length != 0) {
			var msg =  _inputQueue.shift();

            switch (msg) {
                case InGame(seed, rounds, turnsInRount):
                    _inGame = true;
                default:
                    //
            }

            return msg;
		}

		return None;
	}

	public function sendHash(turn:Int, hash:Int) {
        //
    }

    public function disconnect(): Void {

    }
}
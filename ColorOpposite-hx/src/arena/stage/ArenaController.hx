package arena.stage;

enum Input {
    None;
    Touch(x: Int, y: Int);
    CurrentTurn(teamId: Int);
}

interface ArenaController {
    function connected(): Bool;
    function inGame(): Bool;
    function seed(): Int;
    function teamId(): Int;
    function currentTeamId(): Int;
    function myTurn(): Bool;
    function touch(x: Int, y: Int): Void;
    function readInput(): Input;
    function sendHash(turn: Int, hash: Int): Void;

    function disconnect(): Void;
}

class Common implements ArenaController {
    
    var _inputQueue = new Array<Input>();

    public function new() {
        _inputQueue.push(CurrentTurn(1));
    }

	public function connected():Bool {
		return true;
	}

    public function inGame(): Bool {
        return true;
    }

    public function seed(): Int {
        return 0;
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

	public function readInput():Input {
        trace(_inputQueue.length);
		if (_inputQueue.length != 0) {
			return _inputQueue.shift();
		}

		return None;
	}

	public function sendHash(turn:Int, hash:Int) {
        //
    }

    public function disconnect(): Void {

    }
}
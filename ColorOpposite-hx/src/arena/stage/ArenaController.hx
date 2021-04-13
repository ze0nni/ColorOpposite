package arena.stage;

enum Input {
    None;
    Touch(x: Int, y: Int);
}

interface ArenaController {
    function connected(): Bool;
    function inGame(): Bool;
    function seed(): Int;
    function teamId(): Int;
    function myTurn(): Bool;
    function touch(x: Int, y: Int): Void;
    function readInput(): Input;
    function sendHash(turn: Int, hash: Int): Void;

    function disconnect(): Void;
}

class Common implements ArenaController {
    
    public function new() {
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
        return 0;
    }

	public function myTurn():Bool {
		return true;
	}

	public function touch(x:Int, y:Int) {}

	public function readInput():Input {
		return None;
	}

	public function sendHash(turn:Int, hash:Int) {
        //
    }

    public function disconnect(): Void {

    }
}
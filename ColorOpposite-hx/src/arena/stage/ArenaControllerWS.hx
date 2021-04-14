package arena.stage;

import haxe.Json;
import ws.Websocket;
import arena.stage.ArenaController.Input;

class ArenaControllerWS implements ArenaController {

	var _conn: WebsocketConnection;
	var _connected: Bool;
	var _inGame: Bool;
	var _teamId: Int = 0;
	var _activeTeamId = 0;
	var _currentTeamId = 0;
	var _seed: Int = 0;
	var _inputQueue = new Array<Input>();

    public function new(url: String) {
        _conn = Websocket.connect(url, {}, function (_, conn, data) {
			switch (data.event) {
				case EVENT_CONNECTED:
					Websocket.send(conn, '{"command":"handshake"}');
					_connected = true;
				case EVENT_DISCONNECTED:
					_connected = false;
				case EVENT_MESSAGE:
					handleMessage(Json.decode(data.message));
				case EVENT_ERROR:
					//
			}
		});
    }

    public function seed(): Int {
        return 0;
    }

    public function teamId(): Int {
        return _teamId;
    }

	public function currentTeamId(): Int {
		return _currentTeamId;
	}

	public function connected():Bool {
		return _connected;
	}

    public function inGame(): Bool {
        return _inGame;
    }

	public function myTurn():Bool {
		return _teamId == _activeTeamId;
	}

	public function touch(x:Int, y:Int) {
		_activeTeamId = 0;
		send("touch", {
			x: x,
			y: y
		});
	}

	public function readInput():Input {
		if (_inputQueue.length != 0) {
			return _inputQueue.shift();
		}

		return None;
	}

	public function sendHash(turn:Int, hash:Int) {
		send("hash", {
			hash: hash
		});
	}

	public function disconnect(): Void {
		Websocket.disconnect(_conn);
    }

	function send(command: String, data: Dynamic) {
		Websocket.send(_conn, Json.stringify({
			command: command,
		}));
		Websocket.send(_conn, Json.stringify(data));
	}

	function handleMessage(data: Dynamic) {
		switch (Reflect.getProperty(data, "command")) {
			case "startGame":
				_inGame = true;
				_seed = Reflect.getProperty(data, "seed");
				_teamId = Reflect.getProperty(data, "teamId");
				_currentTeamId = 1;

			case "touch":
				var x: Int = Reflect.getProperty(data, "x");
				var y: Int = Reflect.getProperty(data, "y");
				_inputQueue.push(Touch(x, y));

			case "currentTurn":
				_currentTeamId = Reflect.getProperty(data, "teamId");
				_activeTeamId = _currentTeamId;
				_inputQueue.push(CurrentTurn(_currentTeamId));
		}
	}
}
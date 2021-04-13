package arena.stage;

import haxe.Json;
import ws.Websocket;
import arena.stage.ArenaController.Input;

class ArenaControllerWS implements ArenaController {

	var _conn: WebsocketConnection;
	var _connected: Bool;
	var _inGame: Bool;
	var _teamId: Int;
	var _currentTeamId = 1;
	var _seed: Int;
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
        return 0;
    }

	public function connected():Bool {
		return _connected;
	}

    public function inGame(): Bool {
        return _inGame;
    }

	public function myTurn():Bool {
		return _teamId == _currentTeamId;
	}

	public function touch(x:Int, y:Int) {
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
		Websocket.send(_conn, Json.stringify({
			command: "hash",
			hash: hash,
		}));
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
				trace(_teamId);

			case "touch":
				var x: Int = Reflect.getProperty(data, "x");
				var y: Int = Reflect.getProperty(data, "y");
				_inputQueue.push(Touch(x, y));
		}
	}
}
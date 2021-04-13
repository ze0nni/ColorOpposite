package arena.stage;

import ws.Websocket;
import arena.stage.ArenaController.Input;

class ArenaControllerWS implements ArenaController {

	var _conn: WebsocketConnection;
	var _connected: Bool;
	var _inGame: Bool;
	var _teamId: Int;
	var _currentTeamId = 1;
	var _seed: Int;

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

	public function touch(x:Int, y:Int) {}

	public function readInput():Input {
		return None;
	}

	public function sendHash(turn:Int, hash:Int) {}

	public function disconnect(): Void {
		Websocket.disconnect(_conn);
    }

	function handleMessage(data: Dynamic) {
		switch (Reflect.getProperty(data, "command")) {
			case "startGame":
				_inGame = true;
				_seed = Reflect.getProperty(data, "seed");
				_teamId = Reflect.getProperty(data, "teamId");
				_currentTeamId = 1;
				trace(_teamId);
		}
	}
}
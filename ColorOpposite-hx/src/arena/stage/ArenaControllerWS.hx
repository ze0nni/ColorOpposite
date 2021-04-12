package arena.stage;

import ws.Websocket;
import arena.stage.ArenaController.Input;

class ArenaControllerWS implements ArenaController {

    public function new(url: String) {
        var conn = Websocket.connect(url, {}, function (_, conn, data) {
			if (data.event == EVENT_CONNECTED) {
				Websocket.send(conn, "Hello");
			} else {
				trace(data);
			}
		});
    }

	public function connected():Bool {
		return true;
	}

	public function myTurn():Bool {
		return false;
	}

	public function touch(x:Int, y:Int) {}

	public function readInput():Input {
		return None;
	}

	public function sendHash(turn:Int, hash:Int) {}
}
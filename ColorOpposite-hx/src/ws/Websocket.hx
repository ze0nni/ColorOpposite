package ws;

@:native("websocket")
extern class Websocket {
    public static function connect<TSelf>(url: String, params: WSParams, callback: WSCallback<TSelf>): WebsocketConnection;
    public static function disconnect(connection: WebsocketConnection): Void;
    public static function send(connection: WebsocketConnection, message: String): Void;
}


abstract WSCallback<TSelf>(TSelf -> WebsocketConnection -> WSEventData -> Void) from TSelf -> WebsocketConnection -> WSEventData -> Void {
}

typedef WSParams = {

}

typedef WSEventData = {
    var event(default, never): WSEvent;
    var message(default, never): String;
}

@:enum abstract WSEvent(Int) {
    var EVENT_CONNECTED : WSEvent = 0;
    var EVENT_DISCONNECTED : WSEvent = 1;
    var EVENT_MESSAGE : WSEvent = 2;
    var EVENT_ERROR : WSEvent = 3;
}

extern class WebsocketConnection {
    
}
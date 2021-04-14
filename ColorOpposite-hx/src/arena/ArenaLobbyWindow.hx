package arena;

import defold.Go.GoMessages;
import defold.Gui.GuiNode;

typedef ArenaLobbyWindowData = {
    var label: GuiNode;
}

@:publicFields
class ArenaLobbyWindowMessages {
    static var show(default, never) = new Message<Void>("arena_lobby_window_show");
    static var connected(default, never) = new Message<Void>("arena_lobby_window_connected");
    static var disconnected(default, never) = new Message<Void>("arena_lobby_window_disconnected");
    static var in_game(default, never) = new Message<Void>("arena_lobby_window_in_game");
}

class ArenaLobbyWindow extends GuiScript<ArenaLobbyWindowData> {
    override function init(self:ArenaLobbyWindowData) {
        self.label = Gui.get_node(ArenaLobbyWindowRes.label);
    }

    override function on_message<TMessage>(self:ArenaLobbyWindowData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case GoMessages.enable:
                Msg.post(".", GoMessages.acquire_input_focus); 

            case GoMessages.disable:
                Msg.post(".", GoMessages.release_input_focus); 

            case ArenaLobbyWindowMessages.show:
                Gui.set_text(self.label, "Connecting...");

            case ArenaLobbyWindowMessages.connected:
                Gui.set_text(self.label, "Search opponent");

            case ArenaLobbyWindowMessages.disconnected:
                Gui.set_text(self.label, "Disconnected");

            case ArenaLobbyWindowMessages.in_game:
                Gui.set_text(self.label, "Game started");
        }
    }

    override function on_input(self:ArenaLobbyWindowData, action_id:Hash, action:ScriptOnInputAction):Bool {
        return true;
    }
}
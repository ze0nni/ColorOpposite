package arena;

import defold.Gui.GuiNode;

typedef ArenaScreenGuiData = {
    var timerText: GuiNode;
}

@:publicFields
class ArenaScreenGuiMessages {
    static var time_left(default, never) = new Message<{left:Int, total: Int}>("arena_screen_gui_time_left");
}

class ArenaScreenGui extends GuiScript<ArenaScreenGuiData> {
    override function init(self:ArenaScreenGuiData) {
        self.timerText = Gui.get_node(ArenaScreenGuiRes.timerText);
    }

    override function on_message<TMessage>(self:ArenaScreenGuiData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case ArenaScreenGuiMessages.time_left: {
                Gui.set_text(self.timerText, Std.string(message.left));
            }
        }
    }
}
package arena;

import defold.Gui.GuiEasing;
import defold.Gui.GuiNode;

typedef ArenaScreenGuiData = {
    var timerText: GuiNode;
    var timerFill: GuiNode;
}

@:publicFields
class ArenaScreenGuiMessages {
    static var time_left(default, never) = new Message<{left:Int, total: Int}>("arena_screen_gui_time_left");
}

class ArenaScreenGui extends GuiScript<ArenaScreenGuiData> {
    override function init(self:ArenaScreenGuiData) {
        self.timerText = Gui.get_node(ArenaScreenGuiRes.timerText);
        self.timerFill = Gui.get_node(ArenaScreenGuiRes.timer_fill);
    }

    override function on_message<TMessage>(self:ArenaScreenGuiData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case ArenaScreenGuiMessages.time_left: {
                Gui.set_text(self.timerText, Std.string(message.left));
                var ratio = message.left / message.total;
                Gui.animate(self.timerFill, "size.x", 800 * ratio, GuiEasing.EASING_LINEAR, 1);
            }
        }
    }
}
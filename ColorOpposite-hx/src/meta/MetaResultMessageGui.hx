package meta;

import gui.GUI;
import defold.Go.GoMessages;
import arena.stage.RoomResult;

typedef MetaResultMessageData = {
    var gui: GUI;
}

@:publicFields
class MetaResultMessageGuiMessages {
    static var setup(default, never) = new Message<{
        winnder: Bool,
        result: RoomResult,
        score: Int,
        oponentScore: Int
    }>("meta_result_message_gui_setup");
}

class MetaResultMessageGui extends GuiScript<MetaResultMessageData> {

    override function init(self:MetaResultMessageData) {
        Gui.set_render_order(MetaScreen.GUI_POPUP);
        
        self.gui = new GUI(InputRes.touch, ResultWindowText, 1);
        self.gui.buttonUpDown("success", true).OnClickHandle(function () {
            MetaScreen.HideWindows();
        });
    }

    override function final_(self:MetaResultMessageData) {
        super.final_(self);
    }

    override function on_message<TMessage>(self:MetaResultMessageData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case GoMessages.enable:
                Msg.post(".", GoMessages.acquire_input_focus);

            case GoMessages.disable:
                Msg.post(".", GoMessages.release_input_focus);

            case MetaResultMessageGuiMessages.setup:
        }
    }

    override function on_input(self:MetaResultMessageData, action_id:Hash, action:ScriptOnInputAction):Bool {
        self.gui.on_input(action_id, action);
        return true;
    }
}
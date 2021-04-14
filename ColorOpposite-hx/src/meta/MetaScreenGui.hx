package meta;

import arena.ArenaScreen;
import arena.stage.Arena;
import gui.TextMap.TextRoot;
import defold.Go.GoMessages;
import gui.GUI;

typedef MetaScreenGuiData = {
    var gui: GUI;
}

class MetaScreenGui extends GuiScript<MetaScreenGuiData> {
    override function init(self:MetaScreenGuiData) {
        Msg.post(".", GoMessages.acquire_input_focus);

        self.gui = new GUI(InputRes.touch, TextRoot.MetaScreen, 1);

        self.gui
            .buttonUpDown("startSingle", true)
            .OnClickHandle(function () {
               ArenaScreen.EnterCommon(); 
            });

        self.gui
            .buttonUpDown("startPvp", true)
            .OnClickHandle(function () {
                ArenaScreen.EnterWs("ws://127.0.0.1:80/ws");
            });
    }

    override function on_input(self:MetaScreenGuiData, action_id:Hash, action:ScriptOnInputAction):Bool {
        self.gui.on_input(action_id, action);
        return true;
    }
}
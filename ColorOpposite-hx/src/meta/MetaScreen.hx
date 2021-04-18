package meta;

import meta.MetaResultMessageGui.MetaResultMessageGuiMessages;
import gui.Windows;
import arena.stage.RoomResult;

typedef MetaScreenData = {
    var windows: Windows;
}

enum Enter {
    Common;
    Disconnected;
    Result(winnder: Bool, result: RoomResult, score: Int, oponentScore: Int);
}

class MetaScreen extends Script<MetaScreenData> {

    static public inline var GUI_SCREEN = 0;
    static public inline var GUI_POPUP = 1;
    
    static var Instance: MetaScreenData;

    static var Enter: Enter;

    static public function EnterCommon() {
        Enter = Common;
        Main.gotoScreen(MainRes.screen_collection_proxy_meta);
    }

    static public function EnterDisconnected() {
        Enter = Disconnected;
        Main.gotoScreen(MainRes.screen_collection_proxy_meta);
    }

    static public function EnterResult(winnder: Bool, result: RoomResult, score: Int, oponentScore: Int) {
        Enter = Result(winnder, result, score, oponentScore);
        Main.gotoScreen(MainRes.screen_collection_proxy_meta);
    }

    override function init(self:MetaScreenData) {
        self.windows = new Windows(MetaScreenRes.gui);
        self.windows.register("result", MetaScreenRes.resultMessage);
        Instance = self;

        switch (Enter) {
            case Common:
                //
            case Disconnected:
                //
            case Result(winner, result, score, oponentScore):
                showResultWindow(self, winner, result, score, oponentScore);
        }
    }

    override function final_(self:MetaScreenData) {
        Instance = null;
    }

    static public function HideWindows() {
        Instance.windows.hide();
    }

    function showResultWindow(self: MetaScreenData, winnder: Bool, result: RoomResult, score: Int, oponentScore: Int) {
        Msg.post(
            self.windows.show("result"),
            MetaResultMessageGuiMessages.setup,
            {
                winnder: winnder,
                result: result,
                score: score,
                oponentScore: oponentScore
            }
        );
    }
}
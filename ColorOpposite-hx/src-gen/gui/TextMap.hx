package gui;

import model.*;

@:enum abstract TextRoot(String) to String {
    var MetaScreenText: TextRoot = "MetaScreen";
    var ResultWindowText: TextRoot = "ResultWindow";
}

class TextMap {
    

    static public function gui(root: TextRoot, id: String): String {
        switch (root) {
            case MetaScreenText: switch (id) {
                case "startSingle/text":
                    return "Single";

                case "startPvp/text":
                    return "PvP";
            }   
            default:
                //

        }
        return '${root}:${id}';
    }
}
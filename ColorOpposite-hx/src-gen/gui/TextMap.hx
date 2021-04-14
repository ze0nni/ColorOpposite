package gui;

import model.*;

@:enum abstract TextRoot(String) to String {
    var MetaScreen: TextRoot = "MetaScreen";
}

class TextMap {
    

    static public function gui(root: TextRoot, id: String): String {
        switch (root) {
            case MetaScreen: switch (id) {
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
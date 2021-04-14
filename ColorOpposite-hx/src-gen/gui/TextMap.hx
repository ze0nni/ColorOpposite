package gui;

import model.*;

@:enum abstract TextRoot(String) to String {
    var Meta: TextRoot = "Meta";
    var EquipWindow: TextRoot = "EquipWindow";
    var StatWindow: TextRoot = "StatWindow";
    var System: TextRoot = "System";
    var TerrainScreen: TextRoot = "TerrainScreen";
    var ArenaScreenGui: TextRoot = "ArenaScreenGui";
}

class TextMap {
    

    static public function gui(root: TextRoot, id: String): String {
        switch (root) {
            case Meta: switch (id) {
                case "newGame/text":
                    return "New game";
            }
            default:
                //

        }
        return '${root}:${id}';
    }
}
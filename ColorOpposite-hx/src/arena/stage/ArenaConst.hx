package arena.stage;

enum Layer {
    Cell;
    Board;
    OverBoard;
}

class ArenaConst {
    inline public static var TileSize = 92;

    static public function tileCenter(x: Int, y: Int, layer: Layer): Vector3 {
        var z = switch (layer) {
            case Cell: -0.5;
            case Board: 0;
            case OverBoard: 0.5;
        };
        return Vmath.vector3(x * TileSize + TileSize / 2, y * TileSize + TileSize / 2, z);
    }
}
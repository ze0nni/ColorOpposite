package arena.stage;

class ArenaConst {
    inline public static var TileSize = 92;

    static public function tileCenter(x: Int, y: Int): Vector3 {
        return Vmath.vector3(x * TileSize + TileSize / 2, y * TileSize + TileSize / 2, 0);
    }
}
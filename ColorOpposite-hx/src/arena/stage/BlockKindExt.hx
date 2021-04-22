package arena.stage;

class BlockKindExt {
    inline public static function isColorBlock(kind: BlockKind) {
        return kind == Color1
            || kind == Color2
            || kind == Color3
            || kind == Color4
            || kind == Color5
            || kind == Color6
            ;
    }

    inline public static function isPowerup(kind: BlockKind) {
        return isRocket(kind);
    }

    inline public static function isRocket(kind: BlockKind) {
        return kind == RocketVert
            || kind == RocketHor
            ;
    }
}
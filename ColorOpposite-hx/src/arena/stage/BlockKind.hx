package arena.stage;

@:enum abstract BlockKind(Int) {
    var None: BlockKind = 0;
    var Color1: BlockKind = 1;
    var Color2: BlockKind = 2;
    var Color3: BlockKind = 3;
    var Color4: BlockKind = 4;
    var Color5: BlockKind = 5;
    var Color6: BlockKind = 6;

    var RocketVert: BlockKind = 7;
    var RocketHor: BlockKind = 8;
}
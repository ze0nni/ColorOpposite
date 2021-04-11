package arena.stage;

typedef Block = {
    var id(default, null): Identity<Block>;
    
    var kind: BlockKind;
    var x: Int;
    var y: Int;
}
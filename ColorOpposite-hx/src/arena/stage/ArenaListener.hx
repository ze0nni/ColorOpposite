package arena.stage;

interface ArenaListener<TSelf> {
    function onResize(self: TSelf, size: Int): Void;
    
    function onBlockSpawned(self: TSelf, block: Block, reason: BlockSpawnReason): Void;
    function onBlockDespawned(self: TSelf, id: Identity<Block>): Void;
    function onBlockMoved(self: TSelf, id: Identity<Block>, x: Int, y: Int): Void;
    function onBlockKindChanged(self: TSelf, id: Identity<Block>, kind: BlockKind): Void;

    function onMatched(self: TSelf, x: Int, y: Int, score: Int): Void;
}
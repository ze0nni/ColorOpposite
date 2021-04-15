package arena.stage;

interface ArenaListener<TSelf> {
    function onResize(self: TSelf, size: Int): Void;
    
    function onBlockSpawned(self: TSelf, block: Block, reason: BlockSpawnReason): Void;
    function onBlockDespawned(self: TSelf, id: Identity<Block>): Void;
    function onBlockMoved(self: TSelf, id: Identity<Block>, x: Int, y: Int): Void;
    function onBlockKindChanged(self: TSelf, id: Identity<Block>, kind: BlockKind): Void;

    function onMatched(self: TSelf, x: Int, y: Int, score: Int): Void;

    function onConnected(self: TSelf): Void;
    function onDisconnected(self: TSelf): Void;
    function onInGame(self: TSelf, rounds: Int, turnsInRount: Int): Void;
    function onCurrentRound(self: TSelf, teamId: Int): Void;
    function onCurrentTurn(self: TSelf, teamId: Int): Void;
    function onTurnTimeLeft(self: TSelf, left: Int, total: Int): Void;
}
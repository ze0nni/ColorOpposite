package arena.stage;

import arena.stage.BlockKind;
import arena.stage.Block;

enum ArenaEvent {
    Resize(size: Int);
    
    BlockSpawned(block: Block, reason: BlockSpawnReason);
    BlockDespawned(id: Identity<Block>);
    BlockMoved(id: Identity<Block>, x: Int, y: Int);
    BlockKindChanged(id: Identity<Block>, kind: BlockKind);
}
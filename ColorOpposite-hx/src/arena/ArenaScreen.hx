package arena;

import arena.BlockView.BlockViewMessages;
import arena.stage.Block;
import arena.stage.ArenaEvent;
import arena.stage.Arena;

typedef ArenaScreenData = {
    var blocks: Map<Identity<Block>, Hash>;

    var arena: Arena;
}

class ArenaScreen extends Script<ArenaScreenData> {
    public static function Enter() {
        Main.gotoScreen(MainRes.screen_collection_proxy_arena);
    }

    public static var ArenaInst(default, null): Arena;

    override function init(self:ArenaScreenData) {
        self.blocks = new Map();

        self.arena = Arena.Empty(function(event: ArenaEvent) {
            onArenaEvent(self, event);
        });

        ArenaInst = self.arena;
    }

    override function final_(self:ArenaScreenData) {
        ArenaInst = null;
    }

    override function update(self:ArenaScreenData, dt:Float) {
        self.arena.update(dt);
    }

    function onArenaEvent(self: ArenaScreenData, event: ArenaEvent) {
        switch (event) {
            case Resize(size):
            
            case BlockSpawned(block, reason):
                var blockId = Factory.create(ArenaScreenRes.arena_block_factory);
                self.blocks[block.id] = blockId;
                Go.set_parent(blockId, ArenaScreenRes.arena);
                Msg.post(blockId, BlockViewMessages.setup, {block:block,reason: reason});

            case BlockDespawned(id):
                var blockId = self.blocks[id];
                if (blockId != null) {
                    Go.delete(blockId);
                    self.blocks.remove(id);
                }

            case BlockMoved(id, x, y):
                var blockId = self.blocks[id];
                if (blockId != null) {
                    Msg.post(blockId, BlockViewMessages.move, {x:x, y:y});
                }

            case BlockKindChanged(id, kind):
        }
    }
}
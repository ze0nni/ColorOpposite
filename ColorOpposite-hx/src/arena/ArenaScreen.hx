package arena;

import lua.lib.luasocket.socket.SelectResult;
import defold.Go.GoMessages;
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
        Msg.post(".", GoMessages.acquire_input_focus);

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

    override function on_input(self:ArenaScreenData, action_id:Hash, action:ScriptOnInputAction):Bool {
        switch (action_id) {
            case InputRes.touch:
                if (!action.pressed)
                    return true;
                var arenaPos = Go.get_position(ArenaScreenRes.arena);
                var mousePos = Main.screen_to_viewport(action.screen_x, action.screen_y);
                var arenaX = Std.int((mousePos.x - arenaPos.x) / ArenaConst.TileSize);
                var arenaY = Std.int((mousePos.y - arenaPos.y) / ArenaConst.TileSize);
                
                self.arena.touchCell(arenaX, arenaY);
        }

        return true;
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
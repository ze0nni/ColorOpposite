package arena;

import arena.stage.ArenaController.Common;
import lua.lib.luasocket.socket.SelectResult;
import defold.Go.GoMessages;
import arena.BlockView.BlockViewMessages;
import arena.stage.Block;
import arena.stage.ArenaEvent;
import arena.stage.Arena;

typedef ArenaScreenData = {
    var blocks: Map<Identity<Block>, Hash>;

    var arena: Arena<ArenaScreenData>;
    var controller: ArenaController;
}

enum Enter {
    Common;
    WS(url: String);
}

class ArenaScreen extends Script<ArenaScreenData> implements ArenaListener<ArenaScreenData> {

    static var enter: Enter;

    public static function EnterCommon() {
        enter = Common;
        Main.gotoScreen(MainRes.screen_collection_proxy_arena);
    }

    public static function EnterWs(url: String) {
        enter = WS(url);
        Main.gotoScreen(MainRes.screen_collection_proxy_arena);
    }

    public static var ArenaInst(default, null): Arena<ArenaScreenData>;

    override function init(self:ArenaScreenData) {
        Msg.post(".", GoMessages.acquire_input_focus);

        self.blocks = new Map();

        self.controller = switch (enter) {
            case Common:
                new Common();
            case WS(url):
                new ArenaControllerWS(url);
        }

        self.arena = Arena.Empty(self, this, self.controller);

        ArenaInst = self.arena;
    }

    override function final_(self:ArenaScreenData) {
        ArenaInst = null;
    }

    override function update(self:ArenaScreenData, dt:Float) {
        if (!self.controller.inGame())
            return;
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

    public function onResize(self: ArenaScreenData, size: Int): Void {
        var width = size * ArenaConst.TileSize;
        Go.set_position(
            Vmath.vector3(width/2, width/2, 1),
            ArenaScreenRes.solid
        );
        Go.set_scale(
            width * (64/ArenaConst.TileSize),
            ArenaScreenRes.solid
        );
        Go.set(
            ArenaScreenRes.solid_sprite,
            "tint",
            Vmath.vector4(0, 0, 0, 0.5)
        );
    }
    
    public function onBlockSpawned(self: ArenaScreenData, block: Block, reason: BlockSpawnReason): Void {
        var blockId = Factory.create(ArenaScreenRes.arena_block_factory);
        self.blocks[block.id] = blockId;
        Go.set_parent(blockId, ArenaScreenRes.arena);
        Msg.post(blockId, BlockViewMessages.setup, {block:block,reason: reason});
    }

    public function onBlockDespawned(self: ArenaScreenData, id: Identity<Block>): Void {
        var blockId = self.blocks[id];
        if (blockId != null) {
            Go.delete(blockId);
            self.blocks.remove(id);
        }
    }

    public function onBlockMoved(self: ArenaScreenData, id: Identity<Block>, x: Int, y: Int): Void {
        var blockId = self.blocks[id];
        if (blockId != null) {
            Msg.post(blockId, BlockViewMessages.move, {x:x, y:y});
        }
    }

    public function onBlockKindChanged(self: ArenaScreenData, id: Identity<Block>, kind: BlockKind): Void {

    }

    public function onMatched(self: ArenaScreenData, x: Int, y: Int, score: Int): Void {

    }

    public function onCurrentTurn(self: ArenaScreenData, teamId: Int): Void {
        if (teamId == self.controller.teamId()) {
            Msg.post(ArenaScreenRes.solid, GoMessages.disable);
        } else {
            Msg.post(ArenaScreenRes.solid, GoMessages.enable);
        }
    }
}
package arena;

import arena.RocketView.RocketMessages;
import defold.Go.GoEasing;
import defold.Go.GoPlayback;

typedef BlockViewData = {
    var block: Block;
    
    var isCellLocked: Bool;
    var lockedCellX: Int;
    var lockedCellY: Int;
}

@:publicFields
@:publicFields
class BlockViewMessages {
    static var setup(default, never) = new Message<{block:Block, reason:BlockSpawnReason}>("block_view_setup");
    static var remove(default, never) = new Message<Void>("block_view_remove");
    static var move(default, never) = new Message<{x: Int, y: Int}>("block_view_move");
    static var activate(default, never) = new Message<{x: Int, y: Int}>("block_view_activate");
}

class BlockView extends Script<BlockViewData> {
    override function on_message<TMessage>(self:BlockViewData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case BlockViewMessages.setup:
                self.block = message.block;
                setSprite(self, message.block.kind);

                switch (message.reason) {
                    case Swap:
                        Go.set_position(ArenaConst.tileCenter(message.block.x, message.block.y, Board));
                    
                    case Generate:
                        Go.set_position(ArenaConst.tileCenter(message.block.x, message.block.y+1, Board));
                        lockCell(self, message.block.x, message.block.y);
                        Go.animate(
                            ".",
                            "position",
                            GoPlayback.PLAYBACK_ONCE_FORWARD,
                            ArenaConst.tileCenter(message.block.x, message.block.y, Board),
                            GoEasing.EASING_LINEAR,
                            0.15,
                            0,
                            move_done);
                        }
            case BlockViewMessages.remove:
                Go.delete();

            case BlockViewMessages.move:
                lockCell(self, message.x, message.y);
                Go.animate(
                    ".",
                    "position",
                    GoPlayback.PLAYBACK_ONCE_FORWARD,
                    ArenaConst.tileCenter(message.x, message.y, Board),
                    GoEasing.EASING_LINEAR,
                    0.08,
                    0,
                    move_done);

            case BlockViewMessages.activate:
                activate(self, message.x, message.y);
        }
    }

    function move_done(self:BlockViewData, _, _) {
        unlockCell(self);
    }

    inline function lockCell(self:BlockViewData, x: Int, y: Int) {
        unlockCell(self);
        self.isCellLocked = true;
        self.lockedCellX = x;
        self.lockedCellY = y;
        ArenaScreen.ArenaInst.lockCell(x, y);
    }

    inline function unlockCell(self:BlockViewData) {
        if (self.isCellLocked) {
            self.isCellLocked = false;
            ArenaScreen.ArenaInst.unlockCell(self.lockedCellX, self.lockedCellY);
        }
    }

    function setSprite(self:BlockViewData, kind: BlockKind) {
        var image;
        switch (kind) {
            case Color1: image = ArenaAtlasRes.Jelly_1;
            case Color2: image = ArenaAtlasRes.Jelly_2;
            case Color3: image = ArenaAtlasRes.Jelly_3;
            case Color4: image = ArenaAtlasRes.Jelly_4;
            case Color5: image = ArenaAtlasRes.Jelly_5;
            case Color6: image = ArenaAtlasRes.Jelly_6;
            case RocketHor: image = ArenaAtlasRes.Rocket_Hor;
            case RocketVert: image = ArenaAtlasRes.Rocket_Vert;
            default:
                return;
        }
        Sprite.play_flipbook(BlockViewRes.sprite, image);
    }

    function activate(self:BlockViewData, x: Int, y: Int) {
        if (self.block.kind == RocketVert || self.block.kind == RocketHor) {
            var r1 = Factory.create(BlockViewRes.factory_rocket);
            var r2 = Factory.create(BlockViewRes.factory_rocket);
            Go.set_parent(r1, ArenaScreenRes.arena);
            Go.set_parent(r2, ArenaScreenRes.arena);

            if (self.block.kind == RocketHor) {
                Msg.post(r1, RocketMessages.setup, {x: x, y: y, dx: -1, dy: 0});
                Msg.post(r2, RocketMessages.setup, {x: x, y: y, dx: 1, dy: 0});
            } else {
                Msg.post(r1, RocketMessages.setup, {x: x, y: y, dx: 0, dy: -1});
                Msg.post(r2, RocketMessages.setup, {x: x, y: y, dx: 0, dy: 1});
            }
        } else {
            throw 'Can\'t activate ${self.block.kind}';
        }
    }
}
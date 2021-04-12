package arena;

import defold.Go.GoEasing;
import defold.Go.GoPlayback;

typedef BlockViewData = {
    var isCellLocked: Bool;
    var lockedCellX: Int;
    var lockedCellY: Int;
}

@:publicFields
@:publicFields
class BlockViewMessages {
    static var setup(default, never) = new Message<{block:Block, reason:BlockSpawnReason}>("block_view_setup");
    static var move(default, never) = new Message<{x: Int, y: Int}>("block_view_move");
}

class BlockView extends Script<BlockViewData> {
    override function on_message<TMessage>(self:BlockViewData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case BlockViewMessages.setup:
                setSprite(self, message.block.kind);

                switch (message.reason) {
                    case Swap:
                        Go.set_position(ArenaConst.tileCenter(message.block.x, message.block.y));
                    
                    case Generate:
                        Go.set_position(ArenaConst.tileCenter(message.block.x, message.block.y+1));
                        lockCell(self, message.block.x, message.block.y);
                        Go.animate(
                            ".",
                            "position",
                            GoPlayback.PLAYBACK_ONCE_FORWARD,
                            ArenaConst.tileCenter(message.block.x, message.block.y),
                            GoEasing.EASING_LINEAR,
                            0.15,
                            0,
                            move_done);
                        }

            case BlockViewMessages.move:
                lockCell(self, message.x, message.y);
                Go.animate(
                    ".",
                    "position",
                    GoPlayback.PLAYBACK_ONCE_FORWARD,
                    ArenaConst.tileCenter(message.x, message.y),
                    GoEasing.EASING_LINEAR,
                    0.15,
                    0,
                    move_done);
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
            case None:
                return;
            case Color1: image = ArenaAtlasRes.Jelly_1;
            case Color2: image = ArenaAtlasRes.Jelly_2;
            case Color3: image = ArenaAtlasRes.Jelly_3;
            case Color4: image = ArenaAtlasRes.Jelly_4;
            case Color5: image = ArenaAtlasRes.Jelly_5;
            case Color6: image = ArenaAtlasRes.Jelly_6;
        }
        Sprite.play_flipbook(BlockViewRes.sprite, image);
    }
}
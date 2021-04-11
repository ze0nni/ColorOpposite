package arena;

import defold.Go.GoEasing;
import defold.Go.GoPlayback;

typedef BlockViewData = {
    
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
                switch (message.reason) {
                    case Swap:
                        Go.set_position(ArenaConst.tileCenter(message.block.x, message.block.y));
                    
                    case Generate:
                        Go.set_position(ArenaConst.tileCenter(message.block.x, message.block.y+1));
                        Go.animate(
                            ".",
                            "position",
                            GoPlayback.PLAYBACK_ONCE_FORWARD,
                            ArenaConst.tileCenter(message.block.x, message.block.y),
                            GoEasing.EASING_LINEAR,
                            0.15);
                        }

            case BlockViewMessages.move:
                ArenaScreen.ArenaInst.lockCell(message.x, message.y);
                Go.animate(
                    ".",
                    "position",
                    GoPlayback.PLAYBACK_ONCE_FORWARD,
                    ArenaConst.tileCenter(message.x, message.y),
                    GoEasing.EASING_LINEAR,
                    0.15,
                    0,
                    function (_,_,_) {
                        ArenaScreen.ArenaInst.unlockCell(message.x, message.y);
                    });
        }
    }
}
package arena;

import defold.Go.GoEasing;

typedef Data = {
    var x: Float;
    var y: Float;
    var cells: Array<{x:Int, y: Int}>;
}

@:publicFields
class RocketMessages {
    static var setup(default, never) = new Message<{x: Int, y: Int, dx: Int, dy: Int}>("rocket_setup");
}

class RocketView extends Script<Data> {
    override function init(self:Data) {
        self.cells = [];
    }

    override function update(self:Data, dt:Float) {
        var pos = Go.get_position();
        var d = Std.int(Math.sqrt(
            Math.pow(pos.x - self.x, 2) +
            Math.pow(pos.y - self.y, 2))
         / ArenaConst.TileSize);
        if (d > 8) {
            Go.delete();
        }

        for (i in 0...Std.int(Math.min(8, d))) {
            if (self.cells[i] == null)
                continue;
            var cell = self.cells[i];
            self.cells[i] = null;
            trace(cell);
            ArenaScreen.ArenaInst.unlockCell(cell.x, cell.y);
        }
    }

    override function on_message<TMessage>(self:Data, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case RocketMessages.setup:
                var pos = ArenaConst.tileCenter(message.x, message.y, OverBoard);
                self.x = pos.x;
                self.y = pos.y;
                Go.set_position(pos);
                Go.animate(".",
                    "position",
                    PLAYBACK_ONCE_FORWARD,
                    ArenaConst.tileCenter(message.x + 8 * message.dx, message.y + 8 * message.dy, OverBoard),
                    GoEasing.EASING_LINEAR,
                    0.3);

                for (i in 1...8) {
                    var x = message.x + i * message.dx;
                    var y = message.y + i * message.dy;
                    self.cells.push({x:x, y:y});
                    ArenaScreen.ArenaInst.lockCell(x, y);
                }
        }
    }
}
package arena;

import defold.Msg;

@:publicFields
class ArenaScreenRes {
    static var arena = Msg.url("arena:/arena");
    
    static var arena_block_factory = Msg.url("arena:/arena#block_factory");
}
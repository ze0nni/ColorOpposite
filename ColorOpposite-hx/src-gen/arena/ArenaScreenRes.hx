package arena;

import defold.Msg;

@:publicFields
class ArenaScreenRes {
    static var arena(default,never) = Msg.url("arena:/arena");
    
    static var arena_block_factory(default,never) = Msg.url("arena:/arena#block_factory");

    static var solid(default,never) = Msg.url("arena:/solid");
    static var solid_sprite(default,never) = Msg.url("arena:/solid#sprite");

    static var gui(default,never) = Msg.url("arena:/gui");
    static var window_lobby(default,never) = Msg.url("arena:/window_lobby");
}
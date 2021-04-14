package;

import defold.Msg;

@:publicFields
class MainRes {
    static var screen = Msg.url("main:/screen");

    static var screen_collection_proxy_arena(default,never) = Msg.url("main:/screen#collection_proxy_arena");
    static var screen_collection_proxy_meta(default,never) = Msg.url("main:/screen#collection_proxy_meta");
}
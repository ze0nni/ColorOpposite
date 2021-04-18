package meta;

import defold.Msg;

@:publicFields
class MetaScreenRes {
    static var gui(default,never) = Msg.url("meta:/gui");

    static var resultMessage(default,never) = Msg.url("meta:/resultMessage");
}
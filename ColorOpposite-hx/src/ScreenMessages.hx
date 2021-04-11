package;

@:publicFields
class ScreenMessages {
    static var goto_screen(default, never) = new Message<{screen: Url}>("main_goto_screen");
}
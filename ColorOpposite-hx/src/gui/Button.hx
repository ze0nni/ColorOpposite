package gui;

import defold.Gui.GuiNode;

@:allow(gui.GUI)
class Button {
    public var up(default, null): GuiNode;
    public var down(default, null): Null<GuiNode>;
    public var check(default, null): Null<GuiNode>;
    var click = new List<{target: Url, event: Message<Void>}>();
    var clickHandle = new List<Void -> Void>();
    var checked: Bool = false;
    var visible: Bool = true;

    inline function new(
        up: GuiNode,
        ?down: GuiNode
    ) {
        this.up = up;
        this.down = down;
    }

    public function CheckNode(node: GuiNode): Button {
        this.check = node;
        setChecked(checked);
        return this;
    }

    public function onClick(target: Url, event: Message<Void>): Button {
        click.push({target: target, event: event});
        return this;
    }

    public function onClick1<T>(target: Url, event: Message<T>, data: T): Button {
        return OnClickHandle(function () {
            Msg.post(target, event, data);
        });
    }

    public function OnClickHandle(handle: Void -> Void) : Button {
        clickHandle.add(handle);
        return this;
    }

    public function OnClickHandle1<T>(self: T,handle: T -> Void) : Button {
        clickHandle.add(function () handle(self));
        return this;
    }

    public function OnClickHandle2<T,D>(self: T, data: D,handle: T -> D -> Void) : Button {
        clickHandle.add(function () handle(self, data));
        return this;
    }

    inline function doClick() {
        for (e in click) {
            Msg.post(e.target, e.event);
        }
        for (h in clickHandle) {
            h();
        }
    }

    public function setVisible(value: Bool) {
        visible = value;
        Gui.set_enabled(up, value);
        if (down != null) {
            Gui.set_enabled(down, false);
        }
    }

    public function setChecked(value: Bool): Button {
        checked = value;
        if (this.check != null) {
            Gui.set_enabled(this.check, checked);
        }
        return this;
    }
}
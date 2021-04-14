package gui;

import gui.TextMap.TextRoot;
import defold.Gui.GuiNode;

enum Capture {
    None;
    ListBox(listbox: Listbox);
}

class GUI {

    var touchEvent: Hash;
    var textRoot: TextRoot;
    var scale: Float;

    var buttons = new Array<Button>();
    var listboxes = new Array<Listbox>();

    var _capture: Capture = None;

    public function new(touchEvent: Hash, textRoot: TextRoot, scale: Float) {
        this.touchEvent = touchEvent;
        this.textRoot = textRoot;
        this.scale = scale;
    }

    public function release() {
        buttons.resize(0);
        listboxes.resize(0);
        _capture = None;
    }

    public function on_input(action_id:Hash, action:ScriptOnInputAction): Bool {
        if (action_id != this.touchEvent) {
            return false;
        }
        
        switch (_capture) {
            case None:
                //...
            case ListBox(listbox):
                performListbox(listbox, action_id, action, true);
        }

        var result = false;
        for (b in buttons) {
            if (performButton(b, action_id, action)) {
                result = true;
            }
        }

        for (l in listboxes) {
            performListbox(l, action_id, action, false);
            if (_capture != None) {
                return true;
            }
        }

        return result;
    }

    inline function performButton(b: Button, action_id:Hash, action:ScriptOnInputAction): Bool {
        if (!b.visible) {
            return false;
        }
        var result = false;

        var over = Gui.pick_node(b.up, action.x, action.y);
        if (over) {
            result = true;
        }

        if (!action.released) {
            if (b.down != null) {
                Gui.set_enabled(b.up, !over);
                Gui.set_enabled(b.down, over);
            }
        } else {
            if (b.down != null) {
                Gui.set_enabled(b.up, true);
                Gui.set_enabled(b.down, false);
            }
            if (over) {
                b.doClick();
            }
        }

        return result;
    }

    function performListbox(l: Listbox, action_id:Hash, action:ScriptOnInputAction, captured: Bool) {
        if (!captured) {
            if (!action.pressed || !Gui.pick_node(l.box, action.x, action.y)) {
                return;
            }
            _capture = ListBox(l);
            l.capture(action);
        } else {
            l.update(action);
            if (action.released) {
                l.releaseCaptuere();
                _capture = None;
            }
        }
    }

    public function label(nodeName: String, customId: String = null) {
        var node = Gui.get_node(nodeName);
        Gui.set_text(node, TextMap.gui(textRoot, customId != null ? customId : nodeName));
    }

    public function button(
        up: GuiNode,
        ?down: GuiNode
    ) :Button {
        var button = new Button(up, down);
        if (button.down != null) {
            Gui.set_enabled(up, true);
            Gui.set_enabled(down, false);
        }

        this.buttons.push(button);
        return button;        
    }

    public function buttonUpDown(nodeName: String, withText: Bool = false): Button {
        if (withText) {
            var id = '${nodeName}/text';
            label(id);
            label('${nodeName}/text_down', id);
        }
        return button(
            Gui.get_node('${nodeName}/up'),
            Gui.get_node('${nodeName}/down')
        );
    }

    public function listbox(
        box: GuiNode,
        content: GuiNode
    ) {
        var list = new Listbox(box, content, scale);
        listboxes.push(list);
        return list;
    }
}
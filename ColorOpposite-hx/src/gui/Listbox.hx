package gui;

import defold.Gui.GuiNode;

abstract ListboxListener(Int -> Int -> Void) from (Int -> Int -> Void) {
    public function call(virualIndex: Int, index: Int) {
        this(virualIndex, index);
    }
}

@:allow(gui.GUI)
class Listbox {

    var box: GuiNode;
    var content: GuiNode;
    var scale: Float;
    var _itemHeight: Float = 1;
    var _contentPivot: Float = 0.5;

    var _topItem: Int = -1;
    var _topVirtualItem = 0;
    var _items: Array<GuiNode>;
    var _size: Int = 0;

    var _contentSize: Vector3;
    var _contentPos0: Vector3;
    var _contentPos: Vector3;

    var _listY: Float = 0;
    var _listY0: Float = 0;
    var _captureY: Float;

    var _listeners = new List<ListboxListener>();

    function new(
        box: GuiNode,
        content: GuiNode,
        scale: Float
    ) {
        this.box = box;
        this.content = content;
        this.scale = scale;

        _contentSize = Gui.get_size(content);
        _contentPos0 = Gui.get_position(content);
        _contentPos = Vmath.vector3(_contentPos0.x, _contentPos0.y, _contentPos0.z);
    }

    function capture(action:ScriptOnInputAction) {
        _captureY = action.y;
        _listY0 = _listY;
    }

    function update(action:ScriptOnInputAction) {
        _listY = Math.max(0,
                    Math.min(_itemHeight * _size - _contentSize.y,
                        _listY0 + (action.y - _captureY) / scale));
        updateScroll(false);
    }

    function releaseCaptuere() {
        
    }

    public function listen(listener: ListboxListener): Listbox {
        _listeners.add(listener);
        return this;
    }

    public function setItemHeight(value: Float): Listbox {
        _itemHeight = value;
        updateScroll(false);
        return this;
    }

    public function setContentPivot(value: Float): Listbox {
        _contentPivot =value;
        updateScroll(false);
        return this;
    }

    public function setItems(items: Array<GuiNode>) :Listbox {
        _items = items;
        updateScroll(true);
        return this;
    }

    var _itemPosTMP = Vmath.vector3();
    function updateScroll(force: Bool) {
        if (_items == null) {
            return;
        }

        _contentPos.y = _contentPos0.y + _listY % _itemHeight;
        Gui.set_position(content, _contentPos);
        
        var topItem = Std.int(_listY / _itemHeight);
        if (topItem == _topItem)
            return;

        _topItem = topItem;
        _topVirtualItem = _topItem % _items.length;

        var itemsSize = _items.length;

        for (i in 0..._items.length) {
            var index = _topItem + i;
            var vIndex = index % itemsSize;
            var node = _items[vIndex];
            if (index >= _size) {
                Gui.set_enabled(node, false);
            } else {
                _itemPosTMP.y
                    = _contentSize.y * _contentPivot
                    + _itemHeight * _contentPivot
                    - _itemHeight * i
                    ;
                Gui.set_enabled(node, true);
                Gui.set_position(node, _itemPosTMP);

                for (l in _listeners) {
                    l.call(vIndex, index);
                }
            }
        }
    }

    public function resize(size: Int) {
        _size = size;
        _topItem = -1;
        updateScroll(true);
    }
}
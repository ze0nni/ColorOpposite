package gui;

import haxe.Log;
import haxe.ds.Map;
import defold.Go.GoMessages;

class Windows {
    
    var _root: Url;

    var _currentId: Null<String>;
    var _currentWindow: Null<HashOrStringOrUrl>;
    var _windows = new Map<String, HashOrStringOrUrl>();

    public function new(root: Url) {
        _root = root;
    }

    public function release() {
        //TODO:
    }

    public function get(id: String): Null<HashOrStringOrUrl> {
        var result = _windows[id];
        if (result == null) {
            trace('Window not register: ${id}');
        }
        return result;
    }

    public function register(id: String, windowId: HashOrStringOrUrl) {
        _windows[id] = windowId;

        Go.set_parent(windowId, _root);
        Msg.post(windowId, GoMessages.disable);
    }

    public function registerFactory(id: String, factoryId: Url) {
        var windowId = Factory.create(factoryId);
        
        _windows[id] = windowId;

        Go.set_parent(windowId, _root);
        Msg.post(windowId, GoMessages.disable);
    }

    public function show(id: String): Null<HashOrStringOrUrl> {
        if (_currentId == id) {
            return _currentWindow;
        }

        if (_currentWindow != null) {
            Msg.post(_currentWindow, GoMessages.disable);
        }

        _currentWindow = _windows[id];
        if (_currentWindow == null) {
            _currentId = null;
            return null;
        }

        _currentId = id;
        Msg.post(_currentWindow, GoMessages.enable);

        return _currentWindow;
    }

    public function hide() {
        if (_currentWindow == null) {
            return;
        }
        Msg.post(_currentWindow, GoMessages.disable);
        _currentWindow = null;
        _currentId = null;
    }
}
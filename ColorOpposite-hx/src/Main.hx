import arena.stage.ArenaControllerWS;
import arena.stage.ArenaController.Common;
import arena.ArenaScreen;
import Screen.XY;
import defold.Collectionproxy.CollectionproxyMessages;
import defold.Go.GoMessages;

typedef MainData = {
	var currentScreen: Null<Url>;
}

class Main extends defold.support.Script<MainData> {

	var use_fixed_fit_projection(default, never) = new Message<{near: Float, far: Float}>("use_fixed_fit_projection");

	static var DISPLAY_WIDTH: Float;
	static var DISPLAY_HEIGHT: Float;

	public static function screen_to_viewport(x: Float, y: Float): XY {
		var wsize = Window.get_size();
		
		var sx = wsize.width / DISPLAY_WIDTH;
		var sy = wsize.height / DISPLAY_HEIGHT;
		var scale = Math.min(sx, sy);
		
		var ww = wsize.width / scale;
		var wh = wsize.height / scale;
		var ox = (ww - DISPLAY_WIDTH) / 2;
		var oy = (wh - DISPLAY_HEIGHT) / 2;

		x = x / scale - ox;
		y = y / scale - oy;

		return {
			x: x,
			y: y
		}
	}

	public static function gotoScreen(factory: Url) {
		Msg.post(MainRes.screen, ScreenMessages.goto_screen, { screen: factory});
	}

	override function init(self:MainData) {
		DISPLAY_WIDTH = Std.parseInt(Sys.get_config("display.width"));
		DISPLAY_HEIGHT = Std.parseInt(Sys.get_config("display.height"));

		Msg.post(".", GoMessages.acquire_input_focus);
		Msg.post("@render:", use_fixed_fit_projection, { near : -1, far : 1 });

		ArenaScreen.Enter(new Common());
		ArenaScreen.Enter(new ArenaControllerWS("ws://127.0.0.1:80/ws"));
	}

	override function on_message<TMessage>(self:MainData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
		switch (message_id) {
			case CollectionproxyMessages.proxy_loaded:
				self.currentScreen = sender;
				Msg.post(sender, CollectionproxyMessages.init);
				Msg.post(sender, CollectionproxyMessages.enable);

			case ScreenMessages.goto_screen:
				if (self.currentScreen != null) {
					Msg.post(self.currentScreen, CollectionproxyMessages.disable);
					Msg.post(self.currentScreen, CollectionproxyMessages.unload);
					self.currentScreen = null;
				}

				Msg.post(message.screen, CollectionproxyMessages.async_load);
		}
	}
}

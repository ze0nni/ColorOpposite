package meta;

typedef MetaScreenData = {

}

class MetaScreen extends Script<MetaScreenData> {
    static public function Enter() {
        Main.gotoScreen(MainRes.screen_collection_proxy_meta);
    }
}
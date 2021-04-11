package arena;

typedef BlockViewData = {
    
}

@:publicFields
@:publicFields
class BlockViewMessages {
    static var setup(default, never) = new Message<Block>("block_view_setup");
}

class BlockView extends Script<BlockViewData> {

}
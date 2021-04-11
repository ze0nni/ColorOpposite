package arena.stage;

@:enum abstract BlockSpawnReason(Int) {
    var Generate: BlockSpawnReason = 0;
    var Swap: BlockSpawnReason = 1;
}
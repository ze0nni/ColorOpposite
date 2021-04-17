package arena.stage;

typedef ArenaStage = {
    var identity: Int;
    var size(default, null): Int;
    var cells(default, null): Cells;

    var player1(default, null): Player;
    var player2(default, null): Player;
}
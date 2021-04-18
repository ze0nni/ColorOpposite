package arena.stage;

@:enum abstract RoomResult(Int) {
    var RoomResultDraw: RoomResult = 0;
    var RoomResultDone: RoomResult = 1;
    var RoomResultAuto: RoomResult = 2;
    var RoomResultFoul: RoomResult = 3;
}
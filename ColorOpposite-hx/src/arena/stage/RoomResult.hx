package arena.stage;

@:enum abstract RoomResult(Int) {
    var RoomResultDraw: RoomResult = 0;
    var RoomResultLeft: RoomResult = 1;
    var RoomResultRight: RoomResult = 2;
    var RoomResultLeftAuto: RoomResult = 3;
    var RoomResultRightAuto: RoomResult = 4;
    var RoomResultFoul: RoomResult = 5;
}
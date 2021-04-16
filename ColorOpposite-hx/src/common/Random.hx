package common;

class Random {

    var _seed: Int;

    inline public function new(seed: Int) {
        _seed = seed;
    }

    public function next(min: Int, max: Int): Int {
        var a = 45;
        var c = 21;
        var m = 67;
        _seed =  (a * _seed + c) % m;

        var r = max - min;
        var v = _seed % (r + 1);
        return min + v;
    }
}
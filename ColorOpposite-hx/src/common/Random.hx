package common;

import common.RandomLua.Generator;

class Random {

    var _generator: Generator;

    inline public function new(seed: Int) {
        _generator = RandomLua.mwc(seed, MVC);
    }

    public function next(min: Int, max: Int): Int {
        return _generator.random(min, max);
    }
}
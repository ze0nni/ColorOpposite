package common;

@:native("_G")
extern class RandomLua {
    @:overload(function (seed: Int): Generator {})
    public static function lcg(seed: Int, ng: LCGConst): Generator;
    
    @:overload(function (seed: Int): Generator {})
    public static function mwc(seed: Int, ng: LCGConst): Generator;

    public static function twister(seed: Int): Generator;
}

@:enum abstract LCGConst(String) {
    var NR: LCGConst = "nr";
    var MVC: LCGConst = "mvc";
}

extern class Generator {
    @:overload(function(a: Int): Int {})
    @:overload(function(a: Int, b: Int): Int {})
    public function random(): Float;
    
    public function randomseed(s: Int): Void;
}
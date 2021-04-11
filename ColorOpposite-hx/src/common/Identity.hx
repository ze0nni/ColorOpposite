package common;

abstract Identity<T>(Int) {
    inline public function invalid() {
        return this < 0;
    }
}
package arena.stage;

import haxe.ds.Vector;

typedef Cells = Array<Array<Cell>>;

class CellsExt {
    static public function Empty(size: Int): Cells {
        var result = new Array<Array<Cell>>();
        for (y in 0...size) {
            var row = new Array<Cell>();
            result.push(row);
            for (x in 0...size) {
                row.push({
                    block: null,
                });
            }
        }
        return result;
    }
}
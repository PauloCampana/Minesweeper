const ms = @import("main.zig");

pub fn win(board: [][]ms.Cell) bool {
    var correctly_cleared: u16 = 0;
    var correctly_marked: u16 = 0;
    for (board) |col| {
        for (col) |cell| {
            if (cell.mine == false and cell.status == .discovered) {
                correctly_cleared += 1;
            }
            if (cell.mine == true and cell.status == .marked) {
                correctly_marked += 1;
            }
        }
    }
    if (correctly_cleared == ms.rows * ms.columns - ms.mines_total) {
        return true;
    } else if (correctly_marked == ms.mines_total) {
        return true;
    } else {
        return false;
    }
}

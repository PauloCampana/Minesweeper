const std = @import("std");
const ms = @import("main.zig");

pub fn generate(allocator: std.mem.Allocator, generator: std.rand.Random) ![][]ms.Cell {
    const board = try allocator.alloc([]ms.Cell, ms.columns);
    for (board) |*col| {
        col.* = try allocator.alloc(ms.Cell, ms.rows);
        for (col.*) |*cell| {
            cell.*.mine = false;
            cell.*.status = .unknown;
        }
    }
    var mines_so_far: u16 = 0;
    while (mines_so_far < ms.mines_total) {
        const ypos = generator.uintLessThan(usize, ms.columns);
        const xpos = generator.uintLessThan(usize, ms.rows);
        if (board[xpos][ypos].mine) {
            continue;
        } else {
            board[xpos][ypos].mine = true;
            mines_so_far += 1;
        }
    }
    for (board, 0..) |col, x| {
        for (col, 0..) |*cell, y| {
            cell.*.adjacent = 0;
            if (board[x][y].mine) {
                cell.*.adjacent += 1;
            }
            if (x >= 1 and board[x - 1][y].mine) {
                cell.*.adjacent += 1;
            }
            if (y >= 1 and board[x][y - 1].mine) {
                cell.*.adjacent += 1;
            }
            if (x >= 1 and y >= 1 and board[x - 1][y - 1].mine) {
                cell.*.adjacent += 1;
            }
            if (x < ms.columns - 1 and board[x + 1][y].mine) {
                cell.*.adjacent += 1;
            }
            if (y < ms.rows - 1 and board[x][y + 1].mine) {
                cell.*.adjacent += 1;
            }
            if (x < ms.columns - 1 and y < ms.rows - 1 and board[x + 1][y + 1].mine) {
                cell.*.adjacent += 1;
            }
            if (x >= 1 and y < ms.rows - 1 and board[x - 1][y + 1].mine) {
                cell.*.adjacent += 1;
            }
            if (y >= 1 and x < ms.columns - 1 and board[x + 1][y - 1].mine) {
                cell.*.adjacent += 1;
            }
        }
    }
    return board;
}

pub fn free(allocator: std.mem.Allocator, board: [][]ms.Cell) void {
    for (board) |col| {
        allocator.free(col);
    }
    allocator.free(board);
}

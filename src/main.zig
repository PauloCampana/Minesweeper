const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

const board_f = @import("board.zig");
const draw_f = @import("draw.zig");
const input_f = @import("input.zig");
const state_f = @import("state.zig");

pub const screen_width = 800;
pub const screen_height = 900;
pub const header_height = 100;
pub const margin_height = 10;
pub const margin_width = 10;

pub const rows = 10;
pub const columns = 10;
pub const mines_ratio = 0.35;
pub var mines_marked: u16 = 0;
pub const mines_total: comptime_int = rows * columns * mines_ratio;
pub const spacing = (screen_width - 2 * margin_height) / rows;

pub const color_background = rl.Color{ .r = 0x20, .g = 0x20, .b = 0x20, .a = 0xff };
pub const color_grid = rl.Color{ .r = 0x40, .g = 0x40, .b = 0x40, .a = 0xff };
pub const color_line = rl.Color{ .r = 0x80, .g = 0x80, .b = 0x80, .a = 0xff };
pub const color_text = rl.Color{ .r = 0xc0, .g = 0xc0, .b = 0xc0, .a = 0xff };
pub const color_unknown = rl.Color{ .r = 0x20, .g = 0x20, .b = 0x20, .a = 0xff };
pub const color_discovered = rl.Color{ .r = 0xa0, .g = 0xa0, .b = 0xa0, .a = 0xff };
pub const color_marked = rl.Color{ .r = 0x80, .g = 0x40, .b = 0x20, .a = 0xff };
pub const color_win = rl.Color{ .r = 0x20, .g = 0x80, .b = 0x40, .a = 0xff };

pub const Status = enum {
    unknown,
    discovered,
    marked,
};

pub const Cell = struct {
    mine: bool,
    status: Status,
    adjacent: u8,
};

pub fn main() !void {
    const seed: u64 = @intCast(std.time.nanoTimestamp());
    var prng = std.rand.DefaultPrng.init(seed);
    const generator = prng.random();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const board = try board_f.generate(allocator, generator);
    defer board_f.free(allocator, board);

    rl.InitWindow(screen_width, screen_height, "Minesweeper");
    defer rl.CloseWindow();

    rl.SetTargetFPS(144);
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        draw_f.ui();
        draw_f.cells(board);
        draw_f.grid();

        input_f.leftClick(board);
        input_f.rightClick(board);

        if (state_f.win(board)) {
            draw_f.win(board);
        }
    }
}

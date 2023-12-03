const std = @import("std");
const rl = @import("raylib");

const screen_width = 800;
const screen_height = 900;
const header_height = 100;
const margin_height = 10;
const margin_width = 10;

const rows = 10;
const columns = 10;
const mines_ratio = 0.35;
var mines_found: u16 = 0;
const mines_total: comptime_int = rows * columns * mines_ratio;
const spacing = (screen_width - 2 * margin_height) / rows;

const color_background = rl.Color.init(0x20, 0x20, 0x20, 0xff);
const color_grid       = rl.Color.init(0x40, 0x40, 0x40, 0xff);
const color_line       = rl.Color.init(0x80, 0x80, 0x80, 0xff);
const color_text       = rl.Color.init(0xc0, 0xc0, 0xc0, 0xff);
const color_unknown    = rl.Color.init(0x20, 0x20, 0x20, 0xff);
const color_discovered = rl.Color.init(0xa0, 0xa0, 0xa0, 0xff);
const color_marked     = rl.Color.init(0x80, 0x40, 0x20, 0xff);

const Cell = struct {
    mine: bool,
    status: enum {
        unknown,
        discovered,
        marked,
    },
};

pub fn main() !void {
    const seed = @as(u64, @intCast(std.time.nanoTimestamp()));
    var prng = std.rand.DefaultPrng.init(seed);
    const generator = prng.random();

    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const board = try generateBoard(allocator, generator);
    defer freeBoard(allocator, board);

    rl.initWindow(screen_width, screen_height, "Minesweeper");
    defer rl.closeWindow();

    rl.setTargetFPS(360);
    while (!rl.windowShouldClose()) {
        var buf_board: [40]u8 = undefined;
        const board_as_string = try std.fmt.bufPrintZ(
            &buf_board,
            "{}x{} board, {}/{} mines",
            .{rows, columns, mines_found, mines_total}
        );

        var buf_time: [10]u8 = undefined;
        const time_as_string = try std.fmt.bufPrintZ(
            &buf_time,
            "{d:.0}s",
            .{rl.getTime()}
        );

        rl.beginDrawing();
        defer rl.endDrawing();

        drawUI(time_as_string, board_as_string);
        drawCells(board);
        drawGrid();

        if (rl.isMouseButtonPressed(.mouse_button_left)) {
            const position = rl.getMousePosition();
            const intx = @as(u16, @intFromFloat(position.x - margin_width));
            const whichx = intx / spacing;
            const inty = @as(u16, @intFromFloat(position.y - margin_height - header_height));
            const whichy = inty / spacing;
            board[whichx][whichy].status = .discovered;
        }
        if (rl.isMouseButtonPressed(.mouse_button_right)) {
            const position = rl.getMousePosition();
            const intx = @as(u16, @intFromFloat(position.x - margin_width));
            const whichx = intx / spacing;
            const inty = @as(u16, @intFromFloat(position.y - margin_height - header_height));
            const whichy = inty / spacing;
            board[whichx][whichy].status = .marked;
        }
    }
}

fn generateBoard(allocator: std.mem.Allocator, generator: std.rand.Random) ![][]Cell {
    const board = try allocator.alloc([]Cell, columns);
    for (board) |*col| {
        col.* = try allocator.alloc(Cell, rows);
        for (col.*) |*row| {
            row.*.mine = false;
            row.*.status = .unknown;
        }
    }
    var mines_so_far: u16 = 0;
    while (mines_so_far < mines_total) {
        const ypos = generator.uintLessThan(usize, columns);
        const xpos = generator.uintLessThan(usize, rows);
        if (board[xpos][ypos].mine) {
            continue;
        } else {
            board[xpos][ypos].mine = true;
            mines_so_far += 1;
        }
    }
    return board;
}

fn freeBoard(allocator: std.mem.Allocator, board: [][]Cell) void {
    for (board) |col| {
        allocator.free(col);
    }
    allocator.free(board);
}

fn drawUI(time_text: [:0]const u8, board_text: [:0]const u8) void {
    rl.clearBackground(color_background);
    rl.drawFPS(
        screen_width - margin_width - 83,
        margin_height,
    );

    // board
    rl.drawText(
        board_text,
        screen_width / 2 - 125,
        margin_height,
        20,
        color_text
    );

    // timer
    rl.drawText(
        time_text,
        margin_width,
        margin_height,
        20,
        color_text,
    );

    // help text
    rl.drawText(
        "Left click to clear cell",
        margin_width,
        margin_height + 40,
        20,
        color_text,
    );
    rl.drawText(
        "Right click to mark mine",
        margin_width,
        margin_height + 60,
        20,
        color_text,
    );

    // divisor
    rl.drawLine(
        0,
        header_height,
        screen_width,
        header_height,
        color_line,
    );
}

fn drawCells(board: [][]Cell) void {
    for (board, 0..) |col, x| {
        for (col, 0..) |row, y| {
            const ypos = header_height + margin_height + spacing * y;
            const xpos = margin_width + spacing * x;
            const color = switch (row.status) {
                .unknown => color_unknown,
                .discovered => color_discovered,
                .marked => color_marked
            };
            rl.drawRectangle(
                @as(i32, @intCast(xpos)),
                @as(i32, @intCast(ypos)),
                spacing,
                spacing,
                color,
            );
            if (row.mine) {
                rl.drawText("kek", @as(i32, @intCast(xpos)), @as(i32, @intCast(ypos)), 20, color_text);
            }
        }
    }
}

fn drawGrid() void {
    for (0..rows + 1) |y| {
        const ypos = header_height + margin_height + spacing * y;
        const ypos_casted = @as(i32, @intCast(ypos));
        rl.drawLine(
            margin_width,
            ypos_casted,
            screen_width - margin_width,
            ypos_casted,
            color_grid,
        );
    }

    for (0..columns + 1) |x| {
        const xpos = margin_width + spacing * x;
        const xpos_casted = @as(i32, @intCast(xpos));
        rl.drawLine(
            xpos_casted,
            header_height + margin_height,
            xpos_casted,
            screen_height - margin_height,
            color_grid,
        );
    }
}



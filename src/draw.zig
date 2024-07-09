const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));
const ms = @import("main.zig");

pub fn ui() void {
    var buf: [64]u8 = undefined;
    rl.ClearBackground(ms.color_background);
    rl.DrawFPS(
        ms.screen_width - ms.margin_width - 78,
        ms.margin_height,
    );

    const board = std.fmt.bufPrintZ(
        &buf,
        "{}x{} board, {}/{} mines",
        .{ ms.rows, ms.columns, ms.mines_marked, ms.mines_total },
    ) catch unreachable;
    rl.DrawText(
        board,
        ms.screen_width / 2 - 125,
        ms.margin_height,
        20,
        ms.color_text,
    );

    const time = std.fmt.bufPrintZ(
        &buf,
        "{d:.0}s",
        .{rl.GetTime()},
    ) catch unreachable;
    rl.DrawText(
        time,
        ms.margin_width,
        ms.margin_height,
        20,
        ms.color_text,
    );

    rl.DrawText(
        "Left click to clear cell",
        ms.margin_width,
        ms.margin_height + 40,
        20,
        ms.color_text,
    );
    rl.DrawText(
        "Right click to mark mine",
        ms.margin_width,
        ms.margin_height + 60,
        20,
        ms.color_text,
    );

    rl.DrawLine(
        0,
        ms.header_height,
        ms.screen_width,
        ms.header_height,
        ms.color_line,
    );
}

pub fn cells(board: [][]ms.Cell) void {
    for (board, 0..) |col, x| {
        for (col, 0..) |cell, y| {
            const xpos = ms.margin_width + ms.spacing * x;
            const ypos = ms.header_height + ms.margin_height + ms.spacing * y;
            const color = switch (cell.status) {
                .unknown => ms.color_unknown,
                .discovered => ms.color_discovered,
                .marked => ms.color_marked,
            };
            const xpos_casted: i32 = @intCast(xpos);
            const ypos_casted: i32 = @intCast(ypos);
            rl.DrawRectangle(
                xpos_casted,
                ypos_casted,
                ms.spacing,
                ms.spacing,
                color,
            );
            // if (cell.mine) {
            //     rl.drawText("kek", xpos_casted, ypos_casted, 20, ms.color_text);
            // }
            if (cell.status == .discovered) {
                const buf: [1:0]u8 = .{std.fmt.digitToChar(cell.adjacent, .lower)};
                rl.DrawText(
                    &buf,
                    xpos_casted + ms.spacing / 2 - 10,
                    ypos_casted + ms.spacing / 2 - 16,
                    40,
                    ms.color_win,
                );
            }
            if (cell.status == .discovered and cell.mine) {
                rl.DrawRectangle(
                    xpos_casted,
                    ypos_casted,
                    ms.spacing,
                    ms.spacing,
                    rl.Color{ .r = 0x80, .g = 0x20, .b = 0x20, .a = 0xff },
                );
            }
        }
    }
}

pub fn grid() void {
    for (0..ms.rows + 1) |y| {
        const ypos = ms.header_height + ms.margin_height + ms.spacing * y;
        rl.DrawLine(
            ms.margin_width,
            @intCast(ypos),
            ms.screen_width - ms.margin_width,
            @intCast(ypos),
            ms.color_grid,
        );
    }

    for (0..ms.columns + 1) |x| {
        const xpos = ms.margin_width + ms.spacing * x;
        rl.DrawLine(
            @intCast(xpos),
            ms.header_height + ms.margin_height,
            @intCast(xpos),
            ms.screen_height - ms.margin_height,
            ms.color_grid,
        );
    }
}

pub fn win(board: [][]ms.Cell) void {
    for (board, 0..) |col, x| {
        for (col, 0..) |row, y| {
            const ypos = ms.header_height + ms.margin_height + ms.spacing * y;
            const xpos = ms.margin_width + ms.spacing * x;
            const color = switch (row.mine) {
                true => ms.color_marked,
                false => ms.color_win,
            };
            rl.DrawRectangle(
                @intCast(xpos),
                @intCast(ypos),
                ms.spacing,
                ms.spacing,
                color,
            );
        }
    }
    grid();
}

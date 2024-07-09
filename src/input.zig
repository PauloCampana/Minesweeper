const rl = @cImport(@cInclude("raylib.h"));
const ms = @import("main.zig");

pub fn leftClick(board: [][]ms.Cell) void {
    if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
        const position = rl.GetMousePosition();
        if (position.x < ms.margin_width or position.x > ms.screen_width - ms.margin_width) {
            return;
        }
        if (position.y < ms.margin_height + ms.header_height or position.y > ms.screen_height - ms.margin_height) {
            return;
        }
        const intx: u32 = @intFromFloat(position.x - ms.margin_width);
        const whichx = intx / ms.spacing;
        const inty: u32 = @intFromFloat(position.y - ms.margin_height - ms.header_height);
        const whichy = inty / ms.spacing;
        if (board[whichx][whichy].status == .unknown) {
            board[whichx][whichy].status = .discovered;
        }
    }
}

pub fn rightClick(board: [][]ms.Cell) void {
    if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT)) {
        const position = rl.GetMousePosition();
        if (position.x < ms.margin_width or position.x > ms.screen_width - ms.margin_width) {
            return;
        }
        if (position.y < ms.margin_height + ms.header_height or position.y > ms.screen_height - ms.margin_height) {
            return;
        }
        const intx: u32 = @intFromFloat(position.x - ms.margin_width);
        const whichx = intx / ms.spacing;
        const inty: u32 = @intFromFloat(position.y - ms.margin_height - ms.header_height);
        const whichy = inty / ms.spacing;
        switch (board[whichx][whichy].status) {
            .unknown => {
                board[whichx][whichy].status = .marked;
                ms.mines_marked += 1;
            },
            .marked => {
                board[whichx][whichy].status = .unknown;
                ms.mines_marked -= 1;
            },
            else => {},
        }
    }
}

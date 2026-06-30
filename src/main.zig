const std = @import("std");
const Io = std.Io;

const zint = @import("zig_zint");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const text = if (args.len <= 1) "Hello from Zig" else args[1];
    const svg = try zint.generateSVG(arena, zint.Symbology.dm, text);
    try std.Io.File.stdout().writeStreamingAll(init.io, svg);
    try std.Io.File.stdout().writeStreamingAll(init.io, "\n");
}


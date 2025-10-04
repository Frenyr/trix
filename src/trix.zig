const std = @import("std");
const std_writer = std.io.getStdOut().writer();

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    if (args.next()) |arg| {
        try std_writer.print("{s}\n", .{arg});
    } else {
        try std_writer.print("There is no arg\n", .{});
    }
}
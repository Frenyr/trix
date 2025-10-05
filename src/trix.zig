const std = @import("std");
const std_writer = std.io.getStdOut().writer();

const trix_version: []const u8 = "0.1.0";

const Command = enum {
    // common
    install,
    list,
    uninstall,
    info,   // Kiểm tra thông tin của một pack (vd: trix info node)
    moveto,    // Chuyển một pack đến một version được chỉ định (vd: trix move-to jvm@21.0 | trix move-to jvm@lasted)
    

    // self commands
    version,    // Kiểm tra phiên bản
    upgrade,    // Cập nhật lên phiên bản mới nhất hoặc chỉ định (vd: trix upgrade | trix upgrade @1.2)
    help,

    const Self = @This();
    const command_fields = std.meta.fields(Command);

    // Hàm trả ra command tương ứng đọc được từ input args
    pub fn getCommand(arg: []const u8) ?Command {
        inline for (command_fields) |field| {
            if (std.mem.eql(u8, field.name, arg)) {
                return @enumFromInt(field.value);
            }
        }
        return null;
    }
};

fn showVersion() void {
    std_writer.print("trix package manager {s}\n", .{trix_version}) catch unreachable;
}


fn showHelpMenu() void {
    std_writer.writeAll(
        \\Usage: trix [command] [options]
        \\  install     Install a package (ex: trix install <package name>)
        \\  list        List all installed packages
        \\  uninstall   Uninstall a package (ex: trix uninstall <package name>)
        \\  info        Print information of package (ex: trix info <package name>)
        \\  moveto      Change a package to specific version (ex: trix moveto <package name> @<version>)
        
        \\  version     Print version of this package manager
        \\  upgrage     Upgrade this package manager (ex: trix upgrade @<version>)
    ) catch unreachable;
}

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();    // skip arg đầu tiên
    
    // Kiểm tra phần còn lại của args
    if (args.next()) |arg| {
        if (Command.getCommand(arg)) |command| {
            switch (command) {
                .install => {
                    if (args.next()) |install_pack_name| {
                        if (args.next()) |install_pack_version| {
                            try std_writer.print("install package '{s}' version {s}\n", .{install_pack_name, install_pack_version});
                        } else {
                            try std_writer.print("install package '{s}'\n", .{install_pack_name});
                        }
                    } else {
                        try std_writer.writeAll("package name is missing");
                    }
                },
                .list => try std_writer.writeAll("list all pack"),
                .uninstall => {
                    if (args.next()) |uninstall_pack_name| {
                        try std_writer.print("uninstall package '{s}'\n", .{uninstall_pack_name});
                    } else {
                        try std_writer.writeAll("package name is missing");
                    }
                },
                .info => {
                    if (args.next()) |info_pack_name| {
                        try std_writer.print("get info of package '{s}'\n", .{info_pack_name});
                    } else {
                        try std_writer.writeAll("package name is missing");
                    }
                },
                .moveto => {
                    if (args.next()) |moveto_pack_name| {
                        if (args.next()) |moveto_version| {
                            try std_writer.print("update package '{s}' to version '{s}'\n", .{moveto_pack_name, moveto_version});
                        } else {
                            try std_writer.writeAll("package version is missing");
                        }
                    } else {
                        try std_writer.writeAll("package name is missing");
                    }
                },
                .version => {
                    showVersion();
                },
                .upgrade => {
                    if (args.next()) |upgrade_version| {
                        try std_writer.print("upgrade trix to version '{s}'\n", .{upgrade_version});
                    } else {
                        try std_writer.writeAll("upgrade trix to lasted version");
                    }
                },
                .help => {
                    showHelpMenu();
                }
            }
        } else {
            try std_writer.print("command '{s}' is not supported\n", .{arg});
        }
    } else {
        // Hiển thị menu trợ giúp
        showHelpMenu();
    }
}

test "getCommand test" {
    try std.testing.expectEqual(Command.install, Command.getCommand("install"));
    try std.testing.expectEqual(Command.list, Command.getCommand("list"));
    try std.testing.expectEqual(Command.uninstall, Command.getCommand("uninstall"));
    try std.testing.expectEqual(Command.info, Command.getCommand("info"));
    try std.testing.expectEqual(Command.moveto, Command.getCommand("moveto"));
    try std.testing.expectEqual(Command.version, Command.getCommand("version"));
    try std.testing.expectEqual(Command.upgrade, Command.getCommand("upgrade"));
    try std.testing.expectEqual(null, Command.getCommand("??"));
}
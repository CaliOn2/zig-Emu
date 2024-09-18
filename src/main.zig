const std = @import("std");

pub fn hexToHexChar(hexNum: u4) u8 {
    const conversion = [16]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    return conversion[hexNum];
}

pub fn hexCharToHex(hexChar: u8) !u4 {
    const conversion = [16]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    for (0..16) |x| {
        if (hexChar == conversion[x]) {
            return @intCast(x);
        }
    }
    return error.InvalidHex;
}

pub fn orI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] | cache.*[parameters[1]];
}

pub fn xorI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] ^ cache.*[parameters[1]];
}

pub fn andI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] & cache.*[parameters[1]];
}

pub fn nandI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = ~(cache.*[parameters[2]] & cache.*[parameters[1]]);
}

pub fn plusI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] + cache.*[parameters[1]];
}

pub fn minusI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] - cache.*[parameters[1]];
}

pub fn timesI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] * cache.*[parameters[1]];
}

pub fn shiftLI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] << parameters[1];
}

pub fn shiftRI(cache: *[16]u16, parameters: [3]u4) void {
    cache.*[parameters[0]] = cache.*[parameters[2]] >> parameters[1];
}

pub fn setI(cache: *[16]u16, instruction: u16) void {
    cache.*[@intCast((instruction >> 4) & 0b1111)] = instruction >> 8;
}

pub fn loadI(cache: *[16]u16, parameters: [3]u4, storage: *[64000]u8) void {
    cache.*[parameters[0]] = @as(u16, storage.*[cache[parameters[2]]]);
}

pub fn storeI(cache: *[16]u16, parameters: [3]u4, storage: *[64000]u8) void {
    storage.*[cache.*[parameters[0]]] = @intCast(cache.*[parameters[2]]);
}

pub fn getProcCountI(cache: *[16]u16, loadAdress: u4, procCount: *u16) void {
    cache.*[loadAdress] = procCount.*;
}

pub fn compI(cache: *[16]u16, parameters: [3]u4, procCount: *u16) void {
    if (cache.*[parameters[2]] == cache.*[parameters[1]]) {
        procCount.* = cache.*[parameters[0]];
    }
}

pub fn SysOutI(cache: *[16]u16, parameters: [3]u4, storage: *[64000]u8) !void {
    const stdout = std.io.getStdOut().writer();
    const address: u16 = cache.*[parameters[2]];
    switch (parameters[0]) {
        0b1111 => {
            var cacheData: [6]u8 = undefined;
            cacheData[0] = '0';
            cacheData[1] = 'x';
            for (2..6) |x| {
                cacheData[x] = hexToHexChar(@intCast(address >> (12 - @as(u4, @intCast(x)) * 4) & 0b1111));
            }
            stdout.print("{s}\n", .{cacheData}) catch |err| {
                return err;
            };
        },
        0b1110 => {
            var cacheData: [18]u8 = undefined;
            cacheData[0] = '0';
            cacheData[1] = 'b';
            for (2..18) |x| {
                cacheData[x] = hexToHexChar(@intCast(address >> (15 - @as(u4, @intCast(x))) & 0b0001));
            }
            stdout.print("{s}\n", .{cacheData}) catch |err| {
                return err;
            };
        },
        0b0000 => {
            stdout.print(".{s}", .{storage.*[address..(address + cache.*[parameters[1]] + 1)]}) catch |err| {
                return err;
            };
        },
        else => {
            return error.SysoutSubOpcodeNotMatch;
        },
    }
}

pub fn SysInI(cache: *[16]u16, parameters: [3]u4, storage: *[64000]u8) !void {
    const stdin = std.io.getStdIn().reader();
    const address = cache.*[parameters[2]];
    const duration = cache.*[parameters[1]];
    switch (parameters[0]) {
        0b1111 => {
            _ = stdin.readUntilDelimiterOrEof(storage.*[address..(address + duration + 1)], '\n') catch |err| {
                return err;
            };
        },
        else => {
            return error.SysinSubOpcodeNotMatch;
        },
    }
}

pub fn instructionInterpreter(storage: *[64000]u8, cache: *[16]u16, procCount: *u16) !bool {
    const instruction: u16 = (@as(u16, storage[procCount.*]) << 8) + storage[procCount.* + 1];
    const operand: u4 = @intCast(instruction & 0b1111);
    const parameters: [3]u4 = [3]u4{
        @intCast((instruction >> 4) & 0b1111),
        @intCast((instruction >> 8) & 0b1111),
        @intCast((instruction >> 12) & 0b1111),
    };

    switch (operand) {
        0b0000 => {
            orI(cache, parameters);
            if (instruction == 0) {
                return false;
            }
        },
        0b0001 => {
            xorI(cache, parameters);
        },
        0b0010 => {
            andI(cache, parameters);
        },
        0b0011 => {
            nandI(cache, parameters);
        },
        0b0100 => {
            plusI(cache, parameters);
        },
        0b0101 => {
            minusI(cache, parameters);
        },
        0b0110 => {
            timesI(cache, parameters);
        },
        0b0111 => {
            shiftRI(cache, parameters);
        },
        0b1000 => {
            shiftLI(cache, parameters);
        },
        0b1001 => {
            setI(cache, instruction);
        },
        0b1010 => {
            loadI(cache, parameters, storage);
        },
        0b1011 => {
            storeI(cache, parameters, storage);
        },
        0b1100 => {
            getProcCountI(cache, parameters[0], procCount);
        },
        0b1101 => {
            compI(cache, parameters, procCount);
        },
        0b1110 => {
            SysOutI(cache, parameters, storage) catch |err| {
                return err;
            };
        },
        0b1111 => {
            SysInI(cache, parameters, storage) catch |err| {
                return err;
            };
        },
    }
    procCount.* += 2;
    return true;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var storage: [64000]u8 = undefined;
    for (0..64000) |x| {
        storage[x] = 0;
    }
    var storagePointer: u16 = 0;
    var cache: [16]u16 = [16]u16{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    while (true) {
        if (instructionInterpreter(&storage, &cache, &storagePointer)) |running| {
            if (running == false) {
                stdout.print("Program End", .{}) catch |err| {
                    return err;
                };
                return;
            }
        } else |err| {
            stdout.print("Err: {any}", .{err}) catch {
                return err;
            };
        }
    }
}

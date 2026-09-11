pub const packages = struct {
    pub const @"12205d223ce1fd3a13bf748e046c9b0da6f2390b4c9e331d127d5434aeac71b37f40" = struct {
        pub const build_root = "/workspace/services/recorder/../common";
        pub const build_zig = @import("12205d223ce1fd3a13bf748e046c9b0da6f2390b4c9e331d127d5434aeac71b37f40");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "guardian-common", "12205d223ce1fd3a13bf748e046c9b0da6f2390b4c9e331d127d5434aeac71b37f40" },
};

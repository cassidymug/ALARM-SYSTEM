// Camera grid view - displays multiple camera feeds in a grid layout
const std = @import("std");
const common = @import("guardian-common");

const types = common.types;

pub const CameraGrid = struct {
    allocator: std.mem.Allocator,
    cameras: []const types.CameraConfig,
    selected_camera: ?usize,

    pub fn init(allocator: std.mem.Allocator, cameras: []const types.CameraConfig) !CameraGrid {
        return .{
            .allocator = allocator,
            .cameras = cameras,
            .selected_camera = null,
        };
    }

    pub fn deinit(self: *CameraGrid) void {
        _ = self;
    }

    pub fn render(self: *CameraGrid) !void {
        // TODO: Render grid layout
        // - Calculate grid dimensions based on camera count (2x2, 3x3, 4x4)
        // - Fetch substreams from guardian-api
        // - Decode and display video frames
        // - Show camera name overlay
        // - Highlight selected camera if any
        _ = self;
    }

    pub fn selectCamera(self: *CameraGrid, index: usize) void {
        if (index < self.cameras.len) {
            self.selected_camera = index;
        }
    }

    pub fn getTapToHDCamera(self: *CameraGrid) ?types.CameraConfig {
        if (self.selected_camera) |index| {
            return self.cameras[index];
        }
        return null;
    }

    pub fn getGridLayout(self: *CameraGrid) GridLayout {
        const count = self.cameras.len;
        
        if (count <= 4) {
            return .{ .rows = 2, .cols = 2 };
        } else if (count <= 9) {
            return .{ .rows = 3, .cols = 3 };
        } else if (count <= 16) {
            return .{ .rows = 4, .cols = 4 };
        } else {
            return .{ .rows = 4, .cols = 4 }; // Max 16 cameras visible
        }
    }
};

pub const GridLayout = struct {
    rows: u32,
    cols: u32,
};

test "grid layout for camera counts" {
    const allocator = std.testing.allocator;
    
    const cameras_4 = [_]types.CameraConfig{
        .{ .id = "1", .name = "Cam 1", .rtsp_url = "rtsp://test" },
        .{ .id = "2", .name = "Cam 2", .rtsp_url = "rtsp://test" },
        .{ .id = "3", .name = "Cam 3", .rtsp_url = "rtsp://test" },
        .{ .id = "4", .name = "Cam 4", .rtsp_url = "rtsp://test" },
    };
    
    var grid = try CameraGrid.init(allocator, &cameras_4);
    defer grid.deinit();
    
    const layout = grid.getGridLayout();
    try std.testing.expectEqual(@as(u32, 2), layout.rows);
    try std.testing.expectEqual(@as(u32, 2), layout.cols);
}

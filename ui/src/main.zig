// Guardian UI - Zig-based appliance interface
// Uses DRM/KMS or Wayland for direct rendering, no Electron/React/Flutter
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;

const SERVICE_NAME = "ui";

const CameraGrid = @import("camera_grid.zig").CameraGrid;
const ArmKeypad = @import("arm_keypad.zig").ArmKeypad;
const IntercomPanel = @import("intercom_panel.zig").IntercomPanel;

/// Main UI state and event loop
pub const GuardianUI = struct {
    allocator: std.mem.Allocator,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    
    camera_grid: CameraGrid,
    arm_keypad: ArmKeypad,
    intercom_panel: IntercomPanel,
    
    current_view: View,

    const View = enum {
        camera_grid,
        arm_keypad,
        intercom,
        settings,
    };

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig) !GuardianUI {
        return .{
            .allocator = allocator,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .camera_grid = try CameraGrid.init(allocator, config.cameras),
            .arm_keypad = ArmKeypad.init(),
            .intercom_panel = IntercomPanel.init(),
            .current_view = .camera_grid,
        };
    }

    pub fn deinit(self: *GuardianUI) void {
        self.camera_grid.deinit();
    }

    pub fn start(self: *GuardianUI) !void {
        log.info(SERVICE_NAME, "Starting Guardian UI", .{});
        self.running.store(true, .seq_cst);

        // TODO: Initialize DRM/KMS or Wayland display
        // TODO: Create framebuffer or window
        // TODO: Connect to guardian-api for data

        try self.mainLoop();
    }

    pub fn stop(self: *GuardianUI) void {
        log.info(SERVICE_NAME, "Stopping Guardian UI", .{});
        self.running.store(false, .seq_cst);
    }

    fn mainLoop(self: *GuardianUI) !void {
        while (self.running.load(.seq_cst)) {
            // TODO: Handle input events (keyboard, touch)
            // TODO: Update display based on current view
            
            switch (self.current_view) {
                .camera_grid => try self.renderCameraGrid(),
                .arm_keypad => try self.renderArmKeypad(),
                .intercom => try self.renderIntercom(),
                .settings => try self.renderSettings(),
            }

            // ~30 FPS for UI updates
            std.time.sleep(33 * std.time.ns_per_ms);
        }
    }

    fn renderCameraGrid(self: *GuardianUI) !void {
        // TODO: Render camera grid using framebuffer/DRM
        _ = self;
    }

    fn renderArmKeypad(self: *GuardianUI) !void {
        // TODO: Render arm/disarm keypad
        _ = self;
    }

    fn renderIntercom(self: *GuardianUI) !void {
        // TODO: Render intercom controls
        _ = self;
    }

    fn renderSettings(self: *GuardianUI) !void {
        // TODO: Render settings screen
        _ = self;
    }

    fn handleInput(self: *GuardianUI, input: InputEvent) !void {
        // TODO: Route input to current view
        _ = self;
        _ = input;
    }
};

const InputEvent = union(enum) {
    key_press: u8,
    touch: struct { x: u32, y: u32 },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian UI starting", .{});

    // TODO: Load config from API or file
    const dummy_cameras = [_]types.CameraConfig{
        .{
            .id = "cam_front_gate",
            .name = "Front Gate",
            .rtsp_url = "rtsp://192.168.1.100:554/stream1",
            .max_resolution = .uhd_4k,
            .audio_enabled = true,
            .detect_enabled = true,
            .intercom_enabled = true,
        },
        .{
            .id = "cam_driveway",
            .name = "Driveway",
            .rtsp_url = "rtsp://192.168.1.101:554/stream1",
            .max_resolution = .full_hd,
            .audio_enabled = true,
            .detect_enabled = true,
            .intercom_enabled = false,
        },
    };

    const config = types.SiteConfig{
        .site_name = "Test Site",
        .cameras = &dummy_cameras,
        .zones = &.{},
        .backup_scope = .events_only,
        .backup_retention_days = 30,
        .backup_bandwidth_cap_mbps = 10,
        .relay_url = "wss://relay.guardian.example.com",
    };

    var ui = try GuardianUI.init(allocator, config);
    defer ui.deinit();

    try ui.start();
}

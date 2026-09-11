// Guardian UI - Enhanced with detection capabilities
const std = @import("std");
const common = @import("guardian-common");
const sdl = @import("sdl.zig");

const log = common.logging;
const types = common.types;

const CameraGrid = @import("camera_grid.zig").CameraGrid;
const ArmKeypad = @import("arm_keypad.zig").ArmKeypad;
const IntercomPanel = @import("intercom_panel.zig").IntercomPanel;
const DetectionPanel = @import("detection_panel.zig").DetectionPanel;
const CameraConfigPanel = @import("camera_config_panel.zig").CameraConfigPanel;
const ApiClient = @import("api_client.zig").ApiClient;

const SERVICE_NAME = "ui";

/// Main UI application with advanced detection support
pub const GuardianUI = struct {
    allocator: std.mem.Allocator,
    config: types.SiteConfig,
    
    window: *sdl.SDL_Window,
    renderer: *sdl.SDL_Renderer,
    running: bool,
    
    // API client
    api_client: ApiClient,
    
    // Views
    camera_grid: CameraGrid,
    arm_keypad: ArmKeypad,
    intercom_panel: IntercomPanel,
    detection_panel: DetectionPanel,
    camera_config_panel: CameraConfigPanel,
    
    current_view: View,
    window_width: u32 = 1280,
    window_height: u32 = 720,

    const View = enum {
        camera_grid,        // Press 1
        arm_keypad,         // Press 2
        intercom,           // Press 3
        detections,         // Press 4
        camera_config,      // Press 5
    };

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, api_url: []const u8) !GuardianUI {
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) < 0) {
            log.err(SERVICE_NAME, "SDL_Init failed: {s}", .{sdl.SDL_GetError()});
            return error.SDLInitFailed;
        }

        const window = sdl.SDL_CreateWindow(
            "Guardian Security System - AI Detection Enabled",
            sdl.SDL_WINDOWPOS_UNDEFINED,
            sdl.SDL_WINDOWPOS_UNDEFINED,
            1280,
            720,
            sdl.SDL_WINDOW_SHOWN,
        ) orelse {
            log.err(SERVICE_NAME, "SDL_CreateWindow failed: {s}", .{sdl.SDL_GetError()});
            return error.WindowCreationFailed;
        };

        const renderer = sdl.SDL_CreateRenderer(
            window,
            -1,
            sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC,
        ) orelse {
            sdl.SDL_DestroyWindow(window);
            log.err(SERVICE_NAME, "SDL_CreateRenderer failed: {s}", .{sdl.SDL_GetError()});
            return error.RendererCreationFailed;
        };

        return .{
            .allocator = allocator,
            .config = config,
            .window = window,
            .renderer = renderer,
            .running = false,
            .api_client = ApiClient.init(allocator, api_url),
            .camera_grid = try CameraGrid.init(allocator, config.cameras),
            .arm_keypad = ArmKeypad.init(),
            .intercom_panel = IntercomPanel.init(),
            .detection_panel = DetectionPanel.init(allocator),
            .camera_config_panel = CameraConfigPanel.init(allocator, config.cameras),
            .current_view = .camera_grid,
        };
    }

    pub fn deinit(self: *GuardianUI) void {
        self.camera_grid.deinit();
        self.detection_panel.deinit();
        self.camera_config_panel.deinit();
        self.api_client.deinit();
        sdl.SDL_DestroyRenderer(self.renderer);
        sdl.SDL_DestroyWindow(self.window);
        sdl.SDL_Quit();
    }

    pub fn run(self: *GuardianUI) !void {
        log.info(SERVICE_NAME, "Guardian UI starting with advanced detection support", .{});
        self.running = true;

        // Test API connection
        self.api_client.ping() catch |err| {
            log.warn(SERVICE_NAME, "API not available: {s}", .{@errorName(err)});
        };

        while (self.running) {
            try self.handleEvents();
            try self.render();
            sdl.SDL_Delay(16); // ~60 FPS
        }
    }

    fn handleEvents(self: *GuardianUI) !void {
        var event: sdl.SDL_Event = undefined;
        
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => {
                    self.running = false;
                },
                sdl.SDL_KEYDOWN => {
                    try self.handleKeyDown(@ptrCast(&event));
                },
                sdl.SDL_MOUSEBUTTONDOWN => {
                    try self.handleMouseDown(@ptrCast(&event));
                },
                else => {},
            }
        }
    }

    fn handleKeyDown(self: *GuardianUI, event: *const sdl.SDL_KeyboardEvent) !void {
        const key = event.keysym.sym;
        
        // View switching
        if (key == '1') {
            self.current_view = .camera_grid;
            log.info(SERVICE_NAME, "View: Camera Grid", .{});
        } else if (key == '2') {
            self.current_view = .arm_keypad;
            log.info(SERVICE_NAME, "View: Arm/Disarm Keypad", .{});
        } else if (key == '3') {
            self.current_view = .intercom;
            log.info(SERVICE_NAME, "View: Intercom", .{});
        } else if (key == '4') {
            self.current_view = .detections;
            log.info(SERVICE_NAME, "View: Detection Events", .{});
        } else if (key == '5') {
            self.current_view = .camera_config;
            log.info(SERVICE_NAME, "View: Camera Configuration", .{});
        }
        
        // View-specific input
        switch (self.current_view) {
            .arm_keypad => {
                if (key >= sdl.SDLK_0 and key <= sdl.SDLK_9) {
                    self.arm_keypad.addDigit(@intCast(key));
                } else if (key == sdl.SDLK_BACKSPACE) {
                    self.arm_keypad.clear();
                } else if (key == sdl.SDLK_RETURN) {
                    const pin = self.arm_keypad.getCurrentPin();
                    log.info(SERVICE_NAME, "PIN entered, length: {d}", .{pin.len});
                    // TODO: self.api_client.disarmAlarm(pin)
                }
            },
            else => {},
        }
        
        // ESC to quit
        if (key == sdl.SDLK_ESCAPE) {
            self.running = false;
        }
    }

    fn handleMouseDown(self: *GuardianUI, event: *const sdl.SDL_MouseButtonEvent) !void {
        switch (self.current_view) {
            .camera_grid => {
                const x = event.x;
                const y = event.y;
                
                const layout = self.camera_grid.getGridLayout();
                const cell_width = @divTrunc(self.window_width, layout.cols);
                const cell_height = @divTrunc(self.window_height - 30, layout.rows);
                
                const col = @divTrunc(@as(u32, @intCast(x)), cell_width);
                const row = @divTrunc(@as(u32, @intCast(y)), cell_height);
                const index = row * layout.cols + col;
                
                if (index < self.config.cameras.len) {
                    self.camera_grid.selectCamera(@intCast(index));
                    log.info(SERVICE_NAME, "Selected camera: {s}", .{
                        self.config.cameras[index].name,
                    });
                }
            },
            .camera_config => {
                // TODO: Handle clicks on camera list and toggles
            },
            else => {},
        }
    }

    fn render(self: *GuardianUI) !void {
        // Clear background
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 20, 20, 30, 255);
        _ = sdl.SDL_RenderClear(self.renderer);

        // Render current view
        switch (self.current_view) {
            .camera_grid => try self.renderCameraGrid(),
            .arm_keypad => try self.renderArmKeypad(),
            .intercom => try self.renderIntercom(),
            .detections => try self.renderDetections(),
            .camera_config => try self.renderCameraConfig(),
        }

        // Render status bar
        try self.renderStatusBar();

        sdl.SDL_RenderPresent(self.renderer);
    }

    fn renderCameraGrid(self: *GuardianUI) !void {
        const layout = self.camera_grid.getGridLayout();
        const cell_width = @divTrunc(self.window_width, layout.cols);
        const cell_height = @divTrunc(self.window_height - 30, layout.rows);

        for (self.config.cameras, 0..) |camera, i| {
            const col = i % layout.cols;
            const row = i / layout.cols;
            
            const x: c_int = @intCast(col * cell_width);
            const y: c_int = @intCast(row * cell_height);
            const w: c_int = @intCast(cell_width);
            const h: c_int = @intCast(cell_height);

            var rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
            
            // Highlight selected
            if (self.camera_grid.selected_camera) |selected| {
                if (selected == i) {
                    _ = sdl.SDL_SetRenderDrawColor(self.renderer, 0, 150, 255, 255);
                } else {
                    _ = sdl.SDL_SetRenderDrawColor(self.renderer, 60, 60, 70, 255);
                }
            } else {
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 60, 60, 70, 255);
            }
            _ = sdl.SDL_RenderDrawRect(self.renderer, &rect);

            // Inner area
            const margin = 10;
            rect.x += margin;
            rect.y += margin;
            rect.w -= margin * 2;
            rect.h -= margin * 2;
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 40, 40, 50, 255);
            _ = sdl.SDL_RenderFillRect(self.renderer, &rect);

            // Detection capabilities indicators
            const caps = camera.detection_capabilities;
            var indicator_x = x + margin + 5;
            const indicator_y = y + margin + 5;
            const indicator_size = 8;
            const indicator_spacing = 12;

            // Show enabled detection types
            if (caps.facial_recognition) {
                const ind = sdl.SDL_Rect{ .x = indicator_x, .y = indicator_y, .w = indicator_size, .h = indicator_size };
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 150, 255, 255); // Blue = face
                _ = sdl.SDL_RenderFillRect(self.renderer, &ind);
                indicator_x += indicator_spacing;
            }
            if (caps.plate_recognition or caps.vehicle_recognition) {
                const ind = sdl.SDL_Rect{ .x = indicator_x, .y = indicator_y, .w = indicator_size, .h = indicator_size };
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 255, 200, 100, 255); // Orange = vehicle
                _ = sdl.SDL_RenderFillRect(self.renderer, &ind);
                indicator_x += indicator_spacing;
            }
            if (caps.pet_detection) {
                const ind = sdl.SDL_Rect{ .x = indicator_x, .y = indicator_y, .w = indicator_size, .h = indicator_size };
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 255, 150, 200, 255); // Pink = pet
                _ = sdl.SDL_RenderFillRect(self.renderer, &ind);
                indicator_x += indicator_spacing;
            }
            if (caps.gait_recognition) {
                const ind = sdl.SDL_Rect{ .x = indicator_x, .y = indicator_y, .w = indicator_size, .h = indicator_size };
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 255, 200, 255); // Cyan = gait
                _ = sdl.SDL_RenderFillRect(self.renderer, &ind);
            }
        }
    }

    fn renderArmKeypad(self: *GuardianUI) !void {
        const keypad_width = 300;
        const keypad_height = 400;
        const x: c_int = @intCast((self.window_width - keypad_width) / 2);
        const y: c_int = @intCast((self.window_height - keypad_height) / 2);

        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = keypad_width, .h = keypad_height };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 50, 50, 60, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &bg_rect);
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 100, 120, 255);
        _ = sdl.SDL_RenderDrawRect(self.renderer, &bg_rect);

        // PIN display
        const pin_display = sdl.SDL_Rect{ .x = x + 20, .y = y + 20, .w = keypad_width - 40, .h = 40 };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 30, 30, 40, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &pin_display);
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
        _ = sdl.SDL_RenderDrawRect(self.renderer, &pin_display);

        // PIN dots
        const pin = self.arm_keypad.getCurrentPin();
        for (0..pin.len) |i| {
            const dot_rect = sdl.SDL_Rect{
                .x = x + 40 + @as(c_int, @intCast(i * 20)),
                .y = y + 35,
                .w = 8,
                .h = 8,
            };
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 200, 200, 200, 255);
            _ = sdl.SDL_RenderFillRect(self.renderer, &dot_rect);
        }

        // State indicator
        const state_rect = sdl.SDL_Rect{ .x = x + keypad_width / 2 - 50, .y = y + 80, .w = 100, .h = 30 };
        const state_color = switch (self.arm_keypad.current_state) {
            .disarmed => sdl.SDL_Color{ .r = 100, .g = 200, .b = 100, .a = 255 },
            .armed_away, .armed_stay => sdl.SDL_Color{ .r = 200, .g = 100, .b = 100, .a = 255 },
            .alarm => sdl.SDL_Color{ .r = 255, .g = 50, .b = 50, .a = 255 },
            else => sdl.SDL_Color{ .r = 150, .g = 150, .b = 150, .a = 255 },
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, state_color.r, state_color.g, state_color.b, state_color.a);
        _ = sdl.SDL_RenderFillRect(self.renderer, &state_rect);
    }

    fn renderIntercom(self: *GuardianUI) !void {
        const panel_width = 400;
        const panel_height = 300;
        const x: c_int = @intCast((self.window_width - panel_width) / 2);
        const y: c_int = @intCast((self.window_height - panel_height) / 2);

        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = panel_width, .h = panel_height };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 50, 50, 60, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &bg_rect);
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 100, 120, 255);
        _ = sdl.SDL_RenderDrawRect(self.renderer, &bg_rect);

        if (self.intercom_panel.active_session) |session| {
            const status_rect = sdl.SDL_Rect{ .x = x + 20, .y = y + 20, .w = panel_width - 40, .h = 60 };
            const color = switch (session.state) {
                .ringing => sdl.SDL_Color{ .r = 255, .g = 165, .b = 0, .a = 255 },
                .answered, .talking => sdl.SDL_Color{ .r = 100, .g = 200, .b = 100, .a = 255 },
            };
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, color.r, color.g, color.b, color.a);
            _ = sdl.SDL_RenderFillRect(self.renderer, &status_rect);
        }
    }

    fn renderDetections(self: *GuardianUI) !void {
        try self.detection_panel.render(
            self.renderer,
            10,
            10,
            @intCast(self.window_width - 20),
            @intCast(self.window_height - 50),
        );
    }

    fn renderCameraConfig(self: *GuardianUI) !void {
        try self.camera_config_panel.render(
            self.renderer,
            10,
            10,
            @intCast(self.window_width - 20),
            @intCast(self.window_height - 50),
        );
    }

    fn renderStatusBar(self: *GuardianUI) !void {
        const status_height = 30;
        const y: c_int = @intCast(self.window_height - status_height);
        
        const status_rect = sdl.SDL_Rect{
            .x = 0,
            .y = y,
            .w = @intCast(self.window_width),
            .h = status_height,
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 40, 40, 50, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &status_rect);

        // View indicators
        const views = [_]View{ .camera_grid, .arm_keypad, .intercom, .detections, .camera_config };
        const indicator_size = 20;
        const indicator_y = y + 5;

        for (views, 0..) |view, i| {
            const ind_x = 10 + @as(c_int, @intCast(i)) * (indicator_size + 20);
            const ind = sdl.SDL_Rect{
                .x = ind_x,
                .y = indicator_y,
                .w = indicator_size,
                .h = indicator_size,
            };
            
            if (self.current_view == view) {
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 200, 100, 255);
            } else {
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
            }
            _ = sdl.SDL_RenderFillRect(self.renderer, &ind);
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian UI with Advanced Detection starting", .{});

    // Demo config with detection capabilities
    const dummy_cameras = [_]types.CameraConfig{
        .{
            .id = "cam_front_gate",
            .name = "Front Gate",
            .rtsp_url = "rtsp://192.168.1.100:554/stream1",
            .max_resolution = .uhd_4k,
            .audio_enabled = true,
            .detect_enabled = true,
            .intercom_enabled = true,
            .detection_capabilities = .{
                .facial_recognition = true,
                .plate_recognition = true,
                .vehicle_recognition = true,
                .motion_detection = true,
                .audio_detection = true,
            },
            .location = "entrance",
        },
        .{
            .id = "cam_driveway",
            .name = "Driveway",
            .rtsp_url = "rtsp://192.168.1.101:554/stream1",
            .max_resolution = .full_hd,
            .audio_enabled = true,
            .detect_enabled = true,
            .detection_capabilities = .{
                .plate_recognition = true,
                .vehicle_recognition = true,
                .motion_detection = true,
            },
            .location = "driveway",
        },
        .{
            .id = "cam_backyard",
            .name = "Backyard",
            .rtsp_url = "rtsp://192.168.1.102:554/stream1",
            .max_resolution = .full_hd,
            .audio_enabled = false,
            .detect_enabled = true,
            .detection_capabilities = .{
                .motion_detection = true,
                .pet_detection = true,
            },
            .location = "backyard",
        },
        .{
            .id = "cam_front_door",
            .name = "Front Door",
            .rtsp_url = "rtsp://192.168.1.103:554/stream1",
            .max_resolution = .uhd_4k,
            .audio_enabled = true,
            .detect_enabled = true,
            .detection_capabilities = .{
                .facial_recognition = true,
                .gait_recognition = true,
                .motion_detection = true,
                .audio_detection = true,
            },
            .location = "entrance",
        },
    };

    const config = types.SiteConfig{
        .site_name = "Smart Home Security",
        .cameras = &dummy_cameras,
        .zones = &.{},
        .backup_scope = .events_only,
        .backup_retention_days = 30,
        .backup_bandwidth_cap_mbps = 10,
        .relay_url = "wss://relay.guardian.example.com",
    };

    var ui = try GuardianUI.init(allocator, config, "http://localhost:8080");
    defer ui.deinit();

    try ui.run();
}

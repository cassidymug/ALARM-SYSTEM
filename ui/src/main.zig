// Guardian UI - SDL2-based appliance interface
const std = @import("std");
const common = @import("guardian-common");
const sdl = @import("sdl.zig");

const log = common.logging;
const types = common.types;

const CameraGrid = @import("camera_grid.zig").CameraGrid;
const ArmKeypad = @import("arm_keypad.zig").ArmKeypad;
const IntercomPanel = @import("intercom_panel.zig").IntercomPanel;

const SERVICE_NAME = "ui";

/// Main UI application
pub const GuardianUI = struct {
    allocator: std.mem.Allocator,
    config: types.SiteConfig,
    
    window: *sdl.SDL_Window,
    renderer: *sdl.SDL_Renderer,
    running: bool,
    
    camera_grid: CameraGrid,
    arm_keypad: ArmKeypad,
    intercom_panel: IntercomPanel,
    
    current_view: View,
    window_width: u32 = 1280,
    window_height: u32 = 720,

    const View = enum {
        camera_grid,
        arm_keypad,
        intercom,
    };

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig) !GuardianUI {
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) < 0) {
            log.err(SERVICE_NAME, "SDL_Init failed: {s}", .{sdl.SDL_GetError()});
            return error.SDLInitFailed;
        }

        const window = sdl.SDL_CreateWindow(
            "Guardian Security System",
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
            .camera_grid = try CameraGrid.init(allocator, config.cameras),
            .arm_keypad = ArmKeypad.init(),
            .intercom_panel = IntercomPanel.init(),
            .current_view = .camera_grid,
        };
    }

    pub fn deinit(self: *GuardianUI) void {
        self.camera_grid.deinit();
        sdl.SDL_DestroyRenderer(self.renderer);
        sdl.SDL_DestroyWindow(self.window);
        sdl.SDL_Quit();
    }

    pub fn run(self: *GuardianUI) !void {
        log.info(SERVICE_NAME, "Guardian UI starting", .{});
        self.running = true;

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
        
        // Switch views with F-keys
        if (key == '1') {
            self.current_view = .camera_grid;
            log.info(SERVICE_NAME, "Switched to camera grid view", .{});
        } else if (key == '2') {
            self.current_view = .arm_keypad;
            log.info(SERVICE_NAME, "Switched to arm/disarm keypad", .{});
        } else if (key == '3') {
            self.current_view = .intercom;
            log.info(SERVICE_NAME, "Switched to intercom panel", .{});
        }
        
        // Handle view-specific input
        switch (self.current_view) {
            .arm_keypad => {
                // Numeric keys
                if (key >= sdl.SDLK_0 and key <= sdl.SDLK_9) {
                    self.arm_keypad.addDigit(@intCast(key));
                } else if (key == sdl.SDLK_BACKSPACE) {
                    self.arm_keypad.clear();
                } else if (key == sdl.SDLK_RETURN) {
                    const pin = self.arm_keypad.getCurrentPin();
                    log.info(SERVICE_NAME, "PIN entered: {s}", .{pin});
                    // TODO: Send to guardian-api for validation
                }
            },
            else => {},
        }
    }

    fn handleMouseDown(self: *GuardianUI, event: *const sdl.SDL_MouseButtonEvent) !void {
        switch (self.current_view) {
            .camera_grid => {
                const x = event.x;
                const y = event.y;
                
                // Calculate which camera was clicked
                const layout = self.camera_grid.getGridLayout();
                const cell_width = @divTrunc(self.window_width, layout.cols);
                const cell_height = @divTrunc(self.window_height, layout.rows);
                
                const col = @divTrunc(@as(u32, @intCast(x)), cell_width);
                const row = @divTrunc(@as(u32, @intCast(y)), cell_height);
                const index = row * layout.cols + col;
                
                if (index < self.config.cameras.len) {
                    self.camera_grid.selectCamera(@intCast(index));
                    log.info(SERVICE_NAME, "Selected camera #{d}: {s}", .{
                        index, self.config.cameras[index].name,
                    });
                }
            },
            .arm_keypad => {
                // TODO: Check if click was on a button
            },
            .intercom => {
                // TODO: Check if click was on answer/hangup/talk button
            },
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
        }

        // Render status bar
        try self.renderStatusBar();

        sdl.SDL_RenderPresent(self.renderer);
    }

    fn renderCameraGrid(self: *GuardianUI) !void {
        const layout = self.camera_grid.getGridLayout();
        const cell_width = @divTrunc(self.window_width, layout.cols);
        const cell_height = @divTrunc(self.window_height - 30, layout.rows); // Reserve 30px for status bar

        for (self.config.cameras, 0..) |camera, i| {
            const col = i % layout.cols;
            const row = i / layout.cols;
            
            const x: c_int = @intCast(col * cell_width);
            const y: c_int = @intCast(row * cell_height);
            const w: c_int = @intCast(cell_width);
            const h: c_int = @intCast(cell_height);

            // Draw cell border
            var rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
            
            // Highlight selected camera
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

            // Draw camera name (simplified - in production would use SDL_ttf)
            // For now, just show a placeholder rectangle representing the camera
            const inner_margin = 10;
            rect.x += inner_margin;
            rect.y += inner_margin;
            rect.w -= inner_margin * 2;
            rect.h -= inner_margin * 2;
            
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 40, 40, 50, 255);
            _ = sdl.SDL_RenderFillRect(self.renderer, &rect);

            // Camera indicator based on resolution
            const indicator_size = 10;
            const indicator_rect = sdl.SDL_Rect{
                .x = x + inner_margin + 5,
                .y = y + inner_margin + 5,
                .w = indicator_size,
                .h = indicator_size,
            };
            
            switch (camera.max_resolution) {
                .full_hd => _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 200, 100, 255),
                .uhd_4k => _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 150, 255, 255),
                .uhd_8k => _ = sdl.SDL_SetRenderDrawColor(self.renderer, 255, 100, 100, 255),
            }
            _ = sdl.SDL_RenderFillRect(self.renderer, &indicator_rect);
        }
    }

    fn renderArmKeypad(self: *GuardianUI) !void {
        const keypad_width = 300;
        const keypad_height = 400;
        const x: c_int = @intCast((self.window_width - keypad_width) / 2);
        const y: c_int = @intCast((self.window_height - keypad_height) / 2);

        // Draw keypad background
        const bg_rect = sdl.SDL_Rect{
            .x = x,
            .y = y,
            .w = keypad_width,
            .h = keypad_height,
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 50, 50, 60, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 100, 120, 255);
        _ = sdl.SDL_RenderDrawRect(self.renderer, &bg_rect);

        // Draw PIN display area
        const pin_display = sdl.SDL_Rect{
            .x = x + 20,
            .y = y + 20,
            .w = keypad_width - 40,
            .h = 40,
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 30, 30, 40, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &pin_display);
        
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
        _ = sdl.SDL_RenderDrawRect(self.renderer, &pin_display);

        // Draw PIN dots (masked)
        const pin = self.arm_keypad.getCurrentPin();
        const dot_spacing = 20;
        const dot_start_x = x + 40;
        for (0..pin.len) |i| {
            const dot_x = dot_start_x + @as(c_int, @intCast(i * dot_spacing));
            const dot_rect = sdl.SDL_Rect{
                .x = dot_x,
                .y = y + 35,
                .w = 8,
                .h = 8,
            };
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 200, 200, 200, 255);
            _ = sdl.SDL_RenderFillRect(self.renderer, &dot_rect);
        }

        // Draw state indicator
        const state_text_y = y + 80;
        const state_color = switch (self.arm_keypad.current_state) {
            .disarmed => sdl.SDL_Color{ .r = 100, .g = 200, .b = 100, .a = 255 },
            .armed_away, .armed_stay => sdl.SDL_Color{ .r = 200, .g = 100, .b = 100, .a = 255 },
            .alarm => sdl.SDL_Color{ .r = 255, .g = 50, .b = 50, .a = 255 },
            else => sdl.SDL_Color{ .r = 150, .g = 150, .b = 150, .a = 255 },
        };
        
        const state_rect = sdl.SDL_Rect{
            .x = x + keypad_width / 2 - 50,
            .y = state_text_y,
            .w = 100,
            .h = 30,
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, state_color.r, state_color.g, state_color.b, state_color.a);
        _ = sdl.SDL_RenderFillRect(self.renderer, &state_rect);

        // Draw numeric buttons (3x4 grid)
        const button_size = 60;
        const button_spacing = 10;
        const button_start_x = x + (keypad_width - (button_size * 3 + button_spacing * 2)) / 2;
        const button_start_y = y + 150;

        var btn_num: u8 = 1;
        var row: u8 = 0;
        while (row < 4) : (row += 1) {
            var col: u8 = 0;
            while (col < 3) : (col += 1) {
                if (row == 3 and col != 1) continue; // Skip 10th and 12th positions
                
                const btn_x = button_start_x + @as(c_int, col) * (button_size + button_spacing);
                const btn_y = button_start_y + @as(c_int, row) * (button_size + button_spacing);
                
                const btn_rect = sdl.SDL_Rect{
                    .x = btn_x,
                    .y = btn_y,
                    .w = button_size,
                    .h = button_size,
                };
                
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 70, 70, 80, 255);
                _ = sdl.SDL_RenderFillRect(self.renderer, &btn_rect);
                
                _ = sdl.SDL_SetRenderDrawColor(self.renderer, 120, 120, 130, 255);
                _ = sdl.SDL_RenderDrawRect(self.renderer, &btn_rect);
                
                if (row < 3) {
                    btn_num += 1;
                }
            }
        }
    }

    fn renderIntercom(self: *GuardianUI) !void {
        const panel_width = 400;
        const panel_height = 300;
        const x: c_int = @intCast((self.window_width - panel_width) / 2);
        const y: c_int = @intCast((self.window_height - panel_height) / 2);

        // Draw panel background
        const bg_rect = sdl.SDL_Rect{
            .x = x,
            .y = y,
            .w = panel_width,
            .h = panel_height,
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 50, 50, 60, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 100, 120, 255);
        _ = sdl.SDL_RenderDrawRect(self.renderer, &bg_rect);

        // Draw station status
        if (self.intercom_panel.active_session) |session| {
            const status_rect = sdl.SDL_Rect{
                .x = x + 20,
                .y = y + 20,
                .w = panel_width - 40,
                .h = 60,
            };
            
            const status_color = switch (session.state) {
                .ringing => sdl.SDL_Color{ .r = 255, .g = 165, .b = 0, .a = 255 }, // Orange
                .answered, .talking => sdl.SDL_Color{ .r = 100, .g = 200, .b = 100, .a = 255 }, // Green
            };
            
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, status_color.r, status_color.g, status_color.b, status_color.a);
            _ = sdl.SDL_RenderFillRect(self.renderer, &status_rect);
        } else {
            // No active session
            const idle_rect = sdl.SDL_Rect{
                .x = x + 20,
                .y = y + 20,
                .w = panel_width - 40,
                .h = 60,
            };
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
            _ = sdl.SDL_RenderFillRect(self.renderer, &idle_rect);
        }

        // Draw answer/hangup button
        const button_y = y + 100;
        const answer_btn = sdl.SDL_Rect{
            .x = x + 50,
            .y = button_y,
            .w = 120,
            .h = 50,
        };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 200, 100, 255);
        _ = sdl.SDL_RenderFillRect(self.renderer, &answer_btn);

        // Draw talk button
        const talk_btn = sdl.SDL_Rect{
            .x = x + 230,
            .y = button_y,
            .w = 120,
            .h = 50,
        };
        const talk_color = if (self.intercom_panel.active_session != null and
            self.intercom_panel.active_session.?.state == .talking)
            sdl.SDL_Color{ .r = 255, .g = 100, .b = 100, .a = 255 }
        else
            sdl.SDL_Color{ .r = 150, .g = 150, .b = 160, .a = 255 };
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, talk_color.r, talk_color.g, talk_color.b, talk_color.a);
        _ = sdl.SDL_RenderFillRect(self.renderer, &talk_btn);
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

        // Draw view indicators
        const indicator_size = 20;
        const indicator_y = y + 5;
        
        // Camera grid indicator
        var indicator = sdl.SDL_Rect{
            .x = 10,
            .y = indicator_y,
            .w = indicator_size,
            .h = indicator_size,
        };
        if (self.current_view == .camera_grid) {
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 200, 100, 255);
        } else {
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
        }
        _ = sdl.SDL_RenderFillRect(self.renderer, &indicator);

        // Keypad indicator
        indicator.x = 50;
        if (self.current_view == .arm_keypad) {
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 200, 100, 255);
        } else {
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
        }
        _ = sdl.SDL_RenderFillRect(self.renderer, &indicator);

        // Intercom indicator
        indicator.x = 90;
        if (self.current_view == .intercom) {
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 100, 200, 100, 255);
        } else {
            _ = sdl.SDL_SetRenderDrawColor(self.renderer, 80, 80, 90, 255);
        }
        _ = sdl.SDL_RenderFillRect(self.renderer, &indicator);
    }
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
        .{
            .id = "cam_backyard",
            .name = "Backyard",
            .rtsp_url = "rtsp://192.168.1.102:554/stream1",
            .max_resolution = .full_hd,
            .audio_enabled = false,
            .detect_enabled = true,
            .intercom_enabled = false,
        },
        .{
            .id = "cam_garage",
            .name = "Garage",
            .rtsp_url = "rtsp://192.168.1.103:554/stream1",
            .max_resolution = .full_hd,
            .audio_enabled = false,
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

    try ui.run();
}

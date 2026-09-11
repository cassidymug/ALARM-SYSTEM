// Camera Configuration Panel - configure detection capabilities per camera
const std = @import("std");
const common = @import("guardian-common");
const sdl = @import("sdl.zig");

const types = common.types;
const log = common.logging;

const SERVICE_NAME = "camera-config";

pub const CameraConfigPanel = struct {
    allocator: std.mem.Allocator,
    cameras: []const types.CameraConfig,
    selected_camera: ?usize = null,

    pub fn init(allocator: std.mem.Allocator, cameras: []const types.CameraConfig) CameraConfigPanel {
        return .{
            .allocator = allocator,
            .cameras = cameras,
        };
    }

    pub fn deinit(self: *CameraConfigPanel) void {
        _ = self;
    }

    pub fn selectCamera(self: *CameraConfigPanel, index: usize) void {
        if (index < self.cameras.len) {
            self.selected_camera = index;
        }
    }

    pub fn toggleDetectionCapability(self: *CameraConfigPanel, capability: DetectionCapability) !void {
        if (self.selected_camera) |idx| {
            var caps = &self.cameras[idx].detection_capabilities;
            
            switch (capability) {
                .facial_recognition => caps.facial_recognition = !caps.facial_recognition,
                .plate_recognition => caps.plate_recognition = !caps.plate_recognition,
                .vehicle_recognition => caps.vehicle_recognition = !caps.vehicle_recognition,
                .gait_recognition => caps.gait_recognition = !caps.gait_recognition,
                .pet_detection => caps.pet_detection = !caps.pet_detection,
                .motion_detection => caps.motion_detection = !caps.motion_detection,
                .audio_detection => caps.audio_detection = !caps.audio_detection,
            }
            
            log.info(SERVICE_NAME, "Toggled {s} for camera {s}", .{
                @tagName(capability),
                self.cameras[idx].id,
            });
            
            // TODO: Send update to API
        }
    }

    pub fn render(self: *CameraConfigPanel, renderer: *sdl.SDL_Renderer, x: c_int, y: c_int, w: c_int, h: c_int) !void {
        // Split into camera list (left) and config panel (right)
        const list_width = @divTrunc(w, 3);
        const panel_width = w - list_width - 10;

        try self.renderCameraList(renderer, x, y, list_width, h);
        try self.renderConfigPanel(renderer, x + list_width + 10, y, panel_width, h);
    }

    fn renderCameraList(self: *CameraConfigPanel, renderer: *sdl.SDL_Renderer, x: c_int, y: c_int, w: c_int, h: c_int) !void {
        // Background
        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 30, 30, 40, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(renderer, 80, 80, 90, 255);
        _ = sdl.SDL_RenderDrawRect(renderer, &bg_rect);

        // Camera items
        const item_height = 50;
        var current_y = y + 10;

        for (self.cameras, 0..) |camera, i| {
            const item_rect = sdl.SDL_Rect{
                .x = x + 5,
                .y = current_y,
                .w = w - 10,
                .h = item_height,
            };

            const is_selected = if (self.selected_camera) |sel| sel == i else false;
            
            if (is_selected) {
                _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255);
            } else {
                _ = sdl.SDL_SetRenderDrawColor(renderer, 50, 50, 60, 255);
            }
            _ = sdl.SDL_RenderFillRect(renderer, &item_rect);
            
            _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 100, 110, 255);
            _ = sdl.SDL_RenderDrawRect(renderer, &item_rect);

            // Resolution indicator
            const res_size = 15;
            const res_rect = sdl.SDL_Rect{
                .x = x + 10,
                .y = current_y + (item_height - res_size) / 2,
                .w = res_size,
                .h = res_size,
            };
            
            switch (camera.max_resolution) {
                .full_hd => _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 200, 100, 255),
                .uhd_4k => _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255),
                .uhd_8k => _ = sdl.SDL_SetRenderDrawColor(renderer, 255, 100, 100, 255),
            }
            _ = sdl.SDL_RenderFillRect(renderer, &res_rect);

            // TODO: Render camera name with SDL_ttf

            current_y += item_height + 5;
            if (current_y + item_height > y + h) break;
        }
    }

    fn renderConfigPanel(self: *CameraConfigPanel, renderer: *sdl.SDL_Renderer, x: c_int, y: c_int, w: c_int, h: c_int) !void {
        // Background
        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 30, 30, 40, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(renderer, 80, 80, 90, 255);
        _ = sdl.SDL_RenderDrawRect(renderer, &bg_rect);

        if (self.selected_camera) |idx| {
            const camera = self.cameras[idx];
            const caps = camera.detection_capabilities;

            // Title area
            const title_rect = sdl.SDL_Rect{
                .x = x + 10,
                .y = y + 10,
                .w = w - 20,
                .h = 40,
            };
            _ = sdl.SDL_SetRenderDrawColor(renderer, 50, 50, 60, 255);
            _ = sdl.SDL_RenderFillRect(renderer, &title_rect);
            
            // TODO: Render camera name with SDL_ttf

            // Detection capability toggles
            var toggle_y = y + 70;
            const toggle_height = 40;
            const toggle_spacing = 10;

            const capabilities = [_]struct {
                name: []const u8,
                enabled: bool,
                cap: DetectionCapability,
            }{
                .{ .name = "Facial Recognition", .enabled = caps.facial_recognition, .cap = .facial_recognition },
                .{ .name = "License Plate Recognition", .enabled = caps.plate_recognition, .cap = .plate_recognition },
                .{ .name = "Vehicle Recognition", .enabled = caps.vehicle_recognition, .cap = .vehicle_recognition },
                .{ .name = "Gait Recognition", .enabled = caps.gait_recognition, .cap = .gait_recognition },
                .{ .name = "Pet Detection", .enabled = caps.pet_detection, .cap = .pet_detection },
                .{ .name = "Motion Detection", .enabled = caps.motion_detection, .cap = .motion_detection },
                .{ .name = "Audio Detection", .enabled = caps.audio_detection, .cap = .audio_detection },
            };

            for (capabilities) |cap_info| {
                try self.renderToggle(
                    renderer,
                    x + 20,
                    toggle_y,
                    w - 40,
                    toggle_height,
                    cap_info.name,
                    cap_info.enabled,
                );
                toggle_y += toggle_height + toggle_spacing;
            }
        } else {
            // No camera selected message
            const msg_rect = sdl.SDL_Rect{
                .x = x + @divTrunc(w, 2) - 100,
                .y = y + @divTrunc(h, 2) - 20,
                .w = 200,
                .h = 40,
            };
            _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 100, 110, 255);
            _ = sdl.SDL_RenderFillRect(renderer, &msg_rect);
            
            // TODO: Render "Select a camera" text
        }
    }

    fn renderToggle(
        self: *CameraConfigPanel,
        renderer: *sdl.SDL_Renderer,
        x: c_int,
        y: c_int,
        w: c_int,
        h: c_int,
        label: []const u8,
        enabled: bool,
    ) !void {
        _ = self;
        _ = label;
        
        // Toggle background
        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 50, 50, 60, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 100, 110, 255);
        _ = sdl.SDL_RenderDrawRect(renderer, &bg_rect);

        // Toggle switch
        const switch_width = 60;
        const switch_height = 30;
        const switch_x = x + w - switch_width - 10;
        const switch_y = y + @divTrunc(h - switch_height, 2);

        const switch_rect = sdl.SDL_Rect{
            .x = switch_x,
            .y = switch_y,
            .w = switch_width,
            .h = switch_height,
        };

        if (enabled) {
            _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 200, 100, 255);
        } else {
            _ = sdl.SDL_SetRenderDrawColor(renderer, 150, 60, 60, 255);
        }
        _ = sdl.SDL_RenderFillRect(renderer, &switch_rect);
        
        // Switch knob
        const knob_size = 24;
        const knob_x = if (enabled) switch_x + switch_width - knob_size - 3 else switch_x + 3;
        const knob_y = switch_y + 3;
        
        const knob_rect = sdl.SDL_Rect{
            .x = knob_x,
            .y = knob_y,
            .w = knob_size,
            .h = knob_size,
        };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &knob_rect);
        
        // TODO: Render label text with SDL_ttf
    }
};

pub const DetectionCapability = enum {
    facial_recognition,
    plate_recognition,
    vehicle_recognition,
    gait_recognition,
    pet_detection,
    motion_detection,
    audio_detection,
};

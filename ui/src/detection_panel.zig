// Detection Events Panel - shows recent detection events with filtering
const std = @import("std");
const common = @import("guardian-common");
const sdl = @import("sdl.zig");

const types = common.types;
const log = common.logging;

const SERVICE_NAME = "detection-panel";

pub const DetectionPanel = struct {
    allocator: std.mem.Allocator,
    events: std.ArrayList(types.DetectionEvent),
    selected_filter: ?types.DetectionType = null,
    scroll_offset: usize = 0,
    max_visible: usize = 10,

    pub fn init(allocator: std.mem.Allocator) DetectionPanel {
        return .{
            .allocator = allocator,
            .events = std.ArrayList(types.DetectionEvent).init(allocator),
        };
    }

    pub fn deinit(self: *DetectionPanel) void {
        self.events.deinit();
    }

    pub fn addEvent(self: *DetectionPanel, event: types.DetectionEvent) !void {
        try self.events.insert(0, event); // Newest first
        
        // Keep max 100 events
        while (self.events.items.len > 100) {
            _ = self.events.pop();
        }
    }

    pub fn setFilter(self: *DetectionPanel, filter: ?types.DetectionType) void {
        self.selected_filter = filter;
        self.scroll_offset = 0;
    }

    pub fn scrollUp(self: *DetectionPanel) void {
        if (self.scroll_offset > 0) {
            self.scroll_offset -= 1;
        }
    }

    pub fn scrollDown(self: *DetectionPanel) void {
        const filtered_count = self.getFilteredEventCount();
        if (self.scroll_offset + self.max_visible < filtered_count) {
            self.scroll_offset += 1;
        }
    }

    pub fn render(self: *DetectionPanel, renderer: *sdl.SDL_Renderer, x: c_int, y: c_int, w: c_int, h: c_int) !void {
        // Draw panel background
        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 30, 30, 40, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(renderer, 80, 80, 90, 255);
        _ = sdl.SDL_RenderDrawRect(renderer, &bg_rect);

        // Draw filter buttons
        try self.renderFilterButtons(renderer, x + 10, y + 10, w - 20);

        // Draw event list
        const list_y = y + 60;
        const list_h = h - 70;
        try self.renderEventList(renderer, x + 10, list_y, w - 20, list_h);
    }

    fn renderFilterButtons(self: *DetectionPanel, renderer: *sdl.SDL_Renderer, x: c_int, y: c_int, w: c_int) !void {
        const button_w = @divTrunc(w, 8);
        const button_h = 35;
        
        const filters = [_]?types.DetectionType{
            null, // All
            .motion,
            .face_recognized,
            .vehicle,
            .license_plate,
            .pet,
            .audio_event,
        };
        
        const filter_names = [_][]const u8{
            "All", "Motion", "Faces", "Vehicles", "Plates", "Pets", "Audio",
        };

        for (filters, filter_names, 0..) |filter, filter_name, i| {
            const btn_x = x + @as(c_int, @intCast(i)) * (button_w + 5);
            const btn_rect = sdl.SDL_Rect{
                .x = btn_x,
                .y = y,
                .w = button_w,
                .h = button_h,
            };

            const is_selected = if (self.selected_filter) |selected|
                filter != null and filter.? == selected
            else
                filter == null;

            if (is_selected) {
                _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255);
            } else {
                _ = sdl.SDL_SetRenderDrawColor(renderer, 60, 60, 70, 255);
            }
            _ = sdl.SDL_RenderFillRect(renderer, &btn_rect);
            
            _ = sdl.SDL_SetRenderDrawColor(renderer, 120, 120, 130, 255);
            _ = sdl.SDL_RenderDrawRect(renderer, &btn_rect);
            
            // TODO: Render text with SDL_ttf
            _ = filter_name;
        }
    }

    fn renderEventList(self: *DetectionPanel, renderer: *sdl.SDL_Renderer, x: c_int, y: c_int, w: c_int, h: c_int) !void {
        const item_height = 60;
        var current_y = y;
        var visible_count: usize = 0;

        for (self.events.items) |event| {
            // Apply filter
            if (self.selected_filter) |filter| {
                if (event.event_type != filter) continue;
            }

            // Skip scrolled items
            if (visible_count < self.scroll_offset) {
                visible_count += 1;
                continue;
            }

            // Stop if we've filled the visible area
            if (current_y + item_height > y + h) break;

            try self.renderEventItem(renderer, event, x, current_y, w, item_height);
            current_y += item_height + 5;
            visible_count += 1;
        }
    }

    fn renderEventItem(
        self: *DetectionPanel,
        renderer: *sdl.SDL_Renderer,
        event: types.DetectionEvent,
        x: c_int,
        y: c_int,
        w: c_int,
        h: c_int,
    ) !void {
        _ = self;
        
        // Event background
        const bg_rect = sdl.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &bg_rect);
        
        _ = sdl.SDL_SetRenderDrawColor(renderer, 70, 70, 80, 255);
        _ = sdl.SDL_RenderDrawRect(renderer, &bg_rect);

        // Event type indicator (color-coded)
        const indicator_rect = sdl.SDL_Rect{
            .x = x + 5,
            .y = y + 5,
            .w = 10,
            .h = h - 10,
        };
        
        const color = switch (event.event_type) {
            .motion => sdl.SDL_Color{ .r = 100, .g = 200, .b = 100, .a = 255 },
            .face_recognized => sdl.SDL_Color{ .r = 100, .g = 150, .b = 255, .a = 255 },
            .face_unknown => sdl.SDL_Color{ .r = 200, .g = 150, .b = 100, .a = 255 },
            .vehicle, .license_plate => sdl.SDL_Color{ .r = 255, .g = 200, .b = 100, .a = 255 },
            .pet => sdl.SDL_Color{ .r = 255, .g = 150, .b = 200, .a = 255 },
            .audio_event => sdl.SDL_Color{ .r = 150, .g = 100, .b = 255, .a = 255 },
            .gait_match => sdl.SDL_Color{ .r = 100, .g = 255, .b = 200, .a = 255 },
            else => sdl.SDL_Color{ .r = 150, .g = 150, .b = 150, .a = 255 },
        };
        
        _ = sdl.SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
        _ = sdl.SDL_RenderFillRect(renderer, &indicator_rect);

        // Confidence bar
        const conf_width = @as(c_int, @intFromFloat(event.confidence * @as(f32, @floatFromInt(w - 40))));
        const conf_rect = sdl.SDL_Rect{
            .x = x + 25,
            .y = y + h - 15,
            .w = conf_width,
            .h = 8,
        };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 200, 100, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &conf_rect);
        
        // TODO: Render event text details with SDL_ttf
        // - Camera name
        // - Event type
        // - Metadata (e.g., person name, plate number)
        // - Timestamp
    }

    fn getFilteredEventCount(self: *DetectionPanel) usize {
        if (self.selected_filter == null) {
            return self.events.items.len;
        }
        
        var count: usize = 0;
        for (self.events.items) |event| {
            if (event.event_type == self.selected_filter.?) {
                count += 1;
            }
        }
        return count;
    }
};

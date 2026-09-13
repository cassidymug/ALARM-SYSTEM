// SDL2 C bindings for Zig
// Minimal bindings for Guardian UI needs

pub const SDL_INIT_VIDEO = 0x00000020;
pub const SDL_WINDOW_SHOWN = 0x00000004;
pub const SDL_WINDOWPOS_UNDEFINED = 0x1FFF0000;

pub const SDL_RENDERER_ACCELERATED = 0x00000002;
pub const SDL_RENDERER_PRESENTVSYNC = 0x00000004;

pub const SDL_Event = extern struct {
    type: u32,
    padding: [56]u8,
};

pub const SDL_KeyboardEvent = extern struct {
    type: u32,
    timestamp: u32,
    windowID: u32,
    state: u8,
    repeat: u8,
    padding2: u8,
    padding3: u8,
    keysym: SDL_Keysym,
};

pub const SDL_Keysym = extern struct {
    scancode: i32,
    sym: i32,
    mod: u16,
    unused: u32,
};

pub const SDL_MouseButtonEvent = extern struct {
    type: u32,
    timestamp: u32,
    windowID: u32,
    which: u32,
    button: u8,
    state: u8,
    clicks: u8,
    padding: u8,
    x: i32,
    y: i32,
};

pub const SDL_Rect = extern struct {
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,
};

pub const SDL_Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

// Event types
pub const SDL_QUIT = 0x100;
pub const SDL_KEYDOWN = 0x300;
pub const SDL_KEYUP = 0x301;
pub const SDL_MOUSEBUTTONDOWN = 0x401;
pub const SDL_MOUSEBUTTONUP = 0x402;

// Key codes
pub const SDLK_0 = '0';
pub const SDLK_1 = '1';
pub const SDLK_2 = '2';
pub const SDLK_3 = '3';
pub const SDLK_4 = '4';
pub const SDLK_5 = '5';
pub const SDLK_6 = '6';
pub const SDLK_7 = '7';
pub const SDLK_8 = '8';
pub const SDLK_9 = '9';
pub const SDLK_RETURN = '\r';
pub const SDLK_BACKSPACE = '\x08';
pub const SDLK_ESCAPE = '\x1b';

// Opaque types
pub const SDL_Window = opaque {};
pub const SDL_Renderer = opaque {};
pub const SDL_Texture = opaque {};

// Functions
pub extern "c" fn SDL_Init(flags: u32) c_int;
pub extern "c" fn SDL_Quit() void;
pub extern "c" fn SDL_CreateWindow(title: [*:0]const u8, x: c_int, y: c_int, w: c_int, h: c_int, flags: u32) ?*SDL_Window;
pub extern "c" fn SDL_DestroyWindow(window: *SDL_Window) void;
pub extern "c" fn SDL_CreateRenderer(window: *SDL_Window, index: c_int, flags: u32) ?*SDL_Renderer;
pub extern "c" fn SDL_DestroyRenderer(renderer: *SDL_Renderer) void;
pub extern "c" fn SDL_PollEvent(event: *SDL_Event) c_int;
pub extern "c" fn SDL_SetRenderDrawColor(renderer: *SDL_Renderer, r: u8, g: u8, b: u8, a: u8) c_int;
pub extern "c" fn SDL_RenderClear(renderer: *SDL_Renderer) c_int;
pub extern "c" fn SDL_RenderPresent(renderer: *SDL_Renderer) void;
pub extern "c" fn SDL_RenderFillRect(renderer: *SDL_Renderer, rect: ?*const SDL_Rect) c_int;
pub extern "c" fn SDL_RenderDrawRect(renderer: *SDL_Renderer, rect: *const SDL_Rect) c_int;
pub extern "c" fn SDL_Delay(ms: u32) void;
pub extern "c" fn SDL_GetError() [*:0]const u8;

# Guardian UI Implementation Notes

## Rendering Approach: SDL2 with Wayland/X11 backend

**Decision**: Use SDL2 as the graphics abstraction layer

**Rationale**:
- Provides a clean cross-platform abstraction over Wayland, X11, and DRM/KMS
- Well-supported on Linux with minimal dependencies
- Zig has good C interop for SDL2
- Handles input (keyboard, mouse, touch) uniformly
- Can do software or OpenGL-accelerated rendering
- Significantly simpler than direct DRM/KMS or Wayland protocol implementation

**Alternative considered**: Direct Wayland client
- More complex: need to implement Wayland protocol, shared memory buffers, input handling
- Not cross-platform
- Reinventing what SDL2 already provides well

**Alternative considered**: Direct DRM/KMS
- Lowest level, no compositor needed
- Complex: mode setting, buffer management, page flipping
- Input handling would need separate evdev
- Harder to develop/test

## SDL2 as minimal dependency

SDL2 is installed via system package manager (apt):
```bash
sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
```

This is consistent with our ffmpeg approach: well-tested system libraries, not hidden dependencies.

## UI Architecture

```
┌─────────────────────────────────────┐
│  guardian-ui (Zig executable)      │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  SDL2 Window + Renderer      │  │
│  │  (Wayland/X11/DRM backend)   │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Camera Grid                  │  │
│  │  - Fetch frames from API     │  │
│  │  - Decode with ffmpeg        │  │
│  │  - Render to SDL texture     │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Arm Keypad                   │  │
│  │  - SDL_Event for input       │  │
│  │  - POST to guardian-api      │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Intercom Panel               │  │
│  │  - Answer/hangup buttons     │  │
│  │  - Talk button (push to talk)│  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
         │
         ↓
   guardian-api
   (REST/WebSocket)
```

## Video Decode Path

For camera frames:
1. Guardian-api provides substream frames (or main stream for tap-to-HD)
2. UI fetches JPEG frames via HTTP or receives via WebSocket
3. SDL2_image decodes JPEG to SDL_Texture
4. Alternative: ffmpeg pipe for video decode if needed

## Development Notes

- SDL2 runs on Linux (primary), macOS (dev), Windows (possible but not priority)
- For appliance deployment, SDL2 will use Wayland or X11 (whichever is configured)
- For headless testing, can use SDL_VIDEODRIVER=dummy

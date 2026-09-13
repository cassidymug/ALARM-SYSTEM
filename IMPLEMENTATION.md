# Guardian Implementation Notes

## RTSP Ingest (Recorder)

### Approach: FFmpeg Subprocess

**Decision**: Spawn `ffmpeg` as a subprocess per camera.

**Rationale**:
- **Minimal dependencies**: ffmpeg is a system package, no C bindings required
- **Battle-tested**: Handles all RTSP/RTP/codec combinations reliably
- **Mature**: Format negotiation, reconnection, and error handling built-in
- **Consistent with design**: Explicit helper process (like our relay uses Go), not hidden dependency sprawl

**Alternative considered**: libav C bindings
- Would require maintaining C interop code
- Need to handle codec negotiation, RTP parsing, and format detection manually
- FFmpeg CLI already provides this functionality well-tested

### Implementation Details

**Per-camera process**:
1. `ffmpeg -rtsp_transport tcp -i <rtsp_url> -c:v copy -c:a copy -f segment -segment_time 60 ...`
2. Monitors stderr for connection status/errors
3. Restarts on failure with exponential backoff (1s → 2s → 4s → 8s, max 30s)
4. Publishes segment events to event bus when complete

**Resolution profiles**:
- Per-camera `max_resolution` in config: `full_hd`, `uhd_4k`, `uhd_8k`
- FFmpeg copies video stream as-is (no transcoding by default)
- Hardware encoding recommended for multi-4K/8K scenarios

**Error handling**:
- Camera failure does not crash appliance
- Auto-reconnect on network drops
- Logged clearly with camera ID and error details

### Testing

Public RTSP test stream hardcoded for smoke testing:
```
rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4
```

See `TESTING.md` for full test instructions.

---

## UI Rendering

### Approach: SDL2 with Wayland/X11 Backend

**Decision**: Use SDL2 as graphics abstraction.

**Rationale**:
- **Clean cross-platform abstraction**: Works on Wayland, X11, and DRM/KMS
- **Well-supported on Linux**: Minimal system dependencies (`libsdl2-dev`)
- **Good Zig interop**: SDL2 is C-based, Zig has excellent C FFI
- **Unified input handling**: Keyboard, mouse, touch via SDL events
- **Hardware acceleration**: Can use OpenGL or software rendering
- **Significantly simpler**: No need to implement Wayland protocol or DRM/KMS mode-setting manually

**Alternative considered**: Direct Wayland client
- More complex: Wayland protocol, shared memory buffers, input protocols
- Not cross-platform
- Reinventing what SDL2 provides

**Alternative considered**: Direct DRM/KMS
- Lowest level, no compositor
- Complex: mode-setting, buffer management, page flipping, evdev for input
- Harder to develop and test

### Implementation Details

**Architecture**:
```
guardian-ui (Zig executable)
  ├─ SDL2 Window + Renderer (hardware-accelerated)
  │   └─ Wayland/X11/DRM backend (auto-detected)
  ├─ Camera Grid View
  │   ├─ 2x2/3x3/4x4 grid based on camera count
  │   ├─ Click to select camera
  │   └─ Resolution indicators (color-coded)
  ├─ Arm/Disarm Keypad
  │   ├─ PIN entry (0-9, backspace, enter)
  │   ├─ Alarm state display
  │   └─ Numeric button grid
  └─ Intercom Panel
      ├─ Station status
      └─ Answer/hangup/talk buttons
```

**Input handling**:
- SDL_KEYDOWN for keyboard (PIN entry, view switching)
- SDL_MOUSEBUTTONDOWN for clicks (camera selection, buttons)
- ESC to quit

**Views**:
- Press 1: Camera grid
- Press 2: Arm/disarm keypad
- Press 3: Intercom panel

**Frame rate**: ~60 FPS with vsync

### Video Decode Path (Future)

For displaying actual camera frames:
1. Fetch JPEG frames from `guardian-api` via HTTP/WebSocket
2. Decode with SDL2_image (JPEG → SDL_Texture)
3. Alternative: ffmpeg pipe for video decode if needed

Current implementation shows placeholder rectangles until API integration.

### Testing

See `TESTING.md` for:
- Installation of SDL2
- Running the UI
- Keyboard/mouse controls
- Headless testing with `SDL_VIDEODRIVER=dummy`

---

## Build System

### Services (Zig)

Each service has its own `build.zig`:
```zig
const exe = b.addExecutable(.{
    .name = "guardian-recorder",
    .root_source_file = b.path("src/main.zig"),
    // ...
});

const common_mod = b.addModule("guardian-common", .{
    .root_source_file = b.path("../common/src/lib.zig"),
});
exe.root_module.addImport("guardian-common", common_mod);
```

### UI (Zig + SDL2)

```zig
exe.linkSystemLibrary("SDL2");
exe.linkLibC();
```

### Relay (Go)

Standard Go build:
```bash
cd deploy/hetzner/relay
go build -o guardian-relay
```

### Build All

```bash
./build-all.sh
```

Builds all 10 services + UI.

---

## Dependencies

### System Packages (Debian/Ubuntu)

```bash
# For recorder
sudo apt-get install ffmpeg

# For UI
sudo apt-get install libsdl2-dev

# For building (already installed in dev)
# - zig 0.13+
# - go 1.22+
```

These are **explicit, documented dependencies**, not hidden libs. Consistent with minimal-deps design goal.

---

## Next Steps (TODOs)

### Recorder
- [ ] Load config from `/etc/guardian/site.json`
- [ ] Use inotify instead of polling for segment detection
- [ ] Implement retention policy (circular buffer, free space check)
- [ ] Add metadata database (SQLite) for segments

### UI
- [ ] Integrate SDL_ttf for text rendering (camera names, labels)
- [ ] Connect to `guardian-api` for camera list and status
- [ ] Fetch and decode JPEG frames from API for live view
- [ ] Wire button click detection fully (arm/disarm actions)
- [ ] Implement WebSocket connection for real-time events

### Integration
- [ ] API server implementation (REST + WebSocket)
- [ ] API endpoints: `/cameras`, `/alarm/status`, `/alarm/arm`, `/alarm/disarm`
- [ ] WebSocket events: alarm state changes, sensor triggers, recording segments

### Security
- [ ] API authentication (tokens)
- [ ] TLS for API (self-signed or Let's Encrypt)
- [ ] PIN validation with rate limiting
- [ ] Audit log for arm/disarm actions

---

## File Changes Summary

### New Files
- `services/recorder/src/main.zig` - Complete rewrite with FFmpeg subprocess RTSP ingest
- `ui/src/main.zig` - Complete rewrite with SDL2 rendering
- `ui/src/sdl.zig` - SDL2 C bindings for Zig
- `ui/IMPLEMENTATION.md` - UI design rationale
- `ui/build.zig` - Updated to link SDL2
- `TESTING.md` - Testing guide for recorder and UI

### Modified Files
- `services/recorder/build.zig` - Uses direct path imports
- `build-all.sh` - Builds all services including updated recorder/UI

### System Requirements
- Added: `ffmpeg` (recorder)
- Added: `libsdl2-dev` (UI)

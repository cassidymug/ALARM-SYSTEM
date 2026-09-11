# Guardian Testing Guide

## Recorder (RTSP Ingest) Testing

### Prerequisites

```bash
sudo apt-get install ffmpeg
```

### Smoke Test with Public RTSP Stream

The recorder is configured to use a public test stream by default (Big Buck Bunny).

```bash
# Create recording directory
sudo mkdir -p /srv/guardian/recordings
sudo chown $USER /srv/guardian/recordings

# Run recorder (will connect to public test stream)
cd services/recorder
zig build run
```

The recorder will:
1. Connect to `rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4`
2. Write 60-second segments to `/srv/guardian/recordings/cam_test/`
3. Auto-reconnect on failure with exponential backoff

### Test with Your Own Cameras

Edit the config in `services/recorder/src/main.zig`:

```zig
const dummy_cameras = [_]types.CameraConfig{
    .{
        .id = "your_camera",
        .name = "Your Camera Name",
        .rtsp_url = "rtsp://192.168.1.100:554/stream1",
        .max_resolution = .uhd_4k,  // or .full_hd, .uhd_8k
        .audio_enabled = true,
    },
};
```

### Verifying Recording

```bash
# Check for segments
ls -lh /srv/guardian/recordings/cam_test/

# Play a segment
ffplay /srv/guardian/recordings/cam_test/*.mp4
```

---

## UI Testing

### Prerequisites

```bash
sudo apt-get install libsdl2-dev
```

### Running the UI

```bash
cd ui
zig build run
```

The UI window will open with:
- **Press 1** to show camera grid
- **Press 2** to show arm/disarm keypad
- **Press 3** to show intercom panel
- **Press ESC** to quit

### Camera Grid View

- Shows 2x2 grid for 4 cameras (automatically adjusts based on camera count)
- Click a camera to select it (blue border)
- Resolution indicators:
  - Green = Full HD
  - Blue = 4K
  - Red = 8K

### Arm/Disarm Keypad

- Type digits 0-9 to enter PIN
- Backspace to clear
- Enter to submit (logs PIN, will be sent to API in future)
- Shows current alarm state (color-coded)

### Intercom Panel

- Shows active session status (orange = ringing, green = answered)
- Button placeholders for Answer, Hangup, Talk

### Headless Testing

For CI or headless environments:

```bash
SDL_VIDEODRIVER=dummy zig build run
```

---

## Integration Testing (Future)

Once API is implemented:
1. Start `guardian-api` (port 8080)
2. Start `guardian-recorder` (will record to disk)
3. Start `guardian-ui` (will connect to API for camera list/status)
4. UI will show actual camera frames fetched from API

---

## Performance Notes

### Recorder
- Each camera runs in its own thread
- FFmpeg handles codec/format negotiation
- Reconnects automatically on network issues
- Monitor CPU usage: `htop` while recording
- For 4K/8K cameras, ensure hardware encoding is available

### UI
- Runs at ~60 FPS with vsync
- SDL2 uses hardware acceleration when available
- Can run on Wayland, X11, or DRM/KMS
- Memory usage is minimal (no video decode yet, just UI rendering)

---

## Known Limitations (Current Implementation)

### Recorder
- ❌ No actual config file loading (uses hardcoded dummy config)
- ❌ Segment monitoring uses polling (should use inotify)
- ❌ No retention policy enforcement yet
- ❌ No metadata database yet
- ✅ RTSP ingest works
- ✅ Segment writing works
- ✅ Auto-reconnect works
- ✅ 4K/8K resolution profiles work

### UI
- ❌ No actual camera frame display (shows placeholders)
- ❌ No API connection yet
- ❌ No text rendering (SDL_ttf not integrated yet)
- ❌ Buttons are drawn but click detection not fully wired
- ✅ Window rendering works
- ✅ View switching works
- ✅ Keyboard input works
- ✅ Mouse click detection works
- ✅ Resolution-aware grid layout works

---

## Troubleshooting

### Recorder Issues

**"FFmpeg not found"**
```bash
sudo apt-get install ffmpeg
ffmpeg -version
```

**"Permission denied" on /srv/guardian**
```bash
sudo mkdir -p /srv/guardian/recordings
sudo chown -R $USER /srv/guardian
```

**"RTSP connection failed"**
- Check camera is reachable: `ping 192.168.1.100`
- Test stream with ffplay: `ffplay rtsp://192.168.1.100:554/stream1`
- Check camera RTSP settings (TCP transport, authentication)

### UI Issues

**"SDL_Init failed"**
```bash
sudo apt-get install libsdl2-dev
pkg-config --modversion sdl2
```

**"Cannot connect to display"**
- Set `DISPLAY=:0` if running remotely
- Use `SDL_VIDEODRIVER=dummy` for headless
- Ensure X11 or Wayland is running

**Window doesn't open**
- Check window manager is running
- Try `SDL_VIDEODRIVER=x11` to force X11
- Check SDL2 logs: `SDL_LOG_PRIORITY=verbose zig build run`

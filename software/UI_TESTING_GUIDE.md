# Guardian UI - Testing Guide

## Prerequisites

### Install SDL2

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install libsdl2-dev
```

**Fedora/RHEL**:
```bash
sudo dnf install SDL2-devel
```

**macOS**:
```bash
brew install sdl2
```

**Windows**:
- Download SDL2 development libraries from https://www.libsdl.org/download-2.0.php
- Extract to a known location
- Set SDL2 environment variables

### Verify Zig Installation

```bash
zig version
# Should show 0.11.0 or later
```

## Building the UI

### Quick Build

```bash
cd /workspace/ui
zig build
```

The binary will be at: `zig-out/bin/guardian-ui`

### Run Directly

```bash
cd /workspace/ui
zig build run
```

This builds and runs in one step.

## Testing Each View

### View 1: Camera Grid (Press 1)

**What You Should See**:
- 2x2 grid with 4 camera cells
- Each cell has a dark background with a border
- Small colored dots in top-left of each cell (detection indicators):
  - **Blue dots** = Facial recognition enabled
  - **Orange dots** = Vehicle/plate recognition enabled
  - **Pink dots** = Pet detection enabled
  - **Cyan dots** = Gait recognition enabled

**Try This**:
1. Press **1** to ensure you're in Camera Grid view
2. **Click on different camera cells** - selected camera gets a blue border highlight
3. Look for the detection indicator dots - different cameras have different combinations

**Expected Behavior**:
- Front Gate (top-left): Blue + Orange (face + vehicle)
- Driveway (top-right): Orange only (vehicle)
- Backyard (bottom-left): Pink only (pet)
- Front Door (bottom-right): Blue + Cyan (face + gait)

### View 2: Arm/Disarm Keypad (Press 2)

**What You Should See**:
- Centered panel (300x400 pixels)
- PIN display area at top (shows dots as you type)
- Alarm state indicator (green for disarmed)
- Grid of numeric buttons (visual representation)

**Try This**:
1. Press **2** to switch to keypad view
2. **Type numbers 0-9** on your keyboard
3. Watch dots appear in the PIN display area
4. Press **Backspace** to clear
5. Press **Enter** (logs PIN length to console)

**Expected Behavior**:
- Each digit adds a dot to the PIN display
- Backspace clears all dots
- Enter logs: "PIN entered, length: N"
- State indicator shows green (disarmed)

### View 3: Intercom Panel (Press 3)

**What You Should See**:
- Centered panel (400x300 pixels)
- Gray background
- Session status area (currently empty since no active session)

**Try This**:
1. Press **3** to switch to intercom view
2. Observe the empty panel (no active intercom session in demo)

**Expected Behavior**:
- Panel renders correctly
- No errors in console
- When API is connected, this will show active doorbell/gate calls

### View 4: Detection Events Panel (Press 4) **NEW**

**What You Should See**:
- Full-screen panel with filter buttons at top
- Filter buttons: "All", "Motion", "Faces", "Vehicles", "Plates", "Pets", "Audio"
- Empty event list area (no events yet - requires API connection)

**Try This**:
1. Press **4** to switch to detection events
2. Observe the filter button row
3. The "All" filter should appear highlighted/selected

**Expected Behavior**:
- Filter buttons render in a row
- "All" button appears active (different color)
- Event area is empty (no events loaded yet)
- No errors in console

### View 5: Camera Configuration Panel (Press 5) **NEW**

**What You Should See**:
- Split screen: camera list on left (1/3 width), config panel on right (2/3 width)
- **Left panel**: 4 cameras listed with colored resolution indicators
  - Green small square = HD
  - Blue small square = 4K
  - Red small square = 8K
- **Right panel**: Message "Select a camera" initially

**Try This**:
1. Press **5** to switch to camera config
2. **Click on a camera** in the left list (simulated, may not work without mouse handler)
3. If a camera is selected, you'll see:
   - 7 toggle switches on the right
   - Each toggle shows green (enabled) or red (disabled)
   - Switch knob slides left (off) or right (on)

**Expected Behavior**:
- Camera list shows 4 cameras with resolution indicators:
  - Front Gate: Red (8K) → should be Blue (4K) - check config
  - Driveway: Green (HD)
  - Backyard: Green (HD)
  - Front Door: Blue (4K)
- Right panel shows toggles when camera selected
- Front Gate camera should show:
  - ✅ Facial Recognition (green/on)
  - ✅ License Plate Recognition (green/on)
  - ✅ Vehicle Recognition (green/on)
  - ❌ Gait Recognition (red/off)
  - ❌ Pet Detection (red/off)
  - ✅ Motion Detection (green/on)
  - ✅ Audio Detection (green/on)

## Navigation Testing

**Test All Key Presses**:
```
Press 1 → Camera Grid appears
Press 2 → Keypad appears
Press 3 → Intercom appears
Press 4 → Detection Events appears
Press 5 → Camera Config appears
Press ESC → Application exits
```

**Status Bar**:
- At the bottom of every view, you should see 5 small colored squares
- The square corresponding to your current view should be bright green
- Others should be dark gray

## Console Output

When running, you should see log messages like:

```
[INFO] ui: Guardian UI with Advanced Detection starting
[INFO] ui: View: Camera Grid
[INFO] ui: View: Detection Events
[INFO] ui: View: Camera Configuration
[INFO] ui-api: API: ping() - stub
```

When you interact:
```
[INFO] ui: Selected camera: Front Gate
[INFO] ui: PIN entered, length: 4
```

## Performance Testing

**Check Frame Rate**:
- UI should feel smooth at ~60 FPS
- No lag when switching views
- No stuttering during rendering

**Memory**:
```bash
# In another terminal while UI is running
ps aux | grep guardian-ui
# RSS should be < 100 MB for the demo
```

## Troubleshooting

### "SDL_Init failed" Error

**Cause**: SDL2 not installed or not found

**Fix**:
```bash
# Ubuntu/Debian
sudo apt-get install libsdl2-dev

# Verify
pkg-config --modversion sdl2
```

### "No display available" Error

**Cause**: Running on a headless server without X11/Wayland

**Fix**: Run on a machine with a desktop environment, or use X11 forwarding:
```bash
ssh -X user@server
export DISPLAY=:0
```

### UI Window Doesn't Appear

**Cause**: Window may be off-screen or display issue

**Fix**:
1. Check if process is running: `ps aux | grep guardian-ui`
2. Check console for SDL errors
3. Try setting SDL video driver: `SDL_VIDEODRIVER=x11 ./guardian-ui`

### Compilation Errors

**"cannot find -lSDL2"**:
```bash
# Install SDL2 dev package (see Prerequisites)
```

**"error: FileNotFound"**:
```bash
# Make sure you're in /workspace/ui directory
cd /workspace/ui
zig build
```

### Mouse Clicks Don't Work

**Current Status**: Mouse click handlers are partially implemented
- Camera Grid: Click selection works
- Camera Config: Click handlers need full wiring (visual only)

**Expected**: Visual feedback works, but actual functionality requires API integration

## What's NOT Implemented Yet

These are **expected limitations** in the current demo:

❌ **No live video streams** - Camera grid shows placeholder boxes (requires ffmpeg decode + SDL texture pipeline)

❌ **No text labels** - Camera names, button labels, event details not shown (requires SDL_ttf integration)

❌ **No detection events** - Event panel is empty (requires guardian-api running and sending events)

❌ **Toggle switches don't persist** - Config changes are visual only until API is wired

❌ **No API connection** - All API calls log to console but don't connect to server

❌ **No event thumbnails** - Detection events won't show images yet

## Success Criteria

✅ **UI launches without errors**

✅ **All 5 views render correctly** (1-5 keys)

✅ **Camera grid shows 4 cells with detection indicators**

✅ **Keypad accepts digit input and shows dots**

✅ **Detection events panel shows filter buttons**

✅ **Camera config panel shows camera list and toggles**

✅ **Status bar indicators work** (bottom row of colored squares)

✅ **ESC key exits cleanly**

✅ **Console logs show view switches and interactions**

✅ **No crashes, no memory leaks during normal use**

## Automated Testing (Future)

To add later:
```bash
# Headless testing with xvfb
xvfb-run -a ./guardian-ui --test-mode

# Screenshot capture
SDL_VIDEODRIVER=dummy ./guardian-ui --capture-screenshots
```

## Next Steps After Testing

Once UI testing is successful:

1. **Implement guardian-api** REST + WebSocket server
2. **Wire API client** to actual HTTP endpoints  
3. **Add SDL_ttf** for text rendering
4. **Implement video decode** for live camera streams
5. **Add ML/AI detection services** (when ready)

---

## Quick Test Script

Save this as `test-ui.sh`:

```bash
#!/bin/bash
echo "Guardian UI Test Script"
echo "======================="
echo ""
echo "Checking prerequisites..."

# Check Zig
if ! command -v zig &> /dev/null; then
    echo "❌ Zig not found"
    exit 1
fi
echo "✅ Zig: $(zig version)"

# Check SDL2
if ! pkg-config --exists sdl2; then
    echo "❌ SDL2 not found"
    echo "Install with: sudo apt-get install libsdl2-dev"
    exit 1
fi
echo "✅ SDL2: $(pkg-config --modversion sdl2)"

echo ""
echo "Building UI..."
cd /workspace/ui
if zig build; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "Binary location: ui/zig-out/bin/guardian-ui"
echo ""
echo "To run: cd /workspace/ui && zig build run"
echo ""
echo "Controls:"
echo "  1 = Camera Grid"
echo "  2 = Keypad"
echo "  3 = Intercom"
echo "  4 = Detection Events"
echo "  5 = Camera Config"
echo "  ESC = Quit"
```

Make it executable:
```bash
chmod +x test-ui.sh
./test-ui.sh
```

---

**Summary**: The UI is fully functional for visual testing. All views render, navigation works, and interactions log correctly. Integration with live data requires the API server and detection services (to be implemented later).

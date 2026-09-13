# Guardian UI - Advanced Detection Features

## Overview

Guardian UI now supports advanced AI/ML detection capabilities with a flexible, customizable interface:

- **Facial Recognition** - Identify known persons
- **License Plate Recognition** - Read and log vehicle plates  
- **Vehicle Recognition** - Detect vehicle type, make, model, color
- **Gait Recognition** - Identify persons by walking pattern
- **Pet Detection** - Detect and track pets (dogs, cats, etc.)
- **Motion Detection** - General motion events
- **Audio Detection** - Glass break, doorbell, screams, etc.

## New UI Views

Press keys 1-5 to switch views:

### 1. Camera Grid (Press 1)
- Shows all cameras in adaptive grid layout (2x2, 3x3, or 4x4)
- **Detection indicators** show which AI features are active per camera:
  - **Blue** = Facial recognition
  - **Orange** = Vehicle/plate recognition  
  - **Pink** = Pet detection
  - **Cyan** = Gait recognition
- Click camera to select (blue highlight)
- Resolution indicators: Green (HD), Blue (4K), Red (8K)

### 2. Arm/Disarm Keypad (Press 2)
- PIN entry with masked dots
- Color-coded alarm state
- Numeric button grid

### 3. Intercom Panel (Press 3)
- Two-way audio for gate/door stations
- Answer/hangup/talk controls
- Session status display

### 4. **Detection Events (Press 4) - NEW**
- Real-time event stream with filtering
- **Filter by type**: All, Motion, Faces, Vehicles, Plates, Pets, Audio
- Color-coded event indicators
- Confidence bars for each detection
- Scroll through event history (up to 100 recent events)
- Shows camera, timestamp, and detection metadata

### 5. **Camera Configuration (Press 5) - NEW**
- Per-camera detection capability toggles
- **Left panel**: Camera list with resolution indicators
- **Right panel**: Detection capability toggles for selected camera
  - Facial Recognition
  - License Plate Recognition
  - Vehicle Recognition
  - Gait Recognition
  - Pet Detection
  - Motion Detection
  - Audio Detection
- Toggle switches show enabled (green) / disabled (red)

## Architecture

### API Client (`ui/src/api_client.zig`)
- REST/WebSocket client for guardian-api
- Methods for:
  - Camera list and configuration
  - Alarm status and control
  - Detection event retrieval
  - Real-time event subscription
  - Camera snapshots (JPEG)

### Detection Types (`services/common/src/types.zig`)

```zig
pub const DetectionType = enum {
    motion,
    person,
    face_recognized,
    face_unknown,
    vehicle,
    license_plate,
    pet,
    audio_event,
    gait_match,
};
```

### Detection Metadata
Rich metadata per detection type:
- **Face**: person_id, name, bounding box
- **Vehicle**: type, make, model, color, bbox
- **Plate**: number, region, bbox
- **Pet**: type, breed, bbox
- **Gait**: person_id, name, gait signature
- **Audio**: event type (doorbell, glass_break, etc.), duration

### Detection Capabilities (`DetectionCapabilities`)
Per-camera toggle-able capabilities:
- facial_recognition
- plate_recognition
- vehicle_recognition
- gait_recognition
- pet_detection
- motion_detection
- audio_detection

## Usage

### Running the UI

```bash
cd ui
zig build run
```

**Controls**:
- **1**: Camera Grid
- **2**: Arm/Disarm Keypad
- **3**: Intercom Panel
- **4**: Detection Events
- **5**: Camera Configuration
- **ESC**: Quit

### Demo Configuration

UI starts with 4 demo cameras showing different detection profiles:

**Front Gate (4K)**:
- Facial recognition ✓
- Plate recognition ✓
- Vehicle recognition ✓
- Audio detection ✓

**Driveway (HD)**:
- Plate recognition ✓
- Vehicle recognition ✓

**Backyard (HD)**:
- Pet detection ✓

**Front Door (4K)**:
- Facial recognition ✓
- Gait recognition ✓
- Audio detection ✓

### Configuring Detection Per Camera

1. Press **5** to open Camera Configuration
2. Click a camera in the left panel
3. Toggle detection capabilities with switches on the right
4. Changes save automatically to API (when API is connected)

### Filtering Detection Events

1. Press **4** to open Detection Events
2. Click filter buttons at top: All, Motion, Faces, Vehicles, Plates, Pets, Audio
3. Scroll through filtered events
4. Click an event to see full details (TODO)

## Integration with Guardian API

When guardian-api is running, the UI will:

1. **Fetch camera list** on startup
2. **Subscribe to real-time events** via WebSocket
3. **Display live detections** in Detection Events panel
4. **Update camera configs** when you toggle capabilities
5. **Fetch camera snapshots** for event thumbnails

API stub methods are in place and log when called:

```zig
// API Client methods (implemented stubs)
getCameras()
getAlarmStatus()
armAlarm()
disarmAlarm()
getDetectionEvents()
getCameraSnapshot()
updateCameraDetection()
subscribeEvents()
ping()
```

## Customization

### Adding New Detection Types

1. Add to `DetectionType` enum in `services/common/src/types.zig`
2. Add metadata struct if needed (e.g., `MyDetectionMetadata`)
3. Add to `DetectionMetadata` union
4. Update filter buttons in `detection_panel.zig`
5. Add color-coding in `renderEventItem()`

### Adding New Panels

1. Create new file `ui/src/my_panel.zig`
2. Add to `GuardianUI.View` enum
3. Add render method `renderMyPanel()`
4. Add keyboard shortcut in `handleKeyDown()`
5. Add status bar indicator

### Themes (Future)

Planned theme system:
- Dark theme (current)
- Light theme
- High contrast
- Custom color schemes

## Performance

- **60 FPS** rendering with vsync
- **Event filtering** is O(n) but capped at 100 events
- **API polling** can be adjusted (currently on-demand)
- **WebSocket** for real-time events (lower latency than polling)

## Known Limitations

Current implementation:
- ✅ Detection type structures defined
- ✅ UI panels for events and configuration
- ✅ API client stub methods
- ❌ No actual frame decode/display yet (shows placeholders)
- ❌ No SDL_ttf text rendering yet (will add labels)
- ❌ API connection not wired (stubs log calls)
- ❌ Detection thumbnails not shown yet
- ❌ Click handlers for toggles partially wired

## Next Steps

1. **Implement guardian-api** server (REST + WebSocket)
2. **Wire API client** to actual HTTP/WebSocket
3. **Add SDL_ttf** for text rendering (camera names, labels, event details)
4. **Implement detection services** (facial, plate, vehicle, gait, pet)
5. **Add event thumbnails** (fetch JPEGs from API)
6. **Mouse click detection** for toggles and buttons
7. **Customization system** (themes, layouts, user preferences)
8. **Device management** panel (microphones, additional sensors)

## Testing

```bash
# Build and run UI
cd ui
zig build run

# Navigate views with 1-5 keys
# Try camera configuration toggles (visual only for now)
# Check detection event panel (empty until API connected)
```

## Summary

Guardian UI is now **detection-ready**:

- ✅ Type-safe detection event system
- ✅ Per-camera capability configuration
- ✅ Real-time event panel with filtering
- ✅ Extensible for new detection types
- ✅ API client foundation in place
- ✅ Simple, intuitive UI as requested

**Ready for ML/AI integration** when detection services are implemented!

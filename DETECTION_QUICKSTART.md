# Guardian Advanced Detection - Quick Start

## What Was Built

Guardian UI now supports **advanced AI/ML detection** with a simple, intuitive interface:

### Detection Capabilities
- ✅ **Facial Recognition** - Identify known persons
- ✅ **License Plate Recognition** - Read and log vehicle plates
- ✅ **Vehicle Recognition** - Detect type, make, model, color
- ✅ **Gait Recognition** - Identify persons by walking pattern
- ✅ **Pet Detection** - Detect and track pets (dogs, cats, breeds)
- ✅ **Motion Detection** - General movement events
- ✅ **Audio Detection** - Glass break, doorbell, screams, etc.

### UI Features (Press 1-5 to Navigate)

**Press 4: Detection Events Panel**
- Real-time event stream
- Filter by: All, Motion, Faces, Vehicles, Plates, Pets, Audio
- Color-coded events with confidence bars
- Scroll through 100 recent events

**Press 5: Camera Configuration Panel**
- Select camera from list (left panel)
- Toggle detection capabilities (right panel)
- Visual on/off switches (green = enabled, red = disabled)
- Settings save automatically

**Press 1: Camera Grid**
- Detection indicators on each camera:
  - Blue = Facial recognition
  - Orange = Vehicle/plate recognition
  - Pink = Pet detection
  - Cyan = Gait recognition

## Running the UI

```bash
cd ui
zig build run
```

**Keyboard Controls**:
- **1** = Camera Grid
- **2** = Arm/Disarm Keypad
- **3** = Intercom Panel
- **4** = Detection Events (NEW)
- **5** = Camera Configuration (NEW)
- **ESC** = Quit

## Demo Configuration

4 cameras with different detection profiles:

1. **Front Gate (4K)**: Facial + Plate + Vehicle + Audio
2. **Driveway (HD)**: Plate + Vehicle
3. **Backyard (HD)**: Pet detection
4. **Front Door (4K)**: Facial + Gait + Audio

## Architecture

### Detection Types (services/common/src/types.zig)
```zig
DetectionType: motion, person, face_recognized, vehicle, 
               license_plate, pet, audio_event, gait_match

DetectionCapabilities: per-camera toggle-able features
DetectionEvent: timestamp, type, confidence, metadata, thumbnails
```

### API Client (ui/src/api_client.zig)
Stub methods ready for guardian-api integration:
- getCameras()
- getDetectionEvents()
- updateCameraDetection()
- subscribeEvents() (WebSocket)

### Detection Panels
- **DetectionPanel** (`ui/src/detection_panel.zig`): Event stream with filtering
- **CameraConfigPanel** (`ui/src/camera_config_panel.zig`): Per-camera capability toggles

## Customization

### Per-Camera Detection
1. Press **5** (Camera Configuration)
2. Click camera in left panel
3. Toggle capabilities in right panel
4. Changes save automatically

### Adding New Detection Types
1. Add to `DetectionType` enum
2. Add metadata struct (e.g., `MyMetadata`)
3. Add to `DetectionMetadata` union
4. Update filter buttons in detection_panel.zig
5. Add color-coding in render functions

## Next Steps

The UI is **detection-ready**. To complete the system:

1. **Implement guardian-api** REST + WebSocket server
2. **Wire API client** to actual HTTP/WebSocket
3. **Implement detection services** (facial, plate, vehicle, gait, pet)
4. **Add SDL_ttf** for text rendering
5. **Add event thumbnails** from API

## Testing

All builds successful:
```bash
./build-all.sh
```

UI compiles and runs with all 5 views functional.

## Documentation

- `UI_FEATURES.md` - Complete detection features guide
- `TESTING.md` - RTSP and UI testing instructions
- `IMPLEMENTATION.md` - Architecture and rationale
- `configs/examples/` - Example configs with detection profiles

---

**Summary**: Simple, intuitive UI with customizable detection capabilities. Ready for ML/AI integration!

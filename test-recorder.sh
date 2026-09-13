#!/bin/bash
# Smoke test for guardian-recorder RTSP ingest
#
# Uses a public RTSP test stream (Big Buck Bunny)
# Verifies that recorder can connect and write segments

set -e

echo "=== Guardian Recorder Smoke Test ==="
echo ""

# Check for ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "ERROR: ffmpeg not found. Install with:"
    echo "  sudo apt-get install ffmpeg"
    exit 1
fi

echo "✓ ffmpeg found: $(ffmpeg -version | head -1)"
echo ""

# Create test output directory
TEST_DIR="/tmp/guardian-recorder-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

echo "Test output directory: $TEST_DIR"
echo ""

# Build recorder
echo "Building guardian-recorder..."
cd "$(dirname "$0")/services/recorder"
zig build

echo "✓ Build successful"
echo ""

# Create test config
cat > "$TEST_DIR/test-config.json" <<'EOF'
{
  "site_name": "Test Site",
  "cameras": [
    {
      "id": "test_big_buck_bunny",
      "name": "Test Camera (Big Buck Bunny)",
      "rtsp_url": "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4",
      "max_resolution": "full_hd",
      "audio_enabled": true,
      "detect_enabled": false,
      "intercom_enabled": false
    }
  ],
  "zones": [],
  "backup_scope": "events_only",
  "backup_retention_days": 30,
  "backup_bandwidth_cap_mbps": 10,
  "relay_url": "wss://relay.guardian.example.com"
}
EOF

echo "Test config:"
cat "$TEST_DIR/test-config.json"
echo ""

echo "Starting recorder (will run for 90 seconds to capture at least 1 segment)..."
echo "Output: $TEST_DIR/recordings/test_big_buck_bunny/"
echo ""

# Run recorder in background
timeout 90s ./zig-out/bin/guardian-recorder &
RECORDER_PID=$!

echo "Recorder PID: $RECORDER_PID"
echo "Waiting 90 seconds for segment capture..."

# Wait for process
wait $RECORDER_PID || true

echo ""
echo "=== Test Results ==="

# Check for output files
RECORDING_DIR="/srv/guardian/recordings/test_big_buck_bunny"
if [ -d "$RECORDING_DIR" ]; then
    FILE_COUNT=$(find "$RECORDING_DIR" -name "*.mp4" -type f 2>/dev/null | wc -l)
    
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "✓ SUCCESS: Found $FILE_COUNT segment(s) in $RECORDING_DIR"
        echo ""
        echo "Segments:"
        ls -lh "$RECORDING_DIR"/*.mp4 2>/dev/null || true
    else
        echo "✗ FAIL: No segments found in $RECORDING_DIR"
        exit 1
    fi
else
    echo "✗ FAIL: Recording directory not created: $RECORDING_DIR"
    exit 1
fi

echo ""
echo "=== Smoke test PASSED ==="
echo ""
echo "Note: Recorder requires /srv/guardian/recordings/ to exist with proper permissions."
echo "For development, create it with: sudo mkdir -p /srv/guardian/recordings && sudo chown $USER /srv/guardian/recordings"

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
if pkg-config --exists sdl2 2>/dev/null; then
    echo "✅ SDL2: $(pkg-config --modversion sdl2)"
else
    echo "⚠️  SDL2 pkg-config not found (may still work if SDL2 is installed)"
fi

echo ""
echo "Building UI..."
cd /workspace/ui
if zig build 2>&1 | tail -5; then
    echo ""
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
echo ""
echo "Testing complete! 🚀"

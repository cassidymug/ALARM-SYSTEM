#!/bin/bash
# Build all Guardian services and UI

set -e

echo "Building Guardian services and UI..."
echo ""

# Services to build
SERVICES=(
    "common"
    "recorder"
    "detect"
    "alarm"
    "sensors"
    "api"
    "intercom"
    "gateway"
    "backup"
    "setup"
)

# Build each service
for service in "${SERVICES[@]}"; do
    echo "Building guardian-$service..."
    (cd services/$service && zig build)
done

# Build UI
echo "Building guardian-ui..."
(cd ui && zig build)

echo ""
echo "Build complete! Binaries in:"
echo "  - services/*/zig-out/bin/"
echo "  - ui/zig-out/bin/"
echo ""
echo "To install all binaries to a common location:"
echo "  mkdir -p bin"
echo "  cp services/*/zig-out/bin/guardian-* bin/"
echo "  cp ui/zig-out/bin/guardian-ui bin/"

# Guardian software / OS

This folder is the **software and appliance OS** side of ALARM-SYSTEM.

## Layout

| Path | Purpose |
|------|---------|
| `os/` | Debian-minimal appliance image (mkosi build system) — see `os/README.md` |
| `services/` | Zig daemons (recorder, alarm, sensors, gateway, backup, …) |
| `ui/` | Zig UI (SDL2) for local touchscreen/display |
| `debian/` | systemd units and packaging |
| `deploy/` | Hetzner relay deployment |
| `configs/` | Example `/etc/guardian` configs |
| `build-all.sh` | Convenience build script for all services + UI |

Hardware (KiCad zone expander, power distribution) lives in `../hardware/`.  
Design docs live in `../docs/`.

## Build (Linux / WSL recommended)

### Quick start

```bash
cd software
./build-all.sh
```

**Dependencies:**
- Zig 0.13.0+ (for services and UI)
- `libsdl2-dev` (for UI)
- `ffmpeg` (for recorder service)

### Individual components

```bash
# Build all services
cd services/api && zig build
cd services/recorder && zig build
# ... etc

# Build UI
cd ui && zig build

# Build OS image (requires mkosi on Linux)
cd os/debian && sudo mkosi build
```

See `os/README.md` for appliance image build instructions.

## Architecture

Guardian is a **wired-only, hub-edge architecture**:

- **Hub**: This appliance (Debian, Zig services, 16GB RAM standard)
- **Edge devices**: PoE IP cameras, custom 32-zone wired alarm expander (GXP protocol)
- **No wireless**: No Zigbee, Wi-Fi sensors, or wireless cameras at the hub

**Hardware target**: 16GB RAM, quad-core x86-64/ARM64, 256GB+ SSD + large HDD for recordings

Services communicate over local IPC (UNIX sockets + shared event bus). The `gateway` service handles remote relay (Hetzner) for mobile access.

## Working from Windows (WSL)

If you're on Windows (e.g., `C:\dev\alarm system\`):

1. **Install WSL2** with Ubuntu or Debian
2. Clone the repo inside WSL:
   ```bash
   cd ~
   git clone https://github.com/cassidymug/ALARM-SYSTEM.git
   cd ALARM-SYSTEM/software
   ```
3. Install dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install wget xz-utils libsdl2-dev ffmpeg
   
   # Install Zig
   wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz
   tar xf zig-linux-x86_64-0.13.0.tar.xz
   sudo mv zig-linux-x86_64-0.13.0 /usr/local/zig
   export PATH="/usr/local/zig:$PATH"
   echo 'export PATH="/usr/local/zig:$PATH"' >> ~/.bashrc
   ```
4. Build:
   ```bash
   ./build-all.sh
   ```

For OS image builds (`mkosi`), use a Linux machine or VM (not WSL1).

## Running services

See systemd unit files in `debian/systemd/`. Services are designed to run under the `guardian.target`.

For development/testing:
```bash
# Test individual services
./services/api/zig-out/bin/guardian-api
./services/recorder/zig-out/bin/guardian-recorder

# UI (requires X11 or Wayland)
./ui/zig-out/bin/guardian-ui
```

## Next steps

- `os/` — bootable appliance image builds
- `services/` — service implementation (sensors GXP protocol, recorder ONVIF, etc.)
- `ui/` — touch-optimized arming keypad + camera grid
- `debian/` — `.deb` packaging for services
- `deploy/` — Hetzner relay provisioning

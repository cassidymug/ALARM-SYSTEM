# Guardian — DIY DVR + Alarm Appliance

**Status:** MVP scaffolding in progress  
**Platform:** Debian-minimal appliance on Mini PC / NUC  
**Scale:** 8–16 cameras (Full HD, 4K, 8K), many sensor zones  

---

## Overview

Guardian is a unified on-site appliance that:

- **Records** Full HD, 4K, and 8K video+audio from IP cameras
- **Runs** a full-time alarm system (arm/disarm, zones, sensors, siren/notify)
- **Provides** remote access via authenticated cloud/relay gateway (not WireGuard-only)
- **Backs up** encrypted recordings offsite to Hetzner Object Storage
- **Supports** two-way intercom for gate/door stations

**Key principles:**

- Own the stack (Debian + our `.deb` packages + systemd)
- Outbound-only hub (no inbound ports required)
- Client-side encryption for offsite backups
- Zig for UI and most services (minimal dependencies)
- Hardware video encoding recommended for 4K/8K

---

## Architecture

```
On-site:
  ┌─────────────────┐
  │  IP Cameras     │ (Full HD / 4K / 8K + audio)
  │  8-16 cams      │
  └────────┬────────┘
           │ PoE
  ┌────────▼────────┐
  │  Guardian Hub   │ (Mini PC / NUC, Debian)
  │  - recorder     │
  │  - detect       │
  │  - alarm        │
  │  - sensors      │
  │  - api          │
  │  - ui (Zig)     │
  │  - intercom     │
  │  - gateway      │
  │  - backup       │
  └────────┬────────┘
           │ Outbound mTLS/WebSocket
           │
Hetzner:   │
  ┌────────▼────────┐
  │ guardian-relay  │ (Go, auth + signaling)
  └─────────────────┘
           │
  ┌────────▼────────┐
  │ Object Storage  │ (Ciphertext backups)
  └─────────────────┘
```

---

## Repository Structure

```
guardian/
├── services/           # Zig daemons
│   ├── common/         # Shared types, event bus, logging
│   ├── recorder/       # Video+audio ingest (4K/8K support)
│   ├── detect/         # Motion/object detection
│   ├── alarm/          # State machine, zones
│   ├── sensors/        # Zone I/O (GPIO/USB/IP)
│   ├── api/            # Local REST/gRPC
│   ├── intercom/       # Two-way audio (WebRTC)
│   ├── gateway/        # Outbound relay client (mTLS)
│   ├── backup/         # Encrypt + upload offsite
│   └── setup/          # First-boot wizard
│
├── ui/                 # Zig UI (no Electron/React/Flutter)
│   ├── src/
│   │   ├── main.zig
│   │   ├── camera_grid.zig
│   │   ├── arm_keypad.zig
│   │   └── intercom_panel.zig
│   └── build.zig
│
├── os/                 # Debian appliance image
│   └── debian/
│       ├── mkosi.conf
│       └── mkosi.postinst
│
├── debian/             # systemd units + packaging
│   └── systemd/
│       ├── guardian.target
│       ├── guardian-recorder.service
│       ├── guardian-alarm.service
│       └── ... (all services)
│
├── deploy/
│   └── hetzner/        # Relay deployment
│       ├── relay/      # Go relay server
│       └── README.md
│
├── configs/
│   └── examples/
│       ├── site.json
│       ├── backup.yaml
│       ├── RESOLUTION_GUIDE.md
│       └── network.md
│
├── docs/
│   ├── DESIGN.md       # Full engineering design
│   └── BOM.md          # Hardware bill of materials
│
├── build.zig           # Workspace build
├── build.zig.zon       # Workspace dependencies
└── README.md           # This file
```

---

## Building

### Prerequisites

- **Zig 0.13+** ([ziglang.org](https://ziglang.org/))
- **Go 1.22+** (for Hetzner relay only)
- **mkosi** (for appliance image)
- **systemd** (target platform)

### Build All Services and UI

```bash
# From workspace root
zig build

# Binaries installed to zig-out/bin/:
# - guardian-recorder
# - guardian-detect
# - guardian-alarm
# - guardian-sensors
# - guardian-api
# - guardian-intercom
# - guardian-gateway
# - guardian-backup
# - guardian-setup
# - guardian-ui
```

### Build Individual Services

```bash
# Build just the recorder
cd services/recorder
zig build

# Run tests
zig build test

# Build with optimizations
zig build -Doptimize=ReleaseFast
```

### Build Relay (Go)

```bash
cd deploy/hetzner/relay
go build -o guardian-relay
```

### Build Appliance Image (mkosi)

```bash
cd os/debian
mkosi

# Output: guardian-appliance.img
# Flash to USB or NVMe for installation
```

---

## Running (Development)

### Run Individual Services

```bash
# Recorder
cd services/recorder
zig build run

# Alarm
cd services/alarm
zig build run

# UI
cd ui
zig build run
```

**Note:** Services expect configuration at `/etc/guardian/site.json` (or will use dummy config in dev mode).

### Run Relay (Development)

```bash
cd deploy/hetzner/relay
go run main.go
# Listens on :8443
```

---

## Configuration

### Site Configuration

Copy `configs/examples/site.json` to `/etc/guardian/site.json` and edit:

- **cameras**: RTSP URLs, resolution profiles (full_hd, uhd_4k, uhd_8k)
- **zones**: Sensor bindings, zone types, delays
- **relay_url**: Your guardian-relay endpoint
- **backup_scope**: events_only, events_plus_rolling, full_continuous

### Resolution Profiles

See `configs/examples/RESOLUTION_GUIDE.md` for:

- Storage planning (Full HD: ~42 GB/day, 4K: ~270 GB/day, 8K: ~1 TB/day)
- Hardware encoding requirements
- Backup bandwidth considerations

### Network Setup

See `configs/examples/network.md` for:

- VLAN isolation (cameras on dedicated VLAN)
- Firewall rules
- Camera hardening (disable cloud, UPnP)

---

## Deployment

### 1. Prepare Hub Hardware

- Mini PC / NUC (6+ cores, 32GB RAM recommended for 12 cams)
- NVMe: 1TB OS + state
- Media storage: 4-8TB NVMe/SSD for recordings
- UPS for hub + PoE switch

### 2. Install Appliance Image

```bash
# Flash image to USB
dd if=guardian-appliance.img of=/dev/sdX bs=4M status=progress

# Boot from USB, install to internal NVMe
# Follow on-screen prompts
```

### 3. Run Setup Wizard

```bash
# First boot
sudo guardian-setup

# Configure:
# - Network
# - Cameras (discovery + RTSP URLs)
# - Zones and sensors
# - Arming defaults
# - Relay enrollment (mTLS certs)
# - Backup scope (1: events, 2: events+rolling, 3: full)
# - Retention and bandwidth cap
# - Recovery key (print and store offline!)
```

### 4. Deploy Hetzner Relay

See `deploy/hetzner/README.md` for:

- VM creation (CX31 or larger)
- Firewall setup (443 only)
- TLS certificates (Let's Encrypt)
- Hub mTLS CA generation
- Object Storage bucket creation

---

## Security Controls

From `docs/DESIGN.md` Security Controls section:

### Mandatory Practices

- **Outbound-only hub** (no inbound ports from internet)
- **mTLS** between hub and relay
- **Client-side encryption** for backups (recovery key never stored in cloud)
- **Camera VLAN isolation** (cameras on dedicated subnet)
- **Systemd sandboxing**: All units include `ProtectSystem=strict`, `NoNewPrivileges`, capability restrictions
- **Disable vendor cloud/UPnP** on cameras
- **Disk encryption** for media volume (NUC theft scenario)
- **Signed package updates** (no `curl | bash`)

### Process Isolation

Every service runs as dedicated user with tight systemd restrictions:

- `ProtectSystem=strict`
- `PrivateTmp=yes`
- `NoNewPrivileges=yes`
- Narrow `CapabilityBoundingSet`
- `SystemCallFilter=@system-service`

See `debian/systemd/*.service` for complete unit configurations.

---

## Resolution Support: Full HD, 4K, 8K

Per-camera max resolution configured in `site.json`:

```json
{
  "id": "cam_front_gate",
  "max_resolution": "uhd_4k",
  "rtsp_url": "rtsp://192.168.1.100:554/stream1",
  "rtsp_substream_url": "rtsp://192.168.1.100:554/stream2"
}
```

**Options:** `full_hd` (1080p), `uhd_4k` (2160p), `uhd_8k` (4320p)

**Storage planning:**

- Full HD: ~4 Mbps → 42 GB/day
- 4K: ~25 Mbps → 270 GB/day
- 8K: ~100 Mbps → 1 TB/day

**Hardware encoding strongly recommended** for multi-4K or any 8K:

- Intel Quick Sync (11th gen+ for 4K, 12th gen+ for 8K)
- NVIDIA NVENC (GTX 1650+ for 4K, RTX 4000+ for 8K)
- AMD VCN (Ryzen 5000+)

See `configs/examples/RESOLUTION_GUIDE.md` for detailed planning.

---

## Testing

### Run All Tests

```bash
zig build test
```

### Test Individual Components

```bash
cd services/common
zig build test

cd services/recorder
zig build test
```

### Integration Testing

(TODO: Add integration test suite after MVP)

---

## Development Status

**Current (MVP Scaffolding):**

- ✅ Monorepo structure
- ✅ Zig services: common, recorder, detect, alarm, sensors, api, intercom, gateway, backup, setup
- ✅ Zig UI: camera grid, arm keypad, intercom panel
- ✅ Systemd units with security hardening
- ✅ mkosi Debian appliance config
- ✅ Go relay stub
- ✅ Example configs (site.json, backup.yaml, resolution guide, network guide)
- ✅ Builds compile (services and UI)

**Next Steps:**

- Implement actual RTSP ingest (ffmpeg integration)
- DRM/KMS or Wayland rendering for UI
- HTTP server for API (std.http)
- WebSocket/mTLS for gateway
- GPIO/USB/IP sensor interfaces
- Client-side encryption (age/libsodium)
- Setup wizard TUI
- Relay: WebSocket hub sessions, client auth, signaling
- .deb package generation
- Automated tests

**Phase Milestones** (from `docs/DESIGN.md`):

1. ✅ Phase 0: Foundations
2. Phase 1: Record & live (LAN)
3. Phase 2: Alarm
4. Phase 3: Relay remote
5. Phase 4: Intercom
6. Phase 5: Offsite backup
7. Phase 6: Hardening & scale

---

## Language Choices

### Zig (Primary)

Used for all application services and UI:

- **Rationale:** Minimal dependencies, no hidden control flow, excellent performance, small binaries
- **Services:** recorder, detect, alarm, sensors, api, intercom, gateway, backup, setup
- **UI:** Direct DRM/KMS or Wayland (no Electron/React/Flutter)

### Go (Exception: Relay Only)

Used for Hetzner relay server:

- **Rationale:** Network-heavy relay service benefits from Go's excellent stdlib support for WebSocket, mTLS, HTTP, and concurrency
- **Not used** for other services to avoid dependency sprawl on the appliance

---

## Hardware Recommendations

From `docs/BOM.md`:

- **Hub:** Mini PC/NUC (x86_64, 6+ cores, 32GB RAM, 2.5GbE preferred)
- **Storage:** 1TB NVMe (OS) + 4-8TB NVMe/SSD (media)
- **Network:** 16-port PoE+ switch for cameras
- **UPS:** 1000-1500 VA covering hub + switch
- **Cameras:** 8-16 IP cameras with RTSP + audio
- **Gate/door stations:** 2x with two-way audio for intercom
- **Sensors:** 8-16 door/window contacts, 4-8 PIRs, zone expander
- **Hetzner:** CX31+ VM for relay, Object Storage for backups

**Estimated cost:** ~$1,900–4,900 (hardware) + $15–75/month (Hetzner)

---

## Documentation

- **[DESIGN.md](docs/DESIGN.md):** Complete engineering design (authoritative)
- **[BOM.md](docs/BOM.md):** Hardware bill of materials
- **[Resolution Guide](configs/examples/RESOLUTION_GUIDE.md):** Storage planning for 4K/8K
- **[Network Guide](configs/examples/network.md):** VLAN isolation and firewall rules
- **[Hetzner Deployment](deploy/hetzner/README.md):** Relay setup on Hetzner Cloud

---

## Contributing

(TODO: Add contribution guidelines after MVP stabilizes)

---

## License

(TODO: Add license)

---

## Acknowledgments

- Design by Cassidy Mugadza
- Locked decisions from `docs/DESIGN.md` and `docs/BOM.md`
- Security controls mandatory for production
- 4K/8K support per design addenda

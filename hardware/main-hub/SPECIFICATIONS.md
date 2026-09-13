# Guardian Main Hub - Hardware Specifications

## GH-1000 Main Control Hub (Standard Home System)

The Guardian Main Hub is the **central control unit** for a standard home security and surveillance system, integrating a 24-port PoE switch for cameras, full sensor connectivity, and local storage options.

---

## Core Features

### Network Connectivity
- **24× PoE RJ45 ports** (802.3af/at, 15.4W - 30W per port)
  - Total PoE budget: 400W (supports 24× 4K cameras + hub)
  - Gigabit Ethernet (1000 Mbps per port)
  - Auto-MDIX, auto-negotiation
  - VLAN support (camera isolation)
  - Link/activity LEDs per port

### Local Storage & Expansion
- **2× USB 3.0 Type-A ports** (5 Gbps)
  - External HDD/SSD for local recording backup
  - Firmware updates via USB drive
  - Configuration import/export
  
- **2× USB Type-C ports** (10 Gbps, USB 3.1 Gen 2)
  - High-speed external NVMe enclosures
  - Direct-attached storage (DAS)
  - Future expansion (USB4, Thunderbolt compatibility)

### Sensor Interfaces (Built-In)
- **32× Zone Inputs** (Digital, NC/NO/EOL)
- **8× Analog Sensor Inputs** (12-bit ADC, 0-3.3V)
- **4× Smoke Detector Inputs** (Supervised 12V)
- **2× Pulse Counter Inputs** (High-speed, up to 10 kHz)
- **4× Relay Outputs** (SPDT, 5A @ 30V DC)

### Communication & Management
- **1× Ethernet WAN port** (Gigabit, for internet/remote access)
- **2× SFP+ ports** (10 Gbps fiber, optional NAS uplink)
- **1× RS-485 port** (expander bus, up to 32 GXP-32 modules)
- **1× HDMI output** (1080p, local UI/monitoring)
- **Wi-Fi 6E** (802.11ax, 6 GHz, optional)

### Power
- **Input**: 120-240V AC, 50/60 Hz (universal power supply)
- **Internal PSU**: 500W (400W PoE budget + 100W system)
- **Battery backup port**: UPS integration (12V input, 24-48 hour runtime)
- **Redundant power**: Dual PSU support (enterprise models)

---

## Detailed Interface Specifications

### 24-Port PoE Switch (Camera Network)

**Port Configuration:**
```
Ports 1-24: PoE+ (802.3at, 30W per port)
  - Voltage: 48V DC
  - Standard: IEEE 802.3af (15.4W) / 802.3at (30W)
  - Auto-detection: PD (Powered Device) classification
  - Power allocation: Per-port power management
  
Camera Support:
  - 24× 4K cameras @ 15W each = 360W
  - 12× 8K cameras @ 30W each = 360W
  - Mixed: 16× 4K + 8× 8K = 240W + 240W = 480W (requires PSU upgrade)
```

**Switching Fabric:**
- **Chipset**: Broadcom BCM53134 (24-port GbE + 2× 10G uplink)
- **Switching capacity**: 52 Gbps (non-blocking)
- **Forwarding rate**: 38.69 Mpps (wire-speed)
- **MAC address table**: 16,000 entries
- **Jumbo frames**: 9KB (efficient for video streams)

**VLAN Configuration:**
```
VLAN 10: Camera network (ports 1-24, isolated from WAN)
VLAN 20: Management network (WAN port, sensor data)
VLAN 30: Storage network (SFP+ uplinks to NAS)

Default: Cameras cannot access WAN directly (security)
```

**PoE Power Management:**
- **Total budget**: 400W (via internal PSU)
- **Per-port monitoring**: Current, voltage, temperature
- **Priority**: Ports 1-8 (high), 9-16 (medium), 17-24 (low)
- **Overload protection**: Disable lowest priority ports first
- **Power scheduling**: Time-based PoE on/off (energy saving)

---

### USB 3.0 Type-A Ports (2×)

**Specifications:**
- **Standard**: USB 3.0 (USB 3.1 Gen 1)
- **Speed**: 5 Gbps (625 MB/s theoretical)
- **Power**: 5V @ 900mA per port (4.5W)
- **Connector**: Type-A receptacle (backwards compatible with USB 2.0)

**Use Cases:**
1. **Local recording backup**
   - External HDD (4TB-8TB)
   - Automatic video archival (overnight sync)
   - Redundant storage (if NAS fails)

2. **Firmware updates**
   - Load firmware from USB drive
   - No network required for updates
   - Rollback option (keep previous firmware on USB)

3. **Configuration backup**
   - Export system config to USB
   - Import config from USB (disaster recovery)
   - Transfer configs between hubs

4. **Offline playback**
   - Export video clips to USB
   - View on PC without network
   - Evidence collection (law enforcement)

**Supported Filesystems:**
- exFAT (recommended, cross-platform)
- ext4 (Linux native, best performance)
- NTFS (Windows, read/write)
- FAT32 (legacy, <4GB files)

---

### USB Type-C Ports (2×)

**Specifications:**
- **Standard**: USB 3.1 Gen 2 (USB-C)
- **Speed**: 10 Gbps (1.25 GB/s theoretical)
- **Power**: USB-PD (Power Delivery), 5V-20V @ 3A (60W max)
- **Connector**: Type-C receptacle (reversible)

**Use Cases:**
1. **High-speed NVMe storage**
   - External NVMe SSD enclosures (2000+ MB/s)
   - Hot storage tier (recent recordings)
   - 4K/8K video editing (direct access)

2. **Direct-attached storage (DAS)**
   - Multi-drive enclosures (JBOD, RAID)
   - Expansion beyond internal capacity
   - Tiered storage (NVMe hot + HDD warm)

3. **Future expansion**
   - USB4 devices (40 Gbps, forward compatible)
   - Thunderbolt 3/4 devices (with firmware update)
   - External GPUs (AI inference acceleration)

4. **Mobile device integration**
   - Connect smartphone/tablet directly
   - Transfer recordings without network
   - Guardian mobile app (USB tethering)

**USB-PD Power Profiles:**
```
Profile 1: 5V @ 3A (15W) - Standard devices
Profile 2: 9V @ 3A (27W) - Fast charge tablets
Profile 3: 12V @ 3A (36W) - Laptop docks
Profile 4: 15V @ 3A (45W) - External SSDs with power
Profile 5: 20V @ 3A (60W) - High-power NVMe enclosures
```

---

### Built-In Sensor Interfaces

**(Identical to GXP-32 module, see below)**

All sensor interfaces from the modular GXP-32 expander are **built into the main hub** for a standard home installation:

- 32× Zone Inputs
- 8× Analog Inputs
- 4× Smoke Detector Inputs
- 2× Pulse Counter Inputs
- 4× Relay Outputs

**Rationale:** Most homes need 15-25 zones (doors, windows, PIR). 32 zones built-in covers 95% of residential installations without requiring external expanders.

---

### WAN Port (Internet Uplink)

**Specifications:**
- **Speed**: Gigabit Ethernet (1000 Mbps)
- **Connector**: RJ45
- **Purpose**: Internet access, remote monitoring, cloud backup
- **VLAN**: Isolated from camera network (security)

**Features:**
- **Firewall**: Built-in stateful packet inspection (SPI)
- **Port forwarding**: For remote access (HTTPS only)
- **Dynamic DNS**: Automatic domain name updates
- **VPN support**: WireGuard, OpenVPN (encrypted remote access)

---

### SFP+ Ports (2× 10 Gbps Fiber)

**Specifications:**
- **Standard**: SFP+ (10GBASE-SR/LR)
- **Speed**: 10 Gbps per port
- **Connector**: SFP+ cage (small form-factor pluggable)

**Use Cases:**
1. **NAS uplink**
   - 10 Gbps fiber to Synology/QNAP NAS
   - High-speed video archival (100+ cameras)
   - Low latency (<1ms)

2. **Inter-hub linking**
   - Connect multiple Guardian hubs (distributed system)
   - 10 Gbps backbone for large installations
   - Fiber: immune to EMI, long distance (up to 10km)

3. **Storage network**
   - Dedicated VLAN for storage traffic
   - Isolated from camera/sensor networks
   - Full 10 Gbps bandwidth for recordings

**Supported Modules:**
- 10GBASE-SR: Multi-mode fiber, 300m (LC connector)
- 10GBASE-LR: Single-mode fiber, 10km (LC connector)
- 10GBASE-T: RJ45 copper, 100m (for existing Cat6a)

---

### RS-485 Expander Bus

**Purpose:** Connect modular GXP-32 expanders for additional zones

**Specifications:**
- **Topology**: Multi-drop bus (daisy chain)
- **Maximum devices**: 32 expanders (1024 total zones)
- **Baud rate**: 115200 bps
- **Cable**: Twisted pair, Cat5e or better
- **Distance**: Up to 1200m (4000 ft)
- **Termination**: 120Ω at both ends

**Example Expansion:**
```
Main Hub (32 zones built-in)
  ↓ RS-485 bus
Expander 1: +32 zones (64 total)
  ↓
Expander 2: +32 zones (96 total)
  ↓
Expander 3: +32 zones (128 total)
... up to 32 expanders (1024 zones)
```

---

### HDMI Output (Local Display)

**Specifications:**
- **Standard**: HDMI 2.0
- **Resolution**: 1920×1080 @ 60Hz (1080p)
- **Audio**: Stereo (for alarm sounds)

**Use Cases:**
- **Local UI**: View camera feeds, zone status, system logs
- **Touch interface**: Connect USB touchscreen (optional)
- **Kiosk mode**: Mount in security room, always-on display
- **Setup wizard**: Initial configuration without mobile app

**Display Modes:**
- Live view: 4×4 grid (16 cameras), auto-rotate
- Zone status: Visual map of all zones (green/red/yellow)
- Event log: Real-time scrolling event feed
- Dashboard: System health, storage, network status

---

### Wi-Fi 6E (Optional)

**Specifications:**
- **Standard**: 802.11ax (Wi-Fi 6E)
- **Bands**: 2.4 GHz, 5 GHz, 6 GHz
- **Speed**: Up to 2.4 Gbps (160 MHz channels)
- **Range**: ~30m indoors (with external antennas)

**Use Cases:**
- **Wireless cameras**: Backup connectivity (if PoE cable fails)
- **Mobile devices**: Guardian mobile app (local network)
- **IoT devices**: Wireless sensors (not recommended for critical zones)

**Note:** Guardian prioritizes **wired connections** for reliability. Wi-Fi is for convenience, not primary security.

---

## Hardware Block Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Guardian GH-1000 Main Hub                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │               Main Processor (Intel Celeron N5105)                      │ │
│  │  - Quad-core @ 2.0 GHz (burst to 2.9 GHz)                             │ │
│  │  - 16 GB DDR4 RAM (standard)                                           │ │
│  │  - 256 GB NVMe SSD (OS + hot storage)                                  │ │
│  │  - Intel UHD Graphics (HDMI output, hardware decode)                   │ │
│  │  - AES-NI, Quick Sync Video (hardware encoding/decoding)               │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌─────────────────────────┐  ┌─────────────────────────┐                 │
│  │   24-Port PoE Switch    │  │  Sensor Controller      │                 │
│  │   (Broadcom BCM53134)   │  │  (STM32H743)            │                 │
│  │                         │  │                         │                 │
│  │  - 24× GbE PoE+ ports   │  │  - 32× Zone Inputs      │                 │
│  │  - 400W PoE budget      │  │  - 8× Analog ADC        │                 │
│  │  - VLAN support         │  │  - 4× Smoke Inputs      │                 │
│  │  - Jumbo frames         │  │  - 2× Pulse Counters    │                 │
│  │  - Link aggregation     │  │  - 4× Relay Outputs     │                 │
│  │                         │  │  - RS-485 expander bus  │                 │
│  └───────────┬─────────────┘  └───────────┬─────────────┘                 │
│              │                             │                                │
│              │ PCIe x4                     │ USB 3.0 (internal)             │
│              │                             │                                │
│              ├─────────────────────────────┴──────────────────┐            │
│              │           System Bus (PCIe Gen 3.0)            │            │
│              └─────────────────────────────┬──────────────────┘            │
│                                            │                                │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    Storage & Expansion I/O                            │  │
│  │                                                                        │  │
│  │  - 2× USB 3.0 Type-A (5 Gbps)          [Front panel]                │  │
│  │  - 2× USB Type-C (10 Gbps, USB-PD 60W) [Front panel]                │  │
│  │  - 1× Gigabit WAN port (RJ45)          [Rear panel]                 │  │
│  │  - 2× SFP+ 10GbE (fiber)                [Rear panel]                 │  │
│  │  - 1× HDMI 2.0 output (1080p)           [Rear panel]                 │  │
│  │  - Wi-Fi 6E module (optional)           [Internal M.2 slot]          │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    Power Management                                   │  │
│  │                                                                        │  │
│  │  - Input: 120-240V AC, 50/60 Hz                                      │  │
│  │  - Internal PSU: 500W (80 Plus Gold efficiency)                      │  │
│  │    * 400W for PoE (24 ports)                                         │  │
│  │    * 100W for system (CPU, storage, sensors)                         │  │
│  │  - Battery backup input: 12V DC (UPS integration)                    │  │
│  │  - Redundant PSU option: Dual 500W (enterprise)                      │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    Status Indicators (Front Panel)                    │  │
│  │                                                                        │  │
│  │  - Power LED (green)                                                  │  │
│  │  - System status (green/amber/red)                                    │  │
│  │  - Network activity (24× LEDs, one per PoE port)                     │  │
│  │  - Alarm status (red, flashing when active)                          │  │
│  │  - Storage activity (amber, recording indicator)                      │  │
│  │  - 2.8" LCD touchscreen (optional, status display)                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Physical Specifications

### Enclosure
- **Form factor**: 2U rackmount (19" standard rack)
- **Dimensions**: 482mm (W) × 88mm (H) × 400mm (D)
- **Weight**: 8.5 kg (without drives)
- **Material**: Steel chassis (1.5mm), aluminum front panel
- **Mounting**: Rack ears included, optional wall-mount bracket
- **Cooling**: 2× 80mm fans (temperature-controlled, quiet)

### Front Panel Layout
```
┌─────────────────────────────────────────────────────────────────────┐
│  [Power LED] [Status LED] [Alarm LED] [LCD Display (optional)]     │
│                                                                      │
│  [USB-A] [USB-A] [USB-C] [USB-C]  [Reset Button] [Power Button]   │
└─────────────────────────────────────────────────────────────────────┘
```

### Rear Panel Layout
```
┌─────────────────────────────────────────────────────────────────────┐
│  PoE Ports (24× RJ45 in 2 rows)                                    │
│  [1] [2] [3] [4] [5] [6] [7] [8] [9] [10] [11] [12]              │
│  [13][14][15][16][17][18][19][20][21][22] [23] [24]               │
│                                                                      │
│  [WAN RJ45] [SFP+] [SFP+] [HDMI] [AC Power] [Fan Grill]           │
│                                                                      │
│  Sensor Terminals (below PoE ports)                                 │
│  Zone Inputs: [1-8] [9-16] [17-24] [25-32]                        │
│  Analog: [1-4] [5-8]  Smoke: [1-2] [3-4]  Pulse: [1] [2]         │
│  Relay: [1] [2] [3] [4]  RS-485: [A+][B-][GND]                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Bill of Materials (BOM)

| Component | Part Number | Qty | Unit Cost | Total |
|-----------|-------------|-----|-----------|-------|
| **Main Processor** | Intel Celeron N5105 | 1 | $150 | $150 |
| **RAM** | 16GB DDR4 SO-DIMM | 2 | $40 | $80 |
| **Storage** | 256GB NVMe M.2 SSD | 1 | $35 | $35 |
| **PoE Switch IC** | Broadcom BCM53134 | 1 | $45 | $45 |
| **PoE Controller** | TI TPS23881 (8-port) | 3 | $12 | $36 |
| **Sensor MCU** | STM32H743VIT6 | 1 | $12 | $12 |
| **USB 3.0 Controller** | ASMedia ASM1142 | 1 | $8 | $8 |
| **SFP+ Cages** | 10G SFP+ transceiver | 2 | $15 | $30 |
| **RJ45 Connectors** | Shielded, PoE-rated | 25 | $1.50 | $38 |
| **Power Supply** | 500W, 80+ Gold | 1 | $80 | $80 |
| **Enclosure** | 2U rackmount chassis | 1 | $60 | $60 |
| **Cooling** | 80mm fans (2×) | 2 | $8 | $16 |
| **Sensor Components** | (See GXP-32 BOM) | 1 | $60 | $60 |
| **Misc** | PCB, cables, hardware | - | - | $50 |
| **Total BOM** | | | | **$700** |

**Retail price (assembled)**: $1,299 (1.86× BOM cost for assembly + margin)

---

## Modular GXP-32 Expander (Add-On)

For installations requiring **more than 32 zones**, the system supports modular expansion via RS-485 bus.

### GXP-32 Expander Module

**Adds to the system:**
- +32 zone inputs
- +8 analog inputs
- +4 smoke detector inputs
- +2 pulse counters
- +4 relay outputs

**Connection:** Single RS-485 cable (twisted pair) to main hub

**Price:** $120 per expander (same as before)

**Installation:**
```
Main Hub (32 zones) → RS-485 → Expander 1 (+32 zones) → Expander 2 (+32 zones) → ...
```

**Maximum expansion:** 32 expanders = 1,024 total zones (overkill for residential, perfect for commercial)

---

## System Configurations

### Standard Home (Main Hub Only)
- **Cameras**: 24× 4K PoE cameras
- **Zones**: 32 (doors, windows, PIR)
- **Smoke detectors**: 4
- **Storage**: 256GB NVMe (3 days) + 4TB USB HDD (30 days)
- **Price**: $1,299 (hub only, cameras separate)

### Large Home (Hub + 1 Expander)
- **Cameras**: 24× 4K PoE cameras
- **Zones**: 64 (32 built-in + 32 expander)
- **Smoke detectors**: 8 (4 + 4)
- **Storage**: 256GB NVMe + 8TB USB HDD
- **Price**: $1,299 + $120 = $1,419

### Small Business (Hub + 2 Expanders)
- **Cameras**: 24× 4K PoE cameras
- **Zones**: 96 (32 + 32 + 32)
- **Smoke detectors**: 12 (4 + 4 + 4)
- **Storage**: 256GB NVMe + 2× 10TB USB HDD
- **Price**: $1,299 + $240 = $1,539

### Enterprise (Hub + NAS + 4 Expanders)
- **Cameras**: 24× 8K PoE cameras (via hub) + 200+ cameras (via additional hubs)
- **Zones**: 160 (32 + 4×32)
- **Storage**: 10 Gbps SFP+ to 100TB NAS
- **Price**: Custom (multi-hub deployment)

---

## Comparison: Main Hub vs. Expander

| Feature | Main Hub (GH-1000) | Expander (GXP-32) |
|---------|-------------------|-------------------|
| **PoE Ports** | 24× (cameras) | 0 |
| **USB 3.0** | 2× | 0 |
| **USB Type-C** | 2× | 0 |
| **SFP+ 10GbE** | 2× | 0 |
| **WAN Port** | 1× | 0 |
| **HDMI Output** | 1× | 0 |
| **Zone Inputs** | 32 | 32 |
| **Analog Inputs** | 8 | 8 |
| **Smoke Inputs** | 4 | 4 |
| **Pulse Counters** | 2 | 2 |
| **Relay Outputs** | 4 | 4 |
| **CPU** | Intel Celeron (quad-core) | None (expander only) |
| **RAM** | 16 GB | None |
| **Storage** | 256 GB NVMe | None |
| **Communication** | RS-485 master, Ethernet | RS-485 slave only |
| **Price** | **$1,299** | **$120** |

**Key Difference:** Main hub is a complete system (recording, processing, networking). Expander is a **sensor I/O module** (no CPU, no storage).

---

## Certifications & Compliance

- **UL 864** - Fire alarm control units (smoke detection)
- **UL 294** - Access control system units
- **UL 2043** - Fire test for plenum-rated equipment
- **FCC Part 15** - EMI/RFI compliance (Class A)
- **CE** - European conformity
- **RoHS** - Lead-free
- **Energy Star** - Power efficiency
- **NDAA Compliant** - No banned Chinese components (Hikvision, Dahua, Huawei)

---

## What Makes This Design Superior?

### vs. Traditional DVR/NVR Systems

| Feature | Guardian GH-1000 | Traditional NVR |
|---------|-----------------|-----------------|
| **PoE Ports** | 24 built-in | 4-16 (separate switch needed) |
| **Storage** | NVMe + USB + SFP+ NAS | Internal HDD only |
| **Sensor Integration** | 32 zones, smoke, analog | None (separate alarm panel) |
| **Expansion** | Modular (up to 1024 zones) | Fixed, no expansion |
| **Open Source** | ✅ Fully open | ❌ Proprietary |
| **Local Processing** | ✅ AI on-device | ❌ Cloud-dependent |
| **Security** | ✅ Wired-only, isolated VLANs | ❌ Wireless vulnerabilities |
| **Price** | **$1,299** | $800-2,000 (without switch) |

**Guardian wins:** Integrated, expandable, open, secure, cost-effective.

---

## Next Steps

1. **Finalize PCB design** (4-layer, component placement)
2. **Prototype assembly** (order BOM, hand-assemble)
3. **Firmware development** (Linux + Zig services)
4. **Testing & certification** (UL, FCC, CE)
5. **Production run** (100 units, beta testers)

**Timeline:** 6-8 months from design freeze to production (no calendar estimates for agent work).

---

This main hub design provides **everything a standard home needs** in one box, while keeping the modular expander system for growth. It's the perfect balance of integration and scalability!

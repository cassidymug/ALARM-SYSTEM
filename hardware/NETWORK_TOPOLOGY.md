# Guardian System - Network Topology & Connection Diagram

## Overview

The **GH-1000 Main Hub** is an **all-in-one system** - it's not just a "dumb" switch or sensor hub. It contains:
- Intel Celeron N5105 processor (this IS the computer/NUC)
- 24-port PoE switch (for cameras)
- Sensor controller (STM32 for zone/smoke/analog inputs)
- Storage (256GB NVMe + USB ports for expansion)

**There is NO separate NUC or computer needed** - everything is integrated into one 2U rackmount box.

---

## Network Architecture Diagram

```
                                    INTERNET
                                       │
                                       │
                     ┌─────────────────▼──────────────────┐
                     │   Your Router / Firewall / ISP     │
                     │   (192.168.1.1 example)            │
                     └─────────────────┬──────────────────┘
                                       │
                                       │ Ethernet cable (Cat6)
                                       │
                     ┌─────────────────▼──────────────────────────────────┐
                     │                                                     │
                     │         Guardian GH-1000 Main Hub                  │
                     │         (All-in-One System)                        │
                     │                                                     │
                     │  ┌──────────────────────────────────────────────┐ │
                     │  │  WAN Port (Gigabit Ethernet)                 │ │
                     │  │  - Connects to your router                   │ │
                     │  │  - Gets internet access                      │ │
                     │  │  - Static IP or DHCP                         │ │
                     │  └──────────────────────────────────────────────┘ │
                     │                                                     │
                     │  ┌──────────────────────────────────────────────┐ │
                     │  │  Intel Celeron N5105 Processor (Built-In)   │ │
                     │  │  - This IS the computer (like a NUC)         │ │
                     │  │  - Runs Debian Linux OS                      │ │
                     │  │  - Handles recording, AI, sensor processing  │ │
                     │  │  - 16GB RAM, 256GB NVMe SSD                  │ │
                     │  └──────────────────────────────────────────────┘ │
                     │                                                     │
                     │  ┌──────────────────────────────────────────────┐ │
                     │  │  24-Port PoE Switch (Built-In)               │ │
                     │  │  - Broadcom BCM53134 chipset                 │ │
                     │  │  - 400W PoE budget                           │ │
                     │  │  - Isolated camera VLAN                      │ │
                     │  └──────────────────────────────────────────────┘ │
                     │                                                     │
                     └─────┬───────┬───────┬───────┬──────────────────────┘
                           │       │       │       │
                    PoE    │       │       │       │  USB / SFP+ / RS-485
                  Cameras  │       │       │       │
                           │       │       │       │
                ┌──────────▼──┐ ┌──▼───┐ ┌─▼────┐ │
                │ Camera 1    │ │Cam 2 │ │Cam 3 │ │ ... (up to 24 cameras)
                │ 4K PoE      │ │4K PoE│ │4K PoE│ │
                │ 192.168.2.x │ │      │ │      │ │
                └─────────────┘ └──────┘ └──────┘ │
                                                    │
                  ┌─────────────────────────────────┴────────────┐
                  │                                              │
        ┌─────────▼──────────┐                    ┌─────────────▼──────────┐
        │ USB 3.0 / Type-C   │                    │ SFP+ 10GbE (Optional)  │
        │ External Storage   │                    │ NAS Connection         │
        │                    │                    │                        │
        │ 4TB HDD (30 days)  │                    │ 100TB Synology NAS     │
        │ or                 │                    │ (5-year archival)      │
        │ NVMe SSD (DAS)     │                    │ 10.0.0.x network       │
        └────────────────────┘                    └────────────────────────┘
                                                    
                                   ┌────────────────────────────────┐
                                   │ RS-485 Bus (Sensor Expanders)  │
                                   │                                │
                                   │  GXP-32 Expander 1             │
                                   │  (32 zones, sensors)           │
                                   │         │                      │
                                   │  GXP-32 Expander 2             │
                                   │  (32 zones, sensors)           │
                                   │         │                      │
                                   │  ... (up to 32 expanders)      │
                                   └────────────────────────────────┘
```

---

## Connection Details

### 1. Internet Connection (WAN Port)

**Physical Connection:**
```
Your Router → Cat6 Ethernet Cable → GH-1000 WAN Port (RJ45, rear panel)
```

**Network Configuration:**
- **Option A (Recommended)**: DHCP - Hub gets IP automatically from router
  - Router: 192.168.1.1 (gateway)
  - Hub WAN: 192.168.1.50 (assigned by router)
  - DNS: Automatic (from router)

- **Option B**: Static IP - Manual configuration
  - Hub WAN: 192.168.1.50 (fixed)
  - Gateway: 192.168.1.1 (router)
  - DNS: 8.8.8.8, 1.1.1.1 (Google, Cloudflare)

**Firewall Rules:**
- Default: All outbound traffic allowed (hub can access internet)
- Default: All inbound traffic blocked (secure)
- Optional: Port forward 443 (HTTPS) for remote access

**What This Enables:**
- ✅ Remote access to hub (via mobile app, web browser)
- ✅ Firmware updates (download from Guardian servers)
- ✅ Cloud backup (optional, user-controlled)
- ✅ Time synchronization (NTP)
- ✅ Email/SMS notifications
- ✅ Remote monitoring (when away from home)

---

### 2. Camera Network (24× PoE Ports)

**Physical Connection:**
```
Camera 1 → Cat6 PoE Cable (up to 100m) → Hub Port 1
Camera 2 → Cat6 PoE Cable (up to 100m) → Hub Port 2
... (repeat for up to 24 cameras)
```

**Network Configuration (Isolated VLAN):**
- **Camera VLAN**: 192.168.2.x (completely isolated from WAN)
- Camera 1: 192.168.2.101
- Camera 2: 192.168.2.102
- Camera 3: 192.168.2.103
- ... (DHCP assigned by hub's internal DHCP server)

**Why Isolated?**
- Cameras **cannot access the internet** (security)
- Cameras **cannot be hacked from outside**
- Cameras only talk to hub (RTSP streams)
- Hub acts as firewall between cameras and WAN

**Power:**
- Each PoE port provides 15.4W (802.3af) or 30W (802.3at)
- Total budget: 400W (can power all 24 cameras simultaneously)
- No separate power cables needed for cameras

---

### 3. Storage Connections

#### Option A: USB Storage (Simple, Budget-Friendly)

**USB 3.0 Type-A (Front Panel):**
```
Hub USB Port → External HDD (4TB-8TB) → USB-A cable
```
- **Speed**: 5 Gbps (625 MB/s) - fast enough for 24× 4K cameras
- **Capacity**: 4TB = 30 days of 24× 4K @ 15fps
- **Cost**: $80-$150 for 4TB-8TB HDD
- **Use case**: Most residential installations

**USB Type-C (Front Panel):**
```
Hub USB-C Port → NVMe SSD Enclosure (2TB) → USB-C cable
```
- **Speed**: 10 Gbps (1.25 GB/s) - ultra-fast
- **Capacity**: 2TB = hot storage (7 days of 24× 4K @ 30fps)
- **Cost**: $150-$250 for 2TB NVMe + enclosure
- **Use case**: High-performance installations (8K cameras)

#### Option B: Network Storage (NAS) via SFP+ (Enterprise)

**SFP+ 10GbE (Rear Panel):**
```
Hub SFP+ Port 1 → Fiber Cable (up to 10km) → Synology NAS
Hub SFP+ Port 2 → (Optional: redundant NAS or second location)
```
- **Speed**: 10 Gbps (1.25 GB/s) - handles 220+ cameras
- **Capacity**: 100TB+ (5-year retention)
- **Cost**: $5,000-$15,000 (NAS + drives)
- **Use case**: Commercial, enterprise, multi-building

---

### 4. Sensor Expanders (RS-485 Bus)

**Physical Connection (Daisy-Chain):**
```
Hub RS-485 Port → Cat5e Cable (twisted pair, one pair used) → Expander 1 RS-485
Expander 1 RS-485 → Cat5e Cable → Expander 2 RS-485
Expander 2 RS-485 → Cat5e Cable → Expander 3 RS-485
... (up to 32 expanders, 1200m total distance)
```

**Termination:**
- 120Ω resistor at hub (first device)
- 120Ω resistor at last expander (end of bus)

**Topology:**
- **Not Ethernet** - this is RS-485 serial bus
- Uses only one twisted pair from Cat5e cable
- 115200 baud (fast enough for 1000+ zones)
- Up to 1200m (4000 ft) total cable length

---

## Internal Hub Architecture (How It All Works Together)

```
┌─────────────────────────────────────────────────────────────────────┐
│                     GH-1000 Main Hub                                 │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  WAN Port → Internet (via your router)                         │ │
│  └──────────────────┬─────────────────────────────────────────────┘ │
│                     │                                                │
│                     │ Network interface (eth0)                       │
│                     │                                                │
│  ┌──────────────────▼─────────────────────────────────────────────┐ │
│  │       Intel Celeron N5105 CPU (Main Processor)                 │ │
│  │       - Runs Debian Linux OS                                   │ │
│  │       - Guardian Recorder Service (Zig)                        │ │
│  │       - Guardian Sensors Service (Zig)                         │ │
│  │       - Guardian UI (Zig, web server on port 443)              │ │
│  │       - AI Detection (hardware-accelerated)                    │ │
│  │       - Event Bus (internal pub/sub)                           │ │
│  └────┬────────────────────────┬─────────────────────┬────────────┘ │
│       │                        │                     │               │
│       │ PCIe x4                │ USB 3.0             │ RS-485        │
│       │                        │                     │               │
│  ┌────▼─────────────────┐ ┌───▼──────────────┐ ┌───▼─────────────┐ │
│  │ 24-Port PoE Switch   │ │ USB Storage      │ │ Sensor          │ │
│  │ (Broadcom BCM53134)  │ │ Controller       │ │ Controller      │ │
│  │ - Camera VLAN        │ │ - USB 3.0/C      │ │ (STM32H743)     │ │
│  │ - 192.168.2.x        │ │ - NVMe SSD       │ │ - 32 zones      │ │
│  │ - Isolated           │ │ - SATA (future)  │ │ - RS-485 master │ │
│  └────┬─────────────────┘ └──────────────────┘ └─────────────────┘ │
│       │                                                              │
│  ┌────▼─────────────────────────────────────────────────────────┐  │
│  │  PoE Ports 1-24 (RJ45, rear panel)                           │  │
│  │  [1][2][3][4][5][6][7][8][9][10][11][12]                     │  │
│  │  [13][14][15][16][17][18][19][20][21][22][23][24]            │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

**Data Flow Example (Camera Recording):**
1. Camera captures video → sends RTSP stream via PoE cable
2. Hub's PoE switch receives stream on port 5 (example)
3. Stream routed internally (PCIe bus) to CPU
4. Guardian Recorder service (Zig) processes stream
5. Video encoded (H.265, hardware-accelerated)
6. Saved to NVMe SSD (256GB, 3 days) + USB HDD (4TB, 30 days)
7. Optional: Archived to NAS via SFP+ (100TB, 5 years)

**Data Flow Example (Zone Sensor Triggered):**
1. Door opens → zone 5 triggered (NC contact opens)
2. GXP-32 expander detects change (100ms poll rate)
3. Expander sends event over RS-485 bus
4. Hub's sensor controller (STM32) receives event
5. Forwarded to main CPU (Intel Celeron)
6. Guardian Sensors service (Zig) processes event
7. Event bus notifies Recorder service
8. Cameras near zone 5 start high-resolution recording
9. Mobile app notification sent via WAN port → internet

---

## Network Requirements

### Minimum Internet Speed
- **Upstream (upload)**: 5 Mbps (for remote viewing 2-3 cameras)
- **Downstream (download)**: 10 Mbps (for firmware updates)

### Recommended Internet Speed (Remote Access)
- **Upstream**: 25 Mbps (remote viewing 8-10 cameras simultaneously)
- **Downstream**: 50 Mbps (fast firmware updates, cloud backup)

### LAN Requirements (Between Hub and Router)
- **Gigabit Ethernet** (1000 Mbps) - standard Cat5e/Cat6 cable
- **Latency**: <1ms (local network)

### Camera Network (PoE Ports)
- **Per camera**: 8-15 Mbps (4K @ 30fps, H.265)
- **24 cameras**: 192-360 Mbps total (well within 1 Gbps per-port capacity)
- **Cable**: Cat6 or better (supports PoE+, up to 100m)

---

## Common Topology Scenarios

### Scenario 1: Small Home (Simple Setup)

```
Internet
   │
Router (192.168.1.1)
   │
   └─── GH-1000 Hub (192.168.1.50)
          ├─── 8× Cameras (192.168.2.101-108)
          └─── USB HDD (4TB, 30 days)
```

**What you need:**
- 1× Guardian GH-1000 Hub ($1,299)
- 1× Ethernet cable (router to hub)
- 8× 4K PoE cameras ($200 each = $1,600)
- 8× Cat6 cables (cameras to hub, 50ft avg)
- 1× 4TB USB HDD ($100)
- **Total**: ~$3,000

---

### Scenario 2: Large Estate (Multi-Building)

```
Internet
   │
Router + Firewall (192.168.1.1)
   │
   ├─── GH-1000 Hub (192.168.1.50)
   │      ├─── 24× Cameras (192.168.2.101-124)
   │      ├─── USB-C NVMe (2TB, hot storage)
   │      ├─── USB HDD (8TB, warm storage)
   │      ├─── GXP-32 Expander 1 (32 zones, main house)
   │      └─── GXP-32 Expander 2 (32 zones, guest house)
   │
   └─── Synology NAS (10.0.0.5, via SFP+ fiber)
          └─── 100TB (5-year archival)
```

**What you need:**
- 1× Guardian GH-1000 Hub ($1,299)
- 2× GXP-32 Expanders ($120 each = $240)
- 24× 4K/8K cameras ($200-$400 each = $4,800-$9,600)
- 1× 2TB NVMe SSD + USB-C enclosure ($200)
- 1× 8TB USB HDD ($150)
- 1× Synology NAS + 8× 12TB drives ($5,000-$8,000)
- 2× SFP+ fiber modules + cable ($300)
- **Total**: ~$12,000-$20,000

---

### Scenario 3: Commercial (220 Cameras, Multiple Hubs)

```
Internet (100 Mbps)
   │
Firewall + Core Switch (10GbE)
   ├─── GH-1000 Hub 1 (Building A, 24 cameras)
   ├─── GH-1000 Hub 2 (Building B, 24 cameras)
   ├─── GH-1000 Hub 3 (Building C, 24 cameras)
   ├─── ... (10 hubs total, 220 cameras)
   │
   └─── 100TB SAN/NAS (40GbE fiber, shared storage)
          └─── 5-year retention, tiered storage
```

**What you need:**
- 10× Guardian GH-1000 Hubs ($1,299 × 10 = $12,990)
- Multiple GXP-32 Expanders (as needed for zones)
- 220× 8K cameras ($400 × 220 = $88,000)
- 1× 100TB SAN + fiber infrastructure ($50,000)
- **Total**: ~$150,000-$200,000

---

## FAQs

### Q: Do I need a separate computer (NUC) to run the Guardian software?
**A: NO.** The GH-1000 hub **IS the computer**. It has an Intel Celeron processor built-in that runs the Guardian software. You don't need a separate NUC, Raspberry Pi, or server.

### Q: Can I use the hub without internet?
**A: YES.** The hub works **fully offline**. Internet is only needed for:
- Remote access (when away from home)
- Firmware updates
- Cloud backup (optional)
- Email/SMS notifications

Local recording, AI detection, and alarm functions work without internet.

### Q: Can I connect cameras from different brands?
**A: YES.** The hub supports **any ONVIF-compliant IP camera**. Brands like Reolink, Hikvision (older models), Dahua, Amcrest, Uniview, etc. will all work as long as they support ONVIF and RTSP.

### Q: Do cameras need to be PoE?
**A: NO, but recommended.** PoE is convenient (one cable for power + data), but you can use non-PoE cameras with separate power adapters. They'll connect to the hub's PoE ports just fine (PoE is auto-negotiated—if camera doesn't need it, it won't get it).

### Q: Can I add cameras to an existing network?
**A: YES, but not recommended.** For security, cameras should be on the hub's isolated VLAN (192.168.2.x). If you have an existing camera network, you can:
- Option A: Move cameras to hub's PoE ports (recommended)
- Option B: Use hub in "hybrid mode" (WAN port on main network, camera VLAN trunked to existing switch) - advanced setup

### Q: How do I access the hub's web UI?
**A: From any device on your LAN:**
- Open browser, go to `https://192.168.1.50` (hub's IP)
- Login with username/password
- Access live view, recordings, settings, etc.

**A: From internet (remote access):**
- Set up port forwarding on router (port 443 → hub IP)
- Access via `https://your-public-ip` or dynamic DNS domain
- Or use Guardian mobile app (auto-discovery)

### Q: What if I need more than 24 cameras?
**Options:**
1. **Add a second hub** (each hub = 24 more cameras)
2. **Use enterprise architecture** (multiple hubs → shared NAS via SFP+)
3. **Upgrade to commercial switch** (hub becomes recorder only, use managed switch for cameras)

---

## Summary

**Simple Answer:**
1. **Hub connects to internet**: Via its WAN port (RJ45) to your router
2. **No separate NUC needed**: Hub **IS** the computer (Intel Celeron inside)
3. **Cameras connect to hub**: Via 24 built-in PoE ports
4. **Everything in one box**: Computer + PoE switch + sensor controller + storage

**The GH-1000 is a complete, all-in-one system. You just need:**
- Guardian hub ($1,299)
- Your router (already have)
- Cameras (PoE, ONVIF)
- One Ethernet cable (hub to router)

That's it. No separate NUC, no managed switch, no complicated networking. Plug and play!

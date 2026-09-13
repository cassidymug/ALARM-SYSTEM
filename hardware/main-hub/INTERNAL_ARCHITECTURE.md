# Guardian GH-1000 Main Hub - Internal Architecture

## Understanding the Integrated System

**Key Concept:** The GH-1000 is **NOT** a "hub" connected to a separate computer. It **IS** a complete computer system in a 2U rackmount chassis, similar to how a Synology NAS or UniFi Dream Machine works.

---

## Physical Architecture

### What's Inside the 2U Rackmount Box

```
┌─────────────────────────────────────────────────────────────────────┐
│  Guardian GH-1000 Main Hub (2U Rackmount Enclosure)                 │
│  Dimensions: 482mm (W) × 88mm (H) × 400mm (D)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    CUSTOM MAIN PCB                             │ │
│  │                  (4-layer, 300mm × 250mm)                      │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │  Intel Celeron N5105 (SoC)                              │ │ │
│  │  │  - Quad-core @ 2.0-2.9 GHz                              │ │ │
│  │  │  - Intel UHD Graphics (integrated GPU)                  │ │ │
│  │  │  - PCIe Gen 3.0 controller                              │ │ │
│  │  │  - USB 3.0/3.1 controllers                              │ │ │
│  │  │  - HDMI output controller                               │ │ │
│  │  │  - Ethernet MAC (for WAN port)                          │ │ │
│  │  │  - This IS the main computer                            │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                            │                                    │ │
│  │                            │ System Bus (PCIe, USB, I²C)        │ │
│  │                            │                                    │ │
│  │  ┌─────────────────┬──────┴────────┬────────────────────────┐ │ │
│  │  │                 │               │                        │ │ │
│  │  │  RAM Slots      │  NVMe Slot    │  PoE Switch PCIe Card │ │ │
│  │  │  (2× SO-DIMM)   │  (M.2 2280)   │  (Mini PCIe or NGFF) │ │ │
│  │  │                 │               │                        │ │ │
│  │  │  16GB DDR4      │  256GB NVMe   │  Broadcom BCM53134    │ │ │
│  │  │  (2× 8GB)       │  SSD          │  24-port GbE + PoE     │ │ │
│  │  └─────────────────┴───────────────┴────────────────────────┘ │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │  Sensor Controller (Separate PCB, connected via USB)     │ │ │
│  │  │  - STM32H743 microcontroller                             │ │ │
│  │  │  - 32× zone input circuits                               │ │ │
│  │  │  - 8× ADC analog inputs                                  │ │ │
│  │  │  - 4× smoke detector circuits                            │ │ │
│  │  │  - 2× pulse counter circuits                             │ │ │
│  │  │  - 4× relay output drivers                               │ │ │
│  │  │  - RS-485 transceiver                                    │ │ │
│  │  │  - Connected to main CPU via USB 3.0 (internal)          │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                                                 │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  500W Power Supply (Rear-mounted)                            │  │
│  │  - Input: 120-240V AC, 50/60 Hz                              │  │
│  │  - Outputs: +12V (PoE), +5V (logic), +3.3V (CPU)            │  │
│  │  - 80 Plus Gold efficiency                                   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Cooling System                                               │  │
│  │  - 2× 80mm fans (rear exhaust)                               │  │
│  │  - CPU heatsink (passive + airflow)                          │  │
│  │  - Temperature sensors (PWM fan control)                     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Front Panel I/O                                              │  │
│  │  - 2× USB 3.0 Type-A ports                                   │  │
│  │  - 2× USB Type-C ports                                       │  │
│  │  - Power button, Reset button                                │  │
│  │  - Status LEDs (power, network, alarm, storage)             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Rear Panel I/O                                               │  │
│  │  - 24× RJ45 PoE ports (2 rows of 12)                        │  │
│  │  - 1× RJ45 WAN port                                          │  │
│  │  - 2× SFP+ cages (10GbE fiber)                              │  │
│  │  - 1× HDMI port                                              │  │
│  │  - Sensor terminal blocks (zones, analog, smoke, etc.)      │  │
│  │  - AC power inlet (IEC C14)                                  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Component Interconnection

### Main PCB Layout (Custom Design)

The GH-1000 uses a **custom motherboard** (not a standard ATX/ITX board). Think of it like the mainboard in a Synology NAS or a network appliance.

```
┌─────────────────────────────────────────────────────────────────┐
│                     Main PCB (Top View)                          │
│                                                                  │
│  ┌──────────────────┐                ┌────────────────────────┐ │
│  │  Intel Celeron   │◄───PCIe Gen3───┤  PoE Switch Module     │ │
│  │  N5105 SoC       │      x4        │  (Broadcom BCM53134)   │ │
│  │  (BGA package)   │                │  Mini PCIe card        │ │
│  └────────┬─────────┘                └────────────────────────┘ │
│           │                                                      │
│           ├──── DDR4 SO-DIMM Slot 1 (8GB)                      │
│           │                                                      │
│           ├──── DDR4 SO-DIMM Slot 2 (8GB)                      │
│           │                                                      │
│           ├──── M.2 2280 NVMe Slot (256GB SSD)                 │
│           │                                                      │
│           ├──── USB 3.0 Header ──► STM32 Sensor Board (internal)│
│           │                                                      │
│           ├──── USB 3.0 Type-A Front Panel (2×)                │
│           │                                                      │
│           ├──── USB 3.1 Type-C Front Panel (2×)                │
│           │                                                      │
│           ├──── HDMI Output (rear panel)                        │
│           │                                                      │
│           ├──── Gigabit Ethernet PHY ──► WAN Port (RJ45)       │
│           │                                                      │
│           ├──── SFP+ Controller (2× cages, rear panel)         │
│           │                                                      │
│           ├──── M.2 2230 Slot (Wi-Fi 6E module, optional)      │
│           │                                                      │
│           └──── Power Management IC (PMIC)                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Key Point:** The Intel Celeron N5105 is a **System-on-Chip (SoC)** - it contains:
- 4 CPU cores
- Integrated GPU (Intel UHD Graphics)
- Memory controller (DDR4)
- PCIe controller (for NVMe, PoE switch)
- USB controllers (USB 3.0, USB 3.1)
- Display output (HDMI)
- Networking (Ethernet MAC)

All on one chip! This is similar to how a Raspberry Pi or Intel NUC works.

---

## How Components Connect to the Main CPU

### 1. PoE Switch Connection (PCIe)

The 24-port PoE switch is **NOT a separate box**. It's a PCIe card (or integrated chip) on the main PCB.

```
Intel Celeron CPU
    │
    │ PCIe Gen 3.0 x4 lanes (4 GB/s bandwidth)
    │
    ▼
Broadcom BCM53134 Switch Chip (on Mini PCIe card or soldered)
    │
    │ Internal traces (PCB routing)
    │
    ├─── PoE Controller 1 (TI TPS23881, ports 1-8)
    ├─── PoE Controller 2 (TI TPS23881, ports 9-16)
    └─── PoE Controller 3 (TI TPS23881, ports 17-24)
         │
         │ Magnetics + RJ45 jacks
         │
         ▼
    24× RJ45 ports on rear panel
```

**How it works:**
1. Camera sends Ethernet frames → RJ45 port
2. Switch chip receives frames, routes to CPU via PCIe
3. CPU processes video stream (Guardian Recorder service)
4. CPU writes to NVMe SSD or USB storage

**Analogy:** Like a PCIe network card in a desktop PC, but with 24 ports instead of 1.

---

### 2. Sensor Controller Connection (USB 3.0)

The sensor controller is a **separate PCB** (custom design) that connects to the main board via an internal USB 3.0 header.

```
Intel Celeron CPU
    │
    │ USB 3.0 (5 Gbps)
    │ Internal USB header on main PCB
    │
    ▼
STM32H743 Microcontroller (on sensor PCB)
    │
    ├─── 32× Zone Input Circuits ──► Terminal blocks (rear panel)
    ├─── 8× ADC Analog Inputs ──► Terminal blocks (rear panel)
    ├─── 4× Smoke Detector Circuits ──► Terminal blocks (rear panel)
    ├─── 2× Pulse Counter Circuits ──► Terminal blocks (rear panel)
    ├─── 4× Relay Output Drivers ──► Terminal blocks (rear panel)
    └─── RS-485 Transceiver ──► RS-485 terminal (rear panel)
```

**Why a separate PCB?**
- Keeps **analog circuits isolated** from noisy digital circuits (CPU, RAM, NVMe)
- Allows **signal conditioning** close to inputs (TVS diodes, filters, optoisolators)
- Easier **manufacturing** (test sensor board separately)
- **Modular design** (can upgrade sensor board without replacing main board)

**How it works:**
1. Zone 5 door sensor triggers (contact opens)
2. STM32 detects change (via optoisolator, ADC, etc.)
3. STM32 sends event over USB 3.0 to main CPU
4. CPU processes event (Guardian Sensors service)
5. CPU triggers recording on nearby cameras

**Analogy:** Like an Arduino connected to a PC via USB, but internal and custom-designed.

---

### 3. Storage Connection (NVMe, USB)

**NVMe SSD (Internal):**
```
Intel Celeron CPU
    │
    │ PCIe Gen 3.0 x4 (4 GB/s bandwidth)
    │
    ▼
M.2 2280 NVMe SSD (256GB)
    │
    └─── Mounted on main PCB (M.2 slot)
```

**USB Storage (External):**
```
Intel Celeron CPU
    │
    │ USB 3.0/3.1 (5-10 Gbps)
    │
    ▼
Front panel USB ports (Type-A, Type-C)
    │
    └─── User plugs in external HDD/SSD
```

**How it works:**
1. CPU encodes video (H.265, hardware-accelerated)
2. Writes to **NVMe SSD** first (hot storage, 3-7 days)
3. Background process archives to **USB HDD** (warm storage, 30-90 days)
4. Optional: Background process archives to **NAS via SFP+** (cold storage, 5 years)

---

### 4. Network Connections

**WAN Port (Internet):**
```
Intel Celeron CPU
    │
    │ Internal Ethernet MAC
    │
    ▼
Gigabit Ethernet PHY Chip (Realtek RTL8111H)
    │
    │ Magnetics
    │
    ▼
RJ45 jack (WAN port, rear panel)
    │
    └─── Connects to your router
```

**SFP+ Ports (NAS Uplink):**
```
Intel Celeron CPU
    │
    │ PCIe Gen 3.0 x4 (shared with PoE switch)
    │
    ▼
10GbE Controller (Intel X550 or similar)
    │
    │ Fiber optic transceiver module
    │
    ▼
2× SFP+ cages (rear panel)
    │
    └─── Fiber cable to Synology NAS
```

---

## PCB Design (Multi-Board Architecture)

### Option 1: Single Large PCB (Simpler, More Expensive)

```
┌───────────────────────────────────────────────────────────┐
│           One Large Main PCB (350mm × 280mm)              │
│                                                            │
│  ┌─────────┐  ┌──────────┐  ┌──────────────────────────┐ │
│  │ Celeron │  │ RAM      │  │ PoE Switch Section       │ │
│  │ N5105   │  │ 16GB     │  │ (24 ports, integrated)   │ │
│  └─────────┘  └──────────┘  └──────────────────────────┘ │
│                                                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────────┐ │
│  │ NVMe     │  │ STM32    │  │ Sensor Inputs/Outputs    │ │
│  │ SSD      │  │ Sensor   │  │ (32 zones, analog, etc.) │ │
│  └──────────┘  └──────────┘  └──────────────────────────┘ │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Pros:** Simpler assembly, fewer connectors  
**Cons:** Expensive ($200+ per board), hard to test, no modularity

---

### Option 2: Multi-Board with Backplane (Modular, Recommended)

```
┌─────────────────────────────────────────────────────────────┐
│  Main Computer Board (Mini-ITX or custom, 170mm × 170mm)   │
│  - Intel Celeron N5105                                      │
│  - 16GB RAM (SO-DIMM)                                       │
│  - 256GB NVMe M.2                                           │
│  - PCIe x4 edge connector → Backplane                       │
│  - USB 3.0 headers → Backplane                              │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                │ Plugs into backplane
                                │
┌───────────────────────────────▼─────────────────────────────┐
│  Backplane PCB (Passive, 400mm × 100mm)                     │
│  - PCIe slots (for PoE switch card, 10GbE card)             │
│  - USB 3.0 headers (for sensor board)                       │
│  - Power distribution (12V, 5V, 3.3V)                       │
│  - Front/rear panel I/O connectors                          │
└──┬──────────────────┬──────────────────┬───────────────────┘
   │                  │                  │
   │                  │                  │
┌──▼────────────┐  ┌──▼────────────┐  ┌─▼──────────────────┐
│ PoE Switch    │  │ 10GbE SFP+    │  │ Sensor Controller  │
│ Card          │  │ Card          │  │ Board              │
│ (Mini PCIe)   │  │ (Mini PCIe)   │  │ (USB 3.0)          │
│               │  │               │  │                    │
│ BCM53134      │  │ Intel X550    │  │ STM32H743          │
│ 24× GbE PoE   │  │ 2× 10GbE      │  │ 32 zones, sensors  │
└───────────────┘  └───────────────┘  └────────────────────┘
```

**Pros:** Modular (easy to replace/upgrade), easier testing, cheaper per board  
**Cons:** More connectors (potential reliability issues), more assembly steps

---

## Comparison to Similar Devices

### Guardian GH-1000 vs. Synology NAS

Both are **appliances** (purpose-built computers in custom enclosures):

| Component | Guardian GH-1000 | Synology DS1621+ NAS |
|-----------|-----------------|----------------------|
| **CPU** | Intel Celeron N5105 (on-board) | AMD Ryzen V1500B (on-board) |
| **RAM** | 16GB DDR4 SO-DIMM | 4GB DDR4 SO-DIMM (expandable) |
| **Storage** | 256GB NVMe M.2 | No M.2 (SATA only) |
| **Network** | 24× GbE PoE + 1× GbE WAN + 2× 10GbE SFP+ | 4× GbE (no PoE) |
| **PCIe Slots** | Internal Mini PCIe (switch, 10GbE) | 2× PCIe Gen 3.0 slots |
| **Enclosure** | 2U rackmount | Desktop tower |
| **Custom PCB** | Yes (main board + sensor board) | Yes (proprietary mainboard) |
| **Purpose** | Security + surveillance | File storage + apps |

**Key Similarity:** Both are **complete computers** with custom mainboards, not "hubs" connected to separate PCs.

---

### Guardian GH-1000 vs. UniFi Dream Machine Pro

Both are **network appliances** with integrated switching:

| Component | Guardian GH-1000 | UniFi Dream Machine Pro |
|-----------|-----------------|-------------------------|
| **CPU** | Intel Celeron N5105 (quad-core) | Quad-core ARM Cortex-A57 |
| **RAM** | 16GB DDR4 | 4GB DDR4 |
| **Storage** | 256GB NVMe M.2 | 128GB SSD |
| **Switch** | 24× GbE PoE (integrated) | 8× GbE PoE (integrated) |
| **Purpose** | Security + surveillance + sensors | Networking + UniFi Protect |
| **Custom PCB** | Yes | Yes |
| **Form Factor** | 2U rackmount | 1U rackmount |

**Key Similarity:** Both have **integrated PoE switches** connected to the main CPU via internal PCIe, not external cables.

---

## Manufacturing Process

### How the GH-1000 Would Be Built

**Step 1: Main PCB Assembly**
1. Design custom PCB (KiCad, Altium Designer)
2. Order PCB fabrication (JLCPCB, PCBWay) - $200 for 5 boards
3. SMT assembly (surface-mount components): CPU, RAM slots, M.2 slot, PHY chips
4. Through-hole assembly (if any): Connectors, headers

**Step 2: Sensor PCB Assembly**
1. Design sensor board (separate PCB)
2. SMT assembly: STM32, ADC, optoisolators, relay drivers
3. Through-hole: Terminal blocks, RS-485 connector

**Step 3: Integration**
1. Install main PCB in 2U chassis (standoffs, screws)
2. Install sensor PCB (mounted separately or on backplane)
3. Connect internal USB cable (main board → sensor board)
4. Install PoE switch card (Mini PCIe slot or backplane)
5. Install 10GbE SFP+ card (if included)
6. Connect front/rear panel I/O cables
7. Install power supply (500W, rear-mounted)
8. Connect power cables (12V, 5V, 3.3V to boards)
9. Install cooling fans (rear exhaust)

**Step 4: Testing**
1. Power-on self-test (POST)
2. BIOS configuration (boot order, fan control)
3. OS installation (Debian, via USB)
4. Guardian software installation (Zig binaries)
5. Functional testing: PoE, sensors, storage, networking
6. Burn-in test (24 hours under load)

**Step 5: Packaging**
1. Close chassis (top cover, screws)
2. Apply labels (serial number, MAC address, certifications)
3. Pack in box with accessories (power cable, manual, Cat6 cable)
4. Ship to customer

---

## Summary: It's All One System

**Think of the GH-1000 like:**
- A **Synology NAS** (complete computer for file storage)
- A **UniFi Dream Machine** (complete computer for networking)
- A **Mac Mini** (complete computer in a small box)
- A **NUC** (complete computer in a tiny box)

**NOT like:**
- A "hub" (simple switch) + separate PC
- A USB device that connects to a computer
- A peripheral that needs a host computer

---

## Physical Connections (External)

**What you actually plug in:**

1. **Power**: AC power cable → IEC C14 inlet (rear) → Internal PSU
2. **Internet**: Router → Cat6 cable → WAN port (rear) → CPU's Ethernet PHY
3. **Cameras**: Camera 1-24 → Cat6 PoE cables → PoE ports (rear) → PoE switch → CPU
4. **Storage**: USB drive → USB port (front) → CPU's USB controller
5. **Display**: Monitor → HDMI cable → HDMI port (rear) → CPU's GPU
6. **Sensors**: Zone wire → Terminal block (rear) → Sensor PCB → USB (internal) → CPU
7. **NAS**: Fiber module → SFP+ cage (rear) → 10GbE controller → CPU

**Everything goes to the CPU because the CPU IS the main computer.**

---

**Conclusion:** The GH-1000 is **one integrated system**. The "hub" IS the "computer" - they're the same physical device. There's no separate connection between them because they're built together on the same PCB(s) inside one enclosure, just like a NAS or network appliance.

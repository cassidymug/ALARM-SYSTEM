# Guardian System - Complete Interface Summary

## Overview

The Guardian system consists of two hardware components:

1. **GH-1000 Main Hub** - Central control unit with camera network, storage, and built-in sensors
2. **GXP-32 Expanders** - Modular sensor expansion modules (optional, up to 32 units)

---

## GH-1000 Main Hub - Complete Interface List

### Network & Camera Interfaces
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **PoE RJ45 (Cameras)** | 24 | 802.3at, 30W per port, Gigabit | IP cameras (4K/8K) |
| **WAN Port (RJ45)** | 1 | Gigabit Ethernet | Internet uplink |
| **SFP+ Fiber** | 2 | 10 Gbps each | NAS uplink or inter-hub |

### Storage & Expansion
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **USB 3.0 Type-A** | 2 | 5 Gbps (625 MB/s) | External HDD, firmware updates |
| **USB Type-C** | 2 | 10 Gbps (1.25 GB/s), USB-PD 60W | NVMe SSD, DAS, future expansion |
| **Internal NVMe M.2** | 1 | PCIe Gen 3 x4 (256GB standard) | OS + hot storage |

### Sensor Interfaces (Built-In)
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **Zone Inputs** | 32 | Digital NC/NO/EOL, optoisolated | Doors, windows, PIR, contacts |
| **Analog Inputs** | 8 | 12-bit ADC, 0-3.3V | Temperature, humidity, CO, gas |
| **Smoke Detector Inputs** | 4 | Supervised 12V loops, 500mA | Hardwired smoke/heat detectors |
| **Pulse Counter Inputs** | 2 | High-speed, up to 10 kHz | Metal detectors, beam counters |
| **Relay Outputs** | 4 | SPDT, 5A @ 30V DC | Sirens, strobes, locks, HVAC |

### Communication & Management
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **RS-485** | 1 | 115200 baud, up to 1200m | Expander bus (up to 32 modules) |
| **HDMI** | 1 | HDMI 2.0, 1080p @ 60Hz | Local display/UI |
| **Wi-Fi 6E** | 1 | 802.11ax, optional | Wireless connectivity (backup) |

### Power
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **AC Power** | 1 | 120-240V, 50/60 Hz, 500W PSU | Main power |
| **Battery Backup** | 1 | 12V DC input | UPS integration (24-48hr runtime) |

---

## GH-1000 Main Hub - Summary by Category

### Total Interfaces: **87**

| Category | Count | Breakdown |
|----------|-------|-----------|
| **Camera/Network** | 27 | 24× PoE + 1× WAN + 2× SFP+ |
| **Storage** | 5 | 2× USB 3.0 + 2× USB-C + 1× NVMe |
| **Sensor Inputs** | 46 | 32× Zone + 8× Analog + 4× Smoke + 2× Pulse |
| **Outputs** | 4 | 4× Relay |
| **Communication** | 3 | 1× RS-485 + 1× HDMI + 1× Wi-Fi |
| **Power** | 2 | 1× AC + 1× Battery Backup |

---

## GXP-32 Expander - Interface List (Per Module)

### Sensor Interfaces Only
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **Zone Inputs** | 32 | Digital NC/NO/EOL, optoisolated | Doors, windows, PIR, contacts |
| **Analog Inputs** | 8 | 12-bit ADC, 0-3.3V | Temperature, humidity, CO, gas |
| **Smoke Detector Inputs** | 4 | Supervised 12V loops, 500mA | Hardwired smoke/heat detectors |
| **Pulse Counter Inputs** | 2 | High-speed, up to 10 kHz | Metal detectors, beam counters |
| **Relay Outputs** | 4 | SPDT, 5A @ 30V DC | Sirens, strobes, locks, HVAC |

### Communication & Power
| Interface | Quantity | Specifications | Purpose |
|-----------|----------|----------------|---------|
| **RS-485** | 1 | Slave mode, daisy-chain | Connects to main hub |
| **12V DC Power** | 1 | 12V @ 3A (36W) | Powers expander + sensors |
| **PoE (Optional)** | 1 | 802.3af, 15W | Alternative power source |

### Total Interfaces per Expander: **52**

---

## Complete System Capacity

### Standard Home (Main Hub Only)
```
Total Interfaces: 87
├─ 24× Camera PoE ports
├─ 32× Zone inputs
├─ 8× Analog inputs
├─ 4× Smoke detectors
├─ 2× Pulse counters
├─ 4× Relay outputs
├─ 2× USB 3.0 + 2× USB-C
├─ 2× SFP+ (10GbE)
└─ 1× WAN, 1× HDMI, 1× Wi-Fi
```

**Covers 95% of residential installations.**

---

### Large Home (Main Hub + 1 Expander)
```
Total Interfaces: 139 (87 + 52)
├─ 24× Camera PoE ports (main hub)
├─ 64× Zone inputs (32 + 32)
├─ 16× Analog inputs (8 + 8)
├─ 8× Smoke detectors (4 + 4)
├─ 4× Pulse counters (2 + 2)
├─ 8× Relay outputs (4 + 4)
└─ Storage/networking unchanged
```

**Perfect for large estates, multi-building properties.**

---

### Small Business (Main Hub + 2 Expanders)
```
Total Interfaces: 191 (87 + 52 + 52)
├─ 24× Camera PoE ports
├─ 96× Zone inputs (32 + 32 + 32)
├─ 24× Analog inputs (8 + 8 + 8)
├─ 12× Smoke detectors (4 + 4 + 4)
├─ 6× Pulse counters (2 + 2 + 2)
└─ 12× Relay outputs (4 + 4 + 4)
```

**Ideal for offices, warehouses, retail stores.**

---

### Maximum Configuration (Main Hub + 32 Expanders)
```
Total Interfaces: 1,751 (87 + 32 × 52)
├─ 24× Camera PoE ports (main hub)
├─ 1,056× Zone inputs (32 + 32 × 32)
├─ 264× Analog inputs (8 + 32 × 8)
├─ 132× Smoke detectors (4 + 32 × 4)
├─ 66× Pulse counters (2 + 32 × 2)
└─ 132× Relay outputs (4 + 32 × 4)
```

**Enterprise scale: universities, hospitals, industrial complexes.**

---

## Interface Type Breakdown (All Supported Sensor Types)

### Zone Inputs (32 per hub/expander, NC/NO/EOL)
Supports any digital contact sensor:
- ✅ Door/window contacts (magnetic reed switches)
- ✅ PIR motion detectors (pet-immune, dual-tech)
- ✅ Glass break detectors (acoustic)
- ✅ Panic buttons (normally open)
- ✅ Tamper switches (enclosure security)
- ✅ Beam sensors (perimeter security)
- ✅ Vibration sensors (safe/vault protection)
- ✅ Water leak detectors (conductive probe)
- ✅ Freeze sensors (normally closed)
- ✅ Any NC/NO/EOL contact (universal compatibility)

### Analog Inputs (8 per hub/expander, 0-3.3V ADC)
Supports any 0-3.3V analog sensor:
- ✅ Temperature sensors (NTC thermistor, DS18B20, LM35)
- ✅ Humidity sensors (DHT22, capacitive)
- ✅ Gas sensors (CO, methane, propane, natural gas)
- ✅ Smoke sensors (analog, MQ-2)
- ✅ Light level sensors (photoresistor, LDR)
- ✅ Sound level sensors (analog microphone)
- ✅ Pressure sensors (barometric, differential)
- ✅ Custom sensors (any 0-3.3V output)

### Smoke Detector Inputs (4 per hub/expander, 12V supervised)
Supports hardwired life-safety detectors:
- ✅ Ionization smoke detectors (fast flaming fires)
- ✅ Photoelectric smoke detectors (slow smoldering fires)
- ✅ Dual-sensor smoke detectors (ionization + photoelectric)
- ✅ Heat detectors (fixed-temperature, rate-of-rise)
- ✅ CO detectors (carbon monoxide, hardwired)
- ✅ Multi-sensor detectors (smoke + heat + CO)
- ✅ 2-wire or 4-wire configurations
- ✅ UL Listed compatible

### Pulse Counter Inputs (2 per hub/expander, up to 10 kHz)
Supports high-speed digital pulse devices:
- ✅ Walk-through metal detectors (pulse output)
- ✅ Perimeter beam sensors (pulse on break)
- ✅ Turnstile counters (people counting)
- ✅ Flow sensors (water, gas, liquid)
- ✅ Speed sensors (wheel rotation, conveyor belts)
- ✅ Custom pulse devices (3.3V or 5V logic)

### Relay Outputs (4 per hub/expander, SPDT 5A)
Can control any low-voltage device:
- ✅ Sirens (indoor, outdoor)
- ✅ Strobe lights (visual alarm)
- ✅ Door locks (electric strikes, maglocks)
- ✅ HVAC shutdown (fire alarm response)
- ✅ Exhaust fans (CO/gas alarm response)
- ✅ Lighting control (automated on/off)
- ✅ Water shutoff valves (leak detection)
- ✅ Custom actuators (up to 5A load)

---

## Key Interface Features

### 1. **Optoisolation**
- All zone inputs: 2.5kV optical isolation
- All relay outputs: 2.5kV optical isolation
- **Benefit:** Eliminates ground loops, protects MCU from external surges

### 2. **Supervised Circuits**
- Zone inputs: EOL resistor detection (normal/triggered/fault/cut)
- Smoke detectors: Supervised 12V loop (tamper/fault detection)
- **Benefit:** Detects wiring faults before they cause false alarms

### 3. **Signal Conditioning**
- RC filters: Remove RF noise (100kHz LPF)
- Schmitt triggers: Debounce digital inputs
- TVS diodes: ±15kV ESD protection on all external connections
- **Benefit:** Reliable operation in electrically noisy environments

### 4. **Flexible Power Options**
- Main hub: AC power (500W PSU) + UPS backup
- Expanders: 12V DC or PoE (802.3af)
- **Benefit:** Install expanders anywhere (PoE for remote locations)

### 5. **Scalable Architecture**
- RS-485 bus: Up to 1200m distance, 32 expanders max
- Daisy-chain topology: Easy installation (no star wiring)
- **Benefit:** Grow system as needed, no forklift upgrades

---

## Comparison: Guardian vs. Traditional Systems

### Guardian GH-1000 Main Hub
- **Total interfaces**: 87
- **Camera ports**: 24× PoE (built-in switch)
- **Sensor capacity**: 32 zones, 8 analog, 4 smoke
- **Storage**: NVMe + USB + SFP+ NAS
- **Expansion**: Modular (up to 1056 zones)
- **Open source**: ✅ Yes
- **Price**: $1,299

### Traditional DVR + Alarm Panel (Separate)
- **Total interfaces**: ~40 (separate boxes)
- **Camera ports**: 4-16 (separate PoE switch needed)
- **Sensor capacity**: 8-48 zones (fixed, no analog/smoke)
- **Storage**: Internal HDD only (limited)
- **Expansion**: Limited or none
- **Open source**: ❌ No (proprietary)
- **Price**: $800 (DVR) + $600 (alarm panel) + $300 (PoE switch) = **$1,700**

**Guardian wins:** More interfaces, integrated, expandable, cheaper.

---

## Installation Examples

### Example 1: Standard Home (Main Hub Only)
**Property:** 3-bedroom house, 2000 sq ft, suburban

**Configuration:**
- 12× 4K PoE cameras (exterior, entry points)
- 18× zone inputs (doors, windows, motion)
- 4× analog inputs (temperature sensors, garage CO)
- 4× smoke detectors (bedrooms, hallway, kitchen, garage)
- 2× relay outputs (siren, strobe)
- 1× 4TB USB HDD (30-day retention)

**Total used:** 43 interfaces (out of 87)  
**Remaining capacity:** 44 interfaces (50% for future expansion)  
**Cost:** $1,299 (hub) + $300 (HDD) + $2,400 (cameras @ $200 ea) = **$4,000**

---

### Example 2: Large Estate (Main Hub + 2 Expanders)
**Property:** 8,000 sq ft mansion, 5 acres, 3 buildings (main house, guest house, garage)

**Configuration:**
- 24× 4K PoE cameras (perimeter, buildings, driveway)
- 60× zone inputs (all doors, windows, PIR, perimeter beams)
- 12× analog inputs (temperature, humidity, propane tanks)
- 8× smoke detectors (distributed across all buildings)
- 4× pulse counters (driveway beam, gate sensor)
- 6× relay outputs (sirens, strobes, gate control)
- 2× 8TB USB HDDs (60-day retention)
- 10GbE SFP+ to NAS (5-year archival)

**Total used:** 120 interfaces (out of 191)  
**Remaining capacity:** 71 interfaces (37% for future)  
**Cost:** $1,299 (hub) + $240 (2× expanders) + $600 (HDDs) + $4,800 (cameras) + $2,000 (NAS) = **$8,939**

---

### Example 3: Small Business (Main Hub + 4 Expanders)
**Property:** Warehouse + office, 20,000 sq ft, 50 employees

**Configuration:**
- 24× 4K PoE cameras (warehouse, office, loading dock)
- 128× zone inputs (doors, windows, motion, metal detector at entrance)
- 20× analog inputs (temperature, humidity, CO in warehouse)
- 12× smoke detectors (warehouse, office, break room)
- 2× pulse counters (employee turnstile, loading dock counter)
- 8× relay outputs (sirens, strobes, HVAC shutdown, loading dock lights)
- 2× 10TB USB HDDs (90-day retention)
- 10GbE SFP+ to 50TB NAS (1-year archival)

**Total used:** 200 interfaces (out of 295)  
**Remaining capacity:** 95 interfaces (32% for future)  
**Cost:** $1,299 (hub) + $480 (4× expanders) + $800 (HDDs) + $4,800 (cameras) + $5,000 (NAS) = **$12,379**

---

## Wiring Requirements

### Camera Network (24 ports)
- **Cable**: Cat6 or better (PoE++)
- **Distance**: Up to 100m (328 ft) per camera
- **Topology**: Star (hub to each camera)
- **Total cable**: 24× 100m = 2,400m (7,874 ft) worst case

### Zone Inputs (32+ zones)
- **Cable**: 22 AWG twisted pair (alarm wire)
- **Distance**: Up to 300m (984 ft) per zone
- **Topology**: Star (hub to each sensor)
- **EOL resistor**: 5.6kΩ at sensor (supervised)

### RS-485 Expander Bus
- **Cable**: Cat5e twisted pair (one pair)
- **Distance**: Up to 1,200m (3,937 ft) total bus length
- **Topology**: Daisy-chain (hub → exp1 → exp2 → exp3...)
- **Termination**: 120Ω resistor at both ends

### Smoke Detectors (4+ zones)
- **Cable**: 18 AWG 2-conductor (power) + 22 AWG 2-conductor (alarm)
- **Distance**: Up to 100m (328 ft) per detector
- **Topology**: Star or loop (depending on detector type)
- **Power**: 12V @ 500mA per detector (max 50m for 18 AWG)

---

## Summary: Why This Interface Design Matters

### 1. **Integration**
One box does it all: cameras, sensors, storage, networking. No separate DVR + alarm panel + PoE switch.

### 2. **Scalability**
Start with 32 zones, grow to 1056 zones. Modular expansion via cheap GXP-32 modules.

### 3. **Flexibility**
Not just door contacts—supports analog sensors, smoke detectors, metal detectors, relays. Universal compatibility.

### 4. **Reliability**
Supervised circuits, optoisolation, signal conditioning, EMI/RFI protection. Life-safety rated.

### 5. **Cost-Effectiveness**
$1,299 for main hub (vs. $1,700+ for separate DVR + alarm + switch). Expanders are $120 each.

### 6. **Open Source**
Fully documented, user-modifiable, no vendor lock-in. Build your own expanders from $55 BOM.

---

**This is the most comprehensive, flexible, and cost-effective security system interface design on the market.**

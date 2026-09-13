# Guardian Access Control Expander — KiCad Project

**Product:** 8-output access control module with power distribution  
**KiCad version:** 8.x  
**Status:** 📋 Specification complete — schematic design next  

---

## Overview

This project contains the hardware design for the **Guardian Access Control Expander**, a professional-grade output control module for physical security devices including magnetic locks, electric strikes, solenoids, gate motors, and electronic locks.

## Key Features

### Outputs
- **4× Relay channels** (high-power, 10A SPDT)
  - For magnetic locks, strikes, gate motors, high-power solenoids
  - Configurable fail-safe (NO) or fail-secure (NC)
  - Flyback protection on all coils
  
- **4× Solid-state channels** (MOSFET, 5A continuous)
  - For electronic locks, low-power solenoids, door holders
  - PWM-capable for inrush limiting
  - Overcurrent protection

### Inputs
- **8× Door status inputs** (supervised like zone expander)
  - Detects: Closed / Open / Tamper
  - For magnetic door contacts, limit switches
  - TVS protection on all inputs

### Power
- **12-24V DC input** (auto-sensing or selectable)
- **Multi-rail distribution:**
  - 24V rail (for 24V mag locks, gate motors)
  - 12V rail (for 12V locks, strikes, solenoids)
  - 3.3V logic rail (MCU, Ethernet)

### Control
- **Ethernet connectivity** (W5500 + MagJack)
- **STM32G431 MCU** (same as zone expander)
- **GXP protocol** (Guardian eXpander Protocol)

## Use Cases

| Device Type | Output Channel | Power | Control Mode |
|-------------|----------------|-------|--------------|
| Magnetic Lock (12V) | Relay 1-4 | 12V @ 500mA | Latched, fail-secure |
| Magnetic Lock (24V) | Relay 1-4 | 24V @ 250mA | Latched, fail-secure |
| Electric Strike | Relay 1-4 | 12V @ 1.5A | Momentary, PWM hold |
| Solenoid Lock | Relay 1-4 | 12V @ 2A | Momentary |
| Electronic Lock | MOSFET 5-8 | 12V @ 500mA | Momentary, fast |
| Gate Motor (open) | Relay 1 | 24V @ 5A | Momentary, interlock |
| Gate Motor (close) | Relay 2 | 24V @ 5A | Momentary, interlock |
| Door Holder | MOSFET 5-8 | 12V @ 1A | Latched |

## Project Structure

```
access-control-expander/
├── access-control-expander.kicad_pro    # KiCad 8 project file
├── access-control-expander.kicad_sch    # Root schematic (hierarchical)
├── access-control-expander.kicad_pcb    # PCB layout
├── power.kicad_sch                      # Power supply sheet
├── mcu.kicad_sch                        # STM32G431 microcontroller
├── ethernet.kicad_sch                   # W5500 + MagJack
├── relay-outputs.kicad_sch              # 4 relay driver circuits
├── mosfet-outputs.kicad_sch             # 4 MOSFET driver circuits
├── door-inputs.kicad_sch                # 8 door status inputs
├── connectors.kicad_sch                 # Status LEDs, mounting
├── README.md                            # This file
└── schematics-pdf/                      # Exported diagrams (after design)
```

## Hierarchical Design

The schematic is organized into functional blocks:

1. **Root Sheet** — Block diagram showing all hierarchical sheets
2. **Power** — 12-24V input, buck converters (24V, 12V, 3.3V rails)
3. **MCU** — STM32G431CBT6 with crystal, decoupling, SWD, reset
4. **Ethernet** — W5500 SPI controller + RJ45 MagJack
5. **Relay Outputs** — 4 channels with NPN drivers, flyback diodes
6. **MOSFET Outputs** — 4 channels with gate drivers, PWM support
7. **Door Inputs** — 8 supervised inputs with TVS protection
8. **Connectors** — Status LEDs, mounting holes, debug headers

## Design Status

| Task | Status |
|------|--------|
| Hardware specification | ✅ Complete |
| Schematic design | ⏳ Next |
| PCB layout | ⏳ Pending |
| BOM generation | ⏳ Pending |
| Firmware architecture | ⏳ Pending |
| Hub integration | ⏳ Pending |

## Technical Specifications

- **MCU:** STM32G431CBT6 (Cortex-M4F @ 170 MHz, 48-pin LQFP)
- **Ethernet:** W5500 100BASE-TX, hardwired TCP/IP
- **Power Input:** 12-24V DC, 5-10A
- **Output Power:**
  - 24V rail: Up to 5A (120W)
  - 12V rail: Up to 5A (60W)
  - 3.3V logic: 500mA (2W)
- **Relay Specs:** SPDT, 10A @ 250VAC / 30VDC
- **MOSFET Specs:** N-channel, 5A continuous, 10A peak
- **PCB:** 4-layer, ~150mm × 100mm, ENIG finish
- **Connectors:**
  - 17× Screw terminals (power, outputs, inputs)
  - 1× RJ45 MagJack (Ethernet)
  - 1× SWD header (programming)
  - 1× UART header (debug)

## Safety Features

- **Fail-safe/fail-secure modes** per output (configurable)
- **Emergency unlock** (fire alarm integration)
- **Forced entry detection** (door opened without unlock command)
- **Door held open alarm** (timeout monitoring)
- **Overcurrent protection** (fuses, polyfuses)
- **Reverse polarity protection** (input)
- **TVS diodes** (all I/O)
- **Watchdog timer** (firmware hang recovery)

## Integration with Guardian Hub

### Access Control Flow

1. User authenticates (keypad, NFC, mobile app)
2. Hub validates credentials and schedule
3. Hub sends `UNLOCK_OUTPUT` command to expander
4. Expander activates relay/MOSFET for configured duration
5. Expander monitors door status input
6. If door opens: Log "access granted"
7. If door opens WITHOUT unlock: Trigger `FORCED_ENTRY` event
8. Hub receives forced entry → activates zone alarm

### Emergency Unlock

1. Fire alarm detected by zone expander
2. Hub confirms fire alarm
3. Hub sends `EMERGENCY_UNLOCK` to all access control expanders
4. All fail-safe doors unlock immediately
5. Fail-secure doors remain locked (unless explicitly overridden)

## Development Roadmap

### Phase 1: Schematic Design ⏳
- Create hierarchical KiCad 8 schematic
- Power supply design (12V, 24V, 3.3V rails)
- MCU circuit (STM32G431)
- Ethernet circuit (W5500 + MagJack)
- Relay driver circuits (×4)
- MOSFET driver circuits (×4)
- Door status input circuits (×8)
- Protection circuits (TVS, flyback, fuses)
- Connectors and status LEDs

### Phase 2: PCB Layout
- Component placement
- Power plane routing
- High-current trace routing
- Signal routing
- DRC verification
- Generate Gerbers + BOM

### Phase 3: Firmware Development
- W5500 driver (SPI Ethernet)
- GXP protocol client
- Output control (relay, MOSFET, PWM)
- Door status monitoring
- Forced entry detection
- Configuration storage

### Phase 4: Hub Integration
- `guardian-access` service (Zig)
- User authentication flow
- Schedule-based unlocking
- Mobile app integration

## Documentation

- **[Hardware Specification](../../docs/hardware/ACCESS_CONTROL_EXPANDER.md)** — Complete design specification
- **[Zone Expander](../zone-expander/README.md)** — Companion alarm input module
- **[System Architecture](../zone-expander/SYSTEM_ARCHITECTURE.md)** — Reference for similar design patterns

## Next Steps

1. Create hierarchical schematic in KiCad 8
2. Design power supply circuit (12V/24V/3.3V rails)
3. Design MCU and Ethernet circuits (reuse from zone expander)
4. Design relay driver circuits with flyback protection
5. Design MOSFET driver circuits with PWM support
6. Design door status input circuits (supervised, like zones)
7. Export schematics to PDF/SVG
8. Proceed to PCB layout

---

**Ready for schematic design.** 🔧

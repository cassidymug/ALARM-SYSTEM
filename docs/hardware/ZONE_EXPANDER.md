# Guardian — Zone Expander Hardware Specification

**Product:** 32-zone supervised wired alarm expander  
**Owner:** Cassidy Mugadza  
**Target:** Ethernet-connected zone input module for Guardian Hub  
**Status:** Hardware design phase — KiCad schematic in progress  

---

## 1. Overview

The **Guardian Zone Expander** is a purpose-built 32-zone supervised wired alarm input module that connects to the Guardian Hub via Ethernet. It provides professional-grade alarm panel zone monitoring without proprietary cloud dependencies.

### Key specifications

- **32 supervised zones** with 4.7 kΩ end-of-line (EOL) resistors
- **Zone layout:** 4 banks of 8 zones each
- **Outputs:** 1 siren driver + minimum 2 dry-contact relays (Form C)
- **Connectivity:** Ethernet only (no wireless modules)
- **MCU:** STM32G0 or STM32G4 class (ARM Cortex-M)
- **Power:** 12 V DC barrel jack input
- **PCB target:** PCBWay fabrication (~5 units, prefer 4-layer ENIG)
- **Default behavior:** Silent on link loss (no false alarms if network drops)

---

## 2. Functional blocks

### 2.1 Zone inputs (32× supervised)

Each zone channel implements a supervised end-of-line circuit:

- **EOL resistor:** 4.7 kΩ at sensor far end
- **States detected:**
  - **Normal** — loop closed through EOL (≈4.7 kΩ measured)
  - **Alarm** — loop short (≈0 Ω)
  - **Tamper** — loop open (∞ Ω / no EOL)
  - **Fault** — wrong resistance or intermittent
- **Zone front-end per channel:**
  - Voltage divider with reference resistor
  - TVS diode + PTC for protection
  - ADC read via MCU or analog mux
  - Pull-up to safe voltage (3.3 V or 5 V depending on design)
- **Layout:** 4 banks of 8 zones; each bank shares protection and may optionally share one 8:1 analog mux (or direct ADC if MCU has sufficient channels)

### 2.2 MCU & firmware

- **MCU family:** STM32G0 (e.g. STM32G071) or STM32G4 (e.g. STM32G431)
  - Sufficient GPIO + ADC channels for 32 zones (muxed or direct)
  - Hardware CRC, timers for zone scan rate
  - UART for debugging, SWD for programming
- **Firmware:** Bare-metal or FreeRTOS; Guardian zone protocol over Ethernet
- **Protocol:** JSON-over-TCP or binary framing to `guardian-sensors` service
- **Behavior on link loss:** Default **silent** (no siren trigger); reports offline to hub when link restored

### 2.3 Ethernet

- **PHY/Controller:** W5500 (SPI Ethernet controller with integrated MAC/PHY) or discrete PHY + STM32 MAC
  - W5500 preferred for simplicity (SPI to MCU, magnetics/RJ45 MagJack module)
- **Connector:** RJ45 with integrated magnetics (MagJack) or separate transformer module
- **ESD protection:** TVS diodes on Ethernet lines
- **PoE:** Not required for MVP; 12 V barrel power mandatory

### 2.4 Power supply

- **Input:** 12 V DC barrel jack (center positive, 2.1 mm or 2.5 mm standard)
- **Input protection:** Reverse polarity protection (P-channel MOSFET or diode), fuse (e.g. 2 A)
- **Regulation:** Buck converter 12 V → 3.3 V (MCU + Ethernet)
  - Suggested: TPS54331 or similar ≥1 A buck
- **Aux rail (optional):** 12 V direct to siren output; 5 V rail if needed for relays/LEDs
- **Decoupling:** Bulk + ceramic caps per rail; low-ESR ceramics near MCU/W5500

### 2.5 Siren output

- **Driver:** N-channel MOSFET (logic-level gate) or equivalent, driving 12 V siren load
- **Load:** Up to 2 A sustained (typical piezo siren ≤500 mA; design margin 2 A)
- **Protection:** Flyback diode across inductive loads; optional fuse or current limit
- **Control:** MCU GPIO with PWM capability (for pulsed/modulated tones if desired)
- **Output connector:** Screw terminal (12V_SIREN, GND)

### 2.6 Relays

- **Quantity:** Minimum 2 (can expand to 4 if board space allows)
- **Type:** SPDT / Form C dry-contact relays
- **Ratings:** 5 A @ 250 VAC / 30 VDC typical (or 10 A if space permits)
- **Driver:** MCU GPIO → NPN transistor or relay driver IC → relay coil
- **Protection:** Flyback diode per coil
- **Use cases:** Siren enable, strobe, door strike, aux notification
- **Output connectors:** Screw terminals (NO, COM, NC per relay)

### 2.7 Status & debug

- **LEDs:**
  - Power (3.3 V rail active)
  - Link/activity (Ethernet connected)
  - Status (MCU heartbeat / fault)
  - Optional: per-zone LEDs if board space allows (32 is tight; consider bank indicators instead)
- **Programming/debug:**
  - **SWD header** (SWDIO, SWCLK, GND, 3.3V, optional NRST) — 1.27 mm or 2.54 mm pitch
  - **UART header** for debug console (TX, RX, GND)
- **Buttons:**
  - Reset button (NRST pull-down)
  - Optional: user button for test/enroll mode

### 2.8 Connectors & terminals

- **Zone inputs:** Screw terminal blocks, 2-position per zone (32 zones → 16× 4-position blocks or 8× 8-position)
  - Label silk: ZONE1+/−, ZONE2+/−, … ZONE32+/−
- **Siren:** 2-position screw terminal (12V_SIREN, GND)
- **Relays:** 3-position per relay (NO, COM, NC)
- **Power:** 2.1 mm or 2.5 mm barrel jack
- **Ethernet:** RJ45 MagJack
- **Headers:** 2.54 mm for SWD, UART

---

## 3. Schematic hierarchy (KiCad)

Root schematic with hierarchical sheets:

1. **Power** — 12 V input, reverse protection, fuse, buck converter (12V→3.3V), decoupling
2. **MCU** — STM32G0/G4, crystal, reset, SWD header, UART header, decoupling, boot config
3. **Ethernet** — W5500 (or PHY), SPI connections to MCU, magnetics/MagJack, TVS, decoupling
4. **ZoneBank1** — 8 zone channels with EOL resistors, voltage dividers, TVS/PTC, ADC mux (replicate ×4)
5. **ZoneBank2** — (instantiate ZoneBank sheet or copy)
6. **ZoneBank3** — (instantiate ZoneBank sheet or copy)
7. **ZoneBank4** — (instantiate ZoneBank sheet or copy)
8. **Outputs** — Siren MOSFET driver, relay drivers (×2 minimum), flyback diodes, screw terminals
9. **Connectors** — Zone terminal blocks, power jack, Ethernet jack, status LEDs, buttons

---

## 4. Zone front-end circuit (per channel)

**Supervised EOL topology (one of 32 identical channels):**

```
Sensor loop:  [ZONE+] ──── Sensor Contact ──── 4.7kΩ EOL ──── [ZONE−/GND]
                 │                                                │
                 ├─ 10kΩ pull-up to 3.3V (or 5V)                │
                 ├─ TVS diode to GND                             │
                 └─ Voltage divider to ADC ────────────────> MCU_ADCx
```

**Component notes per zone:**
- **Pull-up resistor:** 10 kΩ (or calculated for voltage divider)
- **EOL resistor:** 4.7 kΩ (supplied by installer, placed at sensor far end)
- **TVS diode:** Bidirectional TVS (e.g. SMAJ5.0CA) for ESD/transient protection
- **PTC fuse (optional per bank):** 100–200 mA polyfuse shared by 8 zones
- **ADC:** 12-bit MCU ADC or external ADC (ADS1115 if more channels needed)

**Resistance thresholds (example with 10kΩ pull-up, 4.7kΩ EOL):**
- **Normal:** ≈4.7 kΩ → divider ≈1.6 V (tune per design)
- **Short:** ≈0 Ω → ≈0 V
- **Open:** ∞ Ω → ≈3.3 V (pull-up)
- **Tamper/Fault:** Intermediate voltages or rapid fluctuation

---

## 5. PCB specifications

### 5.1 Layer stackup

**4-layer preferred** (for noise isolation and manufacturability):
1. **Top** — signals, components
2. **GND** — solid ground plane
3. **PWR** — 3.3 V / 12 V pours
4. **Bottom** — signals, components

**2-layer fallback** — acceptable if cost-critical; requires careful ground/power routing

### 5.2 Fabrication target

- **Vendor:** PCBWay (or equivalent)
- **Quantity:** ~5 prototypes initially
- **Finish:** ENIG (Electroless Nickel Immersion Gold) preferred for reliability
- **Copper weight:** 1 oz (2 oz on power layers optional)
- **Solder mask:** Green (or house standard)
- **Silkscreen:** White, clear zone labels, polarity marks
- **Board size:** TBD based on terminal block layout (estimate 150 mm × 200 mm or larger for 32 zones)

### 5.3 Design rules

- **Trace width:** Minimum 0.15 mm (6 mil) for signals; 0.3–0.5 mm for power traces
- **Clearance:** Minimum 0.15 mm (6 mil)
- **Via size:** 0.3 mm drill, 0.6 mm pad typical
- **Thermal relief:** For ground pours on large pads (terminal blocks, connectors)
- **Keepout:** 2 mm edge clearance for board outline, mounting holes

---

## 6. Bill of materials (preliminary)

See `hardware/zone-expander/bom/preliminary_bom.csv` for detailed BOM with reference designators.

**Major components (quantities approximate):**

| Component | Qty | Description | Example part |
|-----------|-----|-------------|--------------|
| MCU | 1 | STM32G071CBT6 or STM32G431CBT6 | STM32G071CBT6 (LQFP-48) |
| Crystal | 1 | 8 MHz or 12 MHz HSE crystal | ABM3B-8.000MHZ-B2-T |
| W5500 | 1 | Ethernet controller (SPI) | W5500 (LQFP-48) |
| MagJack | 1 | RJ45 with magnetics | Hanrun HR911105A or similar |
| Buck converter IC | 1 | 12V→3.3V, ≥1A | TPS54331DR |
| Inductor (buck) | 1 | 22 µH, ≥1.5 A | IHLP2525CZER220M11 |
| Barrel jack | 1 | 2.1 mm or 2.5 mm DC jack | PJ-202A or similar |
| P-channel MOSFET (reverse protection) | 1 | -20V, -5A typical | IRF9540N or AO3401 |
| Fuse | 1 | 2 A slow-blow, through-hole or SMD holder | 0229002.MXP or equivalent |
| TVS diodes (zone protection) | 32+ | Bidirectional, 5 V or 6 V | SMAJ5.0CA (per zone or per bank) |
| PTC fuses (zone banks) | 4–8 | 100–200 mA polyfuse | MF-R090 or per bank |
| Resistors 10 kΩ (pull-up) | 32 | 0805 or 0603, 1% | Standard thick-film |
| Resistors 4.7 kΩ (EOL, user-supplied) | 32 | ¼ W through-hole, installer provides | Not on PCB BOM |
| N-channel MOSFET (siren) | 1 | Logic-level, ≥2 A | IRLZ44N or AO3400 |
| Relays | 2–4 | SPDT, 5A @ 250VAC | Omron G5V-2 or HFD2/005-S |
| Relay driver transistors/IC | 2–4 | NPN (2N2222) or ULN2003 | 2N2222 or ULN2003A |
| Flyback diodes | 3–6 | 1A, fast recovery (relays + siren) | 1N4148 or 1N5819 |
| Screw terminals (zone) | 16–32 | 2-pos or 4-pos, 3.5mm or 5mm pitch | Phoenix 1757242 or similar |
| Screw terminals (outputs) | 3 | 2-pos (siren) + 3-pos per relay | Phoenix or equivalent |
| LEDs (status) | 3–6 | 0805 or 3mm THT (Power, Link, Status) | Standard red/green/yellow |
| Resistors (LED current limit) | 3–6 | 330 Ω or 470 Ω, 0805 | Standard |
| Capacitors (decoupling) | 20–40 | 100nF ceramic (0805), 10µF ceramic/tant per rail | X7R or X5R |
| Capacitors (bulk) | 2–4 | 100µF or 220µF electrolytic (input, 3.3V rail) | Panasonic FR series |
| SWD header | 1 | 2×5 pin, 1.27mm or 2.54mm pitch | Tag-Connect TC2050 or pin header |
| UART header | 1 | 1×3 pin, 2.54mm pitch | Standard pin header |
| Reset button | 1 | Tactile switch, SPST | 6mm tactile switch |

**Note:** Quantities exclude passives for decoupling (capacitors ×50+, resistors varied). Full BOM generated after schematic is complete.

---

## 7. Firmware protocol (stub)

Communication between zone expander and `guardian-sensors` service on the hub:

### 7.1 Transport

- **TCP socket** to hub IP (configured via DHCP or static; hub discovery via mDNS/Avahi optional)
- **Port:** TBD (e.g. 5000 or service-specific port)
- **Fallback:** UDP broadcast for announce/discovery if TCP is unavailable

### 7.2 Message format (JSON over TCP, newline-delimited)

**Zone status report (expander → hub):**

```json
{
  "type": "zone_status",
  "timestamp": 1694620800,
  "zones": [
    {"id": 1, "state": "normal", "raw_adc": 512},
    {"id": 2, "state": "alarm", "raw_adc": 10},
    {"id": 3, "state": "tamper", "raw_adc": 1020},
    ...
    {"id": 32, "state": "normal", "raw_adc": 515}
  ]
}
```

**Command (hub → expander):**

```json
{
  "type": "set_output",
  "siren": true,
  "relay1": false,
  "relay2": true
}
```

**Heartbeat (expander → hub, every 10s):**

```json
{
  "type": "heartbeat",
  "uptime": 12345,
  "link_quality": "good"
}
```

### 7.3 Default behavior on link loss

- **Siren:** Remain **silent** (no autonomous siren trigger; prevents false alarms on network drops)
- **Relays:** Hold last commanded state or failsafe open (configurable per relay)
- **Status LED:** Blink "no link" pattern
- **Resume:** Reconnect on link restore; send full zone status snapshot

---

## 8. Manufacturing & assembly notes

### 8.1 PCBWay export checklist

1. **Gerbers** — RS-274X format, one file per layer (GTL, GBL, G1, G2, GTO, GBO, GTS, GBS, Edge.Cuts)
2. **Drill files** — Excellon format, PTH + NPTH combined or separate
3. **BOM** — CSV with reference designators, values, footprints, quantities, manufacturer part numbers
4. **CPL (Centroid/Pick-and-place)** — CSV with X/Y coordinates, rotation, side (for SMT assembly)
5. **README** — Layer stackup, board thickness (1.6 mm standard), copper weight, finish (ENIG)

### 8.2 Assembly strategy

- **Prototype batch (5 pcs):** Hand-solder or PCBWay SMT assembly for MCU/W5500/passives; hand-place terminal blocks and through-hole connectors
- **Production (if scaled):** Full SMT + wave/selective solder for through-hole

---

## 9. Testing & bring-up

### 9.1 Bench tests (pre-integration)

1. **Power-on:** Verify 12 V input, 3.3 V rail, no smoke
2. **MCU boot:** SWD programming, LED blink firmware, UART console
3. **Ethernet link:** Plug into switch; verify link LED, ping response
4. **Zone loopback:** Install 4.7 kΩ resistor on Zone 1; verify "normal" ADC reading via console
5. **Siren output:** Command siren GPIO high; measure 12 V on terminal with DMM
6. **Relay:** Command relay 1 close; verify continuity NO→COM with multimeter

### 9.2 Integration with Guardian Hub

1. **Discovery:** Expander announces presence on network; `guardian-sensors` detects
2. **Zone mapping:** Configure zone 1-32 names, types (perimeter/interior/24h) in hub UI
3. **Alarm test:** Trigger Zone 1 (short resistor); verify hub sees "alarm" state; trigger siren via hub
4. **Link loss:** Disconnect Ethernet; verify expander does not trigger siren; reconnect; verify status restore

---

## 10. Design files location

**Repository path:** [`hardware/zone-expander/`](../../hardware/zone-expander/)

```
hardware/zone-expander/
├── zone-expander.kicad_pro          # KiCad 8 project file
├── zone-expander.kicad_sch          # Root schematic (hierarchical sheets)
├── zone-expander.kicad_pcb          # PCB layout (placeholder/in-progress)
├── fp-lib-table                     # Footprint library table (project-local if needed)
├── sym-lib-table                    # Symbol library table (project-local if needed)
├── README.md                        # How to open, sheet map, export checklist
├── SYMBOLS.md                       # Schematic symbols list with KiCad library references
├── .gitignore                       # Ignore KiCad backups, lock files
├── bom/
│   └── preliminary_bom.csv          # BOM with reference designators (grouped by bank)
└── gerbers/                         # (Generated) Gerber + drill files for PCBWay
```

**👉 KiCad project:** [`hardware/zone-expander/`](../../hardware/zone-expander/)  
**👉 Setup instructions:** [`hardware/zone-expander/README.md`](../../hardware/zone-expander/README.md)  
**👉 Component symbols:** [`hardware/zone-expander/SYMBOLS.md`](../../hardware/zone-expander/SYMBOLS.md)

---

## 11. Next steps

1. ✅ **KiCad project skeleton created** (root schematic, hierarchical sheet placeholders)
2. ⏳ **Draw zone front-end channel** (1 of 32) with EOL resistor, TVS, ADC, reusable subcircuit
3. ⏳ **Replicate zone channels** across 4 banks (8 zones × 4 banks = 32 total)
4. ⏳ **Complete power, MCU, Ethernet, outputs sheets**
5. ⏳ **Assign footprints** (terminal blocks, MCU, W5500, passives, connectors)
6. ⏳ **PCB layout** (4-layer, place terminal blocks, route zone banks, pour ground/power planes)
7. ⏳ **DRC + ERC checks**
8. ⏳ **Generate Gerbers, BOM, CPL** for PCBWay quote
9. ⏳ **Order prototype batch** (~5 pcs)
10. ⏳ **Firmware skeleton** (STM32 HAL + W5500 driver, zone scan loop, TCP client)

---

*Guardian Zone Expander — Supervised 32-zone wired alarm input module for Ethernet integration with Guardian Hub. No wireless, no cloud lock-in, professional-grade zone monitoring.*

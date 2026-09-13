# Guardian Zone Expander — KiCad Project

**Product:** 32-zone supervised wired alarm input module  
**KiCad version:** 8.x  
**Status:** Schematic skeleton complete; layout in progress  

---

## Quick Start

### Opening the Project

1. **Install KiCad 8.x** (or later) from [kicad.org](https://www.kicad.org/)
2. Clone the Guardian repository:
   ```bash
   git clone https://github.com/cassidymug/ALARM-SYSTEM.git
   cd ALARM-SYSTEM/hardware/zone-expander
   ```
3. **Open in KiCad:**
   - Launch KiCad
   - File → Open Project → Select `zone-expander.kicad_pro`
4. **Schematic Editor:** Double-click `zone-expander.kicad_sch` in project tree
5. **PCB Editor:** Double-click `zone-expander.kicad_pcb` in project tree (layout pending schematic completion)

---

## Project Structure

```
hardware/zone-expander/
├── zone-expander.kicad_pro     # KiCad 8 project file
├── zone-expander.kicad_sch     # Root schematic (hierarchical sheets)
├── zone-expander.kicad_pcb     # PCB layout (4-layer, placeholder)
├── README.md                   # This file
├── SYMBOLS.md                  # Detailed component/symbol list
├── .gitignore                  # KiCad backup/cache exclusions
├── bom/
│   └── preliminary_bom.csv     # BOM with ref designators (generated from schematic)
├── gerbers/                    # (Generated) Gerber + drill files for PCBWay
│   └── README.md               # Gerber export checklist
└── (future) fp-lib-table       # Footprint library table (if project-local libs added)
└── (future) sym-lib-table      # Symbol library table (if project-local libs added)
```

### Related Documentation

- **Hardware specification:** [`docs/hardware/ZONE_EXPANDER.md`](../../docs/hardware/ZONE_EXPANDER.md) — Authoritative design document
- **Symbols list:** [`SYMBOLS.md`](SYMBOLS.md) — Every component with KiCad symbol references, footprints, quantities

---

## Schematic Hierarchy (Hierarchical Sheets)

**Root sheet:** `zone-expander.kicad_sch` — Top-level sheet with hierarchical block diagram

**Hierarchical sheets** (referenced from root; individual `.kicad_sch` files to be created):

1. **Power** (`power.kicad_sch`) — 12V barrel jack, reverse protection, fuse, buck converter (12V→3.3V), decoupling
2. **MCU** (`mcu.kicad_sch`) — STM32G0/G4, crystal, reset, SWD header, UART debug, decoupling, boot config
3. **Ethernet** (`ethernet.kicad_sch`) — W5500 SPI Ethernet controller, MagJack (RJ45 + magnetics), TVS, link/activity LEDs
4. **ZoneBank1** (`zonebank.kicad_sch`, instance 1) — Zones 1-8: EOL resistors, voltage dividers, TVS/PTC, terminal blocks
5. **ZoneBank2** (`zonebank.kicad_sch`, instance 2) — Zones 9-16 (same sheet, replicated)
6. **ZoneBank3** (`zonebank.kicad_sch`, instance 3) — Zones 17-24
7. **ZoneBank4** (`zonebank.kicad_sch`, instance 4) — Zones 25-32
8. **Outputs** (`outputs.kicad_sch`) — Siren MOSFET driver, relay drivers (×2-4), flyback diodes, screw terminals
9. **Connectors & Status** (`connectors.kicad_sch`) — Power/Link/Status LEDs, reset/user buttons, mounting holes, test points

**Note:** Zone bank sheets can be a single reusable hierarchical sheet instantiated 4 times, or 4 separate copies. KiCad 8 supports multi-instance hierarchical sheets with unique reference designators per instance.

---

## PCB Specifications

### Layer Stackup (4-layer preferred)

| Layer | Type | Purpose |
|-------|------|---------|
| **F.Cu** (Top) | Signal | Components, signals, zone terminals |
| **In1.Cu** | Ground plane | Solid GND pour (minimize slots) |
| **In2.Cu** | Power plane | +3.3V and +12V pours with appropriate clearance |
| **B.Cu** (Bottom) | Signal | Components, signals, return paths |

**2-layer fallback:** Acceptable if cost-critical; requires careful ground/power routing with stitching vias.

### PCB Parameters

- **Board thickness:** 1.6 mm (standard)
- **Copper weight:** 1 oz (35 µm) on all layers; optional 2 oz on power layers if high current
- **Finish:** ENIG (Electroless Nickel Immersion Gold) preferred for reliability and shelf life
- **Solder mask:** Green (or house standard)
- **Silkscreen:** White, both sides; clear zone labels (ZONE1+/−, etc.), polarity marks, ref designators
- **Min trace/space:** 0.15 mm (6 mil) for signals; 0.3-0.5 mm for power traces
- **Min drill:** 0.3 mm (0.0118")
- **Via size:** 0.3 mm drill, 0.6 mm pad typical

### Design Rules Summary

| Rule | Value |
|------|-------|
| Min clearance | 0.15 mm (6 mil) |
| Min track width | 0.15 mm (6 mil) signal; 0.3-0.5 mm power |
| Min via diameter | 0.4 mm |
| Min via annular ring | 0.1 mm |
| Min hole-to-hole | 0.25 mm |
| Edge clearance | 2.0 mm (components and traces) |

**See KiCad project settings** (File → Board Setup → Design Rules) for full configuration.

---

## PCBWay Export Checklist

When schematic and PCB layout are complete, export the following for PCBWay fabrication quote:

### 1. Gerber Files (RS-274X format)

Generate from PCB Editor: File → Fabrication Outputs → Gerbers (.gbr)

**Required layers:**
- `zone-expander-F.Cu.gbr` — Top copper
- `zone-expander-In1.Cu.gbr` — Inner layer 1 (GND plane)
- `zone-expander-In2.Cu.gbr` — Inner layer 2 (Power plane)
- `zone-expander-B.Cu.gbr` — Bottom copper
- `zone-expander-F.SilkS.gbr` — Top silkscreen
- `zone-expander-B.SilkS.gbr` — Bottom silkscreen
- `zone-expander-F.Mask.gbr` — Top solder mask
- `zone-expander-B.Mask.gbr` — Bottom solder mask
- `zone-expander-F.Paste.gbr` — Top solder paste (for stencil, if SMT assembly)
- `zone-expander-B.Paste.gbr` — Bottom solder paste
- `zone-expander-Edge.Cuts.gbr` — Board outline

**Optional:**
- `zone-expander-F.Fab.gbr` — Top fabrication layer (assembly drawing)
- `zone-expander-B.Fab.gbr` — Bottom fabrication layer

### 2. Drill Files (Excellon format)

Generate from PCB Editor: File → Fabrication Outputs → Drill Files (.drl)

**Required:**
- `zone-expander-PTH.drl` — Plated through-holes (vias, component leads)
- `zone-expander-NPTH.drl` — Non-plated through-holes (mounting holes, tooling holes)

**Or combined:** `zone-expander.drl` (if PTH/NPTH merged; check PCBWay preference)

### 3. Bill of Materials (BOM)

Generate from Schematic Editor: Tools → Generate BOM → Export CSV

**Required columns:**
- Reference Designator (e.g. R1, C10, U2)
- Quantity
- Value (e.g. 10kΩ, 100nF, STM32G071CBT6)
- Footprint
- Manufacturer Part Number (MPN) — if known
- Description

**Save as:** `bom/zone-expander_bom.csv`

**Note:** Separate SMT and through-hole components if requesting partial assembly.

### 4. Centroid / Pick-and-Place (CPL)

Generate from PCB Editor: File → Fabrication Outputs → Component Placement (.pos or .csv)

**Required columns:**
- Designator
- X position (mm)
- Y position (mm)
- Rotation (degrees)
- Side (Top/Bottom)
- Part (value or MPN)

**Save as:** `bom/zone-expander_cpl.csv`

**Note:** KiCad native format is `.pos` (ASCII); convert to CSV if needed for PCBWay format.

### 5. README for Fabricator

Create `gerbers/README.md` with:
- Board name: Guardian Zone Expander v0.1
- Layer stackup: 4-layer (F.Cu / GND / +3V3+12V / B.Cu)
- Board thickness: 1.6 mm
- Copper weight: 1 oz (or 2 oz if specified)
- Finish: ENIG
- Min trace/space: 0.15 mm / 0.15 mm
- Solder mask color: Green (or specify)
- Silkscreen color: White
- Quantity: ~5 prototypes

### 6. Compress and Upload

Zip all Gerbers + drill files into `zone-expander-gerbers-v0.1.zip` and upload to PCBWay instant quote page.

Attach BOM and CPL if requesting assembly.

---

## BOM Generation

**From schematic:**
1. Open `zone-expander.kicad_sch` in Schematic Editor
2. Tools → Generate BOM
3. Select BOM plugin (default Python script or custom)
4. Export to `bom/preliminary_bom.csv`
5. Review and add manufacturer part numbers (MPNs) and vendor links

**Preliminary BOM** already created in `bom/preliminary_bom.csv` with reference designator placeholders grouped by bank. Update after schematic annotation and footprint assignment.

---

## Testing & Bring-Up Plan

See [`docs/hardware/ZONE_EXPANDER.md`](../../docs/hardware/ZONE_EXPANDER.md) § 9 for detailed testing procedure.

**Summary:**
1. **Visual inspection** — solder bridges, component polarity, paste coverage (if SMT)
2. **Power-on test** — Measure 12V input, 3.3V rail; no smoke
3. **MCU programming** — Flash blink firmware via SWD; verify UART console
4. **Ethernet link** — Plug into switch; verify link LED, ping response
5. **Zone loopback** — Install 4.7kΩ resistor on Zone 1; verify "normal" ADC reading
6. **Siren output** — Command siren GPIO high; measure 12V on terminal
7. **Relay test** — Command relay 1 close; verify continuity NO→COM

---

## Known Issues / TODO

- [ ] Complete hierarchical sheet schematics (power, mcu, ethernet, zonebank, outputs, connectors)
- [ ] Draw detailed zone front-end circuit (1 of 32 channels) with EOL sensing
- [ ] Annotate reference designators (Tools → Annotate Schematic)
- [ ] Assign footprints to all components (Tools → Assign Footprints)
- [ ] Run ERC (Inspect → Electrical Rules Checker) and resolve warnings
- [ ] PCB layout: component placement, routing, power plane pours
- [ ] Run DRC (Inspect → Design Rules Checker) and resolve violations
- [ ] Generate final BOM with MPNs
- [ ] Export Gerbers and request PCBWay quote

---

## Design Notes

### Zone Front-End Circuit (per channel)

**Topology:**

```
Sensor Loop:  [ZONE+] ──── Sensor Contact ──── 4.7kΩ EOL ──── [ZONE−/GND]
                 │
                 ├─ 10kΩ pull-up to +3.3V
                 ├─ TVS diode to GND (SMAJ5.0CA or similar)
                 └─ Voltage divider to MCU ADC input
```

**EOL States:**
- **Normal:** Loop closed through 4.7kΩ → ADC reads ≈1.6V (tune per divider)
- **Alarm:** Loop short (0Ω) → ADC reads ≈0V
- **Tamper:** Loop open (∞Ω) → ADC reads ≈3.3V (pull-up)
- **Fault:** Intermittent or wrong resistance → intermediate voltage

**Protection:**
- TVS diode: Clamps transients from long cable runs (lightning, ESD)
- Optional PTC fuse: Shared per bank (e.g. 100-200mA) to limit current in fault conditions

### Analog Multiplexing (if used)

If MCU has insufficient ADC channels for 32 zones:
- Use 4× **CD74HC4051** (8:1 analog mux, one per bank) or
- Use 2× **CD74HC4067** (16:1 analog mux, for 16 zones each)

**Trade-off:** Adds scan time (sequentially read zones); increases BOM cost. Direct ADC preferred if STM32G4 or sufficient GPIO.

### Power Budget (preliminary)

| Component | Current (mA) | Notes |
|-----------|--------------|-------|
| STM32G0/G4 @ 64 MHz | 20-40 | Typ active mode |
| W5500 | 130-160 | Active Ethernet link |
| Zone banks (pull-ups) | ~10 | 32× 10kΩ pull-ups ≈ 10mA total at 3.3V |
| LEDs (3-6) | 20-60 | 3.3V LEDs at 5-10mA each |
| Relays (coils) | 50-100 ea | If 5V coils; 12V coils ≈20-40mA |
| **Total 3.3V rail** | 200-300 | Margin for transients |
| Siren (12V) | 500-2000 | Peak if siren active; not continuous |

**Buck converter sizing:** 1A at 3.3V provides ample margin (≈3.3W); 2A for future expansion or higher LED count.

---

## License & Contribution

This hardware design is part of the **Guardian DIY Alarm System** project.

**License:** TBD (awaiting project-wide license decision; likely open-source hardware compatible)

**Contributions:**
- Hardware design questions → GitHub Issues
- Schematic/layout improvements → Pull requests to `main` branch
- BOM optimization, footprint corrections, DRC fixes all welcome

---

## Support & Contact

**Owner:** Cassidy Mugadza  
**Repository:** [github.com/cassidymug/ALARM-SYSTEM](https://github.com/cassidymug/ALARM-SYSTEM)  
**Documentation:** See [`docs/hardware/ZONE_EXPANDER.md`](../../docs/hardware/ZONE_EXPANDER.md) for full hardware specification  

For hardware-specific questions, open an issue with the `hardware` label.

---

*Guardian Zone Expander — Professional-grade 32-zone supervised wired alarm input module. Ethernet-connected, STM32-based, no wireless, no cloud lock-in.*

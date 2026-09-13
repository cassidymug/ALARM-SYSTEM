# Guardian Zone Expander — PCB Layout Guide

**Target:** 4-layer PCB via PCBWay  
**KiCad Version:** 8.x  
**Board Dimensions:** ~150mm × 100mm (adjust based on component placement)  
**Status:** Schematic complete, ready for layout

---

## Pre-Layout Checklist

### 1. Open Project in KiCad 8
```bash
# Navigate to project directory
cd hardware/zone-expander/

# Open in KiCad
kicad zone-expander.kicad_pro
```

### 2. Run ERC (Electrical Rules Checker)
1. Open Schematic Editor
2. **Inspect → Electrical Rules Checker**
3. **Run ERC**
4. Address warnings:
   - Power flag issues: Add PWR_FLAG symbols to +12V, +3.3V, GND nets if needed
   - Unconnected pins: Verify intentional (e.g., unused STM32 GPIO) or connect
   - Hierarchical label mismatches: Check spelling/case between sheets

### 3. Annotate Schematic (if needed)
1. **Tools → Annotate Schematic**
2. Use method: **Use first free number after current annotation**
3. **Annotate** — ensures unique reference designators
4. **Save** schematic

### 4. Assign Footprints (verify)
1. **Tools → Assign Footprints**
2. Verify critical components:
   - **U2 (STM32G431CBT6):** `Package_QFP:LQFP-48_7x7mm_P0.5mm`
   - **U3 (W5500):** `Package_QFP:LQFP-48_7x7mm_P0.5mm`
   - **J4 (MagJack):** `Connector_RJ:RJ45_Hanrun_HR911105A` (or create custom if needed)
   - **J10-J47 (Zone terminals):** `TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2_1x02_P5.00mm_Horizontal`
   - **J50-J52 (Output terminals):** Same or 3-position variant
3. **Apply, Save, Close**

### 5. Update PCB from Schematic
1. Open **PCB Editor** (`zone-expander.kicad_pcb`)
2. **Tools → Update PCB from Schematic** (or press `F8`)
3. **Update PCB** — imports all components and nets
4. Components will appear clustered; ready for placement

---

## Layer Stackup (4-Layer)

Configure in **File → Board Setup → Physical Stackup**:

| Layer | Type | Thickness | Material | Purpose |
|-------|------|-----------|----------|---------|
| **F.Cu** (Top) | Copper | 35 µm (1 oz) | Copper | Signal layer: components, traces |
| **Dielectric 1** | Core | 0.2 mm | FR4 | Insulator |
| **In1.Cu** (Inner 1) | Copper | 35 µm (1 oz) | Copper | **GND plane (solid pour)** |
| **Dielectric 2** | Prepreg | 1.0 mm | FR4 | Insulator |
| **In2.Cu** (Inner 2) | Copper | 35 µm (1 oz) | Copper | **+3.3V + +12V power planes** |
| **Dielectric 3** | Core | 0.2 mm | FR4 | Insulator |
| **B.Cu** (Bottom) | Copper | 35 µm (1 oz) | Copper | Signal layer: components, traces |

**Total board thickness:** 1.6 mm (standard)

### Net Classes (File → Board Setup → Design Rules → Net Classes)

| Net Class | Track Width | Clearance | Via Diameter | Via Drill | Notes |
|-----------|-------------|-----------|--------------|-----------|-------|
| **Default** | 0.2 mm | 0.15 mm | 0.6 mm | 0.3 mm | General signals |
| **Power** | 0.5 mm | 0.2 mm | 0.8 mm | 0.4 mm | +12V, +3.3V, GND mains |
| **Analog** | 0.25 mm | 0.2 mm | 0.6 mm | 0.3 mm | Zone ADC inputs (optional class) |

Assign nets to classes in **Design Rules → Net Classes → Net Class Assignments**:
- `+12V` → Power
- `+3V3` → Power
- `GND` → Power (or use default with wider traces manually)

---

## Component Placement Strategy

### Phase 1: Board Outline & Mounting Holes
1. **Edge.Cuts layer:** Draw board outline (150mm × 100mm suggested)
2. Place **mounting holes (H1-H4)** at corners, 3-4mm from edges
3. Keep 5mm keepout zone from board edge for mechanical clearance

### Phase 2: Connectors (Define I/O Edges)
**Top Edge (Zone Inputs):**
- Place **J10-J17** (Zones 1-8, Bank 1) along top edge, evenly spaced
- Place **J20-J27** (Zones 9-16, Bank 2) continuing along top edge
- Leave 2-3mm between terminal blocks for soldering clearance

**Right Edge:**
- Place **J30-J37** (Zones 17-24, Bank 3) along right edge

**Bottom Edge:**
- Place **J40-J47** (Zones 25-32, Bank 4) along bottom edge

**Left Edge (Power & Outputs):**
- **J1 (12V Barrel Jack)** — top-left corner
- **J4 (Ethernet MagJack)** — bottom-left corner
- **J50 (Siren terminal)** — mid-left
- **J51-J52 (Relay terminals)** — below siren

### Phase 3: Power Section (Near J1)
Place near **J1 (barrel jack)**:
- **F1 (fuse)** → immediately after J1
- **D1 (reverse protection)** → after F1
- **C1 (input bulk cap)** → near D1
- **U1 (TPS54331 buck)** → central to power section
- **L1 (inductor)** → near U1 SW pin
- **C2 (output bulk)** → after L1
- **C3-C5 (decoupling)** → around U1
- **D2 (flyback, if external)** → near U1 SW pin
- **R1, R2 (feedback)** → near U1 VSENSE pin

**Grounding:** Star ground from C1− and C2− to single GND point, then to plane.

### Phase 4: MCU Section (Center of Board)
Place **U2 (STM32G431)** in center for equidistant routing to all zone banks:
- **Y1 (crystal)** — immediately adjacent to U2 OSC pins (minimize trace length)
- **C16, C17 (crystal load caps)** — right next to crystal
- **C10-C15 (decoupling)** — distribute around U2, one per VDD pin
- **R10 (NRST pull-up)** — near NRST pin
- **SW1 (reset button)** — near NRST, accessible from board edge
- **R11 (BOOT0)** — near BOOT0 pin
- **J2 (SWD header)** — near U2, accessible from board edge (top or side)
- **J3 (UART header, optional)** — if space allows

### Phase 5: Ethernet Section (Near J4)
Place near **J4 (MagJack)**:
- **U3 (W5500)** — as close to J4 as possible (minimize TX/RX trace length)
- **C40-C41 (decoupling)** — around U3
- **R20 (RSET)** — near U3 RSET pin
- **D10-D13 (TVS, if external ESD)** — between U3 and J4 differential pairs

### Phase 6: Zone Bank Components (Grouped by Bank)
For each bank (1-4), group components:

**Bank 1 (Zones 1-8):**
- Arrange **R100-R107** (pull-ups) in a line near their respective **J10-J17** terminals
- Place **D100-D107** (TVS) between resistors and terminals
- Route ADC traces from resistor midpoint to U2 pins (keep traces short, parallel where possible)

Repeat for Banks 2-4 with their respective components.

**Key:** Keep pull-up resistors and TVS diodes physically close to terminal blocks to protect against ESD at the entry point.

### Phase 7: Output Drivers (Near Left Edge)
**Siren Driver:**
- **Q1 (MOSFET)** — near J50
- **R30, R31** (gate resistors) — near Q1 gate
- **D20 (flyback)** — across siren load (near Q1 drain)

**Relay 1:**
- **K1 (relay)** — near J51
- **R40** (base resistor), **Q10** (driver, if discrete) — near K1 coil
- **D21 (flyback)** — across K1 coil

**Relay 2:** Same as Relay 1, near J52.

### Phase 8: Status LEDs & Misc
- **D10 (Power LED)** — near top edge, visible when installed
- **R50** (LED resistor) — next to D10

---

## Routing Guidelines

### Priority Order
1. **Power traces** (+12V, +3.3V, GND) — widest first
2. **Analog zone inputs** (ZONE_ADC[0..31]) — quiet, star-routed
3. **SPI bus** (SCK, MOSI, MISO, CS to W5500) — medium priority
4. **Ethernet differential pairs** (TX+/TX−, RX+/RX−) — controlled impedance if feasible
5. **GPIO outputs** (siren, relays, LEDs) — last

### Power Routing
1. **+12V distribution:**
   - From J1/F1 → U1 VIN (wide trace, 0.5-1.0mm)
   - From U1 VIN → siren MOSFET drain, relay coil supplies
   - Use **In2.Cu power plane** for +12V distribution (pour with net `+12V`)

2. **+3.3V distribution:**
   - From U1 output → U2 VDD pins (star or tree topology)
   - From U1 output → U3 VDD pins
   - From U1 output → zone pull-up resistors (via plane or wide traces)
   - Use **In2.Cu power plane** for +3.3V distribution (pour with net `+3V3`, separate from +12V)

3. **GND return:**
   - **In1.Cu: Solid GND plane** (no splits, maximize copper pour)
   - Stitch all GND pins to plane with vias (one via per GND pad minimum)
   - **Star ground analog zones:** Route zone ADC returns to a common point near U2 analog ground (VSSA) before connecting to plane
   - Use **stitching vias** (0.3mm drill) every 5-10mm to tie F.Cu and B.Cu GND pours to In1.Cu plane

### Analog Zone Routing (Critical for Noise Immunity)
- Route **ZONE_ADC[0..31]** traces from pull-up resistor midpoint directly to U2 ADC pins
- **Keep traces short** (<50mm if possible)
- **Avoid running near:**
  - High-current power traces (+12V to siren/relays)
  - SPI clock (SCK) or switching signals
  - Ethernet differential pairs
- **Parallel routing OK** for zones within same bank (they're all low-frequency DC sensing)
- Use **ground guard traces** or GND plane cutouts to isolate analog from digital if noise is a concern
- **Return path:** Zone GND (terminal ZONE−) → star point near U2 → GND plane

### SPI Bus (MCU ↔ W5500)
- Route as **parallel group** (SCK, MOSI, MISO, CS) to minimize skew
- Trace width: 0.2-0.25mm
- Spacing: 0.2mm minimum (or 3× trace width for reduced crosstalk)
- Length: <100mm (not critical at SPI speeds <10 MHz)
- Route on **F.Cu** with GND plane underneath (**In1.Cu**) for return path

### Ethernet Differential Pairs (W5500 ↔ MagJack)
- **TX+/TX−** and **RX+/RX−** must be routed as **differential pairs**
- Trace width: 0.2mm (for ~100Ω differential impedance on 4-layer FR4, tune if possible)
- **Spacing:** 0.15-0.2mm (trace-to-trace in pair)
- **Length matching:** Keep TX+ = TX− and RX+ = RX− within 5mm (not critical for short <50mm runs)
- **Route directly** from U3 to J4, minimize vias
- **No 90° bends** — use 45° or smooth arcs
- **Ground plane underneath** (In1.Cu) for controlled impedance
- **Avoid crossing power planes** or other signals

### GPIO Outputs (Siren, Relays, LEDs)
- Standard 0.2-0.3mm traces
- Not critical; route last after power and analog

---

## Copper Pours (Zones)

### Layer: In1.Cu (Inner Layer 1) — GND Plane
1. **Draw Zone → Add Filled Zone**
2. **Layer:** `In1.Cu`
3. **Net:** `GND`
4. **Fill settings:**
   - Clearance: 0.2mm
   - Minimum width: 0.2mm
   - Thermal relief: Yes (4 spokes, 0.4mm spoke width)
   - Fill mode: Solid
5. **Draw zone** covering entire board outline (avoid only mounting holes)
6. **Fill All Zones** (press `B`)

### Layer: In2.Cu (Inner Layer 2) — Power Planes (+3.3V + +12V)
Option A: **Split plane** (recommended for simplicity):
1. **Draw first zone:**
   - Net: `+3V3`
   - Cover ~70% of board (MCU, Ethernet, zone banks area)
2. **Draw second zone:**
   - Net: `+12V`
   - Cover ~30% of board (near power input, siren, relays)
3. Ensure **no overlap** between zones (use board center as split line)

Option B: **+3.3V only** (simpler):
- Pour entire In2.Cu with `+3V3`
- Route +12V as wide traces on F.Cu/B.Cu where needed

### Layers: F.Cu & B.Cu — GND Fill (optional, recommended)
- After all signal routing complete, pour GND zones on F.Cu and B.Cu
- Helps with EMI, provides local return paths
- Stitch to In1.Cu GND plane with vias

---

## Design Rules Check (DRC)

### Run DRC Before Gerber Export
1. **Inspect → Design Rules Checker**
2. **Run DRC**
3. **Address errors:**
   - Clearance violations: Move traces or increase spacing
   - Track width violations: Widen power traces if flagged
   - Unconnected nets: Verify all pads connected (check pour fills)
   - Silkscreen over pads: Move text or reference designators

### Common Fixes
- **Silkscreen on pads:** Move reference designators to open areas
- **Thermal relief not connected:** Re-fill zones (press `B`)
- **Via in pad:** Generally OK for small signal vias; avoid for large pads

---

## Silkscreen & Documentation

### F.Silkscreen (Top Silkscreen)
- **Reference designators:** Visible for all components (auto-placed, then manually adjust)
- **Polarity marks:**
  - `+` near J1 barrel jack positive pin
  - `+` and `−` near zone terminals (ZONE+, ZONE−)
  - `+` near power LEDs
- **Zone labels:** "ZONE 1", "ZONE 2", ... "ZONE 32" near respective terminals
- **Output labels:** "SIREN", "RELAY 1 NO/COM/NC", "RELAY 2 NO/COM/NC"
- **Test point labels:** "TP1 +12V", "TP2 +3.3V", "TP3 GND"
- **Board info:**
  - "Guardian Zone Expander v0.1"
  - "cassidymug/ALARM-SYSTEM"
  - "32 Supervised Zones | 12V DC | 4.7k EOL"

### B.Silkscreen (Bottom Silkscreen)
- Reference designators for bottom components (if any)
- Board outline or mounting hole indicators

---

## Fabrication Output (PCBWay)

### Gerber Export
1. **File → Fabrication Outputs → Gerbers (.gbr)**
2. **Plot format:** Gerber (default)
3. **Layers to include:**
   - ✅ F.Cu, In1.Cu, In2.Cu, B.Cu
   - ✅ F.SilkS, B.SilkS
   - ✅ F.Mask, B.Mask
   - ✅ F.Paste, B.Paste (if SMT assembly)
   - ✅ Edge.Cuts
   - ❌ F.Fab, B.Fab (optional)
4. **Options:**
   - ✅ Use Protel filename extensions (`.gtl`, `.gbl`, etc.) — PCBWay compatible
   - ✅ Subtract soldermask from silkscreen
   - ✅ Use drill/place file origin = Absolute
5. **Output directory:** `gerbers/`
6. **Plot** → Generates `.gbr` files

### Drill File Export
1. **File → Fabrication Outputs → Drill Files (.drl)**
2. **Format:** Excellon (default)
3. **Options:**
   - PTH and NPTH in separate files: ✅ Yes
   - Mirror Y axis: ❌ No
   - Minimal header: ❌ No
4. **Output directory:** `gerbers/` (same as Gerbers)
5. **Generate Drill File**

### Pick-and-Place (Optional for Assembly)
1. **File → Fabrication Outputs → Component Placement (.pos)**
2. **Format:** CSV
3. **Units:** mm
4. **Output directory:** `bom/`

### BOM (Bill of Materials)
1. **Open Schematic Editor**
2. **Tools → Generate BOM**
3. **Plugin:** `bom_csv_grouped_by_value` (or KiCost if installed)
4. **Output:** `bom/zone-expander_bom.csv`
5. **Manual step:** Add manufacturer part numbers (MPNs) for each component

---

## PCBWay Order Checklist

### Upload Files
1. **Zip Gerbers + Drill files:**
   ```bash
   cd gerbers/
   zip ../zone-expander-gerbers-v0.1.zip *.g* *.drl
   ```
2. **Upload to PCBWay:** [https://www.pcbway.com/orderonline.aspx](https://www.pcbway.com/orderonline.aspx)

### PCBWay Order Parameters
- **Dimensions:** Auto-detected from Gerbers (verify ~150×100mm)
- **Layers:** 4
- **Material:** FR4
- **Thickness:** 1.6mm
- **Copper weight:** 1 oz (35 µm) all layers
- **Surface finish:** ENIG (Electroless Nickel Immersion Gold)
- **Solder mask color:** Green (or your preference)
- **Silkscreen color:** White
- **Min track/spacing:** 6/6 mil (0.15/0.15mm)
- **Min drill hole:** 0.3mm
- **Castellated holes:** No
- **Quantity:** **5 boards** (prototypes)

### Assembly (Optional)
- If ordering PCBA: Upload BOM + CPL (pick-and-place)
- Select components to be assembled (recommend: SMD components only)
- Hand-solder through-hole parts (terminals, relays, headers)

---

## Post-Fabrication Testing

### Visual Inspection
1. Check for solder bridges (especially between QFP pins)
2. Verify polarity marks match schematic (+/− on caps, LEDs, diodes)
3. Inspect via fill quality (no voids)

### Electrical Testing
1. **Continuity:**
   - Test GND plane continuity (any two GND pads should read <0.1Ω)
   - Verify no shorts: +12V to GND, +3.3V to GND, +12V to +3.3V
2. **Power-on (no components):**
   - Apply 12V to J1
   - Measure +12V rail: Should be 12V ±0.5V
3. **Power-on (with components, no MCU):**
   - Apply 12V
   - Measure +3.3V rail: Should be 3.3V ±0.1V
   - Check for excessive heat on U1 (buck converter)
4. **Full power-on:**
   - Solder all components
   - Apply 12V
   - Verify all rails present
   - Flash MCU with blink firmware via SWD (J2)
5. **Zone testing:**
   - Install 4.7kΩ resistor on Zone 1 terminal
   - Read ADC value (should be ~1.55V / 1900 counts at 12-bit)
   - Short Zone 1: ADC → 0V
   - Open Zone 1: ADC → 3.3V

---

## Troubleshooting Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| **No +3.3V output** | Buck converter not oscillating | Check U1 orientation, L1 value, feedback resistors R1/R2 |
| **+3.3V too high/low** | Feedback divider wrong | Recalculate R1/R2 per TPS54331 datasheet |
| **MCU won't program** | SWD connection issue | Verify J2 pinout (SWDIO, SWCLK, GND, +3.3V), check NRST pull-up R10 |
| **Ethernet no link** | MagJack pinout wrong | Verify J4 footprint matches HR911105A datasheet |
| **Zones always read 3.3V** | Pull-up not connected | Check R100-R407 placement, verify +3.3V plane pour reaches resistors |
| **Zones always read 0V** | Short to GND | Check for solder bridges on terminal blocks, inspect TVS diodes D100-D407 |
| **Siren doesn't activate** | MOSFET not switching | Verify Q1 gate drive from MCU, check R30/R31, measure gate voltage |
| **Relays won't close** | Coil driver issue | Check relay coil voltage (should match K1/K2 spec), verify flyback diodes D21/D22 orientation |

---

## Revision History

- **v0.1 (2026-09-13):** Initial PCB layout guide based on completed schematic

---

**Next Step:** Open `zone-expander.kicad_pro` in KiCad 8 and follow this guide to complete the PCB layout. Good luck! 🚀

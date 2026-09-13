# Guardian Zone Expander — Schematic Symbols List

**Purpose:** Complete component list with KiCad symbol references, footprints, and quantities for the Guardian 32-zone supervised wired alarm expander.

**KiCad version:** 8.x (native libraries preferred)  
**Custom symbols:** Define project-local symbols if standard library lacks exact match  

---

## 1. Power Supply (Sheet: Power)

| Ref | Qty | Description | KiCad Symbol | Footprint | Notes |
|-----|-----|-------------|--------------|-----------|-------|
| J1 | 1 | Barrel jack, 2.1mm or 2.5mm, 12V DC input | `Connector:Barrel_Jack_Switch` | `BarrelJack_Horizontal` or `CUI_PJ-202A` | Center positive, 5A rating |
| F1 | 1 | Fuse, 2A slow-blow, through-hole holder | `Device:Fuse` | `Fuse_Holder_5x20mm` or SMD holder | Protects 12V input |
| D1 | 1 | Schottky diode or P-MOSFET for reverse polarity protection | `Device:D_Schottky` or custom P-FET circuit | `D_SMA` (diode) or `SOT-23` (MOSFET) | If diode: 3A, 40V (e.g. SS34); if P-FET: IRF9540N or AO3401 |
| U1 | 1 | Buck converter IC, 12V→3.3V, ≥1A | `Regulator_Switching:TPS54331` | `SOIC-8_3.9x4.9mm_P1.27mm` or similar | TI TPS54331DR or equivalent (LM2596, MP1584, etc.) |
| L1 | 1 | Inductor, 22µH, ≥1.5A, low DCR | `Device:L` | `L_12x12mm` or `L_Wuerth_WE-PD` | Vishay IHLP2525CZER220M11 or similar shielded inductor |
| C1, C2 | 2 | Capacitor, electrolytic, 100µF or 220µF, 25V | `Device:CP` | `CP_Radial_D8.0mm_P3.50mm` or SMD tant | Input/output bulk caps for buck |
| C3-C10 | 8+ | Capacitor, ceramic, 100nF, X7R or X5R, 0805 | `Device:C` | `C_0805_2012Metric` | Decoupling caps (distribute across power, MCU, Ethernet, zone banks) |
| C11, C12 | 2 | Capacitor, ceramic, 10µF, X7R, 1206 or 0805 | `Device:C` | `C_1206_3216Metric` | Additional bulk decoupling for 3.3V rail |
| R1, R2 | 2 | Resistor, feedback divider for buck converter | `Device:R` | `R_0805_2012Metric` | Values per buck IC datasheet (e.g. 10kΩ, 2.2kΩ for TPS54331) |
| D2 | 1 | Schottky diode, buck flyback/catch diode | `Device:D_Schottky` | `D_SMA` | 1A, 40V (e.g. 1N5819 or integrated in IC) |
| TP1, TP2, TP3 | 3 | Test points: +12V, +3.3V, GND | `Connector:TestPoint` | `TestPoint_Pad_D2.0mm` | For probing during bring-up |

**Power notes:**
- If using integrated synchronous buck (e.g. TPS54331), external Schottky D2 may be omitted.
- Adjust capacitor count (C3-C10) based on final decoupling needs per sheet (~2-4 per major IC).

---

## 2. MCU (Sheet: MCU)

| Ref | Qty | Description | KiCad Symbol | Footprint | Notes |
|-----|-----|-------------|--------------|-----------|-------|
| U2 | 1 | STM32G071CBT6 or STM32G431CBT6 (or similar G0/G4) | `MCU_ST_STM32G0:STM32G071CBTx` or `MCU_ST_STM32G4:STM32G431CBTx` | `LQFP-48_7x7mm_P0.5mm` | 48-pin LQFP, sufficient GPIO/ADC for 32 zones + peripherals |
| Y1 | 1 | Crystal, 8 MHz or 12 MHz, HC-49S or SMD | `Device:Crystal` | `Crystal_HC49-U_Vertical` or `Crystal_SMD_3225-4Pin` | HSE for MCU main clock |
| C20, C21 | 2 | Capacitor, ceramic, 20pF or 22pF (crystal load caps) | `Device:C` | `C_0805_2012Metric` | Tune per crystal datasheet |
| R10 | 1 | Resistor, 10kΩ, pull-up for NRST | `Device:R` | `R_0805_2012Metric` | Reset line pull-up |
| C22-C30 | 9+ | Capacitor, ceramic, 100nF, X7R, 0805 | `Device:C` | `C_0805_2012Metric` | One per VDD/VDDA pin + extras |
| C31, C32 | 2 | Capacitor, ceramic, 4.7µF or 10µF, 0805 or 1206 | `Device:C` | `C_1206_3216Metric` | Bulk caps for MCU power pins |
| J2 | 1 | SWD programming header, 2×5 pin, 1.27mm or 2.54mm pitch | `Connector_Generic:Conn_02x05_Odd_Even` | `PinHeader_2x05_P1.27mm` or Tag-Connect `TC2050-IDC` | SWDIO, SWCLK, GND, 3.3V, NRST |
| J3 | 1 | UART debug header, 1×3 pin, 2.54mm pitch (TX, RX, GND) | `Connector_Generic:Conn_01x03` | `PinHeader_1x03_P2.54mm_Vertical` | Serial console for firmware debug |
| SW1 | 1 | Reset button, tactile switch, SPST, 6mm | `Switch:SW_Push` | `SW_SPST_6mm` | Connects NRST to GND |
| R11 | 1 | Resistor, 0Ω or 10Ω (BOOT0 to GND for normal boot) | `Device:R` | `R_0805_2012Metric` | Pull BOOT0 low for flash boot mode |

**MCU notes:**
- STM32G071CBT6 (Cortex-M0+) or STM32G431CBT6 (Cortex-M4) both viable; choose based on availability and desired performance.
- If using external ADC mux (CD74HC4067 or similar), add those symbols per zone bank.
- GPIO assignments for zone ADC channels, SPI (W5500), siren, relays, LEDs documented in schematic nets.

---

## 3. Ethernet (Sheet: Ethernet)

| Ref | Qty | Description | KiCad Symbol | Footprint | Notes |
|-----|-----|-------------|--------------|-----------|-------|
| U3 | 1 | W5500 Ethernet controller (SPI, integrated MAC/PHY) | `Interface_Ethernet:W5500` | `LQFP-48_7x7mm_P0.5mm` | WIZnet W5500, hardwired TCP/IP stack |
| J4 | 1 | RJ45 MagJack (integrated magnetics + connector) | `Connector:RJ45_Abracon_ARJP11A-MASA-B-A-EMU2` or `Connector:RJ45_Hanrun_HR911105A` | Custom footprint or `RJ45_Hanrun_HR911105A` | Hanrun HR911105A or Abracon ARJP11A series typical |
| C40-C47 | 8+ | Capacitor, ceramic, 100nF, X7R, 0805 | `Device:C` | `C_0805_2012Metric` | Decoupling for W5500 VDD pins + analog supply |
| C48, C49 | 2 | Capacitor, ceramic, 10µF, X7R, 0805 or 1206 | `Device:C` | `C_1206_3216Metric` | Bulk caps for W5500 power |
| R20 | 1 | Resistor, 12.4kΩ, 1% (W5500 RSET for mode) | `Device:R` | `R_0805_2012Metric` | Per W5500 datasheet reference resistor |
| R21, R22 | 2 | Resistor, 49.9Ω, 1%, for Ethernet termination (optional) | `Device:R` | `R_0805_2012Metric` | Optional series resistors on TX lines if not in MagJack |
| D10-D13 | 4 | TVS diode array for Ethernet ESD protection | `Power_Protection:SP0503BAHT` or similar | `SOT-143` or `SOT-23-6` | Protects Ethernet differential pairs; place near RJ45 |
| LED1, LED2 | 2 | LED, 0805 SMD or 3mm THT (Link, Activity) | `Device:LED` | `LED_0805_2012Metric` or `LED_THT_D3.0mm` | Green for Link, yellow for Activity (or use MagJack integrated LEDs) |
| R23, R24 | 2 | Resistor, 330Ω or 470Ω, current limit for LEDs | `Device:R` | `R_0805_2012Metric` | 3.3V → LED → resistor → GND |

**Ethernet notes:**
- MagJack choice affects footprint and whether integrated LEDs are available; adjust LED symbols if using MagJack LEDs.
- If using discrete Ethernet transformer instead of MagJack, add transformer symbol (e.g. `Transformer:Ethernet_Transformer_1CT-1CT`) and separate RJ45 connector.

---

## 4. Zone Banks (Sheets: ZoneBank1, ZoneBank2, ZoneBank3, ZoneBank4)

**Each bank:** 8 zone channels (replicate ×4 banks = 32 total zones)

| Ref | Qty per bank | Qty total | Description | KiCad Symbol | Footprint | Notes |
|-----|--------------|-----------|-------------|--------------|-----------|-------|
| J10-J17 (Bank1), J20-J27 (Bank2), J30-J37 (Bank3), J40-J47 (Bank4) | 8 | 32 | Screw terminal, 2-position, 3.5mm or 5mm pitch (ZONE+, ZONE−/GND) | `Connector:Screw_Terminal_01x02` | `TerminalBlock_Phoenix_MKDS-1,5-2` or 5mm pitch | Zones 1-8 (Bank1), 9-16 (Bank2), 17-24 (Bank3), 25-32 (Bank4) |
| R100-R107 (Bank1), R200-R207 (Bank2), R300-R307 (Bank3), R400-R407 (Bank4) | 8 | 32 | Resistor, 10kΩ, 0805, pull-up for EOL sensing | `Device:R` | `R_0805_2012Metric` | Pull-up to +3.3V (or +5V if used) per zone channel |
| D100-D107 (Bank1), D200-D207 (Bank2), D300-D307 (Bank3), D400-D407 (Bank4) | 8 | 32 | TVS diode, bidirectional, 5V or 6V, SMD | `Device:D_TVS` | `D_SOD-123` or `D_SMA` | SMAJ5.0CA or equivalent; ESD/transient protection per zone |
| F10-F13 (per bank, optional) | 1-2 per bank | 4-8 | PTC resettable fuse, 100-200mA, radial or SMD | `Device:Polyfuse` | `R_1206_3216Metric` or `Polyfuse_Radial_PTH` | Optional shared per bank (e.g. 2 PTCs per 8 zones) or one per zone for tighter protection |
| **Note:** EOL resistors (4.7kΩ) are **user-supplied** and placed at sensor far end — **not on PCB BOM** | — | 32 | ¼W through-hole resistor, 4.7kΩ, 1% | `Device:R` (for reference only) | `R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal` | Installer provides; document in assembly manual |

**Zone bank notes:**
- Each zone channel schematic: ZONE+ → pull-up resistor (10kΩ) to +3.3V → voltage divider to ADC input → TVS to GND.
- Sensor loop: ZONE+ → contact → 4.7kΩ EOL → ZONE−/GND (closed when normal, open when tamper, short when alarm).
- If using analog multiplexers (e.g. CD74HC4067 for 16:1 mux, use 2 per 32 zones or 4× 8:1 mux like CD74HC4051), add those ICs here:
  - U10, U11, U12, U13 (one per bank): `Analog:CD74HC4051` or `CD74HC4067` with associated decoupling caps.
- ADC connections: If direct MCU ADC, route ZONE_ADC[1..32] to MCU sheet; if muxed, route mux outputs + control lines.

---

## 5. Outputs (Sheet: Outputs)

| Ref | Qty | Description | KiCad Symbol | Footprint | Notes |
|-----|-----|-------------|--------------|-----------|-------|
| Q1 | 1 | N-channel MOSFET, logic-level, ≥2A (siren driver) | `Device:Q_NMOS_GDS` | `SOT-23` or `TO-220-3_Vertical` | IRLZ44N (TO-220) or AO3400 (SOT-23); drives 12V siren load |
| R30 | 1 | Resistor, 10kΩ, gate pull-down for Q1 | `Device:R` | `R_0805_2012Metric` | Ensures MOSFET off when MCU tristated |
| R31 | 1 | Resistor, 100Ω, gate series resistor for Q1 (optional) | `Device:R` | `R_0805_2012Metric` | Reduces ringing on gate drive |
| D20 | 1 | Flyback diode, fast recovery, 1A, for inductive siren loads | `Device:D` | `D_SMA` | 1N4148 or 1N5819; cathode to +12V, anode to siren load |
| J50 | 1 | Screw terminal, 2-position, 5mm pitch (12V_SIREN, GND) | `Connector:Screw_Terminal_01x02` | `TerminalBlock_Phoenix_MKDS-1,5-2` or 5mm | Siren output connector |
| K1, K2, (K3, K4 optional) | 2-4 | Relay, SPDT (Form C), 5A @ 250VAC / 30VDC | `Relay:Relay_SPDT` | `Relay_SPDT_Omron-G5V-2` or `Relay_SPDT_Finder-40.52` | Omron G5V-2, Panasonic HFD2/005-S, or equivalent; 5V or 12V coil |
| Q10, Q11, (Q12, Q13 optional) | 2-4 | NPN transistor or relay driver IC (one per relay) | `Device:Q_NPN_BCE` or `Driver_Relay:ULN2003A` | `SOT-23` (transistor) or `SOIC-16` (ULN2003A) | 2N2222 or BC817 (NPN); or single ULN2003A for 4 relays |
| R40-R43 (one per relay) | 2-4 | Resistor, 1kΩ or 2.2kΩ, base resistor for NPN | `Device:R` | `R_0805_2012Metric` | Current limit for MCU GPIO → NPN base |
| D21-D24 (one per relay) | 2-4 | Flyback diode, 1N4148 or 1N4007, for relay coils | `Device:D` | `D_SMA` or `D_DO-41` | Protects driver transistor from coil inductive spike |
| J51-J54 (one per relay) | 2-4 | Screw terminal, 3-position, 5mm pitch (NO, COM, NC) | `Connector:Screw_Terminal_01x03` | `TerminalBlock_Phoenix_MKDS-1,5-3` or 5mm | Relay dry contacts for external loads |

**Outputs notes:**
- Relay coil voltage: choose 5V or 12V relays based on available rail (12V direct from input, or 5V if added to power sheet).
- If using ULN2003A Darlington array, one IC can drive up to 7 relays (use 4 channels for 4 relays); adjust symbols accordingly.
- Siren MOSFET Q1 can be driven with PWM from MCU for modulated tones (firmware feature, not schematic change).

---

## 6. Connectors & Status (Sheet: Connectors)

| Ref | Qty | Description | KiCad Symbol | Footprint | Notes |
|-----|-----|-------------|--------------|-----------|-------|
| LED10 | 1 | LED, Power indicator (3.3V rail active), red or green | `Device:LED` | `LED_0805_2012Metric` or `LED_THT_D3.0mm` | Always on when powered |
| R50 | 1 | Resistor, 330Ω or 470Ω, LED current limit | `Device:R` | `R_0805_2012Metric` | 3.3V → LED → R50 → GND |
| LED11 | 1 | LED, Status (MCU heartbeat / fault), yellow or blue | `Device:LED` | `LED_0805_2012Metric` or `LED_THT_D3.0mm` | GPIO-driven blink pattern |
| R51 | 1 | Resistor, 330Ω or 470Ω, LED current limit | `Device:R` | `R_0805_2012Metric` | GPIO → LED → R51 → GND |
| SW2 (optional) | 1 | User button (test/enroll mode), tactile, SPST, 6mm | `Switch:SW_Push` | `SW_SPST_6mm` | GPIO with internal pull-up, triggers test mode |
| *(Zone terminal blocks J10-J47 already listed in Zone Banks section)* | | | | | |
| *(Power jack J1, Ethernet jack J4, output terminals J50-J54 already listed above)* | | | | | |

**Connectors notes:**
- Optional: per-zone indicator LEDs (32 additional LEDs + resistors) if board space allows; typically omitted for cost/complexity; bank-level LEDs (4 total) may be added instead.
- Mounting holes (4-6) should be added to PCB layout with `MountingHole` symbols and `MountingHole_3.2mm_M3` footprints (or similar).

---

## 7. Additional Components (Misc / All Sheets)

| Ref | Qty | Description | KiCad Symbol | Footprint | Notes |
|-----|-----|-------------|--------------|-----------|-------|
| MH1-MH4 | 4 | Mounting holes, M3 or M4 | `Mechanical:MountingHole` | `MountingHole_3.2mm_M3` or `MountingHole_4.3mm_M4` | Non-plated or plated-GND for mechanical mounting |
| TP10-TP20 | 10+ | Additional test points for critical nets (optional) | `Connector:TestPoint` | `TestPoint_Pad_D2.0mm` | Useful for debugging zone ADC, SPI, etc. |

---

## 8. Symbol Summary by Category

| Category | Qty (approx) | KiCad Libraries Used |
|----------|--------------|----------------------|
| Passives (R, C, L) | 100+ | `Device` |
| Semiconductors (Diodes, MOSFETs, Transistors) | 40+ | `Device`, `Power_Protection` |
| ICs (MCU, Buck, W5500, Mux) | 3-7 | `MCU_ST_STM32G0`, `MCU_ST_STM32G4`, `Regulator_Switching`, `Interface_Ethernet`, `Analog` (if mux) |
| Connectors (terminals, headers, jacks) | 40+ | `Connector`, `Connector_Generic` |
| Relays | 2-4 | `Relay` |
| LEDs | 3-6 | `Device` |
| Switches | 1-2 | `Switch` |
| Mechanical | 4 | `Mechanical` |

---

## 9. Footprint Notes

- **SMD preferred** for cost/assembly efficiency on prototypes where hand-soldering is feasible (0805 passives, SOT-23 transistors, SOIC/LQFP ICs).
- **Through-hole** for:
  - Screw terminals (zone inputs, outputs, power) — mandatory for field wiring.
  - Barrel jack, test points, optional THT LEDs for visibility.
  - Optional: headers (SWD, UART) — 2.54mm pin headers or Tag-Connect pogo pins.
- **KiCad footprint libraries:**
  - Most footprints in standard KiCad 8 libraries: `Resistor_SMD`, `Capacitor_SMD`, `Diode_SMD`, `Package_SO`, `Package_QFP`, `TerminalBlock_Phoenix`, `Connector_PinHeader`.
  - Custom footprints (MagJack, specific relay) may require project-local library or import from manufacturer (SnapEDA, UltraLibrarian).

---

## 10. Next Steps

1. **Complete schematic entry** for each hierarchical sheet:
   - Draw detailed zone front-end circuit (1 of 32 channels) in ZoneBank sheet.
   - Replicate channel ×8 per bank; instantiate sheet ×4 times.
   - Wire power, MCU, Ethernet, outputs per net labels and buses.
2. **Assign footprints** to all symbols via CvPcb or schematic footprint fields.
3. **Run ERC** (Electrical Rules Check) and resolve warnings/errors.
4. **Generate netlist** and import to PCB editor.
5. **PCB layout:** Place terminal blocks along board edge(s), group zone banks, route power/ground planes, check DRC.
6. **Generate BOM** from schematic (Tools → Generate BOM) and refine for PCBWay assembly quote.
7. **Export Gerbers** (Gerber + drill files) and CPL (pick-and-place) per PCBWay specifications.

---

*Guardian Zone Expander — Detailed schematic symbols list for KiCad 8 project. Cross-reference with hardware/zone-expander/README.md and docs/hardware/ZONE_EXPANDER.md.*

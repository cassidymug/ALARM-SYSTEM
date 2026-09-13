# Guardian Zone Expander — Exported Schematics

This directory contains visual exports of the complete KiCad schematic design.

## Complete Schematic Package

**📄 `zone-expander-complete.pdf`** — **All schematic sheets in one PDF file**
- Contains all 9 sheets in hierarchical order
- Best for printing or offline viewing
- 802 KB, ready for review

## Individual Sheet SVG Files

Each sheet is exported as a separate SVG file for easy web viewing and integration into documentation:

### Root Sheet
**`zone-expander.svg`** — Main hierarchical overview
- Shows the block diagram structure
- Hierarchical sheet blocks for all subsystems
- Inter-sheet signal connections

### Power Supply
**`zone-expander-Power.svg`** — Complete power circuitry
- 12V barrel jack input (J1)
- Fuse and reverse polarity protection (F1, D1)
- TPS54331 buck converter (U1) — 12V → 3.3V @ 1.5A
- Feedback network, compensation, decoupling
- Power LED indicator
- Test points (TP1, TP2, TP3)

### Microcontroller
**`zone-expander-MCU.svg`** — STM32G431CBT6 processor
- 48-pin LQFP microcontroller (U2)
- 8 MHz HSE crystal oscillator (Y1)
- Complete power decoupling (5× 100nF + 2× 10µF)
- SWD programming header (J2)
- Reset button circuit (SW1)
- All 32 ADC input pins labeled
- SPI bus connections to W5500
- GPIO outputs to siren and relays

### Ethernet Connectivity
**`zone-expander-Ethernet.svg`** — W5500 network interface
- W5500 hardwired TCP/IP controller (U3)
- SPI interface connections to MCU
- RJ45 MagJack connector (J4) with integrated magnetics
- 100BASE-TX / 10BASE-T auto-negotiation
- Decoupling capacitors

### Zone Banks (×4 Sheets)
**`zone-expander-ZoneBank1.svg`** — Zones 1-8
**`zone-expander-ZoneBank2.svg`** — Zones 9-16
**`zone-expander-ZoneBank3.svg`** — Zones 17-24
**`zone-expander-ZoneBank4.svg`** — Zones 25-32

Each zone bank sheet contains:
- 8× 2-position screw terminals (ZONE+, ZONE−)
- 8× 10kΩ pull-up resistors to +3.3V
- 8× TVS diodes for ESD/surge protection
- Connections to MCU ADC inputs

### Output Drivers
**`zone-expander-Outputs.svg`** — Siren and relay drivers
- Siren MOSFET driver (Q1: AO3400 N-channel)
  - Gate driver resistors (R30, R31)
  - Flyback diode (D20)
  - 2-position terminal block (J50)
- 2× Relay drivers (K1, K2)
  - NPN transistor drivers (Q10, Q11)
  - Flyback diodes (D21, D22)
  - 3-position terminal blocks (J51, J52: NO/COM/NC)

### Status & Mounting
**`zone-expander-Connectors & Status.svg`** — LEDs and mounting
- Power LED indicator (D10, R50)
- Optional status LEDs
- 4× M3 mounting holes (H1-H4) for DIN rail or wall mount
- Optional UART debug header (J3)

## How to View

### PDF File
- Open `zone-expander-complete.pdf` in any PDF viewer
- All sheets are included in one file
- Best for printing or comprehensive review

### SVG Files
- Open SVG files in any modern web browser (Chrome, Firefox, Edge)
- Double-click the file or drag into browser window
- Vector graphics scale perfectly at any zoom level
- Can be imported into documentation tools (Markdown, Wiki, etc.)

## Component Reference

All components use standard KiCad 8 library symbols and footprints:
- **Resistors**: 0805 SMD (most), 1206 (power)
- **Capacitors**: 0805 SMD (small), 1210/1206 (bulk)
- **ICs**: STM32G431CBT6 (LQFP-48), TPS54331 (SOIC-8), W5500 (LQFP-48)
- **Connectors**: 5.08mm pitch screw terminals, 0.1" (2.54mm) headers
- **MOSFETs**: SOT-23 (AO3400)
- **Diodes**: SMA (Schottky, TVS), SOD-123 (signal)

## Cross-Reference

For detailed explanations of circuit operation and signal flow, see:
- **System Architecture**: `../SYSTEM_ARCHITECTURE.md`
- **Project Overview**: `../README.md`
- **Design Specification**: `../../docs/hardware/ZONE_EXPANDER.md`

---

**Generated:** 2026-09-13  
**KiCad Version:** 8.0.9  
**Export Format:** PDF (complete), SVG (individual sheets)

# PCB Layout Quick Checklist

## Before You Start
- [ ] Open KiCad 8 and load `zone-expander.kicad_pro`
- [ ] Run ERC on schematic, fix warnings
- [ ] Annotate schematic if needed
- [ ] Verify footprint assignments
- [ ] Update PCB from Schematic (F8)

## Setup
- [ ] Define 4-layer stackup: F.Cu / GND / PWR / B.Cu
- [ ] Set net classes (Power: 0.5mm, Default: 0.2mm)
- [ ] Draw board outline ~150×100mm
- [ ] Place mounting holes (H1-H4) at corners

## Placement
- [ ] Terminal blocks at edges (J10-J47 for zones)
- [ ] Power section near J1 (top-left): U1, L1, C1-C6
- [ ] MCU central: U2, Y1, decoupling caps
- [ ] Ethernet near J4 (bottom-left): U3, close to MagJack
- [ ] Zone resistors/TVS near their terminals (R100-R407, D100-D407)
- [ ] Output drivers near left edge: Q1, K1-K2
- [ ] LEDs near top edge

## Routing Priority
1. [ ] Power (+12V, +3.3V): 0.5-1.0mm traces
2. [ ] Zone ADC inputs: Short, quiet, star-routed
3. [ ] SPI (MCU ↔ W5500): Parallel group
4. [ ] Ethernet differential pairs: TX+/TX−, RX+/RX−
5. [ ] GPIO (siren, relays, LEDs)

## Copper Pours
- [ ] In1.Cu: Solid GND plane (entire board)
- [ ] In2.Cu: +3.3V + +12V split or +3.3V only
- [ ] F.Cu & B.Cu: GND fill (after routing)
- [ ] Stitching vias every 5-10mm

## Final Checks
- [ ] Run DRC, resolve violations
- [ ] Verify silkscreen: zone labels 1-32, polarity marks
- [ ] Add test point labels (TP1-TP3)
- [ ] Add board info text
- [ ] Generate Gerbers (F.Cu, In1.Cu, In2.Cu, B.Cu, Edge.Cuts, Masks, Silk)
- [ ] Generate drill files (PTH + NPTH)
- [ ] Zip and upload to PCBWay

## PCBWay Order Settings
- Layers: **4**
- Thickness: **1.6mm**
- Copper: **1oz**
- Finish: **ENIG**
- Quantity: **5**

---

See `PCB_LAYOUT_GUIDE.md` for detailed instructions.

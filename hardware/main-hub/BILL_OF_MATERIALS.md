# Guardian GH-1000 Main Hub - Complete Bill of Materials (BOM)

## Overview: Custom vs. Off-The-Shelf

**Custom Parts (Require Design & Fabrication):**
1. Main PCB (motherboard layout and routing)
2. Sensor Controller PCB (signal conditioning circuits)
3. Front panel PCB (optional, for LEDs/buttons)
4. Chassis modifications (if using custom enclosure)

**Off-The-Shelf Parts (Buy from distributors):**
- All electronic components (CPU, RAM, chips, resistors, capacitors, connectors)
- Power supply
- Enclosure (standard 2U rackmount or modify)
- Cooling fans
- Cables and hardware

---

## Complete BOM with Part Numbers

### Main Processor & Memory

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **CPU (SoC)** | Intel Celeron N5105 | Intel | 1 | $150 | $150 | Quad-core, 2.0-2.9 GHz, 10W TDP |
| **Alternative CPU** | Intel Pentium Silver N6005 | Intel | 1 | $180 | $180 | Faster option (3.3 GHz boost) |
| **RAM** | CT8G4SFRA32A | Crucial | 2 | $30 | $60 | 8GB DDR4-3200 SO-DIMM, industrial temp |
| **NVMe SSD** | WDS256G1X0C | WD Blue SN570 | 1 | $35 | $35 | 256GB M.2 2280, 3500 MB/s read |
| **Alternative SSD** | MZ-V8P256BW | Samsung 980 Pro | 1 | $50 | $50 | Higher endurance (600 TBW) |

**CPU Notes:**
- Intel Celeron N5105 is a **complete SoC** (System-on-Chip)
- Includes: CPU cores, GPU, memory controller, PCIe, USB, SATA, display output
- Available as:
  - Bare chip (BGA package, requires reflow soldering) - **NOT recommended for DIY**
  - Mini-ITX board with N5105 pre-soldered (recommended, see below)

---

### Option 1: Use Mini-ITX Board (Recommended for Prototyping)

Instead of soldering a bare CPU chip, **use an off-the-shelf Mini-ITX board** with N5105 already installed:

| Board | Part Number | Manufacturer | Price | Features |
|-------|-------------|--------------|-------|----------|
| **ASRock N5105-ITX** | N5105-ITX | ASRock | $150 | Mini-ITX, 2× SO-DIMM, M.2, 4× SATA, 2× GbE, PCIe x1 |
| **ASUS PN51** | PN51-S1-B-N5105 | ASUS | $200 | Mini-PC board, 2× SO-DIMM, M.2, Wi-Fi, 2× GbE |
| **Topton N5105** | N5105-4L | Topton/AliExpress | $120 | Mini-ITX, 4× Intel i225 GbE, M.2, fanless |

**Recommendation:** Use **Topton N5105-4L** or similar for **first 100 units** (prototyping phase).
- **Pros:** No CPU soldering, faster time-to-market, proven reliability
- **Cons:** Slightly larger, less integration, higher cost ($120 vs $50 for bare chip)

**For production (1000+ units):** Design custom PCB with bare N5105 chip (see Custom PCB section below).

---

### Network Switch Components

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **Switch IC** | BCM53134MKPBG | Broadcom | 1 | $45 | $45 | 24-port GbE switch, managed |
| **Alternative** | RTL8370MB | Realtek | 1 | $25 | $25 | Budget option, 8-port expandable |
| **PoE Controller** | TPS23881RTQR | Texas Instruments | 3 | $12 | $36 | 8-port PoE PSE, IEEE 802.3at |
| **Ethernet PHY** | RTL8211F-CG | Realtek | 1 | $1.50 | $1.50 | Gigabit PHY for WAN port |
| **Magnetics** | HX1188FNL | Pulse Electronics | 24 | $1.20 | $28.80 | PoE+ rated, 1:1 transformer |
| **RJ45 Jack** | 5-6605759-1 | TE Connectivity | 24 | $2.50 | $60 | Shielded, PoE+, LED integrated |

**Switch IC Notes:**
- **Broadcom BCM53134**: Enterprise-grade, 52 Gbps fabric, VLAN, QoS, expensive
- **Realtek RTL8370MB**: Budget-friendly, 16 Gbps fabric, basic features
- For **first prototypes**: Use a **pre-made PoE switch module** instead (see below)

---

### Option 2: Use Off-Shelf PoE Switch Module (Easier Prototyping)

Instead of building switch from scratch, **integrate a commercial module**:

| Module | Part Number | Manufacturer | Price | Features |
|--------|-------------|--------------|-------|----------|
| **FS S3410-24TF** | S3410-24TF | FS.com | $380 | 24× GbE PoE+, 370W budget, managed, compact |
| **MikroTik CRS328-24P-4S+** | CRS328-24P-4S+RM | MikroTik | $450 | 24× GbE PoE+, 4× SFP+, 500W, RouterOS |
| **UniFi Switch 24 PoE** | USW-24-POE | Ubiquiti | $400 | 24× GbE PoE+, 400W, managed via UniFi |

**Recommendation for prototyping:**
- **Gut a MikroTik CRS328** or **FS S3410** switch
- Remove its enclosure, keep the PCB
- Integrate PCB into Guardian chassis
- Connect to main CPU via Ethernet (WAN port acts as uplink)

**Pros:** Fast prototyping, proven reliability, no switch chip soldering  
**Cons:** Higher cost (~$400 vs ~$150 for custom), less integration

---

### Sensor Controller Components

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **MCU** | STM32H743VIT6 | STMicroelectronics | 1 | $12 | $12 | 400 MHz, 1MB Flash, 1MB RAM |
| **Alternative MCU** | STM32F407VET6 | STMicroelectronics | 1 | $8 | $8 | Budget option, 168 MHz |
| **I/O Expander** | MCP23017-E/SO | Microchip | 2 | $1.20 | $2.40 | 16-bit I²C GPIO (for 32 zones) |
| **ADC** | Built into STM32 | - | - | - | - | 12-bit, 16 channels |
| **Op-Amp** | OPA2350UA | Texas Instruments | 4 | $2.50 | $10 | Dual, rail-to-rail, low offset |
| **Optoisolator** | PC817C | Sharp | 32 | $0.15 | $4.80 | 2.5kV isolation (zone inputs) |
| **RS-485 Transceiver** | MAX485CSA | Maxim | 1 | $0.80 | $0.80 | Half-duplex, 2.5 Mbps |
| **Relay Module** | SRD-05VDC-SL-C | Songle | 4 | $0.50 | $2 | 5V coil, SPDT, 10A contacts |
| **TVS Diode** | SMAJ12CA | Littelfuse | 40 | $0.30 | $12 | 12V bidirectional, 400W surge |
| **Voltage Regulator** | LM2596S-5.0 | Texas Instruments | 1 | $1.50 | $1.50 | 12V→5V, 3A buck converter |
| **LDO Regulator** | AMS1117-3.3 | Advanced Monolithic | 1 | $0.30 | $0.30 | 5V→3.3V, 1A low dropout |

---

### Storage & I/O Controllers

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **USB 3.0 Hub IC** | GL850G | Genesys Logic | 1 | $1.20 | $1.20 | 4-port USB hub (front panel) |
| **USB 3.1 Controller** | ASM1142 | ASMedia | 1 | $8 | $8 | PCIe to USB 3.1 Gen 2 (Type-C) |
| **10GbE Controller** | X550-AT2 | Intel | 1 | $80 | $80 | Dual 10GBASE-T (for SFP+ via adapter) |
| **SFP+ Cage** | SFP-10G-SR | FS.com | 2 | $15 | $30 | 10G fiber transceiver module |

---

### Power Supply

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **PSU (Prototype)** | ENP-7660B | Enhance Electronics | 1 | $120 | $120 | 600W, 80+ Gold, 2U form factor |
| **PSU (Production)** | Custom 500W | Mean Well / Delta | 1 | $80 | $80 | Industrial-grade, PoE optimized |
| **PoE Power Module** | PD-9024GO | Microsemi | 3 | $35 | $105 | Alternative to TPS23881, easier |

**PSU Notes:**
- For **prototyping**: Use off-shelf 2U server PSU (ATX-style)
- For **production**: Design custom PSU or contract with Mean Well / Delta
  - Outputs: +12V (400W for PoE), +5V (50W for logic), +3.3V (20W for CPU/RAM)

---

### Passive Components (High-Quality, Long-Life)

#### Capacitors (Industrial/Automotive Grade)

| Type | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|------|-------------|--------------|-----|-----------|-------|-------|
| **Electrolytic 1000µF 25V** | EEV-FK1E102M | Panasonic | 10 | $0.80 | $8 | 105°C, 5000hr life |
| **Ceramic 100µF 6.3V** | GRM32ER60J107ME20 | Murata | 20 | $0.50 | $10 | X5R, ±20%, low ESR |
| **Ceramic 10µF 16V** | GRM32ER71C106KA12L | Murata | 50 | $0.20 | $10 | X7R, ±10%, decoupling |
| **Ceramic 0.1µF 50V** | C0805C104K5RACTU | Kemet | 100 | $0.05 | $5 | X7R, ±10%, bypass |

**Capacitor Selection for Longevity:**
- Use **X7R or X5R dielectric** (not Y5V - unstable with temperature)
- Use **105°C rated electrolytics** (not 85°C)
- Derate by 50%: If circuit is 12V, use 25V capacitor (not 16V)

#### Resistors (Thick Film, 1% Tolerance)

| Value | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-------|-------------|--------------|-----|-----------|-------|-------|
| **1kΩ 0805 1%** | RC0805FR-071KL | Yageo | 100 | $0.01 | $1 | 1/8W, thick film |
| **10kΩ 0805 1%** | RC0805FR-0710KL | Yageo | 50 | $0.01 | $0.50 | 1/8W, thick film |
| **5.6kΩ 1206 1%** | RC1206FR-075K6L | Yageo | 32 | $0.02 | $0.64 | EOL resistor value |

**Resistor Selection for Longevity:**
- Use **thick film, not carbon composition** (more stable)
- Use **1% tolerance** (better accuracy, tighter specs = better manufacturing)
- Derate by 50%: If dissipating 0.125W, use 0.25W resistor

---

### Connectors & Mechanical

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **Screw Terminal 3-pos** | 1935174 | Phoenix Contact | 40 | $0.80 | $32 | 5.08mm pitch, 16A rated |
| **USB 3.0 Type-A** | UJ2-AMTH-TH | CUI Devices | 2 | $1.20 | $2.40 | Front panel |
| **USB Type-C** | USB4105-GF-A | GCT | 2 | $1.80 | $3.60 | Front panel, USB 3.1 |
| **HDMI Connector** | 10029449-111RLF | Amphenol | 1 | $2.50 | $2.50 | Rear panel |
| **IEC C14 Power Inlet** | 6100.3110 | Schurter | 1 | $3 | $3 | Fused, with switch |

---

### Enclosure & Cooling

| Component | Part Number | Manufacturer | Qty | Unit Cost | Total | Notes |
|-----------|-------------|--------------|-----|-----------|-------|-------|
| **2U Rackmount Chassis** | RM-2380 | Inter-Tech | 1 | $60 | $60 | 19" standard, 380mm depth |
| **Alternative Chassis** | RM23508H02*BKN1 | Norco | 1 | $80 | $80 | Heavy-duty, tool-less |
| **Cooling Fan 80mm** | 8025H12BA | Noctua | 2 | $15 | $30 | 12V, 4-pin PWM, quiet |
| **CPU Heatsink** | NH-L9i-17xx | Noctua | 1 | $45 | $45 | Low-profile, passive-ready |

---

### Total BOM Cost (Prototype Build, Off-Shelf Approach)

| Category | Cost | Notes |
|----------|------|-------|
| **CPU Board** (Mini-ITX) | $150 | Topton N5105-4L or ASRock |
| **RAM** (2× 8GB) | $60 | Industrial DDR4 |
| **NVMe SSD** (256GB) | $35 | WD Blue SN570 |
| **PoE Switch Module** | $380 | FS S3410 or MikroTik (integrated) |
| **Sensor Controller** (custom PCB) | $100 | PCB fab + components (see below) |
| **10GbE Controller** | $80 | Intel X550 |
| **SFP+ Modules** | $30 | 2× cages |
| **Power Supply** | $120 | 600W 2U server PSU |
| **Enclosure** | $60 | Standard 2U chassis |
| **Cooling** | $75 | Fans + heatsink |
| **Connectors & Misc** | $100 | RJ45, terminals, USB, HDMI |
| **Custom PCBs** (sensor board) | $50 | Fabrication (see below) |
| **Assembly Labor** | $100 | 4 hours @ $25/hr |
| **Testing & QA** | $40 | 2 hours |
| **Total Prototype** | **$1,380** | Single unit, hand-built |

**Retail Price:** $1,299 is achievable at volume (500+ units, optimized sourcing).

---

## Custom PCB Designs Required

### 1. Main Computer Board (Option A: Skip for Prototyping)

**For first 100 units:** Use off-shelf Mini-ITX board (ASRock, Topton, etc.)

**For production (1000+ units):** Design custom main PCB
- **Size:** 170mm × 170mm (Mini-ITX compatible)
- **Layers:** 6-layer (power planes, ground, signal routing)
- **Components:** Bare N5105 chip, RAM slots, M.2 slot, PHY chips
- **Complexity:** High (CPU BGA soldering, DDR4 routing, PCIe trace matching)
- **Cost:** $200 per board (small batch), $50 per board (10,000+ qty)

**Recommendation:** Outsource to experienced board design firm (see plan below).

---

### 2. Sensor Controller PCB (Custom, Required)

**Purpose:** Interface 32 zones, analog inputs, smoke detectors, relays

**Specifications:**
- **Size:** 200mm × 150mm (fits in 2U chassis)
- **Layers:** 4-layer (top signal, ground plane, power plane, bottom signal)
- **Components:** STM32H743, MCP23017 I/O expanders, op-amps, optoisolators, terminal blocks
- **Complexity:** Medium (standard SMT assembly, no BGA, no high-speed DDR)
- **Cost:** $50 per board (batch of 10), $15 per board (1,000+ qty)

**Fabrication:** JLCPCB, PCBWay, or local fab house

---

### 3. Front Panel PCB (Optional)

**Purpose:** LEDs, buttons, LCD display (optional 2.8" touchscreen)

**Specifications:**
- **Size:** 482mm × 40mm (front panel width)
- **Layers:** 2-layer (simple)
- **Components:** LEDs, resistors, tactile switches, LCD module
- **Complexity:** Low
- **Cost:** $20 per board (batch of 10)

---

## Manufacturing Plan: From Prototype to Production

### Phase 1: Proof-of-Concept (1-5 Units)

**Goal:** Validate architecture, test functionality

**Approach:** Maximum use of off-shelf modules
- **Main computer:** ASRock N5105-ITX Mini-ITX board ($150)
- **PoE switch:** Gut a MikroTik CRS328 ($450) or use USB-Ethernet adapters (temporary)
- **Sensor controller:** Breadboard prototype with Arduino/STM32 Nucleo board
- **Enclosure:** Standard 2U chassis (unmodified)

**Assembly:**
1. Mount Mini-ITX board in chassis
2. Connect PoE switch module via Ethernet
3. Prototype sensor board on breadboard
4. Flash firmware, test all interfaces
5. Validate: Can it record 24 cameras? Can it read zones? Does PoE work?

**Timeline:** 2-4 weeks  
**Cost per unit:** ~$1,500 (high component cost, no optimization)

---

### Phase 2: Alpha Prototypes (10-20 Units)

**Goal:** Design custom sensor PCB, refine enclosure, prepare for beta

**Approach:**
- **Main computer:** Still use Mini-ITX board (proven, fast)
- **PoE switch:** Still integrate commercial module (FS S3410 or similar)
- **Sensor controller:** **Design custom PCB** (KiCad schematic + layout)
  - Submit to JLCPCB/PCBWay for fabrication ($200 for 10 boards)
  - SMT assembly (hand-solder or JLCPCB PCBA service)
- **Enclosure:** Modify standard chassis (drill holes for terminals, label ports)

**Custom PCB Design Steps:**
1. **Schematic design** (see next section)
2. **PCB layout** (component placement, trace routing, ground planes)
3. **Design review** (simulate, check for errors)
4. **Fabrication** (upload Gerber files to JLCPCB)
5. **Assembly** (solder components, either manually or via PCBA service)
6. **Testing** (functional test, burn-in test)

**Timeline:** 6-10 weeks (includes PCB design, 2-week fab lead time)  
**Cost per unit:** ~$1,200 (custom sensor board, optimized sourcing)

---

### Phase 3: Beta Units (100-200 Units)

**Goal:** Final validation before mass production, beta customer testing

**Approach:**
- **Main computer:** Consider custom main PCB **OR** continue Mini-ITX (decision point)
  - If sticking with Mini-ITX: Negotiate bulk pricing with Topton/ASRock (~$100 per board)
  - If going custom: Outsource main board design to Flex/Sanmina/Jabil (see below)
- **PoE switch:** Transition to custom PoE switch PCB **OR** integrate switch module permanently
  - Custom PCB: Use Broadcom BCM53134 or Realtek RTL8370MB, design switch card
  - Integrated module: Negotiate OEM pricing with MikroTik or FS.com (~$250 per module at 100+ qty)
- **Sensor controller:** Refine PCB (rev 2), fix any issues from alpha
- **Enclosure:** Custom chassis design (optional) or refine modified standard chassis

**PCBA Service (Recommended for Beta):**
- Use **JLCPCB PCBA** or **PCBWay Assembly**
  - Upload BOM, Gerber files, pick-and-place file
  - They source components, assemble boards, test
  - Turnaround: 2-3 weeks
  - Cost: ~$500 setup + $30 per board (100 qty)

**Timeline:** 12-16 weeks  
**Cost per unit:** ~$900-$1,000 (volume pricing, optimized design)

---

### Phase 4: Mass Production (1,000+ Units)

**Goal:** Lowest cost, highest quality, scalable manufacturing

**Approach:**
- **Main computer:** **Custom PCB required** (bare N5105 chip, not Mini-ITX board)
  - Outsource design to **Flex, Sanmina, Jabil, or Chinese ODM**
  - They handle: Schematic, layout, BGA soldering, DDR4 routing, certification
  - Cost: $50,000-$100,000 NRE (non-recurring engineering) + $50 per board
- **PoE switch:** Custom PCB with BCM53134 or Realtek switch IC
  - Integrated into main board **OR** separate switch card (PCIe)
- **Sensor controller:** Production PCB (rev 3+), fully tested and certified
- **Enclosure:** Custom injection-molded plastic or custom sheet metal
  - Tooling cost: $10,000-$30,000 (mold or stamping die)
- **Assembly:** Contract with CM (contract manufacturer)
  - Options: Foxconn, Flex, Sanmina, Jabil (USA), or Chinese CM (lower cost)

**Component Sourcing:**
- Negotiate direct with manufacturers (Intel, STMicro, TI, Broadcom)
- Buy in reel quantities (5,000-10,000 pcs)
- Lock in pricing with long-term contracts

**Timeline:** 6-12 months (from beta to production-ready)  
**Cost per unit:** ~$600-$700 (at 1,000 qty), ~$500-$550 (at 10,000 qty)

---

## Custom PCB Design: Sensor Controller (Detailed Schematic)

### Sensor Controller PCB Requirements

**Functional Blocks:**
1. STM32H743 microcontroller (main processor)
2. 32× zone inputs (optoisolated, EOL resistor detection)
3. 8× analog inputs (op-amp buffer, anti-alias filter, ADC)
4. 4× smoke detector inputs (supervised 12V loops, latching)
5. 2× pulse counter inputs (Schmitt trigger, debounce)
6. 4× relay outputs (optoisolated, flyback protected)
7. RS-485 interface (half-duplex, 120Ω termination)
8. USB 3.0 interface (connects to main CPU)
9. Power supply (12V input → 5V → 3.3V)
10. Status LEDs (power, activity, alarm)

**I'll create a detailed schematic in the next file...**

---

## PCB Manufacturing Plan

### Step 1: Design Tools

**PCB Design Software:**
- **KiCad** (free, open-source) - Recommended for open-source project
- **Altium Designer** ($7,000/year) - Professional, better for production
- **Eagle** ($500/year) - Mid-tier, good for prototyping

**Recommendation:** Use **KiCad** for sensor controller (simpler, community-driven), consider **Altium** for main board (complex DDR4 routing).

---

### Step 2: Fabrication (Sensor Controller PCB)

**Manufacturer Options:**

| Vendor | Location | Lead Time | Price (10 boards) | Price (100 boards) | Quality |
|--------|----------|-----------|-------------------|-------------------|---------|
| **JLCPCB** | China | 5-7 days | $50 (4-layer) | $300 | Good |
| **PCBWay** | China | 5-7 days | $80 (4-layer) | $400 | Excellent |
| **OSH Park** | USA | 12 days | $200 (4-layer) | N/A | Excellent |
| **Advanced Circuits** | USA | 3-5 days | $300 (4-layer) | $1,500 | Excellent |

**Recommendation:** 
- **Prototypes (1-10 boards):** JLCPCB or PCBWay (cheap, fast)
- **Small batch (10-100):** PCBWay (better quality control)
- **Production (1000+):** Chinese CM or USA CM (Sunstone, Sierra Circuits)

---

### Step 3: Assembly Options

**Option A: Hand Assembly (Prototypes)**
- You solder components yourself (SMT reflow oven, hot air station)
- **Pros:** Low cost, full control
- **Cons:** Slow, error-prone, not scalable
- **Best for:** 1-10 boards

**Option B: PCBA Service (Recommended for Beta)**
- JLCPCB PCBA, PCBWay Assembly, or MacroFab
- Upload: BOM, Gerber files, pick-and-place file (from KiCad)
- They: Source parts, assemble, test
- **Pros:** Fast, reliable, scalable to 100-500 units
- **Cons:** Setup fee ($200-$500), component sourcing issues
- **Best for:** 10-500 boards

**Option C: Contract Manufacturer (Production)**
- Foxconn, Flex, Sanmina, Jabil, or Chinese CM
- Full turnkey: They handle everything (design review, sourcing, assembly, test, packaging)
- **Pros:** Highest quality, scalable to 10,000+ units, certifications (UL, CE, FCC)
- **Cons:** High NRE cost ($50k-$500k), long lead time (6-12 months)
- **Best for:** 1,000+ boards

---

### Step 4: Component Sourcing

**Distributors (USA):**
- **Digi-Key** (digi-key.com) - Huge stock, fast shipping, no MOQ
- **Mouser** (mouser.com) - Similar to Digi-Key
- **Arrow** (arrow.com) - Good for large orders, negotiable pricing

**Distributors (China):**
- **LCSC** (lcsc.com) - Integrated with JLCPCB, huge stock, cheap
- **Seeed Studio** - Good for prototyping kits

**Direct from Manufacturer (Production):**
- Contact Intel, STMicro, TI, Broadcom sales reps
- Negotiate pricing for 1,000+ qty orders
- Get on their allocation list (important for CPU, switch chips)

---

### Step 5: Quality Assurance

**Testing Plan:**
1. **Visual inspection:** Check solder joints, component placement
2. **Continuity test:** Multimeter check for shorts/opens
3. **Power-on test:** Apply 12V, check 5V and 3.3V rails
4. **Functional test:** Flash firmware, test each interface
   - 32× zone inputs (trigger each, verify)
   - 8× analog inputs (apply known voltage, verify ADC reading)
   - 4× smoke inputs (test supervised loop)
   - 4× relay outputs (activate, verify with multimeter)
   - RS-485 (loopback test)
   - USB (connect to PC, verify enumeration)
5. **Burn-in test:** Run for 48 hours under load
6. **Temperature test:** Operate at -10°C and +60°C (environmental chamber)

**Test Jig:** Design custom test jig (Arduino or Raspberry Pi-based) to automate testing.

---

## High-Quality Component Selection for Longevity

### Goals
- **20+ year lifespan** (typical industrial equipment)
- **Temperature range:** -10°C to +60°C (covers most climates)
- **Low failure rate:** <1% annual failure rate (AFR)

### Component Selection Criteria

**1. Capacitors:**
- ❌ **Avoid:** Electrolytic capacitors in hot areas (PSU, CPU)
- ✅ **Use:** Ceramic (X7R/X5R), tantalum, or solid polymer caps
- ✅ **Derate:** 50% voltage, 105°C temperature rating

**2. Semiconductors:**
- ✅ **Industrial/Automotive grade:** -40°C to +125°C rated
- ✅ **Reputable manufacturers:** Intel, STMicro, TI, Analog Devices (not knockoffs)
- ✅ **Authorized distributors:** Digi-Key, Mouser, Arrow (not AliExpress for critical parts)

**3. Connectors:**
- ✅ **Gold-plated contacts:** Prevent oxidation (especially RJ45, USB)
- ✅ **Rated for mating cycles:** 1,000+ insertions (USB), 100+ (RJ45)

**4. PCB Material:**
- ✅ **FR-4 TG170** (high glass transition temp) - Better heat resistance
- ✅ **ENIG finish** (Electroless Nickel Immersion Gold) - Best corrosion resistance
- ❌ **Avoid:** HASL (Hot Air Solder Level) - Uneven, lead-based

**5. Solder:**
- ✅ **SAC305** (96.5% Sn, 3% Ag, 0.5% Cu) - Lead-free, RoHS compliant
- ✅ **No-clean flux** - Low residue, no post-clean required

---

## Next Steps: Detailed Schematics

I'll create detailed schematics for:
1. **Sensor Controller PCB** (complete schematic, ready for KiCad)
2. **Power supply distribution** (12V → 5V → 3.3V)
3. **Zone input circuits** (32× optoisolated inputs with EOL detection)
4. **Analog input circuits** (8× buffered ADC inputs with anti-alias filters)
5. **Smoke detector circuits** (4× supervised 12V loops with latching)

**These schematics will be production-ready and can be submitted to JLCPCB/PCBWay for fabrication.**

Would you like me to proceed with creating the detailed schematics now?

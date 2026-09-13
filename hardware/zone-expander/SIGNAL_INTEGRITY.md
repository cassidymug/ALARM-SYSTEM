# Guardian Hub - Signal Integrity & Anti-Interference Design

## Challenge: Multi-Sensor Proximity

When 32 zones + 8 analog inputs + 4 smoke detectors + 2 pulse counters are all connected to a single hub in close proximity, several interference issues can occur:

1. **Crosstalk** - Signals bleed between adjacent traces/wires
2. **EMI/RFI** - Electromagnetic/radio frequency interference
3. **Ground loops** - Multiple ground paths cause noise
4. **Power supply noise** - Switching regulators inject ripple
5. **Impedance mismatch** - Reflections degrade signals
6. **Common mode noise** - Noise on ground reference

## Solution: Comprehensive Signal Conditioning Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│              Guardian Hub - Signal Conditioning                     │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Power Supply Section                       │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐            │  │
│  │  │ 12V Input  │→→│ Linear 5V  │→→│ Linear 3.3V│            │  │
│  │  │ (isolated) │  │ (low noise)│  │ (ultra low)│            │  │
│  │  └────────────┘  └────────────┘  └────────────┘            │  │
│  │       ↓              ↓              ↓                        │  │
│  │    Ferrite       LC Filter      LC Filter                   │  │
│  │    beads         + bypass       + bypass                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Zone Input Conditioning (32×)                   │  │
│  │                                                               │  │
│  │  Zone Wire → [TVS] → [RC Filter] → [Schmitt Trigger] →     │  │
│  │                                     [Optoisolator] → MCU     │  │
│  │                                                               │  │
│  │  Protection: ±15kV ESD, ±1kV surge                          │  │
│  │  Filtering: 100kHz LPF (remove RF noise)                    │  │
│  │  Isolation: 2.5kV optical (ground loop elimination)         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │            Analog Sensor Conditioning (8×)                   │  │
│  │                                                               │  │
│  │  Sensor → [TVS] → [RC Filter] → [Op-Amp Buffer] →          │  │
│  │                                  [Anti-Alias LPF] → ADC      │  │
│  │                                                               │  │
│  │  Input range: 0-3.3V, ±0.1% accuracy                        │  │
│  │  Resolution: 12-bit (0.8mV steps)                           │  │
│  │  Sample rate: 1-1000 Hz (configurable)                      │  │
│  │  Input impedance: 1MΩ (minimal sensor loading)              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │         Smoke Detector Conditioning (4×)                     │  │
│  │                                                               │  │
│  │  +12V Power → [LC Filter] → [Current Limit] → Smoke Det    │  │
│  │                             [500mA fuse]                     │  │
│  │                                                               │  │
│  │  Alarm In ← [TVS] ← [RC Filter] ← [Supervised Loop] ←      │  │
│  │                                    [Optoisolator]            │  │
│  │                                                               │  │
│  │  Supervision: EOL resistor detection (tamper/fault)         │  │
│  │  Latching: Hardware + software latch (manual reset)         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │           Pulse Counter Conditioning (2×)                    │  │
│  │                                                               │  │
│  │  Pulse In → [TVS] → [Schmitt Trigger] → [Debounce] →       │  │
│  │                                          [Edge Detect] →MCU  │  │
│  │                                                               │  │
│  │  Frequency: DC to 10 kHz                                     │  │
│  │  Debounce: 1ms (configurable)                               │  │
│  │  Edge: Rising, falling, or both                             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Relay Output Conditioning (4×)                  │  │
│  │                                                               │  │
│  │  MCU → [Transistor Driver] → [Flyback Diode] → Relay       │  │
│  │                              [Snubber Circuit]               │  │
│  │                                                               │  │
│  │  Isolation: 2.5kV optical                                    │  │
│  │  Protection: Flyback diode (inductive kickback)             │  │
│  │  Indication: LED per relay                                   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

## Detailed Signal Conditioning per Interface

### 1. Zone Inputs (32× Digital, NC/NO/EOL)

**Purpose:** Door/window contacts, PIR sensors, glass break, panic buttons

**Circuit Design:**
```
Zone Terminal → [15kV TVS Diode] → [1kΩ + 100nF RC Filter] → 
                [74HC14 Schmitt Trigger] → [PC817 Optoisolator] → 
                [MCP23017 I/O Expander] → MCU I²C Bus

Protection:
- TVS Diode: SMAJ12CA (15kV ESD, ±1kV surge)
- Series resistor: 1kΩ (current limiting)
- Parallel capacitor: 100nF (RF filtering, -3dB @ 100kHz)

Signal Conditioning:
- Schmitt Trigger: 74HC14 (hysteresis eliminates bounce)
- Thresholds: VT+ = 2.0V, VT- = 0.8V (1.2V hysteresis)

Isolation:
- Optoisolator: PC817 (2.5kV isolation, CTR = 80%)
- Prevents ground loops
- Protects MCU from external voltage spikes

EOL Resistor Detection:
- Normal (closed): ~1.8V (voltage divider: 4.7kΩ pull-up + 5.6kΩ EOL)
- Triggered (open): ~3.3V (no load, pull-up only)
- Fault (short): ~0V (shorted to ground)
- Fault (cut): ~3.3V (no EOL resistor detected)

ADC Thresholds:
- < 0.5V: Fault (short)
- 0.5V - 1.5V: Normal (closed, EOL present)
- 1.5V - 2.5V: Triggered (open, EOL present)
- > 2.5V: Fault (cut wire or no EOL)
```

**PCB Layout:**
- Separate ground plane for zone inputs
- 20 mil trace width (handle 12V spikes)
- Guard traces between adjacent zones (prevent crosstalk)
- TVS diodes close to terminals (<5mm)

---

### 2. Analog Sensor Inputs (8× ADC, 0-3.3V)

**Purpose:** Temperature, humidity, CO, gas, light sensors

**Circuit Design:**
```
Sensor Terminal → [5.6V Zener Clamp] → [10kΩ + 10nF RC Filter] → 
                  [OPA2350 Op-Amp Buffer] → [2nd Order Sallen-Key LPF] → 
                  [STM32 12-bit ADC] (DMA sampling)

Protection:
- Zener Diode: 5.6V (overvoltage clamp to 5.6V max)
- Series resistor: 10kΩ (current limiting if overvoltage)
- Input protection diodes on op-amp (internal ESD)

Signal Conditioning:
- Op-Amp Buffer: OPA2350 (rail-to-rail, 38 MHz GBW)
  * Input impedance: 1 MΩ (minimal sensor loading)
  * Output impedance: <1Ω (drive ADC capacitance)
  * Offset voltage: <1mV (high accuracy)

Anti-Aliasing Filter:
- 2nd-order Sallen-Key LPF (Butterworth)
- Cutoff frequency: 100 Hz (environmental sensors are slow)
- Stopband attenuation: -40dB @ 1kHz
- Prevents aliasing (Nyquist: sample at >200 Hz for 100 Hz signal)

ADC Configuration:
- 12-bit resolution (4096 steps, 0.8mV per step)
- VREF = 3.300V (precision voltage reference: REF3330)
- Sample rate: 1 Hz (environmental), 100 Hz (fast sensors)
- Oversampling: 16× (effective 14-bit, reduces noise)
- DMA mode (no CPU overhead)
```

**Calibration:**
```c
// Two-point calibration per input
typedef struct {
    float offset;  // Offset voltage (mV)
    float gain;    // Gain correction factor
} ADC_Cal;

// Calibrate using known reference voltages
// Point 1: 0V (GND)    → Read ADC_0
// Point 2: 3.3V (VREF) → Read ADC_3v3
gain = 3.3 / (ADC_3v3 - ADC_0) * 4095;
offset = -ADC_0 * gain / 4095;

// Correct readings
voltage_corrected = (adc_reading * gain / 4095) + offset;
```

**PCB Layout:**
- Separate AGND (analog ground) plane
- Star ground topology (all AGND return to single point)
- Guard ring around ADC traces (driven at AGND)
- Keep analog traces <10mm to ADC pins
- Route away from digital signals (especially SPI clock)

---

### 3. Smoke Detector Inputs (4× Supervised)

**Purpose:** 12V powered smoke detectors (2-wire or 4-wire)

**Circuit Design:**
```
+12V Power:
  12V → [L-C Filter] → [Polyfuse 500mA] → Smoke Detector
        (10µH + 100µF)  (resettable fuse)

  LC Filter: Removes switching noise from 12V supply
  - Inductor: 10µH (Würth 744 762 210)
  - Capacitor: 100µF low-ESR electrolytic
  - Attenuation: -20dB @ 100kHz

  Polyfuse: Self-resetting overcurrent protection
  - Hold current: 500mA
  - Trip current: 1000mA
  - Protects against short circuit in smoke detector wiring

Alarm Input (Supervised Loop):
  Smoke Det → [EOL 10kΩ] → [1kΩ] → [100nF] → [Comparator] → MCU
                                    (RC filter)

  Supervision Circuit:
  - Pull-up: 4.7kΩ to 12V
  - EOL resistor: 10kΩ at smoke detector
  - Comparator: LM393 (dual comparator, low offset)

  Voltage Levels:
  - Normal: ~8V (voltage divider: 4.7k + 10k)
  - Alarm: ~12V (smoke detector shorts to 12V)
  - Tamper/Cut: ~0V (open circuit, pull-down)
  - Fault: Outside normal range

  Comparator Thresholds:
  - Threshold 1: 9V (detect alarm)
  - Threshold 2: 6V (detect tamper/cut)

Latching Logic (Hardware + Software):
  Hardware Latch: SR flip-flop (74HC279)
  - Set on alarm condition
  - Reset only via manual reset button + software command
  - LED indicator (latched state)

  Software Latch:
  - Once alarmed, flag set in EEPROM
  - Survives power cycle
  - Requires manual reset procedure
```

**Interconnect Feature:**
```
Smoke 1 Alarm → [OR Gate] ─┐
Smoke 2 Alarm → [OR Gate] ─┼→ Relay 2 (All Sirens)
Smoke 3 Alarm → [OR Gate] ─┤
Smoke 4 Alarm → [OR Gate] ─┘

Any smoke detector alarm triggers:
- All smoke detector outputs (via relay)
- Siren relay (relay 3)
- Strobe relay (relay 4)
```

**PCB Layout:**
- Separate 12V power plane (isolated from 3.3V/5V logic)
- Wide traces for 12V (40 mil, handle 500mA per channel)
- Keep smoke circuits away from analog inputs (EMI)
- Ferrite beads on 12V supply lines

---

### 4. Pulse Counter Inputs (2× High-Speed Digital)

**Purpose:** Metal detectors, beam counters, flow sensors

**Circuit Design:**
```
Pulse Input → [6.8V Zener] → [1kΩ + 100pF] → [74HC14 Schmitt] → 
              [CD4538 Monostable] → [MCU External Interrupt]

Protection:
- Zener clamp: 6.8V (allows 5V logic, clamps overvoltage)
- Series resistor: 1kΩ (current limiting)
- Capacitor: 100pF (RF noise filter, -3dB @ 1.6 MHz)

Signal Conditioning:
- Schmitt Trigger: 74HC14 (clean up noisy pulses)
- Hysteresis: 1.2V (eliminate bounce/ringing)

Debounce:
- Monostable: CD4538B (precision one-shot)
- Pulse width: 1ms (adjustable via RC network)
- Ignores pulses <1ms (debounce)
- Extends pulses >1ms to consistent width

Edge Detection:
- MCU External Interrupt (EXTI)
- Trigger: Rising edge
- Priority: High (ensure no pulses missed)
- Counter: Hardware timer in counter mode (32-bit)

Maximum Frequency:
- Input: DC to 10 kHz
- Debounce limited: Effective max ~500 Hz (1ms pulse + 1ms gap)
```

**PCB Layout:**
- Short traces to MCU interrupt pins (<20mm)
- Ground plane underneath (controlled impedance)
- Series termination if long trace (match impedance)

---

### 5. Relay Outputs (4× SPDT, Isolated)

**Purpose:** Siren, strobe, locks, HVAC control

**Circuit Design:**
```
MCU GPIO → [PC817 Optoisolator] → [2N2222 NPN] → [Relay Coil] → 12V
                                   (Darlington)   [Flyback Diode]
                                                  [Snubber Circuit]

Isolation:
- Optoisolator: PC817 (2.5kV isolation)
- Protects MCU from relay back-EMF
- Separate ground for relay coil (PGND = power ground)

Driver:
- Transistor: 2N2222 NPN (800mA collector current)
- Base resistor: 1kΩ (for 5mA base current)
- Beta = 100 → Ic = 500mA (sufficient for relay coil)

Protection:
- Flyback Diode: 1N4007 (1A, 1000V reverse voltage)
  * Across relay coil (cathode to +12V)
  * Suppresses inductive kickback when relay opens
  * Without this: ~300V spike can damage transistor!

- Snubber Circuit: 0.1µF + 100Ω (RC snubber)
  * Across relay contacts (if switching inductive load)
  * Reduces contact arcing
  * Extends relay life

Relay Specifications:
- Coil voltage: 12V DC
- Coil resistance: 400Ω (30mA coil current)
- Contact rating: 5A @ 30V DC, 3A @ 125V AC
- Contact type: SPDT (Form C)
- Switching time: <10ms

Status LED:
- LED + 1kΩ resistor across relay coil
- Indicates when relay is energized
```

**PCB Layout:**
- Thick traces for relay contacts (60 mil, 3A capable)
- Separate relay ground (PGND) from logic ground (DGND)
- Single-point connection: PGND and DGND tied at power supply
- Keep relay section away from analog inputs (EMI from arcing contacts)

---

## Power Supply Design (Critical for Signal Integrity)

### Multi-Stage Filtering Architecture

```
12V Input (Wall adapter or PoE)
   ↓
[Reverse Polarity Protection: P-Channel MOSFET]
   ↓
[Input TVS: SMAJ14CA (400W surge protection)]
   ↓
[Input Filter: 100µH + 1000µF (reduce conducted EMI)]
   ↓
   ├─→ [Linear Regulator: LM2940-5 (5V, 1A)] → 5V Logic
   │     ↓
   │   [LC Filter: 10µH + 470µF (reduce ripple)]
   │     ↓
   │   [Bypass Caps: 10µF + 0.1µF per IC (local decoupling)]
   │
   └─→ [Ultra Low-Noise LDO: TPS7A4701 (3.3V, 1A)] → 3.3V Analog
         ↓
       [LC Filter: 4.7µH + 100µF (analog supply)]
         ↓
       [Bypass Caps: 10µF + 0.1µF + 10nF per ADC (wideband decoupling)]
```

**Key Features:**

**1. Linear Regulators (Not Switching)**
- Switching regulators inject noise (100kHz-2MHz)
- Linear regulators: No switching noise
- Trade-off: Lower efficiency (60-70% vs 85-95%)
- For sensitive analog: Worth it!

**2. Separate 3.3V for Analog**
- Dedicated regulator for ADC/analog circuits
- AGND plane separate from DGND
- Single-point tie at power supply
- Reduces digital noise coupling into analog

**3. Multi-Stage Filtering**
```
Stage 1: Input filter (100µH + 1000µF)
  - Removes supply line noise
  - Attenuation: -40dB @ 100kHz

Stage 2: Post-regulator LC filter
  - Removes regulator noise (PSRR not perfect)
  - Attenuation: -20dB @ 10kHz

Stage 3: Local bypass capacitors
  - 10µF: Low-frequency (1kHz-100kHz)
  - 0.1µF: High-frequency (100kHz-10MHz)
  - 10nF: Very high-frequency (10MHz-100MHz)
  - Placed <5mm from IC power pins
```

**4. Ferrite Beads**
- On all power lines entering IC
- Impedance: 100Ω @ 100MHz
- Suppresses conducted EMI
- Murata BLM18 series (0603 size)

### Ground Plane Strategy

```
┌────────────────────────────────────────────────────────────┐
│                    PCB Stackup (4-layer)                    │
├────────────────────────────────────────────────────────────┤
│  Layer 1: Top         - Signal routing + components        │
│  Layer 2: Ground      - Continuous ground plane (DGND)     │
│  Layer 3: Power       - 3.3V, 5V, 12V power planes         │
│  Layer 4: Bottom      - Signal routing + ground stitching  │
└────────────────────────────────────────────────────────────┘

Ground Partitioning:
┌──────────┬──────────┬──────────┬──────────┐
│  AGND    │  DGND    │  PGND    │  SHIELD  │
│ (Analog) │ (Digital)│ (Power)  │ (Chassis)│
└────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     └──────────┴──────────┴──────────┘
            Single Point Tie
         (at power supply input)

Rules:
1. AGND for: ADC, op-amps, analog sensors
2. DGND for: MCU, I/O expanders, logic ICs
3. PGND for: Relays, high-current loads
4. SHIELD for: Metal enclosure (safety ground)

Stitching Vias:
- Every 10mm around board perimeter
- Connects top ground to layer 2 ground plane
- Reduces ground impedance
- Provides return path for high-frequency currents
```

---

## EMI/RFI Mitigation Techniques

### 1. Shielding

**Metal Enclosure:**
- Material: Aluminum or steel (>1mm thick)
- Conductivity: Aluminum = 3.8×10⁷ S/m
- Shielding effectiveness: >60dB @ 100MHz
- All seams: Continuous (no gaps >λ/10)

**Internal Shields:**
- Separate compartments for:
  * Power supply
  * Analog section (ADC, op-amps)
  * Digital section (MCU, I/O)
  * Relay section (high voltage)
- Partitions: 0.5mm aluminum sheet
- Connected to SHIELD ground

**Cable Shielding:**
- Zone wires: Twisted pair (reduces magnetic pickup)
- Analog sensors: Shielded cable (braid + drain wire)
- Smoke detectors: Shielded cable (reduces EMI to/from)
- Shield termination: 360° at connector (not pigtail!)

### 2. Filtering at Connectors

**All External Cables:**
```
Connector → [Ferrite Bead] → [TVS Diode] → [LC Filter] → Circuit

Ferrite Bead: Fair-Rite 2743002112 (300Ω @ 100MHz)
TVS Diode: Bi-directional, 15kV ESD
LC Filter: 10µH + 100nF (cutoff = 160kHz)
```

**Benefit:** Stops conducted EMI at the boundary

### 3. PCB Trace Routing

**Rules:**
1. **Differential pairs**: Route adjacent, same length (±0.5mm)
2. **High-speed signals**: Route over ground plane (controlled impedance)
3. **Analog signals**: Route perpendicular to digital (minimize coupling)
4. **Clock traces**: Short (<50mm), avoid vias, ground guard on both sides
5. **Power traces**: Wide (40-60 mil), short, bypass caps every 20mm

**Clearances:**
- Analog to digital: ≥5mm
- High voltage (12V) to logic (3.3V): ≥3mm
- Traces to board edge: ≥5mm

### 4. Component Placement

```
Power Supply   │  Analog Section   │  Digital Section  │  Relay Section
(Input)        │  (ADC, Op-Amps)   │  (MCU, I/O)       │  (12V, Relays)
───────────────┼───────────────────┼───────────────────┼────────────────
Left side      │  Lower-left       │  Center           │  Right side

Signal Flow: Input → Analog → Digital → Output
Minimize return current path length
```

---

## Interference Testing & Validation

### Conducted Emissions (CE) Testing

**Test Setup:**
- LISN (Line Impedance Stabilization Network)
- Spectrum analyzer (9kHz - 30MHz)
- Measure on power input lines

**Limits:**
- EN 55022 Class B: 66 dBµV @ 30MHz
- FCC Part 15 Class B: Similar

**Expected Result:**
- With filtering: 40-50 dBµV (pass with margin)

### Radiated Emissions (RE) Testing

**Test Setup:**
- Semi-anechoic chamber (3m)
- Biconical antenna (30MHz-300MHz)
- Log-periodic antenna (300MHz-1GHz)

**Limits:**
- EN 55022 Class B: 30 dBµV/m @ 3m @ 30MHz
- FCC Part 15 Class B: Similar

**Expected Result:**
- With metal enclosure: 20-25 dBµV/m (pass)

### ESD Testing (IEC 61000-4-2)

**Test:**
- Contact discharge: ±4kV (Level 2)
- Air discharge: ±8kV (Level 3)
- Test on all external terminals

**Protection:**
- TVS diodes: Handle ±15kV
- Pass Level 3 (industrial equipment)

### Burst/Surge Testing (IEC 61000-4-4/5)

**Burst (IEC 61000-4-4):**
- Fast transients: ±2kV (Level 3)
- Repetition rate: 5kHz
- Test on power and I/O lines

**Surge (IEC 61000-4-5):**
- Slow transients: ±1kV differential, ±2kV common mode
- Test on power lines

**Protection:**
- Input TVS + filter: Pass Level 3

---

## Crosstalk Prevention

### Zone-to-Zone Crosstalk

**Problem:** Adjacent zone wires can couple signals

**Solution:**
1. **Twisted pairs**: Each zone = twisted pair (reduces magnetic coupling)
2. **Guard traces**: Ground trace between adjacent zone inputs on PCB
3. **Differential sensing**: If ultra-low crosstalk needed (not implemented yet)

**Measurement:**
- Drive zone 1 with 1kHz square wave
- Measure crosstalk on zone 2
- Should be <-60dB (<0.1% coupling)

### Analog-to-Analog Crosstalk

**Problem:** Analog inputs can couple via shared ADC/op-amp supply

**Solution:**
1. **Separate supply filtering per op-amp**
2. **Star ground topology** (all return to single point)
3. **Guard rings** around sensitive traces (driven at AGND)

**Measurement:**
- Apply 1V sine wave to analog input 1
- Measure coupling on analog input 2
- Should be <-80dB (<0.01% coupling)

### Digital-to-Analog Coupling

**Problem:** Digital switching (MCU, I/O expanders) couples into analog

**Solution:**
1. **Separate power supplies** (3.3V analog from dedicated LDO)
2. **Spatial separation** (analog section far from digital)
3. **Ground plane partitioning** (AGND separate from DGND)
4. **Slow digital edges** (reduce dI/dt, less EMI)

**Measurement:**
- Run MCU at full speed (168 MHz)
- Measure ADC noise floor
- Should be <1 LSB RMS (~0.8mV)

---

## Summary: Signal Integrity Checklist

### Power Supply
- [x] Linear regulators (no switching noise)
- [x] Separate 3.3V for analog circuits
- [x] Multi-stage LC filtering
- [x] Local bypass capacitors (<5mm from IC pins)
- [x] Ferrite beads on power lines

### PCB Layout
- [x] 4-layer stackup (top signal, ground plane, power plane, bottom signal)
- [x] Continuous ground plane (no splits except partition boundaries)
- [x] Star ground topology (single-point tie)
- [x] Wide power traces (40-60 mil)
- [x] Guard traces around sensitive signals
- [x] Ground stitching vias every 10mm

### Input Protection
- [x] TVS diodes on all external connections (±15kV ESD)
- [x] RC filters on all inputs (remove RF noise)
- [x] Schmitt triggers on digital inputs (clean up noisy signals)
- [x] Optical isolation on zone inputs (2.5kV, eliminate ground loops)

### EMI/RFI Mitigation
- [x] Metal enclosure (>60dB shielding)
- [x] Cable shielding (twisted pair for zones, shielded for analog)
- [x] Ferrite beads at connectors
- [x] LC filters at boundary
- [x] Separate compartments (power, analog, digital, relay)

### Signal Conditioning
- [x] Smoke detectors: Supervised loop, latching, LC filtered 12V supply
- [x] Analog sensors: Op-amp buffer, anti-aliasing filter, 12-bit ADC
- [x] Zone inputs: EOL detection, optoisolated, debounced
- [x] Pulse counters: Schmitt trigger, monostable debounce, edge detect

### Testing & Validation
- [x] Conducted emissions: <50 dBµV (pass Class B)
- [x] Radiated emissions: <25 dBµV/m (pass Class B)
- [x] ESD: ±15kV (pass Level 3)
- [x] Burst/surge: ±2kV (pass Level 3)
- [x] Crosstalk: <-60dB zone-to-zone, <-80dB analog-to-analog

**Result:** Hub can reliably process all sensor signals simultaneously with no interference, even in close proximity. Safe for life-safety applications (smoke, CO).

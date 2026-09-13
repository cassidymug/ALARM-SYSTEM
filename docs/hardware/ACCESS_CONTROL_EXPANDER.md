# Guardian — Access Control Expander Hardware Specification

**Product:** 8-output access control module with power distribution  
**Owner:** Cassidy Mugadza  
**Target:** Ethernet-connected output control module for Guardian Hub  
**Status:** Hardware design phase — specification  
**Version:** 0.1  
**Date:** 2026-09-13  

---

## 1. Overview

The **Guardian Access Control Expander** is a purpose-built output control module that connects to the Guardian Hub via Ethernet. It provides professional-grade control for physical security devices including magnetic locks, electric strikes, solenoids, gate motors, and electronic locks.

### Key Specifications

- **8 independently controlled outputs** with configurable power modes
- **Output types:** 4× relay (high-power) + 4× solid-state (fast switching)
- **Power distribution:** Dedicated power supplies for different lock types
- **Door position feedback:** 8 supervised input channels for door/gate status
- **Connectivity:** Ethernet (matches zone expander architecture)
- **MCU:** STM32G4 class (ARM Cortex-M4)
- **Power:** 12-24V DC input with multi-rail output
- **Safety:** Fail-safe/fail-secure modes per output
- **PCB target:** PCBWay fabrication (4-layer ENIG)

---

## 2. Use Cases

### 2.1 Supported Devices

| Device Type | Typical Specs | Control Method | Power Requirement |
|-------------|---------------|----------------|-------------------|
| **Magnetic Lock** | 12V/24V, 150-1200 lbf | Relay (NC for fail-secure) | 12V @ 500mA - 24V @ 250mA |
| **Electric Strike** | 12V/24V, fail-safe/secure | Relay + PWM hold | 12V @ 1.5A (inrush), 500mA hold |
| **Solenoid Lock** | 12V/24V, 1-2A | Relay + inductive protection | 12V/24V @ 1-2A |
| **Electronic Lock** | 12V, <500mA | Solid-state (MOSFET) | 12V @ 500mA |
| **Gate Motor** | 12-24V, 2-5A | High-power relay + interlock | 24V @ 5A (per direction) |
| **Door Closer** | 12V, 1A | Solid-state or relay | 12V @ 1A |

### 2.2 Integration with Guardian Hub

- **Access Control Events:**
  - User authenticated via keypad/NFC → Hub sends unlock command
  - Schedule-based unlocking (office hours, loading dock)
  - Remote unlock via mobile app/dashboard
  - Emergency unlock (fire alarm integration)
  - Lockdown mode (security event)

- **Feedback to Hub:**
  - Door position (open/closed via magnetic contact)
  - Lock status (engaged/disengaged if lock has feedback)
  - Forced entry detection (door opened without unlock command)
  - Door held open alarm (timeout exceeded)

---

## 3. Hardware Architecture

### 3.1 Block Diagram

```
┌────────────────────────────────────────────────────────────┐
│                   ACCESS CONTROL EXPANDER                  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  12-24V DC Input                                           │
│      │                                                     │
│      ├──► 24V Rail (for 24V mag locks, gate motors)       │
│      ├──► 12V Rail (for 12V locks, strikes, solenoids)    │
│      └──► 3.3V Buck (MCU, Ethernet)                       │
│                                                            │
│  ┌──────────────────────────────────────────────────┐     │
│  │  MCU (STM32G431)                                 │     │
│  │  • Ethernet (W5500 SPI)                          │     │
│  │  • 8 output control GPIOs                        │     │
│  │  • 8 door status ADC inputs                      │     │
│  │  • PWM for inrush limiting                       │     │
│  └──────────────────────────────────────────────────┘     │
│                                                            │
│  ┌──────────────────────────────────────────────────┐     │
│  │  Output Drivers (8 channels)                     │     │
│  │                                                  │     │
│  │  Relay Outputs (1-4): High-power switching       │     │
│  │  • SPDT 10A @ 250VAC / 30VDC                     │     │
│  │  • Flyback protection                            │     │
│  │  • Configurable NO/NC (fail-safe/fail-secure)    │     │
│  │                                                  │     │
│  │  Solid-State Outputs (5-8): Fast switching       │     │
│  │  • N-MOSFET, 5A continuous                       │     │
│  │  • PWM-capable (for inrush limiting)             │     │
│  │  • Overcurrent protection                        │     │
│  └──────────────────────────────────────────────────┘     │
│                                                            │
│  ┌──────────────────────────────────────────────────┐     │
│  │  Door Status Inputs (8 channels)                 │     │
│  │  • Supervised inputs (like zone expander)        │     │
│  │  • Detects: Closed / Open / Tamper               │     │
│  │  • TVS protection                                │     │
│  └──────────────────────────────────────────────────┘     │
│                                                            │
│  Ethernet (W5500 + MagJack) → Guardian Hub                │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 3.2 Output Channel Specifications

#### Relay Outputs (Channels 1-4)

**Purpose:** High-power devices requiring isolation or AC switching

**Specifications:**
- **Relay type:** SPDT (Form-C), 10A @ 250VAC / 30VDC
- **Coil voltage:** 12V
- **Driver:** NPN transistor with flyback diode
- **Terminal blocks:** 3-position (NO, COM, NC)
- **Indicators:** LED per channel (relay energized)
- **Use cases:**
  - Magnetic locks (12V/24V, up to 2A)
  - Electric strikes (12V/24V, up to 5A inrush)
  - Gate motors (direction control, interlock logic)
  - High-power solenoids

**Configurable Modes:**
- **Fail-secure:** Use NC contact (power loss = locked)
- **Fail-safe:** Use NO contact (power loss = unlocked)
- **Momentary:** Pulse for X milliseconds, then release
- **Latched:** Hold until explicitly turned off

#### Solid-State Outputs (Channels 5-8)

**Purpose:** Fast switching, PWM-capable, low-power devices

**Specifications:**
- **Switching element:** N-channel MOSFET (AO3400 or similar)
- **Current rating:** 5A continuous, 10A peak
- **Voltage:** Configurable 12V or 24V rail
- **Overcurrent:** Self-resetting polyfuse or active monitoring
- **Terminal blocks:** 2-position (+OUT, GND)
- **Indicators:** LED per channel (output active)
- **Use cases:**
  - Electronic locks (12V, <500mA)
  - Low-power solenoids
  - Door holders/closers
  - Indicator lights / strobes

**PWM Capabilities:**
- **Inrush limiting:** High current (100%) for 100-500ms, then hold current (30-50%)
- **Soft start:** Ramp up to avoid inductive spikes
- **Frequency:** 1 kHz - 20 kHz (silent operation)

### 3.3 Door Status Inputs

**Purpose:** Feedback for door/gate position and forced entry detection

**Specifications:**
- **Channels:** 8 (one per output, or shared)
- **Circuit:** Supervised like zone expander
  - 10kΩ pull-up
  - Detects: Closed (loop) / Open (no loop) / Tamper (wrong resistance)
- **Input device:** Magnetic door contact, limit switch, or position sensor
- **Protection:** TVS diodes
- **Use cases:**
  - Door position monitoring
  - Forced entry detection (door opened without unlock command)
  - Door held open alarm (timeout)
  - Gate position (open, closed, moving)

### 3.4 Power Supply

#### Input

- **Voltage:** 12-24V DC (auto-sensing or selectable)
- **Connector:** Screw terminal (2-position, high-current)
- **Protection:** Reverse polarity, fuse (5A slow-blow)
- **Input filtering:** Bulk capacitors, TVS diode

#### Output Rails

1. **24V Rail** (optional, if 24V input used)
   - Direct feed from input (after protection)
   - For 24V mag locks, gate motors
   - Current: Up to 5A total

2. **12V Rail**
   - Buck converter from input (if >12V) or direct (if 12V input)
   - For 12V mag locks, strikes, solenoids, relay coils
   - Current: Up to 5A total
   - Converter: TPS54531 or similar (5A rated)

3. **3.3V Logic Rail**
   - Buck converter from 12V rail
   - For MCU, W5500, status LEDs
   - Current: 500mA (same as zone expander)
   - Converter: TPS54331 (1.5A rated)

**Total Power Budget:**
- 24V outputs: Up to 5A (120W)
- 12V outputs: Up to 5A (60W)
- Logic: <500mA (<2W)
- **Total input:** Up to 10A @ 12V or 5A @ 24V

---

## 4. MCU & Firmware

### 4.1 Microcontroller

**Selected:** STM32G431CBT6 (same as zone expander for consistency)
- **Core:** ARM Cortex-M4F @ 170 MHz
- **Flash:** 128 KB
- **RAM:** 32 KB
- **Package:** LQFP-48
- **Peripherals:**
  - 3× SPI (W5500 Ethernet)
  - 3× ADC (12-bit, 8 door status inputs)
  - 8× GPIO outputs (relay/MOSFET drivers)
  - 4× TIM (PWM for inrush limiting)
  - 1× SWD (programming/debug)
  - 1× USART (debug console)

### 4.2 Firmware Features

#### Core Functions

1. **Ethernet Communication**
   - W5500 driver (TCP/IP)
   - GXP protocol client (Guardian eXpander Protocol)
   - Heartbeat (every 5 seconds)
   - Command queue (multiple unlock requests)

2. **Output Control**
   - GPIO control for relays (on/off)
   - PWM control for MOSFETs (inrush limiting)
   - Timer-based auto-release (momentary mode)
   - Interlock logic (e.g., gate: open XOR close, never both)

3. **Door Status Monitoring**
   - ADC scan of 8 door inputs (100 Hz)
   - State detection: Closed / Open / Tamper
   - Forced entry detection (door open without unlock)
   - Door held open timer (configurable timeout)

4. **Safety Features**
   - Watchdog timer (auto-reset on hang)
   - Overcurrent detection (via current sense or polyfuse trip)
   - Fail-safe/fail-secure mode enforcement
   - Emergency unlock mode (fire alarm integration)

#### Configuration

Per-output settings (stored in flash):
- **Mode:** Relay or MOSFET
- **Fail mode:** Fail-safe (NO) or fail-secure (NC)
- **Unlock duration:** Momentary (1-10s) or latched
- **Inrush profile:** Duration (ms) and hold percentage (%)
- **Power rail:** 12V or 24V
- **Interlock group:** For gate motors (open/close never simultaneous)

#### Protocol Integration

**GXP Command: UNLOCK_OUTPUT**
```
Message from Hub → Expander:
{
  "type": "UNLOCK_OUTPUT",
  "output_id": 0-7,
  "mode": "momentary" | "latched",
  "duration_ms": 5000,
  "device_id": 0x12345678
}
```

**GXP Event: DOOR_STATUS_CHANGE**
```
Message from Expander → Hub:
{
  "type": "DOOR_STATUS_CHANGE",
  "input_id": 0-7,
  "state": "closed" | "open" | "tamper",
  "output_active": true,
  "timestamp": unix_time,
  "device_id": 0x12345678
}
```

**GXP Event: FORCED_ENTRY**
```
Message from Expander → Hub:
{
  "type": "FORCED_ENTRY",
  "input_id": 0-7,
  "timestamp": unix_time,
  "device_id": 0x12345678
}
```

**GXP Event: DOOR_HELD_OPEN**
```
Message from Expander → Hub:
{
  "type": "DOOR_HELD_OPEN",
  "input_id": 0-7,
  "duration_s": 120,
  "timestamp": unix_time,
  "device_id": 0x12345678
}
```

---

## 5. Physical Design

### 5.1 PCB Layout

- **Size:** ~150mm × 100mm (similar to zone expander)
- **Layers:** 4-layer stackup
  - L1: Signal (components, traces)
  - L2: GND plane
  - L3: PWR plane (12V, 24V zones)
  - L4: Signal (bottom traces)
- **Mounting:** 4× M3 holes, DIN rail clips

### 5.2 Connectors

| Connector | Type | Pins | Purpose |
|-----------|------|------|---------|
| **J1** | Screw terminal | 2 | Power input (12-24V DC) |
| **J2-J5** | Screw terminal | 3 | Relay outputs 1-4 (NO/COM/NC) |
| **J6-J9** | Screw terminal | 2 | MOSFET outputs 5-8 (+OUT/GND) |
| **J10-J17** | Screw terminal | 2 | Door status inputs 1-8 (+IN/GND) |
| **J20** | RJ45 MagJack | 8 | Ethernet (W5500) |
| **J30** | 2×5 header (1.27mm) | 10 | SWD programming |
| **J31** | 1×3 header (2.54mm) | 3 | UART debug |

### 5.3 Status LEDs

- **Power:** Green (3.3V active)
- **Link:** Yellow (Ethernet connected)
- **Activity:** Blue (data transfer)
- **Output 1-8:** Red/Green (per output, active/error)

### 5.4 Thermal Considerations

- **Heatsinks:** Optional for high-power MOSFETs (if sustained >2A)
- **Airflow:** Natural convection (no fan required)
- **Temperature sensors:** Optional thermistor for monitoring

---

## 6. Safety & Compliance

### 6.1 Electrical Safety

- **Isolation:** Relays provide galvanic isolation (250V rated)
- **Overcurrent:** Fuses and polyfuses
- **Overvoltage:** TVS diodes on all I/O
- **Reverse polarity:** P-channel MOSFET on input

### 6.2 Fire Safety Integration

**Emergency Unlock Mode:**
- When fire alarm is active, hub sends `EMERGENCY_UNLOCK` command
- All outputs configured as fail-safe automatically unlock
- Fail-secure outputs (e.g., stairwell doors) remain locked unless explicitly overridden
- Building code compliance: Ensure fail-safe on egress routes

### 6.3 Standards

- **UL 294** (Access Control System Units) — Design target
- **IEC 60950-1** (Electrical safety)
- **EN 301 489** (EMC for telecom equipment)
- **Building codes:** NFPA 101 (Life Safety Code) — egress requirements

---

## 7. Bill of Materials (Preliminary)

### 7.1 Major Components

| Designator | Part Number | Description | Qty | Unit Price | Ext. Price |
|------------|-------------|-------------|-----|------------|------------|
| U1 | STM32G431CBT6 | MCU (LQFP-48) | 1 | $4.50 | $4.50 |
| U2 | W5500 | Ethernet controller | 1 | $3.20 | $3.20 |
| U3 | TPS54531 | 12V buck (5A) | 1 | $1.80 | $1.80 |
| U4 | TPS54331 | 3.3V buck (1.5A) | 1 | $1.20 | $1.20 |
| K1-K4 | Omron G5V-2 | SPDT relay (10A) | 4 | $2.50 | $10.00 |
| Q1-Q4 | AO3400 | N-MOSFET (SOT-23) | 4 | $0.30 | $1.20 |
| Q5-Q12 | 2N2222 | NPN transistor | 8 | $0.10 | $0.80 |
| D1-D20 | Various | Diodes (Schottky, TVS, flyback) | 20 | $0.25 | $5.00 |
| J1-J17 | Phoenix | Screw terminals | 17 | $1.00 | $17.00 |
| J20 | Hanrun HR911105A | RJ45 MagJack | 1 | $1.50 | $1.50 |
| Passives | Various | R, C, L | ~100 | — | $10.00 |
| PCB | PCBWay | 4-layer, 150×100mm | 1 | $30.00 | $30.00 |
| **TOTAL** | | | | | **~$86/unit** |

### 7.2 Cost at Volume

- **Prototype (5 units):** ~$100/unit (includes setup)
- **Production (100 units):** ~$60/unit
- **Production (1000 units):** ~$40/unit

---

## 8. Development Plan

### Phase 1: Schematic Design (Week 1-2)
- [ ] Create hierarchical KiCad 8 schematic
- [ ] Power supply design (12V, 24V, 3.3V rails)
- [ ] MCU circuit (STM32G431)
- [ ] Ethernet circuit (W5500 + MagJack)
- [ ] Relay driver circuits (×4)
- [ ] MOSFET driver circuits (×4)
- [ ] Door status input circuits (×8)
- [ ] Protection circuits (TVS, flyback, fuses)
- [ ] Connectors and status LEDs

### Phase 2: PCB Layout (Week 3-4)
- [ ] Component placement (power first, then signal)
- [ ] Power plane routing (12V, 24V, GND)
- [ ] High-current trace routing
- [ ] Differential pair routing (Ethernet)
- [ ] Signal routing (SPI, GPIO, ADC)
- [ ] DRC and clearance verification
- [ ] Generate Gerbers + BOM

### Phase 3: Firmware Development (Week 5-8)
- [ ] W5500 driver (SPI Ethernet)
- [ ] GXP protocol client (TCP)
- [ ] Relay control (GPIO)
- [ ] MOSFET control (PWM)
- [ ] Door status monitoring (ADC)
- [ ] Forced entry detection
- [ ] Inrush limiting PWM
- [ ] Configuration storage (flash)
- [ ] Watchdog and safety features

### Phase 4: Testing & Integration (Week 9-10)
- [ ] Power supply testing (12V, 24V, 3.3V rails)
- [ ] Output testing (relays, MOSFETs, load tests)
- [ ] Door status input testing
- [ ] Ethernet connectivity
- [ ] Hub integration (GXP commands)
- [ ] Load testing (multiple outputs active)
- [ ] Thermal testing (sustained load)
- [ ] EMC pre-compliance

### Phase 5: Hub Software Integration (Week 11-12)
- [ ] `guardian-access` service (Zig)
- [ ] GXP server for access control commands
- [ ] User authentication flow (keypad → unlock)
- [ ] Schedule-based unlocking
- [ ] Mobile app integration (remote unlock)
- [ ] Dashboard UI (access logs, door status)

---

## 9. Hub Integration Architecture

### 9.1 System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    GUARDIAN HUB (NUC)                       │
│                                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │  guardian-access (Zig service)                    │     │
│  │  • GXP server for access control expanders       │     │
│  │  • User authentication (keypad, NFC, mobile)     │     │
│  │  • Schedule engine (time-based unlocking)        │     │
│  │  • Access log database (who/when/where)          │     │
│  └───────────────┬───────────────────────────────────┘     │
│                  │                                          │
│  ┌───────────────▼───────────────────────────────────┐     │
│  │  guardian-alarm (Main logic)                      │     │
│  │  • Fire alarm integration (emergency unlock)     │     │
│  │  • Lockdown mode (security event → lock all)     │     │
│  │  • Forced entry → trigger zone alarm             │     │
│  └───────────────────────────────────────────────────┘     │
│                                                             │
└──────────────────────┬──────────────────────────────────────┘
                       │ Ethernet (GXP over TCP)
         ──────────────┼──────────────
         │             │             │
    ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
    │  Zone   │   │ Access  │   │ Access  │
    │Expander │   │Control  │   │Control  │
    │  #1     │   │Expander │   │Expander │
    │ (Zones) │   │   #1    │   │   #2    │
    └─────────┘   └────┬────┘   └────┬────┘
                       │             │
                  ┌────▼───┐    ┌────▼───┐
                  │ Mag    │    │ Strike │
                  │ Lock   │    │ Front  │
                  │ (12V)  │    │ Door   │
                  └────────┘    └────────┘
```

### 9.2 Access Control Flow

**User Authentication → Unlock:**
```
1. User enters code on keypad (or presents NFC card)
2. Keypad sends to Hub via guardian-keypad service
3. guardian-access validates credentials
4. guardian-access checks schedule (is it allowed now?)
5. guardian-access sends UNLOCK_OUTPUT to Access Control Expander
6. Expander activates relay/MOSFET for configured duration
7. Expander monitors door status input
8. If door opens: Log "access granted"
9. If door doesn't open within 10s: Log "access unused"
10. If door opens WITHOUT unlock: Trigger FORCED_ENTRY event
11. guardian-alarm receives FORCED_ENTRY → trigger zone alarm
```

**Fire Alarm → Emergency Unlock:**
```
1. Zone expander detects fire alarm zone activation
2. guardian-alarm receives zone alarm
3. guardian-alarm confirms fire alarm (not false alarm)
4. guardian-alarm sends EMERGENCY_UNLOCK to all access expanders
5. All fail-safe doors unlock immediately
6. Fail-secure doors remain locked (stairwell, server room, etc.)
7. Access logs record emergency unlock event
```

---

## 10. Future Enhancements

### 10.1 Potential Features

- **PoE support:** Eliminate 12-24V power supply (use PoE injector)
- **Wiegand input:** Direct keypad/reader integration (no separate controller)
- **REX input:** Request-to-exit button monitoring (8 inputs)
- **Card reader support:** Built-in RFID/NFC reader interface
- **Biometric integration:** Fingerprint/face recognition interface
- **Elevator control:** Integration with elevator access control
- **Anti-passback:** Track entry/exit to prevent tailgating

### 10.2 Scalability

- **Multiple expanders:** Each expander = 8 doors/gates
- **Large installations:** 10 expanders = 80 doors (typical office building)
- **GXP addressing:** 32-bit device ID (billions of unique devices)
- **VLAN segmentation:** Separate physical security network

---

## 11. Testing Requirements

### 11.1 Hardware Tests

- [ ] Power supply (all rails under load)
- [ ] Relay switching (10k cycles)
- [ ] MOSFET switching (100k cycles)
- [ ] Overcurrent protection (short circuit test)
- [ ] Thermal (sustained 5A load, 2 hours)
- [ ] EMC (radiated/conducted emissions)
- [ ] ESD (contact/air discharge per IEC 61000-4-2)

### 11.2 Firmware Tests

- [ ] Ethernet connectivity (link up/down)
- [ ] GXP command processing (all message types)
- [ ] Output control (all 8 channels)
- [ ] PWM inrush limiting (oscilloscope verification)
- [ ] Door status monitoring (all states)
- [ ] Forced entry detection (timing accuracy)
- [ ] Watchdog recovery (firmware hang simulation)

### 11.3 Integration Tests

- [ ] Hub communication (command/response)
- [ ] User authentication flow (keypad → unlock)
- [ ] Schedule-based unlocking (time accuracy)
- [ ] Fire alarm emergency unlock (latency <1s)
- [ ] Forced entry alarm (integration with zone expander)
- [ ] Multiple simultaneous unlocks (load test)

---

## 12. Documentation Deliverables

- [ ] Hardware specification (this document)
- [ ] KiCad schematic (hierarchical, all sheets)
- [ ] PCB layout guide
- [ ] Bill of materials (BOM) with vendor links
- [ ] Firmware architecture document
- [ ] GXP protocol specification (access control commands)
- [ ] User manual (installation, wiring, configuration)
- [ ] Hub integration guide (for guardian-access service)

---

**End of Specification**

*Guardian Access Control Expander — Professional-grade output control for physical security devices. Ethernet-connected, STM32-based, no cloud lock-in.*

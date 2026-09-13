# Guardian Zone Expander - Hardware Specifications

## GXP-32 Multi-Sensor Hub

The Guardian Zone Expander is a **multi-function sensor hub** that supports various sensor types beyond simple door/window contacts.

## Supported Sensor Types

### 1. Contact Sensors (Zone Inputs)
- Door/window contacts (NC/NO)
- Glass break detectors
- Panic buttons
- Tamper switches

### 2. Smoke & Fire Detection
- **4× dedicated smoke detector inputs** (supervised)
- 12V power output for hardwired smoke detectors
- Supports 2-wire or 4-wire smoke detectors
- Latching alarm (manual reset required)
- UL Listed compatibility

### 3. Analog Sensor Inputs
- **8× analog inputs** (12-bit ADC, 0-3.3V)
  - Temperature sensors (DS18B20, NTC thermistor)
  - Humidity sensors
  - Light level sensors
  - Gas sensors (CO, methane, propane)
  - Vibration sensors

### 4. PIR Motion Detectors
- **Direct wiring** via zone inputs (NC/NO)
- Supports supervised zones with EOL resistors
- Pet-immune compatible
- Dual-technology (PIR + microwave) support

### 5. Metal Detectors
- **2× pulse counter inputs** (high-speed)
  - Supports walk-through metal detectors
  - Pulse counting for event detection
  - Tamper detection

### 6. Relay Outputs
- **4× relay outputs** (SPDT, 5A @ 30V DC)
  - Control sirens, lights, locks
  - Fire alarm notification
  - HVAC shutdown on smoke

## Hardware Block Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                Guardian GXP-32 Zone Expander                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Main Controller (STM32F407)                    │ │
│  │  - 168 MHz ARM Cortex-M4                                   │ │
│  │  - 192 KB RAM, 1 MB Flash                                  │ │
│  │  - 3× 12-bit ADC (analog sensors)                          │ │
│  │  - 2× SPI (W5500 Ethernet)                                 │ │
│  │  │  - USART (RS-485)                                        │ │
│  └──┴───────────────────────────────────────────────────────────┘ │
│     │                                                             │
│  ┌──▼────────────────────────────────────────────────────────┐  │
│  │          32× Supervised Zone Inputs                        │  │
│  │  - NC/NO/EOL resistor detection                            │  │
│  │  - 12V tolerance, ESD protection                           │  │
│  │  - Individual zone LEDs                                    │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │        4× Dedicated Smoke Detector Inputs                  │ │
│  │  - UL Listed compatible                                    │ │
│  │  - 12V @ 500mA power output per zone                       │ │
│  │  - Latching alarm (manual reset)                           │ │
│  │  - Supervised (tamper detection)                           │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │           8× Analog Sensor Inputs (ADC)                    │ │
│  │  - 0-3.3V input range (12-bit, 0.8mV resolution)           │ │
│  │  - Temperature: DS18B20 (1-Wire), NTC thermistor           │ │
│  │  - Humidity: DHT22, capacitive sensors                     │ │
│  │  - Gas: MQ-2 (smoke), MQ-7 (CO), MQ-5 (gas)               │ │
│  │  - Custom: Any 0-3.3V analog sensor                        │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │          2× Pulse Counter Inputs (Metal Detectors)         │ │
│  │  - High-speed pulse counting (up to 10 kHz)                │ │
│  │  - Walk-through metal detector support                     │ │
│  │  - Configurable threshold                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │               4× Relay Outputs (SPDT)                      │ │
│  │  - 5A @ 30V DC or 3A @ 125V AC                             │ │
│  │  - Optical isolation                                       │ │
│  │  - Siren, strobe, HVAC control                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Communication Interfaces                       │ │
│  │  - RS-485 (half-duplex, 115200 baud)                       │ │
│  │  - Ethernet (W5500, 10/100 Mbps)                           │ │
│  │  - PoE support (802.3af, 15W)                              │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                Power Management                             │ │
│  │  - Input: 12V DC @ 3A (36W)                                │ │
│  │  - PoE: 802.3af (15W, Class 3)                             │ │
│  │  - Battery backup: 12V 7Ah SLA (optional)                  │ │
│  │  - Low-battery detection                                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Status Indicators                              │ │
│  │  - Power LED (green)                                       │ │
│  │  - Network activity (amber)                                │ │
│  │  - Alarm status (red, flashing)                            │ │
│  │  - 32× zone LEDs (individual status)                       │ │
│  │  - Smoke alarm LED (red, latching)                         │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Connector Pinouts

### Zone Inputs (32×)

**Terminal blocks (screw terminals):**
```
Zone 1-32: [COM] [NC] [NO]
  - COM: Common (ground)
  - NC: Normally closed input
  - NO: Normally open input
  - Supports EOL resistor (5.6kΩ recommended)
```

### Smoke Detector Inputs (4×)

**Terminal blocks:**
```
Smoke 1-4: [+12V] [Alarm] [GND]
  - +12V: 12V DC power output (500mA max)
  - Alarm: Supervised alarm input
  - GND: Ground/common
  
Supported smoke types:
  - 2-wire: 12V + Alarm (combined)
  - 4-wire: Separate power and alarm
```

### Analog Sensor Inputs (8×)

**Terminal blocks:**
```
Analog 1-8: [Signal] [+3.3V] [GND]
  - Signal: Analog input (0-3.3V)
  - +3.3V: Sensor power (100mA max per channel)
  - GND: Ground
  
Supported sensors:
  - Temperature: NTC 10kΩ thermistor, DS18B20
  - Humidity: DHT22, capacitive
  - Gas: MQ-2, MQ-7, MQ-5
  - Light: Photoresistor, LDR
  - Custom: Any 0-3.3V analog
```

### Pulse Counter Inputs (2×)

**Terminal blocks:**
```
Pulse 1-2: [Signal] [+5V] [GND]
  - Signal: Digital pulse input (3.3V/5V compatible)
  - +5V: Sensor power (200mA max)
  - GND: Ground
  
Supported devices:
  - Walk-through metal detectors
  - Beam counters
  - Flow sensors
  - Custom pulse devices
```

### Relay Outputs (4×)

**Terminal blocks (SPDT):**
```
Relay 1-4: [COM] [NO] [NC]
  - COM: Common
  - NO: Normally open (closes on activation)
  - NC: Normally closed (opens on activation)
  
Rating: 5A @ 30V DC, 3A @ 125V AC
Isolation: 2.5kV optical

Use cases:
  - Siren control
  - Strobe light
  - HVAC shutdown (fire alarm)
  - Door unlock/lock
```

### Communication

**RS-485:**
```
Terminal block: [A+] [B-] [GND]
  - A+: Data positive
  - B-: Data negative
  - GND: Shield/ground (optional)
  
Topology: Multi-drop bus (32 expanders max)
Termination: 120Ω resistor at both ends
```

**Ethernet:**
```
RJ45 connector: Standard 8P8C
  - PoE compatible (802.3af)
  - Auto-MDIX
  - Link/activity LEDs
```

### Power Input

**Terminal block:**
```
Power: [+12V] [GND]
  - Input: 12V DC @ 3A (36W max)
  - Polarity-protected
  - Fuse: 3A fast-blow
  
Optional PoE:
  - 802.3af (15W, Class 3)
  - Powers expander only (not sensors)
```

## Bill of Materials (BOM)

| Component | Part Number | Qty | Unit Cost | Total |
|-----------|-------------|-----|-----------|-------|
| **MCU** | STM32F407VET6 | 1 | $8.00 | $8.00 |
| **Ethernet** | W5500 module | 1 | $5.00 | $5.00 |
| **RS-485** | MAX485 transceiver | 1 | $0.50 | $0.50 |
| **I/O Expanders** | MCP23017 (I²C, 16-bit) | 2 | $1.00 | $2.00 |
| **Relay Module** | 4-channel 5V relay board | 1 | $4.00 | $4.00 |
| **Voltage Regulators** | LM2596 (12V→5V, 3A) | 1 | $1.00 | $1.00 |
| | AMS1117-3.3 (5V→3.3V, 1A) | 1 | $0.30 | $0.30 |
| **ADC** | Built-in STM32 (12-bit) | - | - | - |
| **Screw Terminals** | 3-pos, 5.08mm pitch | 40 | $0.15 | $6.00 |
| **LEDs** | 5mm (green, amber, red) | 35 | $0.05 | $1.75 |
| **Resistors** | 1/4W (various) | 100 | $0.01 | $1.00 |
| **Capacitors** | Ceramic + electrolytic | 50 | $0.05 | $2.50 |
| **Diodes** | 1N4007, Zener | 40 | $0.05 | $2.00 |
| **Transistors** | 2N2222, BSS138 | 20 | $0.10 | $2.00 |
| **Fuses** | 3A fast-blow | 2 | $0.50 | $1.00 |
| **PCB** | 4-layer, 200×150mm | 1 | $15.00 | $15.00 |
| **Enclosure** | ABS plastic, wall-mount | 1 | $8.00 | $8.00 |
| **Misc** | Connectors, standoffs | - | - | $3.00 |
| **Total BOM** | | | | **$63.05** |

**Retail price (assembled)**: $120 (1.9× BOM cost for assembly + margin)

## Sensor Configuration Examples

### Temperature Monitoring (Server Room)

```json
{
  "analog_input_1": {
    "type": "temperature",
    "sensor": "ntc_10k",
    "name": "Server Room Temp",
    "thresholds": {
      "warning": 28,  // 28°C (82°F)
      "critical": 35, // 35°C (95°F)
      "shutdown": 40  // 40°C (104°F)
    },
    "actions": {
      "warning": "notify",
      "critical": "alarm + notify",
      "shutdown": "alarm + relay_1_on" // Activate HVAC
    }
  }
}
```

### Smoke Detection (Kitchen)

```json
{
  "smoke_input_1": {
    "type": "smoke_detector",
    "location": "Kitchen",
    "supervised": true,
    "actions": {
      "alarm": [
        "activate_all_smoke_alarms",
        "relay_2_on",  // Strobe light
        "relay_3_on",  // Siren
        "notify_fire_department"
      ]
    },
    "reset": "manual" // Requires manual reset
  }
}
```

### Carbon Monoxide Detection

```json
{
  "analog_input_2": {
    "type": "co_detector",
    "sensor": "mq7",
    "name": "Garage CO",
    "thresholds": {
      "warning": 50,   // 50 ppm
      "danger": 150,   // 150 ppm
      "extreme": 400   // 400 ppm
    },
    "actions": {
      "warning": "notify",
      "danger": "alarm + relay_4_on", // Exhaust fan
      "extreme": "evacuate + call_911"
    }
  }
}
```

### Metal Detector (Entrance)

```json
{
  "pulse_input_1": {
    "type": "metal_detector",
    "location": "Main Entrance",
    "threshold": 5, // 5 pulses = alarm
    "timeout_ms": 1000,
    "actions": {
      "detect": [
        "alarm",
        "snapshot_camera",
        "log_event",
        "notify_security"
      ]
    }
  }
}
```

### PIR Motion (Warehouse)

```json
{
  "zone_8": {
    "type": "pir_motion",
    "name": "Warehouse Motion",
    "zone_type": "instant", // No delay
    "pet_immune": true,
    "actions": {
      "triggered": [
        "snapshot_camera",
        "turn_on_lights",
        "log_motion_event"
      ]
    }
  }
}
```

## Technical Specifications

### Environmental
- **Operating temperature**: -10°C to +60°C (14°F to 140°F)
- **Storage temperature**: -40°C to +85°C (-40°F to 185°F)
- **Humidity**: 5% to 95% RH (non-condensing)
- **Altitude**: Up to 3000m (10,000 ft)

### Electrical
- **Input voltage**: 12V DC ±10% (10.8V - 13.2V)
- **Input current**: 3A max (36W)
- **PoE power**: 802.3af, Class 3 (15W)
- **Battery backup**: 12V 7Ah SLA (optional, 8 hours runtime)

### Certifications (Target)
- **UL 864** (Fire alarm control units) - For smoke detection
- **UL 294** (Access control system units)
- **FCC Part 15** (EMI/RFI compliance)
- **CE** (European conformity)
- **RoHS** (Lead-free)

## Comparison to Commercial Expanders

| Feature | Guardian GXP-32 | DSC PC5108 | Honeywell 4204 |
|---------|-----------------|------------|----------------|
| **Zones** | 32 | 8 | 4 (relays) |
| **Smoke inputs** | 4 dedicated | 0 | 0 |
| **Analog inputs** | 8 (ADC) | 0 | 0 |
| **Relay outputs** | 4 | 0 | 4 |
| **Pulse counters** | 2 | 0 | 0 |
| **Protocol** | Open (GXP) | Proprietary | Proprietary |
| **Communication** | RS-485 + Ethernet | Proprietary bus | Proprietary bus |
| **Scalability** | 32 expanders (1024 zones) | Limited | Limited |
| **Price** | **$55 DIY / $120 retail** | $130 | $80 |
| **Open source** | ✅ Yes | ❌ No | ❌ No |

**Guardian GXP-32 is more capable and cheaper!**

## Firmware Features

The STM32 firmware includes:
- GXP protocol handler
- Real-time zone monitoring (100ms poll rate)
- Analog sensor sampling (1 Hz)
- Smoke detector supervision
- Pulse counting (metal detector)
- Relay control logic
- Temperature compensation
- Self-test diagnostics
- Watchdog timer
- OTA firmware updates (via Ethernet)

## Assembly & Testing

**DIY assembly:**
1. Order PCB from JLCPCB/PCBWay ($15 for 5 boards)
2. Order components from DigiKey/Mouser ($48)
3. Solder SMD components (hot air station)
4. Solder through-hole terminals
5. Flash firmware via ST-Link
6. Test all zones, sensors, relays
7. Install in enclosure

**Testing procedure:**
- Power-on self-test (POST)
- Zone continuity test (all 32 zones)
- Smoke input test (supervised loop)
- Analog sensor calibration
- Relay switching test
- Communication test (RS-485 + Ethernet)
- Tamper detection test

**Estimated assembly time**: 2-3 hours (experienced) or 4-6 hours (beginner)

## Safety Notes

**Smoke detectors:**
- Use UL-listed smoke detectors only
- Follow local fire codes (NFPA 72)
- Test monthly, replace every 10 years
- Install on every level + bedrooms

**High voltage:**
- Relays can switch 125V AC - use caution!
- Label relay outputs clearly
- Use proper wire gauge (14 AWG for 15A circuits)

**Battery backup:**
- SLA batteries contain lead - dispose properly
- Replace every 3-5 years
- Charge before installation

**ESD protection:**
- Handle PCB by edges
- Use ESD wrist strap during assembly
- Store in anti-static bag

---

This expander is the heart of the Guardian alarm system - supporting everything from simple door contacts to sophisticated smoke detection and environmental monitoring!

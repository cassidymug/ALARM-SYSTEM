# Guardian Zone Expander — System Architecture & Connection Diagram

**Document:** Complete schematic overview and functional description  
**Date:** 2026-09-13  
**Version:** 0.1  

---

## Table of Contents

1. [High-Level Block Diagram](#high-level-block-diagram)
2. [Power Distribution Architecture](#power-distribution-architecture)
3. [Zone Input Signal Flow](#zone-input-signal-flow)
4. [MCU Peripheral Connections](#mcu-peripheral-connections)
5. [Ethernet Communication Path](#ethernet-communication-path)
6. [Output Driver Architecture](#output-driver-architecture)
7. [Complete Connection Matrix](#complete-connection-matrix)
8. [Functional Operation](#functional-operation)

---

## High-Level Block Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GUARDIAN ZONE EXPANDER v0.1                              │
│                    32-Zone Supervised Wired Alarm Module                    │
└─────────────────────────────────────────────────────────────────────────────┘

                          ┌──────────────────┐
                          │   12V DC INPUT   │
                          │   (Barrel Jack)  │
                          │       J1         │
                          └────────┬─────────┘
                                   │ 12V
                            ┌──────┴──────┐
                            │  Fuse (2A)  │
                            │     F1      │
                            └──────┬──────┘
                                   │ 12V (protected)
                            ┌──────┴──────────┐
                            │ Reverse Polarity│
                            │   Protection    │
                            │   Schottky D1   │
                            └──────┬──────────┘
                                   │ 12V (protected)
                    ┌──────────────┼──────────────┐
                    │              │              │
                    │       ┌──────┴──────┐      │ +12V Rail
                    │       │Buck Converter│      │ (to Outputs)
                    │       │  TPS54331   │      │
                    │       │     U1      │      ├────────► Siren MOSFET (Q1)
                    │       └──────┬──────┘      │
                    │              │ 3.3V        └────────► Relay Coils (K1, K2)
                    │              │
                    │       ┌──────┴──────┐
                    │       │    +3.3V    │ Main Logic Rail
                    │       │  Power Net  │
                    │       └──┬──┬───┬───┘
                    │          │  │   │
         ┌──────────┴────┐     │  │   │
         │   Zone Banks  │     │  │   │
         │  32 Pull-Ups  │◄────┘  │   │
         │  R100-R407    │        │   │
         │    (10kΩ)     │        │   │
         └───────────────┘        │   │
                                  │   │
              ┌───────────────────┘   │
              │ STM32G431CBT6         │
              │  Microcontroller      │
              │        U2             │
              │                       │
              │ • Cortex-M4F 170MHz   │
              │ • 48-pin LQFP         │
              │ • 32 ADC inputs       │
              │ • SPI master          │
              │ • GPIO outputs        │
              └─┬───┬───┬─────┬───┬───┘
                │   │   │     │   │
        ┌───────┘   │   │     │   └─────────┐
        │ ADC       │   │     │ GPIO        │ SPI
        │ Inputs    │   │     │ Outputs     │ Bus
        │           │   │     │             │
    ┌───▼─────┐     │   │  ┌──▼──┐      ┌──▼─────────┐
    │ 32 Zones│     │   │  │Siren│      │  W5500     │
    │ Banks   │     │   │  │ Q1  │      │  Ethernet  │
    │ 1-4     │     │   │  └─────┘      │ Controller │
    │         │     │   │               │     U3     │
    │ EOL 4.7k│     │   │  ┌────┐       └─────┬──────┘
    │ (user)  │     │   │  │Relay│            │ TX±/RX±
    └───┬─────┘     │   │  │K1/K2│            │
        │           │   │  └─────┘       ┌────▼─────┐
        │ Field     │   │                │ MagJack  │
        │ Wiring    │   │ Debug          │ RJ45 +   │
        │           │   │ Access         │ Magnetics│
    ┌───▼───────┐   │   │                │    J4    │
    │ Sensors:  │   │   │                └────┬─────┘
    │ • Doors   │   │   │                     │
    │ • Windows │   │   └─► SWD Header        │ Ethernet
    │ • PIRs    │   │         J2              │ Cable
    │ • Tampers │   │                         │
    │ • Panic   │   └──► UART Header     ┌────▼────┐
    └───────────┘           J3 (opt)     │ Network │
                                         │ Switch/ │
                            8MHz Crystal │ Router  │
                            Y1 + Caps    └────┬────┘
                            (HSE Clock)       │
                                         ┌────▼────────┐
                            Reset Button │   Guardian  │
                            SW1 → NRST   │   Hub (NUC) │
                                         │             │
                            Status LEDs  │ GXP Protocol│
                            • Power (D10)│   Server    │
                            • Link       └─────────────┘
                            • Activity
```

---

## Power Distribution Architecture

### 12V DC Input Stage

```
12V DC Input (J1 Barrel Jack, Center Positive, 2.1mm)
    │
    ├─── Pin 1 (Tip): +12V
    ├─── Pin 2 (Ring): Switched GND (with internal disconnect switch)
    └─── Pin 3 (Sleeve): GND
         │
         │ Step 1: Overcurrent Protection
         ├─► F1 (Fuse, 2A Slow-Blow, 1206 SMD)
         │   • Protects against shorts, overcurrent
         │   • Blows at sustained >2A draw
         │
         │ Step 2: Reverse Polarity Protection
         ├─► D1 (Schottky Diode, SS34, SMA package)
         │   • Cathode to +12V rail (forward biased in normal operation)
         │   • Anode to input side (blocks reverse voltage)
         │   • Vf ≈ 0.5V @ 1A (low voltage drop)
         │   • If 12V reversed: diode blocks, no current flows
         │
         │ Step 3: Input Bulk Filtering
         ├─► C1 (100µF Electrolytic, 25V)
         │   • Smooths input voltage ripple
         │   • Provides reservoir for transient loads
         │
         ▼
    +12V Protected Rail
         │
         ├──────────────────────────────┬─────────────────────┐
         │                              │                     │
         │ To Buck Converter            │ To Output Drivers   │
         ▼                              ▼                     ▼
    ┌────────────┐              ┌──────────┐         ┌──────────┐
    │ TPS54331   │              │ Siren    │         │ Relays   │
    │ Buck (U1)  │              │ MOSFET   │         │ K1, K2   │
    │ 12V → 3.3V │              │ (Q1)     │         │ Coils    │
    │ @ 1.5A     │              │ Drain    │         │          │
    └─────┬──────┘              └──────────┘         └──────────┘
          │                          │                     │
          │ 3.3V Output         12V Switched          12V Switched
          │ (Max 1.5A)          (via MCU GPIO)        (via MCU GPIO)
          │                          │                     │
          │                     Siren Terminal        Relay Terminals
          │                     J50 (2-pos)           J51, J52 (3-pos)
          │
          ▼
    +3.3V Logic Rail
```

### Buck Converter Detail (TPS54331)

```
                   TPS54331 Synchronous Buck Converter (U1)
                   ┌────────────────────────────────────┐
                   │                                    │
    +12V ─────────►│ VIN (Pin 2)              SW (Pin 7)├───┐
    (from D1)      │  • Input: 10-14V          • Switch  │   │
                   │  • Enable threshold       • 600kHz  │   │
                   │                                     │   │
    +3.3V ────────►│ EN (Pin 3)                         │   │
    (via R-divider)│  • Enable input                    │   │
                   │  • Pull to VIN for always-on       │   │
                   │                                     │   │
    GND ──────────►│ GND (Pin 4)           BOOT (Pin 1) │◄──┤
                   │  • Power ground                    │   │
                   │                                     │   │ L1 (22µH)
    Feedback ─────►│ VSENSE (Pin 5)                     │   │ Inductor
    (from R1/R2)   │  • Output voltage sense            │   │
                   │  • Target: 0.6V ref                │   ├───┐
                   │                                     │   │   │
    Compensation ─►│ COMP (Pin 6)                       │   │   │
    (RC network)   │  • Loop compensation               │   │   │
                   │                                     │   │   │
    Power Good ───►│ PWRGD (Pin 8)                      │   │   │
    (to MCU)       │  • High when output in regulation  │   │   │
                   └────────────────────────────────────┘   │   │
                                                            │   │
                        SW Node (switching at 600kHz)      │   │
                                 │                          │   │
                                 ├──► L1 (22µH) ───────────┘   │
                                 │    • Energy storage          │
                                 │    • Current smoothing       │
                                 │                              │
                                 │                              │
                        ┌────────┴────────┐                    │
                        │ C2 (47µF)       │◄───────────────────┘
                        │ Output Cap      │    +3.3V Output
                        │ (Ceramic)       │
                        └────────┬────────┘
                                 │
                        ┌────────┴────────┐
                        │ C3 (10µF)       │ Additional bulk
                        └────────┬────────┘
                                 │
                        ┌────────┴────────┐
                        │ C4, C5 (100nF)  │ High-freq decoupling
                        └────────┬────────┘
                                 │
                                GND
                                
    Feedback Divider:
    +3.3V ─┬─ R1 (10kΩ) ─┬─ R2 (2.2kΩ) ─┬─ GND
           │             │               │
           │             └───► VSENSE    │
           │                   (Pin 5)   │
           │                             │
    Divider ratio: 2.2k / (10k + 2.2k) = 0.18
    VSENSE = 3.3V × 0.18 = 0.594V ≈ 0.6V (TPS54331 reference)
```

### 3.3V Power Distribution

```
+3.3V Rail from Buck Converter (U1 Output)
    │
    ├─► Test Point TP2 (+3.3V probe point)
    │
    ├─► Power LED Circuit:
    │   └─► D10 (Green LED, 0805) → R50 (470Ω) → GND
    │       • Always-on power indicator
    │       • Current: (3.3V - 2.0V) / 470Ω ≈ 2.8mA
    │
    ├─► MCU Power (STM32G431CBT6, U2):
    │   ├─► VDD (Pin 24, 48) ───► C10, C11 (100nF) → GND
    │   ├─► VDDA (Pin 9)     ───► C15 (10µF) → GND
    │   ├─► VDDUSB (Pin 36)  ───► C14 (10µF) → GND
    │   └─► VBAT (Pin 1)     ───► C12 (100nF) → GND
    │       • Total decoupling: 5× 100nF + 2× 10µF
    │       • One cap per VDD pin minimum
    │
    ├─► Ethernet Power (W5500, U3):
    │   ├─► VDD (Pin 7, multiple) ──► C40, C41 (100nF + 10µF) → GND
    │   └─► VDDA (analog supply) ───► Additional 100nF → GND
    │       • W5500 draws ~130-160mA active
    │
    ├─► Zone Pull-Up Resistors (32 total):
    │   ├─► R100-R107 (Bank 1, Zones 1-8)   } Each 10kΩ
    │   ├─► R200-R207 (Bank 2, Zones 9-16)  } to respective
    │   ├─► R300-R307 (Bank 3, Zones 17-24) } ZONE+ terminal
    │   └─► R400-R407 (Bank 4, Zones 25-32) }
    │       • Total current (all zones open): 32 × (3.3V/10kΩ) ≈ 10.6mA
    │       • Current when one zone alarm (short): ~0.33mA per shorted zone
    │
    └─► Miscellaneous:
        ├─► Crystal oscillator bias (if needed)
        ├─► SWD pull-ups (if added)
        └─► Reset pull-up: R10 (10kΩ) to NRST pin

    Total 3.3V Budget:
    • MCU (U2): 20-40mA typical, 100mA max
    • W5500 (U3): 130-160mA active, 50mA idle
    • Zone pull-ups: 10-15mA
    • LEDs & misc: 5-10mA
    • TOTAL: ~200-300mA typical, <500mA max
    • Buck converter rated: 1.5A (3× safety margin)
```

---

## Zone Input Signal Flow

### Single Zone Channel Architecture (Replicated ×32)

```
Zone 1 Example (J10 Terminal Block):

Field Wiring Side:
┌─────────────────────────────────────┐
│  Sensor Installation                │
│  (Door/Window/PIR/Tamper)           │
│                                     │
│  ┌─────┐ Contact/Switch             │
│  │     │  (N.C. for secure,         │
│  │  S  │   N.O. for alarm)          │
│  │     │                            │
│  └──┬──┘                            │
│     │                               │
│  ┌──▼──────────┐                    │
│  │  4.7kΩ EOL  │ ◄─── Installer    │
│  │  Resistor   │      Supplies     │
│  │  (¼W THT)   │      (Not on PCB) │
│  └──┬──────────┘                    │
│     │                               │
│  Terminal Connections:              │
│     ├─► ZONE1+ (Red wire)           │
│     └─► ZONE1− (Black wire to GND)  │
└──────┬──────────────────┬───────────┘
       │                  │
       │ 2-conductor      │
       │ 18-22 AWG        │
       │ Cable (up to     │
       │ 300m run)        │
       │                  │
PCB Side:                 │
┌──────▼──────────────────▼───────────┐
│  J10 (Screw Terminal Block)        │
│  ┌──────────────────────┐           │
│  │ Pin 1: ZONE1+ ───────┼───► ADC  │
│  │ Pin 2: ZONE1− (GND) ─┼───► GND  │
│  └──────────────────────┘           │
└─────────────────────────────────────┘
       │                  │
       │ ZONE1+           │ GND
       │                  │
       ▼                  ▼

    ZONE1+ Node (PCB Trace)
       │
       ├─────────────────────────┐
       │                         │
       │ Pull-Up Path            │ Sense Path
       │                         │
    ┌──▼──┐                  ┌───▼────┐
    │ R100│ 10kΩ              │ MCU U2 │
    │     │                   │ PA0    │
    │     │                   │ (ADC1) │
    └──┬──┘                   │ Pin 10 │
       │                      └────────┘
    +3.3V                         │
                                  │ ADC Reading
       │                          │ (12-bit: 0-4095)
       │ Protection Path          │
       │                          │
    ┌──▼──────┐                   │
    │ D100    │ TVS Diode         │
    │ SMAJ5.0CA                   │
    │ (Bidirectional)             │
    └──┬──────┘                   │
       │                          │
      GND                         ▼
                          To Firmware ADC Handler
                          (See ADC State Decode below)

Zone States and ADC Voltages:
┌──────────────────────────────────────────────────────────────┐
│ State         │ Loop Condition      │ Voltage │ ADC Count    │
├───────────────┼─────────────────────┼─────────┼──────────────┤
│ NORMAL        │ Closed via 4.7kΩ    │ ~1.55V  │ ~1900 / 4095 │
│ (Secure)      │ Contact closed      │         │              │
│               │ Current path:       │         │              │
│               │ +3.3V → 10kΩ →      │         │              │
│               │ → Contact → 4.7kΩ → │         │              │
│               │ → GND               │         │              │
│               │ Divider: 4.7k/14.7k │         │              │
├───────────────┼─────────────────────┼─────────┼──────────────┤
│ ALARM         │ Loop shorted (0Ω)   │ ~0.0V   │ ~0 / 4095    │
│ (Intrusion)   │ Contact bypassed    │         │              │
│               │ Current path:       │         │              │
│               │ +3.3V → 10kΩ → GND  │         │              │
│               │ (4.7kΩ bypassed)    │         │              │
├───────────────┼─────────────────────┼─────────┼──────────────┤
│ OPEN/TAMPER   │ Loop open (∞Ω)      │ ~3.3V   │ ~4095 / 4095 │
│ (Cut wire)    │ Contact open        │         │              │
│               │ No current flow     │         │              │
│               │ Pull-up wins        │         │              │
├───────────────┼─────────────────────┼─────────┼──────────────┤
│ FAULT         │ Wrong/damaged EOL   │ 0.5-3.0V│ Variable     │
│ (Maintenance) │ e.g., 2.2kΩ, 10kΩ   │         │              │
└──────────────────────────────────────────────────────────────┘
```

### ADC State Decode Logic (Firmware)

```c
// Firmware pseudo-code for zone state detection
// Running on STM32G431 @ 170MHz

#define ADC_RESOLUTION    4095      // 12-bit ADC
#define ZONE_ALARM_HIGH   200       // <200 counts = Alarm (short)
#define ZONE_NORMAL_LOW   1400      // 1400-2400 = Normal (4.7k EOL)
#define ZONE_NORMAL_HIGH  2400
#define ZONE_OPEN_LOW     3800      // >3800 = Open/Tamper

typedef enum {
    ZONE_STATE_ALARM,      // Loop shorted
    ZONE_STATE_NORMAL,     // Secure with EOL
    ZONE_STATE_OPEN,       // Cut/tampered
    ZONE_STATE_FAULT       // Wrong EOL or intermittent
} zone_state_t;

zone_state_t decode_zone_adc(uint16_t adc_value) {
    if (adc_value < ZONE_ALARM_HIGH) {
        return ZONE_STATE_ALARM;       // 0V: Contact shorted
    } else if (adc_value >= ZONE_NORMAL_LOW && 
               adc_value <= ZONE_NORMAL_HIGH) {
        return ZONE_STATE_NORMAL;      // 1.55V: 4.7k divider
    } else if (adc_value > ZONE_OPEN_LOW) {
        return ZONE_STATE_OPEN;        // 3.3V: Open circuit
    } else {
        return ZONE_STATE_FAULT;       // Intermediate: Wrong EOL
    }
}

// Called from ADC DMA interrupt or polled scan
void scan_all_zones(void) {
    for (int zone = 0; zone < 32; zone++) {
        uint16_t adc_raw = ADC1->DR[zone];  // Read from DMA buffer
        zone_state_t state = decode_zone_adc(adc_raw);
        
        // Debounce: require same state for N consecutive reads
        if (state != zone_state_prev[zone]) {
            zone_debounce_counter[zone]++;
            if (zone_debounce_counter[zone] > DEBOUNCE_THRESHOLD) {
                // State change confirmed, send to hub via GXP
                zone_state_current[zone] = state;
                send_zone_update_to_hub(zone, state);
                zone_debounce_counter[zone] = 0;
            }
        } else {
            zone_debounce_counter[zone] = 0;
        }
        zone_state_prev[zone] = state;
    }
}
```

### All 32 Zones Connection Map

```
Bank 1 (Zones 1-8):   J10-J17 → R100-R107 + D100-D107 → U2 PA0-PA7
Bank 2 (Zones 9-16):  J20-J27 → R200-R207 + D200-D207 → U2 PB0-PB1, PC0-PC5
Bank 3 (Zones 17-24): J30-J37 → R300-R307 + D300-D307 → U2 (ADC2 channels)
Bank 4 (Zones 25-32): J40-J47 → R400-R407 + D400-D407 → U2 (ADC2 channels)

STM32G431 ADC Pin Mapping (Example):
┌────────────────┬──────────┬──────────────┐
│ Zone Number    │ MCU Pin  │ ADC Channel  │
├────────────────┼──────────┼──────────────┤
│ Zone 1         │ PA0      │ ADC1_IN1     │
│ Zone 2         │ PA1      │ ADC1_IN2     │
│ Zone 3         │ PA2      │ ADC1_IN3     │
│ Zone 4         │ PA3      │ ADC1_IN4     │
│ Zone 5         │ PA4      │ ADC1_IN5     │
│ Zone 6         │ PA5      │ ADC1_IN6     │
│ Zone 7         │ PA6      │ ADC1_IN7     │
│ Zone 8         │ PA7      │ ADC1_IN8     │
│ Zone 9         │ PB0      │ ADC1_IN15    │
│ Zone 10        │ PB1      │ ADC1_IN12    │
│ Zone 11        │ PC0      │ ADC1_IN6     │
│ Zone 12        │ PC1      │ ADC1_IN7     │
│ ... (pattern continues for all 32)      │
└────────────────┴──────────┴──────────────┘
```

---

## MCU Peripheral Connections

### STM32G431CBT6 Complete Pinout

```
                     STM32G431CBT6 (48-pin LQFP)
                    ┌────────────────────────────┐
   VBAT (C12 decap) │ 1  ┌────────────────┐  48 │ VDD (C10 decap)
   PC13 (GPIO)      │ 2  │                │  47 │ VSS (GND)
   PC14-OSC32_IN    │ 3  │                │  46 │ PB9 (Relay2/I2C)
   PC15-OSC32_OUT   │ 4  │   STM32G431    │  45 │ PB8 (Siren)
   PF0-OSC_IN ◄─────┤ 5  │    Cortex-M4F  │  44 │ BOOT0 (R11→GND)
   PF1-OSC_OUT ─────┤ 6  │    170 MHz     │  43 │ PB7 (I2C1_SDA)
   NRST (R10,SW1) ──┤ 7  │                │  42 │ PB6 (I2C1_SCL)
   VSSA (GND)       │ 8  │   48 GPIO      │  41 │ PB5 (SPI3_MOSI)
   VDDA (C15 decap) │ 9  │   3× ADC       │  40 │ PB4 (SPI3_MISO)
   PA0 (Zone1 ADC) ─┤10  │   5× USART     │  39 │ PB3 (SPI3_SCK)
   PA1 (Zone2 ADC) ─┤11  │   3× SPI       │  38 │ PA15 (UART2_RX)
   PA2 (Zone3 ADC) ─┤12  │   3× I2C       │  37 │ PA14-SWCLK ◄────┐
   PA3 (Zone4 ADC) ─┤13  └────────────────┘  36 │ VDDUSB (C14)    │SWD
   PA4 (Zone5 ADC) ─┤14                      35 │ VSS (GND)       │J2
   PA5-SPI1_SCK ────┤15 ─────────────► W5500 34 │ VSS (GND)       │
   PA6-SPI1_MISO ◄──┤16 ◄────────────── W5500 33 │ PA13-SWDIO ◄────┘
   PA7-SPI1_MOSI ───┤17 ─────────────► W5500 32 │ PA12 (GPIO)
   PB0 (Zone9 ADC) ─┤18                      31 │ PA11 (W5500_IRQ)
   PB1 (Zone10 ADC) ┤19                      30 │ PA10 (UART1_RX)
   PB2 (GPIO)       │20                      29 │ PA9 (UART1_TX)
   PB10 (Relay1) ───┤21                      28 │ PA8 (W5500_CS)
   PB11 (Status LED)│22                      27 │ PB15 (SPI2_MOSI)
   VSS (GND)        │23                      26 │ PB14 (SPI2_MISO)
   VDD (C11 decap)  │24                      25 │ PB13 (SPI2_SCK)
                    └────────────────────────────┘
                              │
                    Y1 (8 MHz HSE Crystal)
                    C16, C17 (20pF load caps)
```

### Key Peripheral Usage

```
ADC (Analog-to-Digital Converter):
├─► ADC1 (12-bit, 5 MSPS):
│   ├─ Channels 1-8:  PA0-PA7  (Zones 1-8)
│   ├─ Channels 12,15: PB1, PB0 (Zones 9-10)
│   └─ Channels 6-7:  PC0-PC1 (Zones 11-12)
├─► ADC2 (12-bit, 5 MSPS):
│   └─ Additional 20 channels for Zones 13-32 (shared pins)
└─► Configuration:
    • DMA circular mode for continuous scanning
    • Scan all 32 channels sequentially
    • Sample time: 12.5 cycles (@ 170 MHz: ~0.07µs per sample)
    • Total scan rate: ~32 channels × 0.07µs = ~2.3µs per full scan
    • Update rate: ~430 kHz (overkill; firmware decimates to 100 Hz)

SPI1 (Serial Peripheral Interface — Ethernet):
├─► Master mode, 8-bit frame
├─► Clock: PA5 (SCK) ─────► W5500 SCK
├─► MISO:  PA6 (MISO) ◄──── W5500 MISO
├─► MOSI:  PA7 (MOSI) ────► W5500 MOSI
├─► CS:    PA8 (GPIO) ─────► W5500 ~CS (chip select)
├─► IRQ:   PA11 (GPIO) ◄─── W5500 ~INT (interrupt, optional)
└─► Speed: Up to 21 MHz (W5500 supports up to 33 MHz)

USART1 (Debug Console — Optional):
├─► TX: PA9  ─────► J3 Pin 1 (UART debug header)
├─► RX: PA10 ◄──── J3 Pin 2
└─► Baud: 115200 bps (configurable)

GPIO (General Purpose I/O):
├─► PB8:  Siren output (drives Q1 MOSFET gate via R30)
├─► PB10: Relay 1 output (drives K1 coil via R40/NPN)
├─► PB9:  Relay 2 output (drives K2 coil via R41/NPN)
├─► PB11: Status LED output (optional, GPIO-driven)
└─► PC13: User button input (optional, pulled high internally)

TIMERS (for PWM, delays, watchdog):
├─► TIM1: Advanced timer (can generate PWM for siren tones)
├─► TIM2: General-purpose 32-bit (systick, delays)
└─► IWDG: Independent watchdog (safety reset if firmware hangs)

CLOCK SOURCES:
├─► HSE (High-Speed External): 8 MHz crystal (Y1)
│   └─► PLL multiplied to 170 MHz for CPU
├─► HSI (High-Speed Internal): 16 MHz RC (backup)
└─► LSI (Low-Speed Internal): 32 kHz (watchdog, RTC)
```

---

## Ethernet Communication Path

### W5500 → MagJack → Network

```
STM32 MCU (U2) ◄──────► W5500 Ethernet Controller (U3) ◄──────► RJ45 MagJack (J4) ◄──► Network

SPI Bus (3-wire + CS):
┌────────────────────────────────────────────────────────────┐
│  MCU U2          Signal         W5500 U3                   │
├──────────────────────────────────────────────────────────--┤
│  PA5 (SPI1_SCK) ────► SCK ────► Pin 3 (SCK input)          │
│  PA7 (SPI1_MOSI)────► MOSI ───► Pin 2 (MOSI input)         │
│  PA6 (SPI1_MISO)◄───── MISO ◄── Pin 5 (MISO output)        │
│  PA8 (GPIO)     ────► ~CS ────► Pin 4 (~CS input)          │
│  PA11 (GPIO)    ◄───── ~INT ◄── Pin 50 (~INT output, opt)  │
│  GND            ──────────────── Pin 1, 15 (GND)           │
│  +3.3V          ──────────────── Pin 7 (VDD)              │
└────────────────────────────────────────────────────────────┘

W5500 Internal Architecture:
┌─────────────────────────────────────────────────────────────┐
│                         W5500                               │
│  ┌──────────┐    ┌──────────────┐    ┌─────────────┐      │
│  │   SPI    │───►│  Register    │───►│ Hardwired   │      │
│  │ Interface│    │    Bank      │    │  TCP/IP     │      │
│  │          │◄───│ • Mode regs  │◄───│   Stack     │      │
│  └──────────┘    │ • Socket regs│    │             │      │
│                  │ • Memory ptr │    │ • TCP       │      │
│                  └──────────────┘    │ • UDP       │      │
│                                      │ • ICMP      │      │
│                                      │ • ARP       │      │
│                                      │ • DHCP      │      │
│                                      │ • DNS       │      │
│  ┌───────────────────────────────┐  └──────┬──────┘      │
│  │  Socket Buffers (32KB)        │         │             │
│  │  • 8 sockets (0-7)            │         │             │
│  │  • TX buffer: 2KB per socket  │         │             │
│  │  • RX buffer: 2KB per socket  │         │             │
│  └───────────────────────────────┘         │             │
│                                             ▼             │
│  ┌─────────────────────────────────────────────┐         │
│  │          PHY (Physical Layer)               │         │
│  │  • 100BASE-TX / 10BASE-T                    │         │
│  │  • Auto-negotiation                         │         │
│  │  • Full/half duplex                         │         │
│  └───────┬────────────┬────────────┬───────────┘         │
│          │ TX+        │ TX−        │ RX+/RX−             │
│    Pin 11│      Pin 12│      Pin 13,14                   │
└──────────┼────────────┼────────────┼─────────────────────┘
           │            │            │
           ▼            ▼            ▼
      ┌────────────────────────────────────┐
      │  J4: MagJack (Hanrun HR911105A)    │
      │  RJ45 + Integrated Magnetics       │
      │                                    │
      │  Internal Transformer:             │
      │  ┌──────────────────────────────┐  │
      │  │  TX Transformer (1:1)        │  │
      │  │  ┌───┐        ┌───┐          │  │
      │  │  │ P │───||───│ S │─────► Pin 1 (TX+)
      │  │  └───┘        └───┘─────► Pin 2 (TX−)
      │  │                           │  │
      │  │  RX Transformer (1:1)     │  │
      │  │  ┌───┐        ┌───┐       │  │
      │  │  │ S │───||───│ P │◄───── Pin 3 (RX+)
      │  │  └───┘        └───┘◄───── Pin 6 (RX−)
      │  └──────────────────────────────┘  │
      │                                    │
      │  Shield: Pin 9 (chassis ground)   │
      │  LEDs (optional internal):        │
      │  • Link/Activity (if present)     │
      └────────────┬───────────────────────┘
                   │
            RJ45 Ethernet Cable
            (CAT5e/CAT6, up to 100m)
                   │
                   ▼
         ┌──────────────────┐
         │  Network Switch   │
         │  or Router        │
         │  (LAN segment)    │
         └──────────┬────────┘
                    │
         ┌──────────▼─────────┐
         │  Guardian Hub (NUC)│
         │  GXP Server        │
         │  (guardian-sensors)│
         └────────────────────┘
```

### Ethernet Protocol Stack

```
Application Layer:
┌────────────────────────────────────────────┐
│  Guardian Expander Protocol (GXP)          │
│  • Custom binary protocol over TCP         │
│  • Port: 4570 (example)                    │
│  • Messages:                               │
│    - HELLO (device ID, capabilities)       │
│    - ZONE_UPDATE (zone_id, state, ts)     │
│    - OUTPUT_SET (output_id, level)        │
│    - HEARTBEAT (every 5s)                 │
│    - TAMPER_EVENT (if case open)          │
│  • Mutual TLS authentication (optional)    │
└────────────────┬───────────────────────────┘
                 │
Transport Layer: │
┌────────────────▼───────────────────────────┐
│  TCP (Transmission Control Protocol)       │
│  • Connection-oriented                     │
│  • Reliable delivery (ACK, retransmit)     │
│  • Port: 4570 (server listens on hub)     │
│  • Socket: W5500 Socket 0 (main GXP)      │
└────────────────┬───────────────────────────┘
                 │
Network Layer:   │
┌────────────────▼───────────────────────────┐
│  IP (Internet Protocol)                    │
│  • IPv4 only (for simplicity)              │
│  • Static IP or DHCP                       │
│  • Example: 192.168.1.50/24                │
│  • Gateway: 192.168.1.1 (to hub)           │
└────────────────┬───────────────────────────┘
                 │
Data Link Layer: │
┌────────────────▼───────────────────────────┐
│  Ethernet II (802.3)                       │
│  • MAC address: Factory-assigned in W5500  │
│  • Frame size: 64-1518 bytes               │
│  • Handled by W5500 hardware              │
└────────────────┬───────────────────────────┘
                 │
Physical Layer:  │
┌────────────────▼───────────────────────────┐
│  100BASE-TX / 10BASE-T                     │
│  • Auto-negotiation                        │
│  • Full/half duplex                        │
│  • PHY in W5500, magnetics in MagJack      │
└────────────────────────────────────────────┘
```

### GXP Message Format (Example)

```
Zone Update Message (Expander → Hub):
┌──────────────────────────────────────────────────────┐
│ Offset │ Field         │ Type    │ Value (Example)   │
├────────┼───────────────┼─────────┼───────────────────┤
│ 0x00   │ Magic         │ uint16  │ 0x4758 ('GX')     │
│ 0x02   │ Message Type  │ uint8   │ 0x02 (ZONE_UPDATE)│
│ 0x03   │ Length        │ uint8   │ 0x0C (12 bytes)   │
│ 0x04   │ Device ID     │ uint32  │ 0x12345678        │
│ 0x08   │ Zone ID       │ uint8   │ 0x00 (Zone 1)     │
│ 0x09   │ State         │ uint8   │ 0x01 (ALARM)      │
│ 0x0A   │ Timestamp     │ uint32  │ 0x61A3B4C0 (Unix) │
│ 0x0E   │ Reserved      │ uint16  │ 0x0000            │
│ 0x10   │ CRC-16        │ uint16  │ 0xABCD (checksum) │
└──────────────────────────────────────────────────────┘

Output Command Message (Hub → Expander):
┌──────────────────────────────────────────────────────┐
│ Offset │ Field         │ Type    │ Value (Example)   │
├────────┼───────────────┼─────────┼───────────────────┤
│ 0x00   │ Magic         │ uint16  │ 0x4758 ('GX')     │
│ 0x02   │ Message Type  │ uint8   │ 0x03 (OUTPUT_SET) │
│ 0x03   │ Length        │ uint8   │ 0x08 (8 bytes)    │
│ 0x04   │ Device ID     │ uint32  │ 0x12345678        │
│ 0x08   │ Output ID     │ uint8   │ 0x00 (Siren)      │
│ 0x09   │ Level         │ uint8   │ 0x01 (On)         │
│ 0x0A   │ Duration (ms) │ uint16  │ 0x0000 (forever)  │
│ 0x0C   │ Reserved      │ uint16  │ 0x0000            │
│ 0x0E   │ CRC-16        │ uint16  │ 0x1234 (checksum) │
└──────────────────────────────────────────────────────┘
```

---

## Output Driver Architecture

### Siren Output (12V Switched)

```
MCU U2 PB8 (GPIO Output)
    │
    │ 3.3V logic signal
    │
    ├───► R30 (100Ω series) ─────┐
    │                            │
    │                            ├───► Q1 Gate (AO3400 N-MOSFET)
    │                            │     • SOT-23 package
    │                            │     • Vgs(th) = 0.9V (logic-level)
    │                      R31 ──┴──► Q1 Gate pull-down (10kΩ to GND)
    │                      (10kΩ)    • Ensures MOSFET off when MCU tristated
    │
    └───► (firmware control: GPIO_SetBits/ResetBits)

Q1 MOSFET (AO3400):
    Gate ◄─── (from R30/R31 network above)
    │
    │ Threshold: ~0.9V, fully on at 2.5V
    │ 3.3V drive → fully enhanced, Rds(on) ≈ 30 mΩ
    │
    Drain ──► Connected to 12V rail (via load)
    │
    │         ┌─────────────────────────┐
    │         │ +12V Rail               │
    │         │ (from Buck input side)  │
    │         └────────┬────────────────┘
    │                  │
    │                  ├───► D20 (Flyback Diode, 1N4148)
    │                  │     • Cathode to +12V
    │                  │     • Anode to siren coil
    │                  │     • Clamps inductive kickback
    │                  │
    │                  ├───► Siren Load
    │                  │     (Piezo or magnetic siren)
    │                  │     • Typical: 12V, 100-500mA
    │                  │     • Max: 2A (Q1 can handle 5A)
    │                  │
    │                  └───► J50 Pin 1 (SIREN+)
    │
    Source ──► Q1 Drain ───► J50 Pin 2 (SIREN−, returns via Q1)
    │
    GND (when Q1 on, siren completes circuit to GND)

Siren Terminal J50:
    Pin 1: SIREN+ (to +12V via load)
    Pin 2: SIREN− (switched GND via Q1)

Operation:
• MCU sets PB8 HIGH (3.3V) → Q1 gate rises → Q1 conducts → Siren ON
• MCU sets PB8 LOW (0V) → R31 pulls gate to GND → Q1 off → Siren OFF
• Firmware can PWM PB8 for modulated tones (e.g., 1 kHz square wave)
```

### Relay Outputs (Dry Contact Switching)

```
Relay 1 (K1) — Same circuit for Relay 2 (K2)

MCU U2 PB10 (GPIO Output for Relay 1)
    │
    │ 3.3V logic signal
    │
    ├───► R40 (1kΩ series) ─────► Q10 Base (2N2222 NPN transistor)
    │                              │ SOT-23 or TO-92 package
    │                              │
    │                        Q10 Emitter ──► GND
    │
    │                        Q10 Collector ──┐
    │                                        │
    │                                        ├───► K1 Coil Pin A1
    │                                        │     (Relay coil)
    │                                        │
    │                        +12V Rail ──────┼───► K1 Coil Pin A2
    │                        (or 5V if       │
    │                         relay is 5V)   │
    │                                        │
    │                        D21 (1N4148) ───┘ Flyback diode
    │                        • Cathode to +12V (or +5V)
    │                        • Anode to coil A1
    │
    └───► (firmware control: GPIO_SetBits/ResetBits)

Relay K1 (Omron G5V-2 or similar):
    Coil: A1, A2 (12V or 5V, ~20-40mA)
    Contacts: 11 (NO), 12 (COM), 14 (NC)
    
    ┌──────────────────────────────────┐
    │  K1 Contact Arrangement (SPDT)   │
    │                                  │
    │  Pin 14 (NC) ─────┐              │
    │                   │              │
    │  Pin 12 (COM) ────┼──► Armature │
    │                   │              │
    │  Pin 11 (NO) ─────┘              │
    │                                  │
    │  When coil de-energized:         │
    │    COM connected to NC (14)      │
    │  When coil energized:            │
    │    COM connected to NO (11)      │
    └──────────────────────────────────┘

J51 Terminal Block (Relay 1 Contacts):
    Pin 1: NO (Normally Open) ──► K1 Pin 11
    Pin 2: COM (Common)       ──► K1 Pin 12
    Pin 3: NC (Normally Closed) ─► K1 Pin 14

User connects external load between NO-COM or NC-COM:
Example: Electric door strike (12VDC)
    +12V external ──► Door strike ──► J51 NO (Pin 1)
    GND external  ──► J51 COM (Pin 2)
    
When MCU energizes relay: Strike activates (door unlocks)
When MCU de-energizes: Strike off (door locked)

Operation:
• MCU sets PB10 HIGH (3.3V) → Q10 saturates → Current flows through K1 coil
  → Relay armature pulls in → COM switches to NO
• MCU sets PB10 LOW (0V) → Q10 off → No coil current → Relay releases
  → COM switches back to NC
• D21 flyback diode prevents inductive spike from damaging Q10
```

---

## Complete Connection Matrix

### Power Connections

```
12V DC Input (J1) ──► F1 (2A Fuse) ──► D1 (Reverse Protect) ──┬──► +12V Rail
                                                                │
                                                                ├──► U1 VIN (Buck)
                                                                ├──► Q1 Drain (Siren)
                                                                └──► K1/K2 Coil Supply

+3.3V Rail (U1 Output) ──┬──► U2 VDD/VDDA/VDDUSB (MCU power)
                          ├──► U3 VDD (W5500 power)
                          ├──► R100-R407 (32 zone pull-ups)
                          ├──► R10 (NRST pull-up)
                          └──► D10 Anode (Power LED)

GND (Common Ground) ──┬──► All component GND pins
                      ├──► J1 Pin 2/3 (barrel jack sleeve)
                      ├──► J10-J47 Pin 2 (32 zone terminals ZONE−)
                      ├──► Q1 Source (siren MOSFET)
                      ├──► Q10, Q11 Emitters (relay drivers)
                      └──► In1.Cu GND plane (solid pour)
```

### Signal Connections

```
MCU U2 ◄──────► W5500 U3 (SPI Ethernet):
  PA5 (SCK)  ──────► Pin 3 (SCK)
  PA7 (MOSI) ──────► Pin 2 (MOSI)
  PA6 (MISO) ◄───── Pin 5 (MISO)
  PA8 (CS)   ──────► Pin 4 (~CS)
  PA11 (IRQ) ◄───── Pin 50 (~INT, optional)

MCU U2 ◄──────► Zone Inputs (ADC):
  PA0-PA7    ◄───── R100-R107 (Zones 1-8, Bank 1)
  PB0-PB1    ◄───── R200-R201 (Zones 9-10, Bank 2)
  PC0-PC5    ◄───── R202-R207 (Zones 11-16, Bank 2)
  (Additional ADC pins for Zones 17-32)

MCU U2 ──────► Outputs (GPIO):
  PB8  ──────► R30 ──► Q1 Gate (Siren MOSFET)
  PB10 ──────► R40 ──► Q10 Base (Relay 1 driver)
  PB9  ──────► R41 ──► Q11 Base (Relay 2 driver)

MCU U2 ◄──────► Debug Interfaces:
  PA13 (SWDIO) ◄───► J2 Pin 2 (SWD programming)
  PA14 (SWCLK) ◄───► J2 Pin 4
  NRST         ◄───► J2 Pin 10 (reset)
  PA9  (UART TX) ──► J3 Pin 1 (debug console, optional)
  PA10 (UART RX) ◄── J3 Pin 2

W5500 U3 ◄──────► MagJack J4 (Ethernet PHY):
  Pin 11 (TX+) ──────► J4 Pin 1 (via transformer)
  Pin 12 (TX−) ──────► J4 Pin 2
  Pin 13 (RX+) ◄───── J4 Pin 3 (via transformer)
  Pin 14 (RX−) ◄───── J4 Pin 6

Zone Terminals J10-J47 ◄──────► Field Sensors:
  Pin 1 (ZONE+) ◄───── Sensor contact ◄───── 4.7kΩ EOL ◄───── Pin 2 (ZONE−/GND)
```

### Physical Layer Summary

```
┌─────────────────────────────────────────────────────────────────┐
│ Terminal Blocks (User-Accessible):                             │
├─────────────────────────────────────────────────────────────────┤
│ J1  (2.1mm Barrel)  │ 12V DC Input (center +, sleeve −)        │
│ J10-J17 (2-pos 5mm) │ Zones 1-8 (ZONE+, ZONE−/GND)             │
│ J20-J27 (2-pos 5mm) │ Zones 9-16                               │
│ J30-J37 (2-pos 5mm) │ Zones 17-24                              │
│ J40-J47 (2-pos 5mm) │ Zones 25-32                              │
│ J50 (2-pos 5mm)     │ Siren (SIREN+, SIREN−)                   │
│ J51 (3-pos 5mm)     │ Relay 1 (NO, COM, NC)                    │
│ J52 (3-pos 5mm)     │ Relay 2 (NO, COM, NC)                    │
│ J4  (RJ45 MagJack)  │ Ethernet (100BASE-TX)                    │
├─────────────────────────────────────────────────────────────────┤
│ Internal Headers (Debug/Programming):                          │
├─────────────────────────────────────────────────────────────────┤
│ J2  (2×5 1.27mm)    │ ARM SWD (SWDIO, SWCLK, NRST, +3.3V, GND)│
│ J3  (1×3 2.54mm)    │ UART (TX, RX, GND) — optional            │
├─────────────────────────────────────────────────────────────────┤
│ Test Points:                                                    │
├─────────────────────────────────────────────────────────────────┤
│ TP1 │ +12V  │ 12V rail monitoring                              │
│ TP2 │ +3.3V │ 3.3V rail monitoring                             │
│ TP3 │ GND   │ Ground reference                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Functional Operation

### System Boot Sequence

```
┌──────────────────────────────────────────────────────────────────┐
│ Power-On Sequence (Cold Start)                                   │
├──────────────────────────────────────────────────────────────────┤
│ 1. 12V Applied to J1                                             │
│    ├─► F1 fuse checks OK (no short)                              │
│    ├─► D1 forward-biased (assuming correct polarity)             │
│    └─► +12V rail rises to ~11.5V (after Vf drop)                 │
│                                                                   │
│ 2. Buck Converter (U1 TPS54331) Starts                           │
│    ├─► VIN pin sees 11.5V (above UVLO threshold ~7V)             │
│    ├─► EN pin pulled high (enabled)                              │
│    ├─► Internal oscillator starts at 600 kHz                     │
│    ├─► SW pin switches, L1 inductor charges/discharges           │
│    ├─► Output voltage ramps up over ~10ms                        │
│    └─► +3.3V rail reaches 3.3V ±1%, PWRGD goes high              │
│        • Decoupling caps C1-C5 charge                            │
│        • Power LED D10 turns on (visible indicator)              │
│                                                                   │
│ 3. MCU (U2 STM32G431) Boots                                      │
│    ├─► VDD/VDDA/VDDUSB pins reach 3.3V                           │
│    ├─► Internal POR (Power-On Reset) releases after ~50ms        │
│    ├─► Boot mode determined: BOOT0 = GND → Flash boot            │
│    ├─► CPU starts executing from Flash (0x08000000)              │
│    ├─► Vector table loaded, Reset_Handler() called               │
│    ├─► SystemInit(): Configure clocks (HSE → PLL → 170 MHz)      │
│    └─► main() entered                                            │
│                                                                   │
│ 4. Firmware Initialization (main.c)                              │
│    ├─► GPIO_Init():                                              │
│    │   ├─► PB8 (Siren) → Output, initially LOW                   │
│    │   ├─► PB9, PB10 (Relays) → Output, initially LOW            │
│    │   └─► PA0-PA7, PB0-PB1, PC0-PC5 → Analog mode (ADC inputs) │
│    ├─► ADC_Init():                                               │
│    │   ├─► Configure ADC1 for 32-channel scan                    │
│    │   ├─► DMA circular mode enabled                             │
│    │   └─► Start continuous conversion (scan rate: 100 Hz)       │
│    ├─► SPI_Init():                                               │
│    │   ├─► SPI1 master mode, 8-bit, 10 MHz                       │
│    │   └─► PA5/PA6/PA7/PA8 configured                            │
│    ├─► W5500_Init():                                             │
│    │   ├─► Reset W5500 via GPIO (if RST pin connected)           │
│    │   ├─► Write MAC address to W5500 registers                  │
│    │   ├─► Write IP config (static or DHCP request)              │
│    │   └─► Open TCP socket 0, connect to hub IP:4570             │
│    ├─► GXP_Init():                                               │
│    │   ├─► Send HELLO message to hub                             │
│    │   │   • Device ID: 0x12345678                               │
│    │   │   • Capabilities: 32 zones, 1 siren, 2 relays           │
│    │   └─► Wait for ACK from hub                                 │
│    └─► Timer_Init():                                             │
│        ├─► SysTick: 1ms tick for delays                          │
│        └─► TIM2: 100 Hz zone scan trigger                        │
│                                                                   │
│ 5. Idle Loop (Superloop)                                         │
│    while(1) {                                                    │
│      ├─► scan_all_zones();        // Read 32 ADC values          │
│      ├─► process_zone_events();   // Detect state changes        │
│      ├─► gxp_handle_rx();         // Process hub commands        │
│      ├─► gxp_send_heartbeat();    // Every 5 seconds             │
│      └─► watchdog_refresh();      // Pet the dog                 │
│    }                                                             │
└──────────────────────────────────────────────────────────────────┘
```

### Normal Operation State Machine

```
┌───────────────────────────────────────────────────────────────┐
│ State: IDLE (No alarms, monitoring zones)                     │
├───────────────────────────────────────────────────────────────┤
│ • All zones in NORMAL state (ADC ≈1.55V)                      │
│ • Siren OFF (PB8 = LOW)                                       │
│ • Relays OFF (PB9, PB10 = LOW)                                │
│ • Ethernet: TCP connection to hub established                 │
│ • Heartbeat sent every 5 seconds                              │
│                                                               │
│ Firmware Loop (every 10ms):                                   │
│   1. Read all 32 ADC channels (DMA buffer)                    │
│   2. For each zone:                                           │
│      a. Decode state (alarm/normal/open/fault)                │
│      b. If state == previous_state: continue                  │
│      c. If state != previous_state:                           │
│         ├─► Increment debounce counter                        │
│         └─► If debounce_count > 3 (30ms stable):              │
│             ├─► Update current_state                          │
│             ├─► Log event                                     │
│             └─► Send ZONE_UPDATE to hub via GXP               │
│   3. Check W5500 RX buffer for hub commands                   │
│   4. If OUTPUT_SET command received:                          │
│      ├─► Parse output_id, level, duration                     │
│      └─► Execute (set GPIO, start timer if duration)          │
│   5. Refresh watchdog                                         │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│ Event: Zone 1 Goes to ALARM (e.g., door opened)               │
├───────────────────────────────────────────────────────────────┤
│ 1. Sensor contact opens: 4.7kΩ bypassed → ZONE1+ = 0V         │
│ 2. ADC reads PA0 ≈0V (count <200)                             │
│ 3. decode_zone_adc(0) → ZONE_STATE_ALARM                      │
│ 4. Debounce for 30ms (3 consecutive reads)                    │
│ 5. State confirmed → send_zone_update_to_hub():               │
│    ├─► GXP message:                                           │
│    │   • Type: ZONE_UPDATE                                    │
│    │   • Zone: 1                                              │
│    │   • State: ALARM                                         │
│    │   • Timestamp: current Unix time                         │
│    └─► TCP send via W5500 socket 0                            │
│ 6. Hub receives, processes via guardian-alarm logic:          │
│    ├─► Check if system armed                                  │
│    ├─► Check zone type (perimeter/interior/24h)               │
│    └─► If alarm condition met:                                │
│        ├─► Send OUTPUT_SET(siren, ON, 300000) ← 5 min         │
│        └─► Send OUTPUT_SET(relay1, ON, 0) ← strobe            │
│ 7. Expander receives OUTPUT_SET commands:                     │
│    ├─► Parse: siren ON for 300s                               │
│    ├─► Set PB8 = HIGH → Q1 conducts → Siren activates         │
│    ├─► Start timer: 300000ms countdown                        │
│    ├─► Parse: relay1 ON indefinitely                          │
│    └─► Set PB10 = HIGH → K1 energizes → Strobe activates      │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│ Event: User Disarms System (Hub Command)                      │
├───────────────────────────────────────────────────────────────┤
│ 1. User enters code on hub keypad (not on expander)           │
│ 2. Hub sends OUTPUT_SET commands to expander:                 │
│    ├─► OUTPUT_SET(siren, OFF, 0)                              │
│    └─► OUTPUT_SET(relay1, OFF, 0)                             │
│ 3. Expander processes:                                        │
│    ├─► Set PB8 = LOW → Siren OFF                              │
│    └─► Set PB10 = LOW → Relay1 OFF (strobe deactivates)       │
│ 4. Zone 1 still in ALARM state (door still open)              │
│ 5. When door closes:                                          │
│    ├─► 4.7kΩ EOL in circuit → ZONE1+ ≈1.55V                   │
│    ├─► ADC reads normal state                                 │
│    └─► Send ZONE_UPDATE(zone=1, state=NORMAL) to hub          │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│ Event: Zone Tamper Detected (Wire Cut)                        │
├───────────────────────────────────────────────────────────────┤
│ 1. Attacker cuts wire between sensor and expander             │
│ 2. Loop opens: no current path → ZONE+ = 3.3V (pull-up)       │
│ 3. ADC reads ≈4095 counts                                     │
│ 4. decode_zone_adc(4095) → ZONE_STATE_OPEN                    │
│ 5. Debounce 30ms, send ZONE_UPDATE(zone=X, state=OPEN)        │
│ 6. Hub interprets OPEN as tamper (24-hour alarm):             │
│    └─► Trigger immediate siren regardless of arm state        │
│        (tamper is always alarmed)                             │
└───────────────────────────────────────────────────────────────┘
```

### Failure Modes and Safety

```
┌───────────────────────────────────────────────────────────────┐
│ Failure Mode: Power Loss                                      │
├───────────────────────────────────────────────────────────────┤
│ • 12V input lost → Buck converter shuts down                   │
│ • +3.3V rail decays over ~50-100ms (held by output caps)      │
│ • MCU brown-out reset triggers                                │
│ • All GPIO outputs go LOW (safe state):                       │
│   ├─► Siren OFF                                               │
│   └─► Relays OFF                                              │
│ • TCP connection to hub times out (hub detects offline)       │
│ • Hub policy: "Fail secure" → No auto-siren on link loss      │
│                                                               │
│ Recovery: When power returns, system reboots (see boot seq)   │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│ Failure Mode: Ethernet Cable Unplugged                        │
├───────────────────────────────────────────────────────────────┤
│ • W5500 PHY detects link down                                 │
│ • TCP connection closed by timeout (~30s)                     │
│ • Firmware detects connection loss, attempts reconnect        │
│ • Hub marks expander as offline                               │
│ • Hub policy: "Silent on link loss" (per spec)                │
│   └─► No auto-siren trigger (prevents false alarms)           │
│                                                               │
│ Recovery: When cable reconnected:                             │
│   ├─► PHY autonegotiates                                      │
│   ├─► TCP reconnect                                           │
│   └─► HELLO handshake re-establishes session                  │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│ Failure Mode: Firmware Hang (Watchdog Reset)                  │
├───────────────────────────────────────────────────────────────┤
│ • If firmware loop stalls (bug, infinite loop):                │
│   ├─► Watchdog timer (IWDG) not refreshed                     │
│   ├─► After ~2 seconds: Watchdog expires                      │
│   └─► MCU hard reset (system reboots)                         │
│ • Outputs briefly go LOW during reset (~10ms)                 │
│ • System recovers via normal boot sequence                    │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│ Failure Mode: Overcurrent (Fuse Blow)                         │
├───────────────────────────────────────────────────────────────┤
│ • If sustained >2A draw (e.g., short on 12V rail):             │
│   ├─► F1 (2A slow-blow) heats, resistance increases           │
│   └─► After ~5-10 seconds: Fuse opens (blows)                 │
│ • 12V input disconnected, system powers down                  │
│                                                               │
│ Recovery: Replace F1 fuse, investigate short                  │
└───────────────────────────────────────────────────────────────┘
```

---

## Summary: Data Flow from Sensor to Hub

```
┌────────────────────────────────────────────────────────────────────┐
│                    End-to-End Data Flow                            │
└────────────────────────────────────────────────────────────────────┘

Sensor Event (Door Opens):
    │
    ▼
Door Contact Opens → 4.7kΩ EOL Bypassed → ZONE+ = 0V
    │
    ▼
10kΩ Pull-Up + 0Ω to GND → Voltage Divider = 0V
    │
    ▼
TVS Diode (D100) Clamps Any Transients
    │
    ▼
ZONE1+ Trace on PCB → MCU U2 Pin 10 (PA0/ADC1_IN1)
    │
    ▼
ADC Conversion (12-bit, DMA): Raw Count ≈ 0 / 4095
    │
    ▼
Firmware decode_zone_adc(0) → ZONE_STATE_ALARM
    │
    ▼
Debounce Logic (30ms stable) → Confirmed ALARM
    │
    ▼
Build GXP Message: ZONE_UPDATE(zone=1, state=ALARM, ts=now)
    │
    ▼
Serialize to Binary (16 bytes + CRC)
    │
    ▼
SPI Write to W5500 (PA5/6/7/8) → Socket 0 TX Buffer
    │
    ▼
W5500 TCP/IP Stack: Packetize, Add IP/Ethernet Headers
    │
    ▼
W5500 PHY: 100BASE-TX Encoding, Differential TX (TX+/TX−)
    │
    ▼
MagJack Transformer: Galvanic Isolation, Line Driver
    │
    ▼
Ethernet Cable (CAT5e, up to 100m)
    │
    ▼
Network Switch: Layer 2 Forwarding by MAC Address
    │
    ▼
Guardian Hub (NUC): Receives Ethernet Frame
    │
    ▼
Hub TCP/IP Stack: Unwrap IP/TCP, Deliver to Port 4570
    │
    ▼
guardian-sensors (Zig): GXP Server Receives Message
    │
    ▼
Parse GXP: Extract zone_id=1, state=ALARM, timestamp
    │
    ▼
Publish to Internal Event Bus: "zone.1.alarm" Event
    │
    ▼
guardian-alarm (Main Logic): Receives Event
    │
    ▼
Evaluate Alarm Rules: Is system armed? Is Zone 1 perimeter?
    │
    ▼
Decision: Trigger Siren (Zone 1 is perimeter, system armed)
    │
    ▼
Send GXP Command: OUTPUT_SET(siren, ON, 300000ms)
    │
    ▼
guardian-sensors → TCP Send to Expander
    │
    ▼
(Reverse path: Network → W5500 → SPI → MCU)
    │
    ▼
Firmware gxp_handle_rx(): Parse OUTPUT_SET
    │
    ▼
Set MCU GPIO PB8 = HIGH
    │
    ▼
Q1 MOSFET Gate → 3.3V → MOSFET Conducts
    │
    ▼
12V Flows Through Siren Load → Siren Sounds
    │
    ▼
[Alarm Event Complete: User Notified, Response Triggered]
```

---

## Appendix: Key Specifications Summary

```
┌──────────────────────────────────────────────────────────────┐
│ Guardian Zone Expander — Technical Summary                   │
├──────────────────────────────────────────────────────────────┤
│ Zones:          32 supervised (EOL 4.7kΩ)                    │
│ Zone Detection: Normal / Alarm / Open / Fault (4 states)     │
│ ADC Resolution: 12-bit (4096 counts)                         │
│ Scan Rate:      100 Hz (all 32 zones)                        │
│ Debounce:       30 ms (configurable)                         │
├──────────────────────────────────────────────────────────────┤
│ MCU:            STM32G431CBT6 (Cortex-M4F @ 170 MHz)         │
│ Flash:          128 KB                                       │
│ RAM:            32 KB                                        │
│ Clock Source:   8 MHz HSE crystal → PLL                      │
├──────────────────────────────────────────────────────────────┤
│ Ethernet:       W5500 100BASE-TX, hardwired TCP/IP           │
│ Protocol:       GXP over TCP/IP (custom)                     │
│ Link Speed:     10/100 Mbps auto-negotiation                 │
│ Cable Length:   Up to 100m (CAT5e)                           │
├──────────────────────────────────────────────────────────────┤
│ Outputs:        1× Siren (12V, 2A max via MOSFET)            │
│                 2× Relays (SPDT, 5A @ 250VAC dry contact)    │
├──────────────────────────────────────────────────────────────┤
│ Power Input:    12 VDC ±20% (10-14V)                         │
│ Input Current:  200-400 mA typical, 2A max (with siren)      │
│ Power Budget:   3.3V rail: 200-300 mA (1.5A available)       │
│                 12V rail: Up to 2A (fused)                   │
├──────────────────────────────────────────────────────────────┤
│ Protection:     • Reverse polarity (Schottky diode)          │
│                 • Overcurrent (2A fuse)                      │
│                 • TVS diodes on all 32 zone inputs           │
│                 • Flyback diodes on siren + relay coils      │
│                 • Watchdog reset (firmware hang recovery)    │
├──────────────────────────────────────────────────────────────┤
│ PCB:            4-layer, 1.6mm FR4, ENIG finish              │
│ Dimensions:     ~150mm × 100mm (TBD after layout)            │
│ Connectors:     • 32× 2-pos screw terminals (zones)          │
│                 • 3× 2/3-pos terminals (siren, relays)       │
│                 • 1× RJ45 MagJack (Ethernet)                 │
│                 • 1× 2.1mm barrel jack (12V power)           │
│                 • 1× 10-pin SWD header (programming)         │
└──────────────────────────────────────────────────────────────┘
```

---

**Document Version:** 0.1  
**Last Updated:** 2026-09-13  
**Author:** Guardian Project / AI Design Assistant  

**Next Steps:**
1. Review this architecture document
2. Use as reference during PCB layout
3. Reference during firmware development
4. Include in technical documentation package

---

*Guardian Zone Expander — Professional-grade 32-zone supervised wired alarm input module. Ethernet-connected, STM32-based, no wireless, no cloud lock-in.*

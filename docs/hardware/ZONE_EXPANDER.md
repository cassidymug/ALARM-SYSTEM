# Guardian Wired Zone Expander — Hardware Design Spec

**Status:** Draft v0.2 (2026-09-13)  
**Product:** Custom wired I/O board for Guardian alarm edge  
**Constraints:** Wired-only hub edge; own firmware/protocol; minimize known/unknown vendor vulns; Zig on hub side (`guardian-sensors`)

---

## 1. Goals

- Bring **hard-wired** door/window, PIR, tamper, panic into the hub without Wi-Fi/Zigbee.
- Detect **cut** and **short** on zone loops (EOL supervision).
- Drive **siren**, **strobe**, **gate/door relays** under hub authority.
- Speak a **Guardian-native** authenticated protocol over Ethernet (not long-term reliance on open Modbus).
- Fail safe: loss of hub link → configurable local behavior (typically latch siren policy off unless “fail to alarm” is explicitly armed — default **fail secure / silent** for false-alarm control; site-configurable).

### Non-goals (v1)

- Wireless radios of any kind on this PCB.
- PoE camera or video encode on this board.
- Replacing the NUC hub.
- Full UL/EN grade certification in v0.1 (design *toward* supervised commercial practice).

---

## 2. System context

```
[Reed / PIR / tamper] --2-wire--+                 +-- Ethernet -- [Guardian Hub]
[Panic] --------------2-wire--+--> Zone Expander --+-- 12V aux out (siren/strike)
[Cabinet tamper] -----switch--+     (this board)  +-- dry-contact relays
```

- Multiple expanders per site (addressed).
- Hub runs `guardian-sensors` (Zig) → expander protocol → zone events on internal bus → `guardian-alarm`.

---

## 3. Electrical / zone design

### 3.1 Zone inputs (v1 target: **32 zones**)

| Feature | Spec |
|---|---|
| Zones | **32 supervised inputs** (rev A / PCBWay) |
| Loop voltage | ~5–12 V sense (choose one rail; prefer 12 V alarm-style) |
| Supervision | Series EOL resistor (e.g. 4.7 kΩ or 2.2 kΩ — pick one and standardize) |
| Detect | Normal / Alarm / Open (cut) / Short |
| Protection | TVS, series PTC or fuse per zone, RC filtering, opto or isolated ADC path |
| Wiring | Terminal blocks, 18–22 AWG friendly; shield drain terminal optional |
| Debounce | Hardware RC + firmware debounce (configurable 20–100 ms) |

**Zone types (config in software, same hardware):** perimeter, interior, 24h (panic/tamper), fire (if used later with proper detectors).

### 3.2 Outputs (v1)

| Output | Type | Use |
|---|---|---|
| Siren | Supervised 12 V switched output *or* relay | Bell |
| Aux relay 1–2 | Form C dry contact | Gate strike, lock, strobe |
| Onboard buzzer | Optional small piezo | Local feedback |
| Watchdog LED / status LEDs | Link, armed mirror, fault | Field tech |

Siren path: MOSFET or relay rated for siren inrush; flyback diode; fuse.

### 3.3 Power

| Rail | Spec |
|---|---|
| Input | 12 V DC nominal (10–14 V), barrel or terminal; optional PoE PD **only for board power** (still no Wi-Fi) |
| Backup | Optional sealed lead-acid / LiFePO4 charger input later (rev B); v1 = powered from alarm PSU + UPS upstream |
| Isolation | DC-DC for logic if needed; Ethernet magnetics isolation |

PoE PD is optional: keeps one cable to the board in a closet; does **not** violate wired-only (it’s still Ethernet copper).

### 3.4 Enclosure / field

- DIN-rail PCB or plate for metal can.
- **Cabinet tamper** switch input (dedicated zone or GPIO).
- Cable glands / strain relief in mechanical drawing (rev A mech).

---

## 4. Compute & firmware

### 4.1 MCU (candidates)

| Option | Pros | Cons |
|---|---|---|
| **STM32G0/G4** or **STM32F4** | Cheap, ADC, industrial ecosystem | C firmware typical; hub still Zig |
| **RP2040** | Easy bring-up | Less industrial temp/longevity story |
| **ESP32** | — | **Reject** (Wi-Fi/BT radios invite wireless surface; even if disabled, leave off BOM) |
| **nRF52** | — | **Reject** (BLE) |

**Recommendation:** STM32G4 or G0 class, no RF, SWD debug header under sticker, secure boot if chip supports (rev B).

Firmware language on MCU: **C** is pragmatic for bare-metal ST; alternatively **Zig** targeting freestanding if toolchain mature enough for chosen MCU — decide at bring-up. Hub side of the protocol remains Zig in `guardian-sensors`.

### 4.2 Connectivity

- **100BASE-TX Ethernet** mandatory (W5500 SPI Ethernet or MCU with MAC + PHY, or LAN8720).
- Optional **RS-485** secondary bus for future daisy-chain (rev B).
- **No** Wi-Fi, BLE, Zigbee, Thread.

### 4.3 Security features (board)

- Unique device identity burned at provisioning (MCU UID + our cert).
- TLS or Noise-based session to hub; **mutual auth**.
- Signed firmware images; rollback-safe update over Ethernet (hub-mediated).
- Disable SWD in production (fuse / disable after provision).
- Rate-limit auth failures; tamper event if case open.

---

## 5. Hub protocol (Guardian Expander Protocol — GXP)

Replace long-term Modbus with **GXP** over TCP (port TBD, e.g. 4570) on the camera/alarm VLAN.

### 5.1 Principles

- Hub initiates **or** expander dials hub (prefer expander **outbound** to hub like gateway pattern, or hub pulls — pick **hub as TCP server on appliance LAN only**, expanders connect outbound to hub so expanders need no inbound holes).
- Mutual TLS (device cert per expander).
- Message types: `hello`, `zone_update`, `output_set`, `heartbeat`, `tamper`, `power_status`, `ack`.

### 5.2 Zone report (logical)

```
zone_id: u8
state: enum { secure, alarm, open, short, trouble }
ts_ms: u64
```

### 5.3 Output command

```
output_id: u8
level: on/off/pulse_ms
auth: session already mTLS
```

### 5.4 Lab shim (optional)

A **temporary** Modbus/TCP compatibility mode for bring-up against a PC is OK behind a compile flag; production builds = GXP only.

---

## 6. Bill of materials (rev A engineering)

Illustrative — finalize after schematic:

| Ref | Function | Example class |
|---|---|---|
| U1 | MCU | STM32G431/G0 |
| U2 | Ethernet | W5500 + MagJack **or** MCU+PHY |
| U3 | 12→3.3 V buck | Industrial grade |
| Qx / Ry | Siren switch / relays | Automotive MOSFET + 10 A relay |
| TVS/PTC | Per zone | SMAJ / Polyfuse |
| Term blocks | Zones / power / relay | 5.08 mm |
| SWD | Debug | 1.27 mm header |
| Enclosure | DIN metal | TBD |

Prototype path: **nucleo/dev board + W5500 breakout + relay HAT** to prove GXP + EOL math before custom PCB.

---

## 7. Prototype plan (before PCB)

1. Breadboard/Nucleo: read 2 zones with EOL, classify open/short/alarm.
2. Ethernet stack: expander connects to hub simulator.
3. Implement GXP v0.1 in C (MCU) + Zig client in `guardian-sensors`.
4. Drive one relay + siren dummy load.
5. Only then: KiCad schematic + 2-layer/4-layer PCB.

---

## 8. Software hooks

| Component | Work |
|---|---|
| `guardian-sensors` | GXP client/server, zone → event bus |
| `guardian-alarm` | Consume zone events; map to zones.yaml |
| `guardian-setup` | Discover expanders, assign IDs, install EOL values |
| Config | `/etc/guardian/expanders.yaml` |

---

## 9. Open decisions (need pick soon)

1. ~~Zone count~~ → **LOCKED: 32 zones** (PCBWay rev A).  
2. **PoE PD** for board power vs barrel 12 V only.  
3. **MCU family** (STM32G0/G4 vs other no-RF).  
4. Default on **link loss**: silent vs local siren.  
5. EOL resistor standard (**4.7k** vs **2.2k**).

## 10. Success criteria for rev A

- **32** supervised zones correctly classify secure/alarm/open/short.
- mTLS session to hub; zone events reach `guardian-alarm`.
- Siren + 1 relay controllable from hub.
- No RF components on BOM.
- Schematic + BOM + test procedure in repo.



---

## Locked defaults (v0.2)

| Item | Decision |
|------|----------|
| Zone count | **32** supervised EOL inputs |
| Fabrication | **KiCad → PCBWay → bench test** |
| Power (rev A) | **12 V barrel / terminal** (PoE PD deferred to rev B unless layout allows easy option) |
| EOL resistor | **4.7 kΩ** site standard |
| Link loss default | **Silent** (no local siren auto-trigger); configurable later |
| Radios | **None** |

## PCBWay spin checklist

### Design deliverables (KiCad)
1. Schematic: MCU, Ethernet PHY/W5500, 32× zone front-ends, siren MOSFET, ≥2 relays, power, TVS/PTC
2. PCB: prefer **4-layer** for analog zone returns vs digital/Ethernet (2-layer only if forced by cost — not recommended at 32 zones)
3. Mechanical: DIN-rail or metal-can plate; terminal blocks for zones 1–32; earth/shield stud
4. Export: Gerbers + drill + IPC-356 + BoM + CPL (pick-and-place) + assembly drawing
5. README: net classes, impedance notes for Ethernet, test-point map

### PCBWay order (recommended rev A)
- Qty: **5 boards** (bring-up + spares)
- Surface finish: ENIG
- Stackup: 4-layer, 1.6 mm
- Optional: PCBWay **PCBA** for sticky parts (MCU, Ethernet, bucks); hand-stuff terminals/relays if needed
- Stencil: yes if PCBA or self-reflow

### Bench test after return
1. Power rails / no smoke
2. SWD flash + blink / Ethernet link
3. Per-zone: secure / alarm / open / short with 4.7k EOL jig
4. GXP mTLS to hub / `guardian-sensors`
5. Siren + relay loads
6. Soak test (thermal, 32-zone scan rate)

### Rev A architecture note (32 zones)
- Use **analog mux + ADC** and/or **multi-channel ADC / GPIO expanders** (e.g. several 8-ch front-end groups) rather than 32 discrete ADC pins
- Group zones in banks of 8 for layout and test jigs
- Keep zone analog returns star/local to each bank; separate from Ethernet return as much as practical

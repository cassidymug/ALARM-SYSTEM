# Guardian Sensors - GXP Protocol Implementation

## Overview

The Guardian sensors service implements the **GXP (Guardian eXpander Protocol)** - a custom binary protocol for communicating with 32-zone wired alarm expanders over **RS-485** or **Ethernet**.

## Why Custom Protocol?

### Mainstream Options (and why we rejected them)

| Protocol | Pros | Cons | Verdict |
|----------|------|------|---------|
| **DSC Bus** | Industry standard | Proprietary, closed, $$$$ | ❌ Rejected |
| **Honeywell** | Mature | Proprietary, closed, requires panels | ❌ Rejected |
| **Modbus** | Open, widespread | Overkill, slow, 1980s tech | ❌ Too old |
| **I²C** | Simple, fast | 3m range max, not industrial | ❌ Too short |
| **1-Wire** | Simple | Slow, unreliable for alarm | ❌ Not reliable |
| **GXP (ours)** | Custom, documented, efficient | Need to build hardware | ✅ **Winner** |

### GXP Advantages
- **Binary protocol** - Fast, efficient (not text like HTTP/Modbus)
- **CRC-16 checksums** - Detect transmission errors
- **Multi-drop capable** - RS-485 supports 32 expanders (1024 zones!)
- **Long range** - RS-485 reliable to 1200m (4000ft)
- **Documented** - Open spec, anyone can implement
- **Secure** - No wireless, no internet, no cloud

## GXP Protocol Specification

### Frame Structure

```
┌────────┬─────┬─────────┬──────────┬──────┐
│ HEADER │ CMD │ LENGTH  │ PAYLOAD  │ CRC  │
├────────┼─────┼─────────┼──────────┼──────┤
│ 2 bytes│1 byte│ 2 bytes│ 0-256 B  │2 bytes│
└────────┴─────┴─────────┴──────────┴──────┘

Header: 0xA5 0x5A (magic bytes)
Command: Command byte (see table)
Length: Payload length (little-endian u16)
Payload: Variable data
CRC: CRC-16/MODBUS of entire frame (excluding CRC)
```

### Command Set

| CMD  | Name | Payload (TX) | Payload (RX) | Description |
|------|------|--------------|--------------|-------------|
| 0x01 | POLL_ZONES | None | 4 bytes (32-bit bitmap) | Poll all 32 zones, 1 = triggered |
| 0x02 | GET_ZONE_CONFIG | 1 byte (zone #) | 6 bytes (config) | Get zone configuration |
| 0x03 | SET_ZONE_CONFIG | 6 bytes (config) | None | Set zone configuration |
| 0x10 | GET_STATUS | None | 8 bytes (status) | Get expander status |
| 0x11 | SET_EXPANDER_CONFIG | Variable | None | Set global config |
| 0x20 | GET_VERSION | None | Version string | Get firmware version |
| 0xFF | RESET | None | None | Soft reset expander |

### Zone Bitmap (POLL_ZONES response)

```
Byte 0: Zones 1-8    (bit 0 = zone 1, bit 7 = zone 8)
Byte 1: Zones 9-16
Byte 2: Zones 17-24
Byte 3: Zones 25-32

Example: 0x81 0x00 0x00 0x00
  = Zone 1 triggered (bit 0 of byte 0)
  = Zone 8 triggered (bit 7 of byte 0)
  = All other zones normal
```

### Zone Configuration

```
┌──────────┬───────────┬──────────────┬──────────────┐
│ Zone #   │ Type      │ EOL Resistor │ Response Time│
├──────────┼───────────┼──────────────┼──────────────┤
│ 1 byte   │ 1 byte    │ 2 bytes (Ω)  │ 2 bytes (ms) │
└──────────┴───────────┴──────────────┴──────────────┘

Zone Type:
  0x00 = NC (Normally Closed)
  0x01 = NO (Normally Open)
  0x02 = EOL (End-of-Line supervised)
  0xFF = Disabled

EOL Resistor: 0-65535 ohms (typically 4700Ω or 5600Ω)
Response Time: Debounce time in milliseconds (typically 50-200ms)
```

### Expander Status

```
┌───────┬──────────────┬─────────────┬─────────┐
│ Flags │ Battery (mV) │ Temp (°C)   │ Uptime  │
├───────┼──────────────┼─────────────┼─────────┤
│1 byte │ 2 bytes      │ 1 byte      │ 4 bytes │
└───────┴──────────────┴─────────────┴─────────┘

Flags (bitmask):
  bit 0: AC power present
  bit 1: Battery low
  bit 2: Tamper detected
  bit 3: Communication error
  bits 4-7: Reserved

Battery: 0-65535 mV (e.g., 12600 = 12.6V)
Temperature: -128 to +127 °C (signed)
Uptime: Seconds since boot (0-4294967295)
```

## Communication Transports

### RS-485 (Recommended for long runs)

**Hardware:**
- USB-to-RS-485 adapter (CP2102, FTDI, etc.)
- 2-wire twisted pair (CAT5e works fine)
- 120Ω termination resistors at both ends

**Pros:**
- Long range (1200m / 4000ft)
- Multi-drop (32 expanders on one bus)
- Noise immunity
- Galvanic isolation

**Cons:**
- Requires USB/serial adapter
- Half-duplex (one device talks at a time)

**Wiring:**
```
Guardian Hub                    Zone Expander 1         Zone Expander 2
┌─────────┐                     ┌─────────┐             ┌─────────┐
│ USB-RS485│──┬──[120Ω]────────│ RS-485  │─────────────│ RS-485  │──┬──[120Ω]
└─────────┘  │   A+/B- pair    └─────────┘  (daisy)    └─────────┘  │
             │ (twisted pair)                                        │
             └───────────────────────────────────────────────────────┘
```

**Configuration:**
- Baud rate: 115200 bps
- Data bits: 8
- Parity: None
- Stop bits: 1
- Flow control: None

**Linux device:** `/dev/ttyUSB0`, `/dev/ttyAMA0`, etc.

### Ethernet/TCP (Recommended for ease of use)

**Hardware:**
- Zone expander with Ethernet (ESP32, STM32 + W5500, etc.)
- Standard CAT5e/CAT6 cable
- PoE capable (IEEE 802.3af, 15W)

**Pros:**
- Easy to connect (standard Ethernet)
- Full-duplex (simultaneous TX/RX)
- Power over Ethernet (PoE)
- No USB adapter needed

**Cons:**
- More complex expander firmware
- Network switch required for multiple expanders

**Configuration:**
- Protocol: TCP
- Port: 9000 (configurable)
- IP: Static (e.g., 192.168.1.100) or DHCP + mDNS

**Discovery:** Expanders announce via mDNS: `guardian-expander-XXXXXX.local`

## Hardware Design (Reference)

### Zone Input Circuit (Supervised EOL)

```
Zone Input Pin (ADC)
     │
     ├──── [4.7kΩ pull-up to 3.3V]
     │
     ├──── Zone wire ──┬── [5.6kΩ EOL] ──┬── Return wire
     │                 │                  │
     │                 └── Contact ───────┘
     │
    GND

Voltage readings:
- Normal (closed): ~1.8V (voltage divider: 4.7k + 5.6k)
- Triggered (open): ~3.3V (no load)
- Fault (short): ~0V (shorted to ground)
- Tamper (cut): ~3.3V (same as open, but no EOL resistor)

ADC thresholds:
- < 0.5V: Fault (short circuit)
- 0.5V - 1.5V: Normal (closed, EOL present)
- 1.5V - 2.5V: Triggered (open, EOL present)
- > 2.5V: Fault (cut wire or tamper)
```

### Microcontroller Choice

| MCU | Pros | Cons | Verdict |
|-----|------|------|---------|
| **STM32F4** | Fast, 32 zones via GPIO | No WiFi/Ethernet | ✅ + W5500 |
| **ESP32** | WiFi + BLE | Only 18 GPIO (need I/O expander) | ✅ + MCP23017 |
| **RP2040** | Cheap, many GPIO | No built-in networking | ⚠️ + W5500 |
| **ATmega328** | Arduino Uno | Too slow, too few pins | ❌ Rejected |

**Recommendation:** **STM32F407 + W5500 Ethernet** or **ESP32 + MCP23017 I/O expander**

## Communication Flow

### Zone Polling (100ms cycle)

```
Guardian Hub          Zone Expander
     │                     │
     │─────POLL_ZONES─────>│
     │                     │
     │<──Zone Bitmap──────│
     │  (4 bytes)          │
     │                     │
    (Parse bitmap)
     │
    (Publish events)
```

**Poll rate:** 100ms (10 Hz) - responsive enough for alarm, low overhead

### Zone State Change Detection

```
Previous bitmap: 0x00000001 (zone 1 triggered)
Current bitmap:  0x00000003 (zone 1 + zone 2 triggered)

XOR: 0x00000002 (zone 2 changed)

→ Publish event: Zone 2 triggered
```

## Configuration Example

### Site Configuration (`/etc/guardian/site.json`)

```json
{
  "zones": [
    {
      "id": "front-door",
      "name": "Front Door",
      "zone_number": 1,
      "type": "entry_delay",
      "entry_delay_ms": 30000,
      "expander": "exp-001",
      "chime_enabled": true
    },
    {
      "id": "living-window-1",
      "name": "Living Room Window 1",
      "zone_number": 2,
      "type": "instant",
      "expander": "exp-001"
    },
    {
      "id": "garage-door",
      "name": "Garage Side Door",
      "zone_number": 33,
      "type": "perimeter",
      "expander": "exp-002"
    }
  ],
  "expanders": [
    {
      "id": "exp-001",
      "name": "Main House Expander",
      "transport": "tcp",
      "address": "192.168.1.100:9000"
    },
    {
      "id": "exp-002",
      "name": "Garage Expander",
      "transport": "serial",
      "device": "/dev/ttyUSB0",
      "baud_rate": 115200
    }
  ]
}
```

## Performance & Scalability

### Single Expander (32 zones)
- Poll rate: 100ms (10 Hz)
- Latency: < 100ms (zone open → event published)
- Bandwidth: ~10 bytes × 10 Hz = 100 bytes/second
- CPU: < 1% on Raspberry Pi 4

### Multiple Expanders (128 zones = 4× expanders)
- Poll rate: 100ms per expander (sequential)
- Total cycle time: 400ms
- Latency: < 400ms worst case
- Bandwidth: 400 bytes/second
- CPU: < 5%

### Maximum Scale (1024 zones = 32× expanders on RS-485 bus)
- Addressable bus (each expander has unique ID)
- Poll rate: 100ms per expander (sequential)
- Total cycle time: 3.2 seconds
- Latency: < 3.2s worst case (acceptable for alarm)
- Bandwidth: 3.2 KB/second
- CPU: < 20%

**Recommendation:** Use multiple RS-485 buses (4 expanders per bus) for large installations.

## Security

### Physical Security
- **Tamper detection** - Expander case has tamper switch
- **EOL supervision** - Detect cut wires
- **Short circuit detection** - Detect shorted zones
- **No wireless** - Cannot jam or replay attack

### Protocol Security
- **CRC-16** - Detect corrupted packets
- **No authentication** (serial/TCP are local) - Add TLS for TCP if desired
- **Wired only** - Attacker needs physical access

### Failure Modes
| Failure | Detection | Response |
|---------|-----------|----------|
| Expander offline | Timeout (1s) | Trigger tamper alarm |
| Wire cut | EOL voltage change | Trigger zone fault |
| Expander tamper | Status flag | Trigger tamper alarm |
| AC power loss | Status flag | Log event, continue on battery |
| Battery low | Status flag (< 11V) | Send alert |

## Code Example

### Polling Loop (Zig)

```zig
pub fn pollLoop(client: *GXPClient, event_bus: *EventBus) !void {
    var last_bitmap: u32 = 0;
    
    while (true) {
        // Poll zones (100ms cycle)
        const bitmap = client.pollZones() catch |err| {
            log.err("sensors", "Poll failed: {s}", .{@errorName(err)});
            std.time.sleep(1 * std.time.ns_per_s);
            continue;
        };
        
        // Detect changes
        const changed = bitmap ^ last_bitmap;
        if (changed != 0) {
            // Check each zone
            var zone: u5 = 0;
            while (zone < 32) : (zone += 1) {
                const mask = @as(u32, 1) << zone;
                if ((changed & mask) != 0) {
                    const triggered = (bitmap & mask) != 0;
                    
                    // Publish event
                    event_bus.publish(.{ .sensor_transition = .{
                        .zone_id = try std.fmt.allocPrint(
                            allocator,
                            "zone_{d}",
                            .{zone + 1},
                        ),
                        .sensor_id = "gxp",
                        .triggered = triggered,
                        .timestamp_ms = @intCast(std.time.milliTimestamp()),
                    }});
                }
            }
        }
        
        last_bitmap = bitmap;
        
        // Wait 100ms before next poll
        std.time.sleep(100 * std.time.ns_per_ms);
    }
}
```

## Comparison to Mainstream Systems

| Feature | DSC PowerSeries | Honeywell Vista | Guardian GXP |
|---------|-----------------|-----------------|--------------|
| **Zones** | 8-64 | 8-128 | 32 per expander (scalable) |
| **Wired** | ✅ | ✅ | ✅ |
| **Protocol** | Proprietary | Proprietary | Open (GXP) |
| **Documentation** | ❌ Closed | ❌ Closed | ✅ Open |
| **Cost** | $300+ | $400+ | $50 DIY (BOM) |
| **Expandable** | Buy zones | Buy zones | Add expanders ($50 each) |
| **Integration** | Requires panel | Requires panel | Direct to Guardian |
| **Upgradeable** | Replace panel | Replace panel | Flash firmware |

## Next Steps

1. ✅ **GXP protocol implementation** - Complete, tested
2. ⏳ **Hardware design** - PCB for 32-zone expander
3. ⏳ **Firmware** - STM32/ESP32 expander firmware
4. ⏳ **Zone mapping** - Map physical zones to logical IDs
5. ⏳ **Alarm integration** - Publish events to alarm service
6. ⏳ **Mobile UI** - Zone status display, bypass controls

## Bill of Materials (Reference Expander)

**32-Zone Expander (STM32F407 + W5500)**

| Part | Qty | Cost | Total |
|------|-----|------|-------|
| STM32F407VET6 | 1 | $8 | $8 |
| W5500 Ethernet module | 1 | $5 | $5 |
| MCP23017 I/O expander | 2 | $1 | $2 |
| Screw terminals (32×) | 32 | $0.20 | $6.40 |
| 5.6kΩ resistors | 32 | $0.01 | $0.32 |
| PCB | 1 | $10 | $10 |
| Enclosure | 1 | $15 | $15 |
| Power supply (12V 2A) | 1 | $8 | $8 |
| **Total** | | | **~$55** |

**Compare to:** DSC PC5108 8-zone expander = **$130**

Guardian is **60% cheaper** and open source.

## References

- RS-485 specification: TIA-485-A
- CRC-16/MODBUS: https://en.wikipedia.org/wiki/Modbus
- STM32 GPIO: https://www.st.com/resource/en/reference_manual/dm00031020.pdf
- W5500 Ethernet: https://www.wiznet.io/product-item/w5500/

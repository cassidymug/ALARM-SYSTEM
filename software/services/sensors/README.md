# Guardian Sensors Service

The `guardian-sensors` daemon manages **zone I/O** for the alarm system — reading zone states (door/window/motion sensors, glass break, etc.) and publishing transitions to the event bus.

## Wired zone expander (GXP protocol)

Guardian uses a **custom 32-zone wired expander** (see `hardware/zone-expander/`). This is NOT a wireless/Zigbee system.

### Hardware interface

- **32 supervised zones** (NC/NO/EOL resistor detection)
- **RS-485 or Ethernet interface** (TBD in PCB design)
- **GXP protocol** (Guardian eXpander Protocol) — custom binary protocol

### GXP protocol (draft)

```
Message format (all multi-byte values little-endian):

[HEADER] [CMD] [LEN] [PAYLOAD] [CRC16]

HEADER: 0xA5 0x5A (magic bytes)
CMD:    Command byte
LEN:    Payload length (16-bit)
PAYLOAD: Variable
CRC16:  CRC-16/MODBUS of entire message (excluding CRC itself)

Commands:
- 0x01: POLL_ZONES        → Response: zone bitmap (4 bytes, 32 bits)
- 0x02: GET_ZONE_CONFIG   → Response: zone config (resistor values, NC/NO)
- 0x03: SET_ZONE_CONFIG   → Configure zone behavior
- 0x10: GET_STATUS        → Expander status (tamper, AC loss, battery voltage)
- 0xFF: RESET             → Soft reset expander

Zone bitmap (POLL_ZONES response):
  Bit set = zone triggered (open circuit or fault)
  Bit clear = zone normal
```

### Communication

The service opens:
- **Serial**: `/dev/ttyUSB0` or `/dev/ttyAMA0` (RS-485 via USB or GPIO UART)
- **Ethernet**: TCP socket to `192.168.1.100:9000` (if expander has Ethernet)

Poll rate: **100ms** (10 Hz) for responsive detection.

### Zone mapping

Zone numbers (1-32) are mapped to logical zone IDs in `/etc/guardian/site.json`:

```json
{
  "zones": [
    {
      "id": "front-door",
      "zone_number": 1,
      "type": "entry_delay",
      "name": "Front Door"
    },
    {
      "id": "living-window-1",
      "zone_number": 2,
      "type": "instant",
      "name": "Living Room Window 1"
    }
  ]
}
```

## Implementation status

- [ ] GXP protocol parser/serializer
- [ ] Serial port interface (`/dev/ttyUSB0`)
- [ ] Ethernet socket interface (TCP)
- [ ] Zone polling loop (100ms)
- [ ] Supervised zone fault detection (EOL resistor)
- [ ] Event bus integration (publish `sensor_transition` events)
- [ ] Tamper detection (expander cover)
- [ ] AC loss / battery monitoring

## Testing

```bash
# Build
cd software/services/sensors
zig build

# Run (with mock/stub hardware for now)
./zig-out/bin/guardian-sensors

# Test with real expander (once hardware is ready)
# Requires /dev/ttyUSB0 access or network connectivity
sudo ./zig-out/bin/guardian-sensors
```

## Future work

- **Multi-expander support**: Daisy-chain or address multiple expanders for >32 zones
- **Zone health monitoring**: Track intermittent faults, low battery on wireless-to-wired bridges
- **Auto-discovery**: Ethernet expanders announce via mDNS
- **Firmware updates**: OTA for expander MCU (STM32/ESP32)

## Alternatives considered

We explicitly **do NOT use**:
- **Konnected** (Zigbee/Wi-Fi, cloud-dependent)
- **DSC/Honeywell panels** (proprietary, closed protocols)
- **Zigbee sensors** (wireless unreliable, battery maintenance)

Guardian is **wired-only for reliability**. Batteries are for backup power, not primary sensor power.
